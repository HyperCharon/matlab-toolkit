classdef thermal
%ECALCULATOR.THERMAL 热力学工程计算器
%
%   ecalculator.thermal.conduction(k, A, dT, L)      热传导
%   ecalculator.thermal.convection(h, A, dT)          对流换热
%   ecalculator.thermal.radiation(epsilon, A, T1, T2) 辐射换热
%   ecalculator.thermal.fintube(n, k_fin, L, w, t, h, Tb, Ta)  翅片管散热
%   ecalculator.thermal.heatpipe(Q, L, d)             热管传热
%
%   See also ecalculator.circuit, ecalculator.motor

    methods(Static)
        function info = conduction(k, A, dT, L)
        %CONDUCTION 热传导计算 (傅里叶定律)
        %
        %   ecalculator.thermal.conduction(385, 0.01, 50, 0.1)
        %
        %   参数:
        %     k  - 导热系数 (W/(m·K))
        %     A  - 截面积 (m²)
        %     dT - 温差 (K)
        %     L  - 厚度 (m)

            Q = k * A * dT / L;
            R = L / (k * A);

            fprintf('🔥 热传导计算:\n');
            fprintf('   导热系数: %.2f W/(m·K)\n', k);
            fprintf('   截面积:   %.4f m²\n', A);
            fprintf('   温差:     %.1f K\n', dT);
            fprintf('   厚度:     %.4f m\n', L);
            fprintf('   热流量:   %.4f W\n', Q);
            fprintf('   热阻:     %.6f K/W\n', R);

            info.Q = Q;
            info.R = R;
        end

        function info = convection(h, A, dT)
        %CONVECTION 对流换热计算 (牛顿冷却定律)
        %
        %   ecalculator.thermal.convection(50, 0.01, 50)

            Q = h * A * dT;
            R = 1 / (h * A);

            fprintf('🌬️  对流换热计算:\n');
            fprintf('   换热系数: %.2f W/(m²·K)\n', h);
            fprintf('   面积:     %.4f m²\n', A);
            fprintf('   温差:     %.1f K\n', dT);
            fprintf('   热流量:   %.4f W\n', Q);
            fprintf('   热阻:     %.6f K/W\n', R);

            info.Q = Q;
            info.R = R;
        end

        function info = radiation(epsilon, A, T1, T2)
        %RADIATION 辐射换热计算 (斯蒂芬-玻尔兹曼定律)
        %
        %   ecalculator.thermal.radiation(0.9, 0.01, 373, 293)
        %
        %   参数:
        %     epsilon - 发射率 (0~1)
        %     A       - 面积 (m²)
        %     T1, T2  - 温度 (K)

            sigma = eutils.constants.sigma;
            Q = epsilon * sigma * A * (T1^4 - T2^4);

            fprintf('☀️  辐射换热计算:\n');
            fprintf('   发射率:   %.2f\n', epsilon);
            fprintf('   面积:     %.4f m²\n', A);
            fprintf('   温度 T1:  %.1f K (%.1f°C)\n', T1, T1-273.15);
            fprintf('   温度 T2:  %.1f K (%.1f°C)\n', T2, T2-273.15);
            fprintf('   热流量:   %.4f W\n', Q);

            info.Q = Q;
        end

        function info = fintube(n, k_fin, L, w, t, h, Tb, Ta)
        %FINTUBE 翅片管散热计算
        %
        %   ecalculator.thermal.fintube(20, 200, 0.02, 0.01, 0.001, 50, 80, 25)

            % 翅片参数
            m = sqrt(2*h / (k_fin * t));
            Af = 2 * n * w * L;  % 总翅片面积
            Ab = w * (1 - n*t);  % 基座面积

            % 翅片效率 (直翅片)
            eta_f = tanh(m*L) / (m*L);

            % 总效率
            Atotal = Af + Ab;
            eta_o = 1 - (Af/Atotal) * (1 - eta_f);

            % 散热量
            Q = eta_o * h * Atotal * (Tb - Ta);

            fprintf('🌡️  翅片管散热:\n');
            fprintf('   翅片数:     %d\n', n);
            fprintf('   导热系数:   %.1f W/(m·K)\n', k_fin);
            fprintf('   翅片长度:   %.4f m\n', L);
            fprintf('   翅片厚度:   %.4f m\n', t);
            fprintf('   换热系数:   %.1f W/(m²·K)\n', h);
            fprintf('   基座温度:   %.1f°C\n', Tb);
            fprintf('   环境温度:   %.1f°C\n', Ta);
            fprintf('   翅片效率:   %.2f%%\n', eta_f*100);
            fprintf('   总效率:     %.2f%%\n', eta_o*100);
            fprintf('   散热量:     %.4f W\n', Q);

            info.Q = Q;
            info.eta_f = eta_f;
            info.eta_o = eta_o;
            info.m = m;
        end

        function info = heatpipe(Q, L_eff, d, fluid)
        %HEATPIPE 热管传热能力估算
        %
        %   ecalculator.thermal.heatpipe(50, 0.1, 0.006, 'water')

            if nargin < 4, fluid = 'water'; end

            % 热管参数 (简化模型)
            switch lower(fluid)
                case 'water'
                    sigma = 0.0589;  % 表面张力 (N/m) @ 80°C
                    rho_l = 971.8;   % 液体密度
                    rho_v = 0.293;   % 蒸汽密度
                    hfg = 2308e3;    % 汽化潜热
                    mu_l = 0.355e-3; % 液体粘度
                    r_eff = 1e-6;    % 有效毛细半径
                case 'ethanol'
                    sigma = 0.0223;
                    rho_l = 789;
                    rho_v = 1.59;
                    hfg = 841e3;
                    mu_l = 1.2e-3;
                    r_eff = 5e-6;
                otherwise
                    error('ecalculator:thermal:unknownFluid', '未知流体: %s', fluid);
            end

            % 毛细极限
            dP_cap = 2 * sigma / r_eff;
            Q_cap = dP_cap * pi * d^2 * rho_l * hfg / (128 * mu_l * L_eff);

            % 蒸汽极限
            Q_vap = 0.4 * rho_v * hfg * pi * d^2 / 4 * sqrt(sigma * (rho_l - rho_v) / (rho_v^2));

            Q_max = min(Q_cap, Q_vap);

            fprintf('🔧 热管传热分析:\n');
            fprintf('   流体:       %s\n', fluid);
            fprintf('   有效长度:   %.3f m\n', L_eff);
            fprintf('   直径:       %.4f m\n', d);
            fprintf('   毛细极限:   %.2f W\n', Q_cap);
            fprintf('   蒸汽极限:   %.2f W\n', Q_vap);
            fprintf('   最大传热:   %.2f W\n', Q_max);

            if Q > Q_max
                fprintf('   ❌ 需求 (%.1f W) 超过最大传热能力!\n', Q);
            else
                fprintf('   ✅ 安全裕度: %.1f%%\n', (Q_max - Q)/Q * 100);
            end

            info.Q_max = Q_max;
            info.Q_cap = Q_cap;
            info.Q_vap = Q_vap;
        end

        function info = heatsink(Tj, Ta, P, Rth_jc, Rth_cs)
        %HEATSINK 散热器选型计算
        %
        %   ecalculator.thermal.heatsink(150, 40, 10, 1.5, 0.5)

            if nargin < 5, Rth_cs = 0.5; end

            Rth_ja_max = (Tj - Ta) / P;
            Rth_sa_max = Rth_ja_max - Rth_jc - Rth_cs;

            fprintf('🔲 散热器选型:\n');
            fprintf('   结温上限:     %.1f°C\n', Tj);
            fprintf('   环境温度:     %.1f°C\n', Ta);
            fprintf('   功耗:         %.2f W\n', P);
            fprintf('   Rth_jc:       %.2f K/W\n', Rth_jc);
            fprintf('   Rth_cs:       %.2f K/W\n', Rth_cs);
            fprintf('   Rth_ja_max:   %.2f K/W\n', Rth_ja_max);
            fprintf('   散热器热阻:   ≤ %.2f K/W\n', Rth_sa_max);

            if Rth_sa_max < 0
                fprintf('   ❌ 无法满足散热要求! 需要降低功耗或改善封装\n');
            else
                fprintf('   ✅ 选择 Rth_sa ≤ %.2f K/W 的散热器\n', Rth_sa_max);
            end

            info.Rth_ja_max = Rth_ja_max;
            info.Rth_sa_max = Rth_sa_max;
        end
    end
end
