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
        function info = dc_motor(V, Ra, La, Ke, Kt, J, B, varargin)
        %DC_MOTOR 直流电机完整分析
        %
        %   ecalculator.motor.dc_motor(24, 0.5, 1e-3, 0.05, 0.05, 1e-4, 1e-5)
        %   ecalculator.motor.dc_motor(24, 0.5, 1e-3, 0.05, 0.05, 1e-4, 1e-5, 'plot', false)
        %
        %   参数:
        %     V  - 额定电压 (V)
        %     Ra - 电枢电阻 (Ω)
        %     La - 电枢电感 (H)
        %     Ke - 反电动势常数 (V·s/rad)
        %     Kt - 转矩常数 (N·m/A)
        %     J  - 转动惯量 (kg·m²)
        %     B  - 粘性摩擦系数 (N·m·s/rad)

            opts = struct('plot', true);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

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
            fprintf('   电枢电阻:     %s\n', eutils.formatters.resistance(Ra));
            fprintf('   电枢电感:     %s\n', eutils.formatters.inductance(La));
            fprintf('   反电动势常数: %.4f V·s/rad\n', Ke);
            fprintf('   转矩常数:     %.4f N·m/A\n', Kt);
            fprintf('   转动惯量:     %s\n', eutils.formatters.inertia(J));
            fprintf('   摩擦系数:     %.2e N·m·s/rad\n', B);
            fprintf('   ───── 性能指标 ─────\n');
            fprintf('   堵转电流:     %s\n', eutils.formatters.current(I_stall));
            fprintf('   堵转转矩:     %s\n', eutils.formatters.torque(T_stall));
            fprintf('   空载转速:     %d RPM (%.2f rad/s)\n', round(RPM_no_load), w_no_load);
            fprintf('   最大功率:     %s @ %d RPM\n', eutils.formatters.power(P_max_power), round(RPM_no_load/2));
            fprintf('   ───── 时间常数 ─────\n');
            fprintf('   电气时间常数: %s\n', eutils.formatters.time(tau_e));
            fprintf('   机械时间常数: %s\n', eutils.formatters.time(tau_m));

            % 绘制特性曲线
            if opts.plot
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
            end

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
            fprintf('   Rs:           %s\n', eutils.formatters.resistance(params.Rs));
            fprintf('   Ld:           %s\n', eutils.formatters.inductance(params.Ld));
            fprintf('   Lq:           %s\n', eutils.formatters.inductance(params.Lq));
            fprintf('   Ke:           %.4f V·s/rad\n', params.Ke);
            fprintf('   ───── 工作点 ─────\n');
            fprintf('   转速:         %d RPM\n', speed_ref);
            fprintf('   电角速度:     %.2f rad/s\n', we);
            fprintf('   最大相电压:   %.2f V\n', Vmax);
            fprintf('   ───── 电流环 ─────\n');
            fprintf('   带宽:         %s\n', eutils.formatters.frequency(bw_current));
            fprintf('   Kp_d:         %.6f\n', Kp_d);
            fprintf('   Ki_d:         %.6f\n', Ki_d);
            fprintf('   Kp_q:         %.6f\n', Kp_q);
            fprintf('   Ki_q:         %.6f\n', Ki_q);
            fprintf('   ───── 速度环 ─────\n');
            fprintf('   带宽:         %s\n', eutils.formatters.frequency(bw_speed));

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
            fprintf('   功耗:         %s\n', eutils.formatters.power(Ploss));
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

        function info = pmsm_params(Vdc, Rs, Ld, Lq, Ke)
        %PMSM_PARAMS 永磁同步电机参数分析
        %
        %   ecalculator.motor.pmsm_params(48, 0.5, 1e-3, 1.2e-3, 0.05)
        %
        %   参数:
        %     Vdc - 直流母线电压 (V)
        %     Rs  - 定子电阻 (Ω)
        %     Ld  - d 轴电感 (H)
        %     Lq  - q 轴电感 (H)
        %     Ke  - 反电动势常数 (V·s/rad)

            % 最大相电压
            Vmax = Vdc / sqrt(3);

            % 最大电流 (假设)
            Imax = Vmax / sqrt(Rs^2 + (2*pi*1000*Lq)^2);

            % 最大转矩
            p = 4;  % 假设 4 极对数
            Tmax = 1.5 * p * Ke * Imax;

            % 最大转速
            wmax = Vmax / Ke;
            RPMmax = wmax * 60 / (2*pi);

            % 特征频率
            f_d = Rs / (2*pi*Ld);
            f_q = Rs / (2*pi*Lq);

            fprintf('🔧 PMSM 参数分析:\n');
            fprintf('   ───── 电气参数 ─────\n');
            fprintf('   母线电压:   %.1f V\n', Vdc);
            fprintf('   最大相电压: %.2f V\n', Vmax);
            fprintf('   Rs:         %s\n', eutils.formatters.resistance(Rs));
            fprintf('   Ld:         %s\n', eutils.formatters.inductance(Ld));
            fprintf('   Lq:         %s\n', eutils.formatters.inductance(Lq));
            fprintf('   Ke:         %.4f V·s/rad\n', Ke);
            fprintf('   ───── 性能指标 ─────\n');
            fprintf('   最大电流:   %s\n', eutils.formatters.current(Imax));
            fprintf('   最大转矩:   %s\n', eutils.formatters.torque(Tmax));
            fprintf('   最大转速:   %d RPM\n', round(RPMmax));
            fprintf('   ───── 特征频率 ─────\n');
            fprintf('   d 轴频率:   %s\n', eutils.formatters.frequency(f_d));
            fprintf('   q 轴频率:   %s\n', eutils.formatters.frequency(f_q));

            info.Vmax = Vmax;
            info.Imax = Imax;
            info.Tmax = Tmax;
            info.wmax = wmax;
            info.RPMmax = RPMmax;
            info.f_d = f_d;
            info.f_q = f_q;
        end
    end
end

