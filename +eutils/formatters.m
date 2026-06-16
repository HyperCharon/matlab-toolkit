classdef formatters
%EUTILS.FORMATTERS 工程单位格式化工具
%
%   eutils.formatters.resistance(R)    电阻格式化
%   eutils.formatters.capacitance(C)   电容格式化
%   eutils.formatters.inductance(L)    电感格式化
%   eutils.formatters.frequency(f)     频率格式化
%   eutils.formatters.current(I)       电流格式化
%   eutils.formatters.voltage(V)       电压格式化
%   eutils.formatters.power(P)         功率格式化
%   eutils.formatters.time(t)          时间格式化
%   eutils.formatters.distance(d)      距离格式化
%
%   See also eutils.units, eutils.constants

    methods(Static)
        function s = resistance(R)
        %RESISTANCE 电阻格式化 (自动选择 Ω/kΩ/MΩ)
        %
        %   s = eutils.formatters.resistance(4700)
        %   返回: '4.70 kΩ'

            if abs(R) >= 1e6
                s = sprintf('%.2f MΩ', R/1e6);
            elseif abs(R) >= 1e3
                s = sprintf('%.2f kΩ', R/1e3);
            else
                s = sprintf('%.2f Ω', R);
            end
        end

        function s = capacitance(C)
        %CAPACITANCE 电容格式化 (自动选择 pF/nF/μF/mF)
        %
        %   s = eutils.formatters.capacitance(100e-9)
        %   返回: '100.00 nF'

            if abs(C) >= 1e-3
                s = sprintf('%.2f mF', C*1e3);
            elseif abs(C) >= 1e-6
                s = sprintf('%.2f μF', C*1e6);
            elseif abs(C) >= 1e-9
                s = sprintf('%.2f nF', C*1e9);
            else
                s = sprintf('%.2f pF', C*1e12);
            end
        end

        function s = inductance(L)
        %INDUCTANCE 电感格式化 (自动选择 nH/μH/mH/H)
        %
        %   s = eutils.formatters.inductance(100e-6)
        %   返回: '100.00 μH'

            if abs(L) >= 1
                s = sprintf('%.2f H', L);
            elseif abs(L) >= 1e-3
                s = sprintf('%.2f mH', L*1e3);
            elseif abs(L) >= 1e-6
                s = sprintf('%.2f μH', L*1e6);
            else
                s = sprintf('%.2f nH', L*1e9);
            end
        end

        function s = frequency(f)
        %FREQUENCY 频率格式化 (自动选择 Hz/kHz/MHz/GHz)
        %
        %   s = eutils.formatters.frequency(2.4e9)
        %   返回: '2.40 GHz'

            if abs(f) >= 1e9
                s = sprintf('%.2f GHz', f/1e9);
            elseif abs(f) >= 1e6
                s = sprintf('%.2f MHz', f/1e6);
            elseif abs(f) >= 1e3
                s = sprintf('%.2f kHz', f/1e3);
            else
                s = sprintf('%.2f Hz', f);
            end
        end

        function s = current(I)
        %CURRENT 电流格式化 (自动选择 μA/mA/A)
        %
        %   s = eutils.formatters.current(0.015)
        %   返回: '15.0000 mA'

            if abs(I) >= 1
                s = sprintf('%.4f A', I);
            elseif abs(I) >= 1e-3
                s = sprintf('%.4f mA', I*1e3);
            else
                s = sprintf('%.4f μA', I*1e6);
            end
        end

        function s = voltage(V)
        %VOLTAGE 电压格式化 (自动选择 μV/mV/V/kV)
        %
        %   s = eutils.formatters.voltage(3300)
        %   返回: '3.30 kV'

            if abs(V) >= 1e3
                s = sprintf('%.2f kV', V/1e3);
            elseif abs(V) >= 1
                s = sprintf('%.4f V', V);
            elseif abs(V) >= 1e-3
                s = sprintf('%.4f mV', V*1e3);
            else
                s = sprintf('%.4f μV', V*1e6);
            end
        end

        function s = power(P)
        %POWER 功率格式化 (自动选择 μW/mW/W/kW/MW)
        %
        %   s = eutils.formatters.power(1500)
        %   返回: '1.50 kW'

            if abs(P) >= 1e6
                s = sprintf('%.2f MW', P/1e6);
            elseif abs(P) >= 1e3
                s = sprintf('%.2f kW', P/1e3);
            elseif abs(P) >= 1
                s = sprintf('%.4f W', P);
            elseif abs(P) >= 1e-3
                s = sprintf('%.4f mW', P*1e3);
            else
                s = sprintf('%.4f μW', P*1e6);
            end
        end

        function s = time(t)
        %TIME 时间格式化 (自动选择 ns/μB/ms/s)
        %
        %   s = eutils.formatters.time(0.001)
        %   返回: '1.0000 ms'

            if abs(t) >= 1
                s = sprintf('%.4f s', t);
            elseif abs(t) >= 1e-3
                s = sprintf('%.4f ms', t*1e3);
            elseif abs(t) >= 1e-6
                s = sprintf('%.4f μs', t*1e6);
            else
                s = sprintf('%.4f ns', t*1e9);
            end
        end

        function s = inertia(J)
        %INERTIA 转动惯量格式化 (自动选择 mg·cm²/g·cm²/kg·m²)
        %
        %   s = eutils.formatters.inertia(1e-4)
        %   返回: '0.0001 kg·m²'

            if abs(J) >= 1e-3
                s = sprintf('%.4f kg·m²', J);
            elseif abs(J) >= 1e-6
                s = sprintf('%.4f g·cm²', J*1e7);
            else
                s = sprintf('%.4f mg·cm²', J*1e10);
            end
        end

        function s = torque(T)
        %TORQUE 转矩格式化 (自动选择 μN·m/mN·m/N·m)
        %
        %   s = eutils.formatters.torque(0.05)
        %   返回: '0.0500 N·m'

            if abs(T) >= 1
                s = sprintf('%.4f N·m', T);
            elseif abs(T) >= 1e-3
                s = sprintf('%.4f mN·m', T*1e3);
            else
                s = sprintf('%.4f μN·m', T*1e6);
            end
        end

        function s = distance(d)
        %DISTANCE 距离格式化 (自动选择 nm/μm/mm/m/km)
        %
        %   s = eutils.formatters.distance(0.05)
        %   返回: '50.00 mm'

            if abs(d) >= 1e3
                s = sprintf('%.2f km', d/1e3);
            elseif abs(d) >= 1
                s = sprintf('%.4f m', d);
            elseif abs(d) >= 1e-3
                s = sprintf('%.4f mm', d*1e3);
            elseif abs(d) >= 1e-6
                s = sprintf('%.4f μm', d*1e6);
            else
                s = sprintf('%.4f nm', d*1e9);
            end
        end
    end
end
