classdef circuit
%ECALCULATOR.CIRCUIT 电路工程计算器
%
%   ecalculator.circuit.voltage_divider(Vin, R1, R2)    分压计算
%   ecalculator.circuit.rc_filter(R, C, type)           RC 滤波器
%   ecalculator.circuit.rl_filter(R, L, type)           RL 滤波器
%   ecalculator.circuit.rlc_resonance(R, L, C)          RLC 谐振
%   ecalculator.circuit.opamp_gain(Rf, Rin)             运放增益
%   ecalculator.circuit.power(V, I)                     功率计算
%   ecalculator.circuit.thermal(Rja, P, Ta)             热计算
%
%   示例:
%     ecalculator.circuit.voltage_divider(12, 10e3, 4.7e3)
%     ecalculator.circuit.rc_filter(10e3, 100e-9, 'lowpass')
%
%   See also ecalculator.control, ecalculator.signal

    methods(Static)
        function info = voltage_divider(Vin, R1, R2)
        %VOLTAGE_DIVIDER 分压电路计算
        %
        %   info = ecalculator.circuit.voltage_divider(12, 10e3, 4.7e3)

            Vout = Vin * R2 / (R1 + R2);
            I = Vin / (R1 + R2);
            P_R1 = I^2 * R1;
            P_R2 = I^2 * R2;
            P_total = Vin * I;

            fprintf('⚡ 分压电路计算:\n');
            fprintf('   输入电压:   %.3f V\n', Vin);
            fprintf('   R1:         %s\n', format_resistance(R1));
            fprintf('   R2:         %s\n', format_resistance(R2));
            fprintf('   输出电压:   %.4f V\n', Vout);
            fprintf('   分压比:     %.4f (%.1f%%)\n', Vout/Vin, Vout/Vin*100);
            fprintf('   电流:       %s\n', format_current(I));
            fprintf('   R1 功耗:    %s\n', format_power(P_R1));
            fprintf('   R2 功耗:    %s\n', format_power(P_R2));
            fprintf('   总功耗:     %s\n', format_power(P_total));

            info.Vout = Vout;
            info.I = I;
            info.P_R1 = P_R1;
            info.P_R2 = P_R2;
            info.P_total = P_total;
            info.ratio = Vout/Vin;
        end

        function info = rc_filter(R, C, type, varargin)
        %RC_FILTER RC 滤波器计算
        %
        %   ecalculator.circuit.rc_filter(10e3, 100e-9, 'lowpass')
        %   ecalculator.circuit.rc_filter(10e3, 100e-9, 'highpass', 'plot', true)

            opts = struct('plot', true, 'w', []);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            fc = 1 / (2 * pi * R * C);
            tau = R * C;

            fprintf('🔌 RC %s 滤波器:\n', upper(type));
            fprintf('   R:          %s\n', format_resistance(R));
            fprintf('   C:          %s\n', format_capacitance(C));
            fprintf('   截止频率:   %s\n', format_frequency(fc));
            fprintf('   时间常数:   %s\n', format_time(tau));

            switch lower(type)
                case 'lowpass'
                    num = 1;
                    den = [R*C 1];
                case 'highpass'
                    num = [R*C 0];
                    den = [R*C 1];
                otherwise
                    error('ecalculator:circuit:unknownType', '类型必须是 lowpass 或 highpass');
            end

            sys = tf(num, den);

            if opts.plot
                fig = figure('Name', sprintf('RC %s Filter', type));
                if isempty(opts.w)
                    w = logspace(log10(fc/100), log10(fc*100), 1000);
                else
                    w = opts.w;
                end
                bode(sys, w);
                title(sprintf('RC %s Filter (fc = %s)', type, format_frequency(fc)));
                grid on;
            end

            info.fc = fc;
            info.tau = tau;
            info.tf = sys;
        end

        function info = rl_filter(R, L, type, varargin)
        %RL_FILTER RL 滤波器计算
        %
        %   ecalculator.circuit.rl_filter(100, 10e-3, 'lowpass')

            opts = struct('plot', true);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            fc = R / (2 * pi * L);
            tau = L / R;

            fprintf('🔌 RL %s 滤波器:\n', upper(type));
            fprintf('   R:          %s\n', format_resistance(R));
            fprintf('   L:          %s\n', format_inductance(L));
            fprintf('   截止频率:   %s\n', format_frequency(fc));
            fprintf('   时间常数:   %s\n', format_time(tau));

            switch lower(type)
                case 'lowpass'
                    num = R/L;
                    den = [1 R/L];
                case 'highpass'
                    num = [1 0];
                    den = [1 R/L];
                otherwise
                    error('ecalculator:circuit:unknownType', '类型必须是 lowpass 或 highpass');
            end

            sys = tf(num, den);

            if opts.plot
                figure('Name', sprintf('RL %s Filter', type));
                bode(sys);
                title(sprintf('RL %s Filter (fc = %s)', type, format_frequency(fc)));
                grid on;
            end

            info.fc = fc;
            info.tau = tau;
            info.tf = sys;
        end

        function info = rlc_resonance(R, L, C)
        %RLC_RESONANCE RLC 谐振电路分析
        %
        %   ecalculator.circuit.rlc_resonance(10, 10e-3, 100e-9)

            w0 = 1 / sqrt(L * C);
            f0 = w0 / (2 * pi);
            Q = w0 * L / R;
            BW = w0 / Q;
            Z0 = sqrt(L / C);

            fprintf('🔔 RLC 谐振电路:\n');
            fprintf('   R:          %s\n', format_resistance(R));
            fprintf('   L:          %s\n', format_inductance(L));
            fprintf('   C:          %s\n', format_capacitance(C));
            fprintf('   谐振频率:   %s\n', format_frequency(f0));
            fprintf('   谐振角频率: %.2f rad/s\n', w0);
            fprintf('   品质因数:   %.2f\n', Q);
            fprintf('   带宽:       %s\n', format_frequency(BW/(2*pi)));
            fprintf('   特性阻抗:   %s\n', format_resistance(Z0));

            % 绘制频率响应
            sys = tf([1 0], [L R 1/C]);
            figure('Name', 'RLC Resonance');
            bode(sys);
            title(sprintf('RLC Resonance (f₀ = %s, Q = %.1f)', format_frequency(f0), Q));
            grid on;

            info.f0 = f0;
            info.w0 = w0;
            info.Q = Q;
            info.BW = BW;
            info.Z0 = Z0;
        end

        function info = opamp_gain(Rf, Rin, type)
        %OPAMP_GAIN 运放电路增益计算
        %
        %   ecalculator.circuit.opamp_gain(100e3, 10e3)         反相放大器
        %   ecalculator.circuit.opamp_gain(100e3, 10e3, 'noninverting')  同相放大器

            if nargin < 3, type = 'inverting'; end

            switch lower(type)
                case 'inverting'
                    gain = -Rf / Rin;
                    gain_dB = 20*log10(abs(gain));
                    fprintf('🔺 反相放大器:\n');
                    fprintf('   Rf:         %s\n', format_resistance(Rf));
                    fprintf('   Rin:        %s\n', format_resistance(Rin));
                    fprintf('   增益:       %.4f (%.2f dB)\n', gain, gain_dB);
                    fprintf('   相位:       180°\n');

                case 'noninverting'
                    gain = 1 + Rf / Rin;
                    gain_dB = 20*log10(gain);
                    fprintf('🔻 同相放大器:\n');
                    fprintf('   Rf:         %s\n', format_resistance(Rf));
                    fprintf('   Rin:        %s\n', format_resistance(Rin));
                    fprintf('   增益:       %.4f (%.2f dB)\n', gain, gain_dB);
                    fprintf('   相位:       0°\n');

                otherwise
                    error('ecalculator:circuit:unknownType', '类型必须是 inverting 或 noninverting');
            end

            info.gain = gain;
            info.gain_dB = gain_dB;
            info.Rf = Rf;
            info.Rin = Rin;
        end

        function info = power(V, I)
        %POWER 功率计算
        %
        %   ecalculator.circuit.power(12, 0.5)

            P = V * I;
            R = V / I;

            fprintf('⚡ 功率计算:\n');
            fprintf('   电压:       %.4f V\n', V);
            fprintf('   电流:       %s\n', format_current(I));
            fprintf('   功率:       %s\n', format_power(P));
            fprintf('   等效电阻:   %s\n', format_resistance(R));

            info.P = P;
            info.R = R;
        end

        function info = thermal(Rja, P, Ta)
        %THERMAL 热计算
        %
        %   ecalculator.circuit.thermal(50, 2, 25)

            Tj = Ta + P * Rja;

            fprintf('🌡️  热计算:\n');
            fprintf('   环境温度:   %.1f °C\n', Ta);
            fprintf('   功耗:       %s\n', format_power(P));
            fprintf('   热阻:       %.1f °C/W\n', Rja);
            fprintf('   结温:       %.1f °C\n', Tj);

            if Tj > 125
                fprintf('   ❌ 结温过高! 需要散热措施\n');
            elseif Tj > 100
                fprintf('   ⚠️  结温偏高，建议增加散热\n');
            else
                fprintf('   ✅ 结温在安全范围内\n');
            end

            info.Tj = Tj;
            info.margin = 150 - Tj;  % 150°C 为一般最大结温
        end
    end
