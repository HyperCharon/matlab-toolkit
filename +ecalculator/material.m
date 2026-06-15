classdef material
%ECALCULATOR.MATERIAL 材料力学工程计算器
%
%   ecalculator.material.stress(F, A)                 应力计算
%   ecalculator.material.strain(dL, L)                应变计算
%   ecalculator.material.beam_deflection(P, L, E, I)  梁挠度
%   ecalculator.material.pressure_vessel(P, r, t)     压力容器
%   ecalculator.material.fatigue(Sa, Se, Sut)         疲劳分析
%
%   See also ecalculator.thermal, ecalculator.fluid

    methods(Static)
        function info = stress(F, A)
        %STRESS 应力计算
        %
        %   ecalculator.material.stress(1000, 0.001)

            sigma = F / A;

            fprintf('💪 应力计算:\n');
            fprintf('   力:     %.2f N\n', F);
            fprintf('   面积:   %.6f m²\n', A);
            fprintf('   应力:   %.2f Pa (%.4f MPa)\n', sigma, sigma/1e6);

            info.sigma = sigma;
        end

        function info = strain(dL, L)
        %STRAIN 应变计算
        %
        %   ecalculator.material.strain(0.001, 1)

            epsilon = dL / L;

            fprintf('📏 应变计算:\n');
            fprintf('   变形量: %.6f m\n', dL);
            fprintf('   原长:   %.4f m\n', L);
            fprintf('   应变:   %.6f (%.4f%%)\n', epsilon, epsilon*100);

            info.epsilon = epsilon;
        end

        function info = hookes_law(sigma, E)
        %HOOKES_LAW 胡克定律
        %
        %   ecalculator.material.hookes_law(100e6, 200e9)

            epsilon = sigma / E;
            delta_L = epsilon;  % 相对变形

            fprintf('📐 胡克定律:\n');
            fprintf('   应力:   %.2f MPa\n', sigma/1e6);
            fprintf('   弹性模量: %.1f GPa\n', E/1e9);
            fprintf('   应变:   %.6f\n', epsilon);
            fprintf('   相对变形: %.4f%%\n', epsilon*100);

            info.epsilon = epsilon;
        end

        function info = beam_deflection(P, L, E, I, type)
        %BEAM_DEFLECTION 梁挠度计算
        %
        %   ecalculator.material.beam_deflection(1000, 1, 200e9, 1e-6, 'cantilever')
        %
        %   类型:
        %     'cantilever'   - 悬臂梁 (端部集中力)
        %     'simply'       - 简支梁 (中部集中力)
        %     'distributed'  - 简支梁 (均布载荷)

            if nargin < 5, type = 'cantilever'; end

            switch lower(type)
                case 'cantilever'
                    % 悬臂梁端部集中力
                    delta_max = P * L^3 / (3 * E * I);
                    theta_max = P * L^2 / (2 * E * I);
                    desc = '悬臂梁 (端部集中力)';

                case 'simply'
                    % 简支梁中部集中力
                    delta_max = P * L^3 / (48 * E * I);
                    theta_max = P * L^2 / (16 * E * I);
                    desc = '简支梁 (中部集中力)';

                case 'distributed'
                    % 简支梁均布载荷 (P 为总载荷)
                    q = P / L;
                    delta_max = 5 * q * L^4 / (384 * E * I);
                    theta_max = q * L^3 / (24 * E * I);
                    desc = '简支梁 (均布载荷)';

                otherwise
                    error('ecalculator:material:unknownType', '未知梁类型: %s', type);
            end

            fprintf('🏗️  梁挠度计算 (%s):\n', desc);
            fprintf('   载荷:       %.2f N\n', P);
            fprintf('   长度:       %.4f m\n', L);
            fprintf('   弹性模量:   %.1f GPa\n', E/1e9);
            fprintf('   惯性矩:    %.2e m⁴\n', I);
            fprintf('   最大挠度:   %.6f m (%.4f mm)\n', delta_max, delta_max*1000);
            fprintf('   最大转角:   %.6f rad (%.4f°)\n', theta_max, theta_max*180/pi);

            % 挠度校核
            L_ratio = delta_max / L;
            fprintf('   挠度/跨度:  %.4f%%\n', L_ratio*100);
            if L_ratio > 0.001
                fprintf('   ⚠️  挠度较大，建议增加截面惯性矩\n');
            else
                fprintf('   ✅ 挠度在可接受范围内\n');
            end

            info.delta_max = delta_max;
            info.theta_max = theta_max;
            info.L_ratio = L_ratio;
        end

        function info = pressure_vessel(P, r, t, type)
        %PRESSURE_VESSEL 压力容器应力计算
        %
        %   ecalculator.material.pressure_vessel(1e6, 0.1, 0.005, 'thin')
        %
        %   类型:
        %     'thin' - 薄壁容器
        %     'thick' - 厚壁容器

            if nargin < 4, type = 'thin'; end

            switch lower(type)
                case 'thin'
                    % 薄壁容器
                    sigma_hoop = P * r / t;        % 环向应力
                    sigma_axial = P * r / (2*t);   % 轴向应力
                    sigma_von = sigma_hoop;         % Von Mises (简化)

                    fprintf('🛢️  薄壁压力容器:\n');

                case 'thick'
                    % 厚壁容器 (Lame 方程)
                    ri = r;
                    ro = r + t;

                    % 内壁应力最大
                    sigma_hoop = P * (ro^2 + ri^2) / (ro^2 - ri^2);
                    sigma_radial = -P;
                    sigma_axial = P * ri^2 / (ro^2 - ri^2);

                    fprintf('🛢️  厚壁压力容器:\n');
                    fprintf('   内径:   %.4f m\n", 2*ri);
                    fprintf('   外径:   %.4f m\n', 2*ro);

                otherwise
                    error('ecalculator:material:unknownType', '未知类型: %s', type);
            end

            fprintf('   压力:     %.2f MPa\n', P/1e6);
            fprintf('   半径:     %.4f m\n', r);
            fprintf('   壁厚:     %.4f m\n', t);
            fprintf('   环向应力: %.2f MPa\n', sigma_hoop/1e6);
            fprintf('   轴向应力: %.2f MPa\n', sigma_axial/1e6);

            info.sigma_hoop = sigma_hoop;
            info.sigma_axial = sigma_axial;
        end

        function info = fatigue(Sa, Se, Sut, N)
        %FATIGUE 疲劳分析 (S-N 曲线)
        %
        %   ecalculator.material.fatigue(200, 150, 500, 1e6)

            if nargin < 4, N = 1e6; end

            % Goodman 准则
            if Se > 0 && Sut > 0
                Sa_allowable = Se * (1 - 0/Sut);  % 平均应力为 0
                safety_factor = Se / Sa;
            else
                Sa_allowable = 0;
                safety_factor = 0;
            end

            % S-N 曲线参数 (简化)
            % S = a * N^b
            b = -log(Sut/Se) / log(1e6/1e3);
            a = Sut / (1e3^b);

            % 寿命估算
            if Sa > Se
                N_f = (Sa/a)^(1/b);
            else
                N_f = Inf;
            end

            fprintf('🔄 疲劳分析:\n');
            fprintf('   应力幅:       %.2f MPa\n', Sa);
            fprintf('   疲劳极限:     %.2f MPa\n', Se);
            fprintf('   拉伸强度:     %.2f MPa\n', Sut);
            fprintf('   安全系数:     %.2f\n', safety_factor);
            fprintf('   预估寿命:     %.2e 次\n", N_f);

            if safety_factor > 1
                fprintf('   ✅ 无限寿命设计\n');
            else
                fprintf('   ⚠️  有限寿命，需要降低应力幅\n');
            end

            info.safety_factor = safety_factor;
            info.N_f = N_f;
            info.a = a;
            info.b = b;
        end

        function info = torsion(T, r, J, L, G)
        %TORSION 扭转变形计算
        %
        %   ecalculator.material.torsion(100, 0.01, 1.57e-8, 0.5, 80e9)

            tau_max = T * r / J;
            theta = T * L / (G * J);

            fprintf('🔩 扭转变形:\n');
            fprintf('   扭矩:     %.2f N·m\n', T);
            fprintf('   半径:     %.4f m\n', r);
            fprintf('   极惯性矩: %.2e m⁴\n", J);
            fprintf('   长度:     %.4f m\n', L);
            fprintf('   剪切模量: %.1f GPa\n", G/1e9);
            fprintf('   最大剪应力: %.2f MPa\n", tau_max/1e6);
            fprintf('   扭转角:   %.4f rad (%.2f°)\n', theta, theta*180/pi);

            info.tau_max = tau_max;
            info.theta = theta;
        end
    end
end
