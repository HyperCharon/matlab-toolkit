classdef power
%ECALCULATOR.POWER 电力电子工程计算器
%
%   ecalculator.power.buck_converter(Vin, Vout, fsw, L, C)  Buck 变换器
%   ecalculator.power.boost_converter(Vin, Vout, fsw, L, C) Boost 变换器
%   ecalculator.power.inverter(Vdc, f, R, L)                逆变器
%   ecalculator.power.pfc(Vin, Pout, fsw)                   PFC 计算
%   ecalculator.power.transformer(V1, V2, I1, I2)           变压器
%
%   See also ecalculator.circuit, ecalculator.motor

    methods(Static)
        function info = buck_converter(Vin, Vout, fsw, L, C, Iout)
        %BUCK_CONVERTER Buck 变换器设计计算
        %
        %   ecalculator.power.buck_converter(24, 12, 100e3, 100e-6, 100e-6, 5)

            if nargin < 6, Iout = 5; end

            D = Vout / Vin;
            delta_IL = (Vin - Vout) * D / (fsw * L);
            IL_avg = Iout;
            IL_peak = IL_avg + delta_IL / 2;

            delta_Vout = Iout * D * (1 - D) / (8 * fsw * C * fsw);
            Pout = Vout * Iout;
            Pin = Pout / 0.95;  % 假设 95% 效率
            Iin = Pin / Vin;

            fprintf('⚡ Buck 变换器设计:\n');
            fprintf('   输入电压:   %.2f V\n', Vin);
            fprintf('   输出电压:   %.2f V\n', Vout);
            fprintf('   开关频率:   %.2f kHz\n', fsw/1e3);
            fprintf('   电感:       %.2f μH\n', L*1e6);
            fprintf('   电容:       %.2f μF\n', C*1e6);
            fprintf('   输出电流:   %.2f A\n', Iout);
            fprintf('   ───── 计算结果 ─────\n');
            fprintf('   占空比:     %.4f (%.2f%%)\n', D, D*100);
            fprintf('   电感纹波:   %.4f A\n", delta_IL);
            fprintf('   电感峰值:   %.4f A\n", IL_peak);
            fprintf('   输出纹波:   %.4f V\n", delta_Vout);
            fprintf('   输出功率:   %.2f W\n", Pout);
            fprintf('   输入电流:   %.4f A\n", Iin);

            % 电感选择建议
            L_min = (Vin - Vout) * D / (fsw * 0.3 * Iout);
            fprintf('\n   💡 建议:\n');
            fprintf('   最小电感: %.2f μH (30%% 纹波)\n', L_min*1e6);

            info.D = D;
            info.delta_IL = delta_IL;
            info.IL_peak = IL_peak;
            info.delta_Vout = delta_Vout;
            info.Pout = Pout;
            info.L_min = L_min;
        end

        function info = boost_converter(Vin, Vout, fsw, L, C, Iout)
        %BOOST_CONVERTER Boost 变换器设计计算
        %
        %   ecalculator.power.boost_converter(12, 24, 100e3, 100e-6, 100e-6, 5)

            if nargin < 6, Iout = 5; end

            D = 1 - Vin / Vout;
            delta_IL = Vin * D / (fsw * L);
            IL_avg = Iout / (1 - D);
            IL_peak = IL_avg + delta_IL / 2;

            delta_Vout = Iout * D / (fsw * C);
            Pout = Vout * Iout;
            Pin = Pout / 0.95;
            Iin = Pin / Vin;

            fprintf('⚡ Boost 变换器设计:\n');
            fprintf('   输入电压:   %.2f V\n', Vin);
            fprintf('   输出电压:   %.2f V\n', Vout);
            fprintf('   开关频率:   %.2f kHz\n', fsw/1e3);
            fprintf('   电感:       %.2f μH\n', L*1e6);
            fprintf('   电容:       %.2f μF\n', C*1e6);
            fprintf('   输出电流:   %.2f A\n', Iout);
            fprintf('   ───── 计算结果 ─────\n');
            fprintf('   占空比:     %.4f (%.2f%%)\n', D, D*100);
            fprintf('   电感纹波:   %.4f A\n', delta_IL);
            fprintf('   电感平均:   %.4f A\n', IL_avg);
            fprintf('   电感峰值:   %.4f A\n', IL_peak);
            fprintf('   输出纹波:   %.4f V\n', delta_Vout);
            fprintf('   输出功率:   %.2f W\n', Pout);
            fprintf('   输入电流:   %.4f A\n', Iin);

            info.D = D;
            info.delta_IL = delta_IL;
            info.IL_avg = IL_avg;
            info.IL_peak = IL_peak;
            info.delta_Vout = delta_Vout;
            info.Pout = Pout;
        end

        function info = inverter(Vdc, f, R, L, modulation)
        %INVERTER 逆变器设计计算
        %
        %   ecalculator.power.inverter(400, 50, 10, 1e-3, 'SPWM')

            if nargin < 5, modulation = 'SPWM'; end

            switch upper(modulation)
                case 'SPWM'
                    % 正弦 PWM
                    Vout_rms = Vdc / (2 * sqrt(2));
                    Vout_peak = Vdc / 2;
                    ma = 1;  % 调制比

                case 'SVPWM'
                    % 空间矢量 PWM
                    Vout_rms = Vdc / sqrt(6);
                    Vout_peak = Vdc / sqrt(3);
                    ma = 1;

                otherwise
                    error('ecalculator:power:unknownModulation', '未知调制方式: %s', modulation);
            end

            % 阻抗
            Z = sqrt(R^2 + (2*pi*f*L)^2);
            Iout = Vout_rms / Z;
            Pout = Iout^2 * R;

            fprintf('⚡ %s 逆变器设计:\n', modulation);
            fprintf('   直流电压:   %.2f V\n', Vdc);
            fprintf('   输出频率:   %.2f Hz\n', f);
            fprintf('   负载电阻:   %.2f Ω\n', R);
            fprintf('   负载电感:   %.2f mH\n', L*1e3);
            fprintf('   ───── 计算结果 ─────\n');
            fprintf('   输出电压(RMS): %.2f V\n', Vout_rms);
            fprintf('   输出电压(峰值): %.2f V\n', Vout_peak);
            fprintf('   调制比:     %.2f\n', ma);
            fprintf('   负载阻抗:   %.4f Ω\n', Z);
            fprintf('   输出电流:   %.4f A\n', Iout);
            fprintf('   输出功率:   %.2f W\n', Pout);

            info.Vout_rms = Vout_rms;
            info.Vout_peak = Vout_peak;
            info.Z = Z;
            info.Iout = Iout;
            info.Pout = Pout;
        end

        function info = pfc(Vin_rms, Pout, fsw, topology)
        %PFC 功率因数校正计算
        %
        %   ecalculator.power.pfc(220, 1000, 65e3, 'boost')

            if nargin < 4, topology = 'boost'; end

            % 假设功率因数和效率
            PF = 0.99;
            eta = 0.95;

            Pin = Pout / eta;
            Iin_rms = Pin / (Vin_rms * PF);

            switch lower(topology)
                case 'boost'
                    % Boost PFC
                    Vout = 400;  % 典型输出电压
                    D = 1 - Vin_rms * sqrt(2) / Vout;

                    fprintf('⚡ Boost PFC 设计:\n');

                case 'buck'
                    Vout = 100;
                    D = Vout / (Vin_rms * sqrt(2));

                    fprintf('⚡ Buck PFC 设计:\n');
            end

            fprintf('   输入电压(RMS): %.2f V\n', Vin_rms);
            fprintf('   输出功率:   %.2f W\n', Pout);
            fprintf('   开关频率:   %.2f kHz\n', fsw/1e3);
            fprintf('   ───── 计算结果 ─────\n');
            fprintf('   输入功率:   %.2f W\n', Pin);
            fprintf('   功率因数:   %.2f\n', PF);
            fprintf('   效率:       %.2f%%\n", eta*100);
            fprintf('   输入电流(RMS): %.4f A\n', Iin_rms);
            fprintf('   占空比:     %.4f\n', D);

            % 电感设计
            delta_IL = 0.2 * Iin_rms * sqrt(2);
            L_min = Vin_rms * sqrt(2) * D / (fsw * delta_IL);
            fprintf('   最小电感:   %.2f μH\n', L_min*1e6);

            info.Pin = Pin;
            info.Iin_rms = Iin_rms;
            info.D = D;
            info.L_min = L_min;
        end

        function info = transformer(V1, V2, I1, I2, f)
        %TRANSFORMER 变压器参数计算
        %
        %   ecalculator.power.transformer(220, 12, 1, 18, 50)

            if nargin < 5, f = 50; end

            turns_ratio = V1 / V2;
            S1 = V1 * I1;
            S2 = V2 * I2;
            eta = S2 / S1;

            % 匝数计算 (假设 Bmax = 1.5T, Ae = 10 cm²)
            Bmax = 1.5;
            Ae = 10e-4;  % m²
            N1 = V1 / (4.44 * f * Bmax * Ae);
            N2 = N1 / turns_ratio;

            fprintf('⚡ 变压器设计:\n');
            fprintf('   一次电压:   %.2f V\n', V1);
            fprintf('   二次电压:   %.2f V\n', V2);
            fprintf('   一次电流:   %.4f A\n', I1);
            fprintf('   二次电流:   %.4f A\n', I2);
            fprintf('   频率:       %.2f Hz\n', f);
            fprintf('   ───── 计算结果 ─────\n');
            fprintf('   变比:       %.2f:1\n', turns_ratio);
            fprintf('   一次容量:   %.2f VA\n', S1);
            fprintf('   二次容量:   %.2f VA\n', S2);
            fprintf('   效率:       %.2f%%\n', eta*100);
            fprintf('   一次匝数:   %d\n', round(N1));
            fprintf('   二次匝数:   %d\n', round(N2));

            info.turns_ratio = turns_ratio;
            info.S1 = S1;
            info.S2 = S2;
            info.eta = eta;
            info.N1 = round(N1);
            info.N2 = round(N2);
        end
    end
end
