classdef motor
%ECALCULATOR.MOTOR 电机工程计算器
%
%   ecalculator.motor.dc_motor(V, Ra, La, Ke, Kt, J, B)  直流电机分析
%   ecalculator.motor.pmsm_params(Vdc, Rs, Ld, Lq, Ke)   PMSM 参数分析
%   ecalculator.motor.foc_calc(speed_ref, torque_ref)     FOC 控制参数
%   ecalculator.motor.thermal_model(Rth, Ploss, Ta)       电机热模型
%
%   See also ecalculator.control, ecalculator.circuit

    methods(Static)
        function info = dc_motor(V, Ra, La, Ke, Kt, J, B)
        %DC_MOTOR 直流电机完整分析
        %
        %   ecalculator.motor.dc_motor(24, 0.5, 1e-3, 0.05, 0.05, 1e-4, 1e-5)
        %
        %   参数:
        %     V  - 额定电压 (V)
        %     Ra - 电枢电阻 (Ω)
        %     La - 电枢电感 (H)
        %     Ke - 反电动势常数 (V·s/rad)
        %     Kt - 转矩常数 (N·m/A)
        %     J  - 转动惯量 (kg·m²)
        %     B  - 粘性摩擦系数 (N·m·s/rad)

            % 堵转参数
            I_stall = V / Ra;
            T_stall = Kt * I_stall;

            % 空载参数
            w_no_load = V / Ke;
            RPM_no_load = w_no_load * 60 / (2*pi);

            % 最大功率点
            I_max_power = I_stall / 2;
            w_max_power = w_no_load / 2;
            T_max_power = T_stall / 2;
            P_max_power = T_max_power * w_max_power;

            % 电气时间常数
            tau_e = La / Ra;

            % 机械时间常数
            tau_m = J * Ra / (Kt * Ke);

            % 传递函数
            % Ω(s)/V(s) = Kt / (La*J*s^2 + (La*B + Ra*J)*s + Ra*B + Kt*Ke)
            num = Kt;
            den = [La*J, La*B + Ra*J, Ra*B + Kt*Ke];
            sys = tf(num, den);

            fprintf('⚡ 直流电机分析:\n');
            fprintf('   ───── 额定参数 ─────\n');
            fprintf('   额定电压:     %.1f V\n', V);
            fprintf('   电枢电阻:     %s\n', format_resistance(Ra));
            fprintf('   电枢电感:     %s\n', format_inductance(La));
            fprintf('   反电动势常数: %.4f V·s/rad\n', Ke);
            fprintf('   转矩常数:     %.4f N·m/A\n', Kt);
            fprintf('   转动惯量:     %s\n', format_inertia(J));
            fprintf('   摩擦系数:     %.2e N·m·s/rad\n', B);
            fprintf('   ───── 性能指标 ─────\n');
            fprintf('   堵转电流:     %s\n', format_current(I_stall));
            fprintf('   堵转转矩:     %s\n', format_torque(T_stall));
            fprintf('   空载转速:     %d RPM (%.2f rad/s)\n', round(RPM_no_load), w_no_load);
            fprintf('   最大功率:     %s @ %d RPM\n', format_power(P_max_power), round(RPM_no_load/2));
            fprintf('   ───── 时间常数 ─────\n');
            fprintf('   电气时间常数: %s\n', format_time(tau_e));
            fprintf('   机械时间常数: %s\n', format_time(tau_m));

            % 绘制特性曲线
            fig = figure('Name', 'DC Motor Characteristics');

            % 转矩-转速曲线
            subplot(2,2,1);
            T_range = linspace(0, T_stall, 100);
            w_range = w_no_load * (1 - T_range/T_stall);
            RPM_range = w_range * 60 / (2*pi);
            plot(T_range, RPM_range, 'b-', 'LineWidth', 1.5);
            xlabel('Torque (N·m)');
            ylabel('Speed (RPM)');
            title('Torque-Speed Curve');
            grid on;

            % 转矩-电流曲线
            subplot(2,2,2);
            I_range = T_range / Kt;
            plot(T_range, I_range*1000, 'r-', 'LineWidth', 1.5);
            xlabel('Torque (N·m)');
            ylabel('Current (mA)');
            title('Torque-Current Curve');
            grid on;

            % 效率曲线
            subplot(2,2,3);
            P_in = V * I_range;
            P_out = T_range .* w_range;
            efficiency = P_out ./ (P_in + eps) * 100;
            plot(T_range, efficiency, 'g-', 'LineWidth', 1.5);
            xlabel('Torque (N·m)');
            ylabel('Efficiency (%)');
            title('Efficiency Curve');
            grid on;

            % 阶跃响应
            subplot(2,2,4);
            step(sys);
            title('Speed Step Response');
            grid on;

            info.I_stall = I_stall;
            info.T_stall = T_stall;
            info.w_no_load = w_no_load;
            info.RPM_no_load = RPM_no_load;
            info.P_max_power = P_max_power;
            info.tau_e = tau_e;
            info.tau_m = tau_m;
            info.tf = sys;
        end

        function info = foc_calc(speed_ref, torque_ref, params)
        %FOC_CALC FOC 控制参数计算
        %
        %   params.Vdc = 48;
        %   params.Rs = 0.5;
        %   params.Ld = 1e-3;
        %   params.Lq = 1.2e-3;
        %   params.Ke = 0.05;
        %   params.p = 4;  % 极对数
        %   ecalculator.motor.foc_calc(3000, 10, params)

            if nargin < 3
                params.Vdc = 48;
                params.Rs = 0.5;
                params.Ld = 1e-3;
                params.Lq = 1.2e-3;
                params.Ke = 0.05;
                params.p = 4;
            end

            % 电气参数
            we = speed_ref * 2*pi/60 * params.p;  % 电角速度
            Vmax = params.Vdc / sqrt(3);           % 最大相电压

            % 电流环带宽 (通常取电气时间常数的 5-10 倍)
            tau_d = params.Ld / params.Rs;
            tau_q = params.Lq / params.Rs;
            bw_current = min(1/tau_d, 1/tau_q) / (2*pi) / 5;

            % PI 参数 (内模控制法)
            Kp_d = params.Ld * bw_current * 2 * pi;
            Ki_d = params.Rs * bw_current * 2 * pi;
            Kp_q = params.Lq * bw_current * 2 * pi;
            Ki_q = params.Rs * bw_current * 2 * pi;

            % 速度环带宽 (通常取电流环的 1/5 - 1/10)
            bw_speed = bw_current / 10;

            fprintf('🔧 FOC 控制参数:\n');
            fprintf('   ───── 电机参数 ─────\n');
            fprintf('   极对数:       %d\n', params.p);
            fprintf('   Rs:           %s\n', format_resistance(params.Rs));
            fprintf('   Ld:           %s\n', format_inductance(params.Ld));
            fprintf('   Lq:           %s\n', format_inductance(params.Lq));
            fprintf('   Ke:           %.4f V·s/rad\n', params.Ke);
            fprintf('   ───── 工作点 ─────\n');
            fprintf('   转速:         %d RPM\n', speed_ref);
            fprintf('   电角速度:     %.2f rad/s\n', we);
            fprintf('   最大相电压:   %.2f V\n', Vmax);
            fprintf('   ───── 电流环 ─────\n');
            fprintf('   带宽:         %s\n', format_frequency(bw_current));
            fprintf('   Kp_d:         %.6f\n', Kp_d);
            fprintf('   Ki_d:         %.6f\n', Ki_d);
            fprintf('   Kp_q:         %.6f\n', Kp_q);
            fprintf('   Ki_q:         %.6f\n', Ki_q);
            fprintf('   ───── 速度环 ─────\n');
            fprintf('   带宽:         %s\n', format_frequency(bw_speed));

            % MTPA 计算
            Is_max = torque_ref / (1.5 * params.p * params.Ke);
            id_ref = (params.Lq - params.Ld) / (4*(params.Lq - params.Ld)) * ...
                     (1 - sqrt(1 + 8*Is_max^2/(params.Lq - params.Ld)^2));
            iq_ref = sqrt(Is_max^2 - id_ref^2);

            fprintf('   ───── MTPA ─────\n');
            fprintf('   id_ref:       %.4f A\n', id_ref);
            fprintf('   iq_ref:       %.4f A\n', iq_ref);

            info.Kp_d = Kp_d;
            info.Ki_d = Ki_d;
            info.Kp_q = Kp_q;
            info.Ki_q = Ki_q;
            info.bw_current = bw_current;
            info.bw_speed = bw_speed;
            info.id_ref = id_ref;
            info.iq_ref = iq_ref;
        end

        function info = thermal_model(Rth_ja, Rth_jc, Ploss, Ta)
        %THERMAL_MODEL 电机热模型
        %
        %   ecalculator.motor.thermal_model(50, 2, 100, 40)

            if nargin < 2
                Rth_jc = Rth_ja * 0.3;  % 估算
            end

            Tj = Ta + Ploss * Rth_ja;
            Tc = Ta + Ploss * (Rth_ja - Rth_jc);

            fprintf('🌡️  电机热模型:\n');
            fprintf('   环境温度:     %.1f °C\n', Ta);
            fprintf('   功耗:         %s\n', format_power(Ploss));
            fprintf('   结到环境热阻: %.1f °C/W\n', Rth_ja);
            fprintf('   结到壳热阻:   %.1f °C/W\n', Rth_jc);
            fprintf('   结温:         %.1f °C\n', Tj);
            fprintf('   壳温:         %.1f °C\n', Tc);

            if Tj > 150
                fprintf('   ❌ 结温过高! 需要散热措施\n');
            elseif Tj > 120
                fprintf('   ⚠️  结温偏高，建议增加散热\n');
            else
                fprintf('   ✅ 结温在安全范围内\n');
            end

            info.Tj = Tj;
            info.Tc = Tc;
            info.margin = 150 - Tj;
        end
    end
