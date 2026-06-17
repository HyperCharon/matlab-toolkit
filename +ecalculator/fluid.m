classdef fluid
%ECALCULATOR.FLUID 流体力学工程计算器
%
%   ecalculator.fluid.reynolds(rho, v, D, mu)         雷诺数
%   ecalculator.fluid.pipe_flow(rho, mu, D, L, v)     管道流动
%   ecalculator.fluid.nozzle(P1, T1, P2, gamma)       喷管流动
%   ecalculator.fluid.pitot(rho, dP)                  皮托管测速
%   ecalculator.fluid.bernoulli(P1, v1, z1, P2, v2, z2, rho)  伯努利方程
%
%   See also ecalculator.thermal, ecalculator.circuit

    methods(Static)
        function info = reynolds(rho, v, D, mu)
        %REYNOLDS 雷诺数计算
        %
        %   ecalculator.fluid.reynolds(1000, 1, 0.01, 1e-3)

            if mu == 0
                error('ecalculator:fluid:zeroViscosity', '动力粘度不能为零');
            end

            Re = rho * v * D / mu;

            fprintf('🌊 雷诺数计算:\n');
            fprintf('   密度:     %.2f kg/m³\n', rho);
            fprintf('   速度:     %.4f m/s\n', v);
            fprintf('   直径:     %.4f m\n', D);
            fprintf('   粘度:     %.2e Pa·s\n', mu);
            fprintf('   雷诺数:   %.0f\n', Re);

            if Re < 2300
                fprintf('   流态:     层流\n');
                info.regime = 'laminar';
            elseif Re < 4000
                fprintf('   流态:     过渡区\n');
                info.regime = 'transition';
            else
                fprintf('   流态:     湍流\n');
                info.regime = 'turbulent';
            end

            info.Re = Re;
        end

        function info = pipe_flow(rho, mu, D, L, v, epsilon)
        %PIPE_FLOW 管道流动计算
        %
        %   ecalculator.fluid.pipe_flow(1000, 1e-3, 0.01, 10, 1, 0.001)

            if nargin < 6, epsilon = 0; end

            Re = rho * v * D / mu;
            A = pi * D^2 / 4;
            Q = v * A;

            % 摩擦系数 (Colebrook 方程简化)
            if Re < 2300
                f = 64 / Re;
            else
                % Swamee-Jain 近似
                f = 0.25 / (log10(epsilon/(3.7*D) + 5.74/Re^0.9))^2;
            end

            % 压降
            dP = f * (L/D) * (rho * v^2 / 2);

            % 沿程损失
            hf = dP / (rho * eutils.constants.g);

            fprintf('🔧 管道流动计算:\n');
            fprintf('   直径:       %.4f m\n', D);
            fprintf('   长度:       %.2f m\n', L);
            fprintf('   流速:       %.4f m/s\n', v);
            fprintf('   雷诺数:     %.0f\n', Re);
            fprintf('   摩擦系数:   %.4f\n', f);
            fprintf('   流量:       %.6f m³/s (%.2f L/min)\n', Q, Q*1000*60);
            fprintf('   压降:       %.2f Pa (%.4f kPa)\n', dP, dP/1000);
            fprintf('   沿程损失:   %.4f m\n', hf);

            info.Re = Re;
            info.f = f;
            info.Q = Q;
            info.dP = dP;
            info.hf = hf;
        end

        function info = nozzle(P1, T1, P2, gamma, R)
        %NOZZLE 喷管流动计算
        %
        %   ecalculator.fluid.nozzle(101325, 300, 50000, 1.4, 287)

            if nargin < 5, R = 287; end

            % 临界压力比
            Pr = (2/(gamma+1))^(gamma/(gamma-1));
            P_star = P1 * Pr;

            % 出口参数
            if P2 > P_star
                % 亚临界
                T2 = T1 * (P2/P1)^((gamma-1)/gamma);
                v2 = sqrt(2*gamma*R*T1/(gamma-1) * (1 - (P2/P1)^((gamma-1)/gamma)));
                regime = '亚临界';
            else
                % 临界/超临界
                T2 = T1 * Pr^((gamma-1)/gamma);
                v2 = sqrt(gamma * R * T2);
                regime = '临界';
            end

            rho2 = P2 / (R * T2);

            fprintf('💨 喷管流动计算:\n');
            fprintf('   入口压力:   %.0f Pa\n', P1);
            fprintf('   入口温度:   %.1f K\n', T1);
            fprintf('   出口压力:   %.0f Pa\n', P2);
            fprintf('   临界压力比: %.4f\n', Pr);
            fprintf('   临界压力:   %.0f Pa\n', P_star);
            fprintf('   流动状态:   %s\n', regime);
            fprintf('   出口温度:   %.1f K\n', T2);
            fprintf('   出口速度:   %.2f m/s\n', v2);
            fprintf('   出口密度:   %.4f kg/m³\n', rho2);

            info.Pr = Pr;
            info.T2 = T2;
            info.v2 = v2;
            info.rho2 = rho2;
        end

        function info = pitot(rho, dP)
        %PITOT 皮托管测速
        %
        %   ecalculator.fluid.pitot(1.225, 100)

            v = sqrt(2 * dP / rho);

            fprintf('📐 皮托管测速:\n');
            fprintf('   密度:     %.4f kg/m³\n', rho);
            fprintf('   压差:     %.2f Pa\n', dP);
            fprintf('   流速:     %.4f m/s\n', v);

            info.v = v;
            info.rho = rho;
            info.dP = dP;
        end

        function info = bernoulli(P1, v1, z1, P2, v2, z2, rho)
        %BERNOULLI 伯努利方程计算
        %
        %   ecalculator.fluid.bernoulli(101325, 1, 0, 0, 0, 1, 1000)

            if nargin < 7, rho = 1000; end
            g = eutils.constants.g;

            % 总压头
            H1 = P1/(rho*g) + v1^2/(2*g) + z1;
            H2 = P2/(rho*g) + v2^2/(2*g) + z2;
            H_loss = H1 - H2;

            fprintf('📊 伯努利方程:\n');
            fprintf('   位置 1: P=%.0f Pa, v=%.2f m/s, z=%.2f m\n', P1, v1, z1);
            fprintf('   位置 2: P=%.0f Pa, v=%.2f m/s, z=%.2f m\n', P2, v2, z2);
            fprintf('   总压头 1: %.4f m\n', H1);
            fprintf('   总压头 2: %.4f m\n', H2);
            fprintf('   损失:     %.4f m\n', H_loss);

            info.H1 = H1;
            info.H2 = H2;
            info.H_loss = H_loss;
        end
    end
end