end

% 格式化辅助函数
function s = format_resistance(R)
    if R >= 1e6
        s = sprintf('%.2f MΩ', R/1e6);
    elseif R >= 1e3
        s = sprintf('%.2f kΩ', R/1e3);
    else
        s = sprintf('%.2f Ω', R);
    end
end

function s = format_capacitance(C)
    if C >= 1e-3
        s = sprintf('%.2f mF', C*1e3);
    elseif C >= 1e-6
        s = sprintf('%.2f μF', C*1e6);
    elseif C >= 1e-9
        s = sprintf('%.2f nF', C*1e9);
    else
        s = sprintf('%.2f pF', C*1e12);
    end
end

function s = format_inductance(L)
    if L >= 1
        s = sprintf('%.2f H', L);
    elseif L >= 1e-3
        s = sprintf('%.2f mH', L*1e3);
    elseif L >= 1e-6
        s = sprintf('%.2f μH', L*1e6);
    else
        s = sprintf('%.2f nH', L*1e9);
    end
end

function s = format_frequency(f)
    if f >= 1e9
        s = sprintf('%.2f GHz', f/1e9);
    elseif f >= 1e6
        s = sprintf('%.2f MHz', f/1e6);
    elseif f >= 1e3
        s = sprintf('%.2f kHz', f/1e3);
    else
        s = sprintf('%.2f Hz', f);
    end
end

function s = format_current(I)
    if I >= 1
        s = sprintf('%.4f A', I);
    elseif I >= 1e-3
        s = sprintf('%.4f mA', I*1e3);
    else
        s = sprintf('%.4f μA', I*1e6);
    end
end

function s = format_power(P)
    if P >= 1
        s = sprintf('%.4f W', P);
    elseif P >= 1e-3
        s = sprintf('%.4f mW', P*1e3);
    else
        s = sprintf('%.4f μW', P*1e6);
    end
end

function s = format_time(t)
    if t >= 1
        s = sprintf('%.4f s', t);
    elseif t >= 1e-3
        s = sprintf('%.4f ms', t*1e3);
    elseif t >= 1e-6
        s = sprintf('%.4f μs', t*1e6);
    else
        s = sprintf('%.4f ns', t*1e9);
    end
end