end

% 格式化函数
function s = format_resistance(R)
    if R >= 1e6, s = sprintf('%.2f MΩ', R/1e6);
    elseif R >= 1e3, s = sprintf('%.2f kΩ', R/1e3);
    else, s = sprintf('%.3f Ω', R); end
end

function s = format_inductance(L)
    if L >= 1, s = sprintf('%.2f H', L);
    elseif L >= 1e-3, s = sprintf('%.2f mH', L*1e3);
    elseif L >= 1e-6, s = sprintf('%.2f μH', L*1e6);
    else, s = sprintf('%.2f nH', L*1e9); end
end

function s = format_inertia(J)
    if J >= 1e-3, s = sprintf('%.4f kg·m²', J);
    elseif J >= 1e-6, s = sprintf('%.4f g·cm²', J*1e7);
    else, s = sprintf('%.4f mg·cm²', J*1e10); end
end

function s = format_current(I)
    if I >= 1, s = sprintf('%.3f A', I);
    elseif I >= 1e-3, s = sprintf('%.3f mA', I*1e3);
    else, s = sprintf('%.3f μA', I*1e6); end
end

function s = format_torque(T)
    if T >= 1, s = sprintf('%.4f N·m', T);
    elseif T >= 1e-3, s = sprintf('%.4f mN·m', T*1e3);
    else, s = sprintf('%.4f μN·m', T*1e6); end
end

function s = format_power(P)
    if P >= 1, s = sprintf('%.2f W', P);
    elseif P >= 1e-3, s = sprintf('%.2f mW', P*1e3);
    else, s = sprintf('%.2f μW', P*1e6); end
end

function s = format_frequency(f)
    if f >= 1e6, s = sprintf('%.2f MHz', f/1e6);
    elseif f >= 1e3, s = sprintf('%.2f kHz', f/1e3);
    else, s = sprintf('%.2f Hz', f); end
end

function s = format_time(t)
    if t >= 1, s = sprintf('%.4f s', t);
    elseif t >= 1e-3, s = sprintf('%.4f ms', t*1e3);
    else, s = sprintf('%.4f μs', t*1e6); end
end
