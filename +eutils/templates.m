classdef templates
%EUTILS.TEMPLATES 课程设计与实验模板
%
%   eutils.templates.pid_design()           PID 控制器设计模板
%   eutils.templates.motor_control()        直流电机控制模板
%   eutils.templates.filter_design()        数字滤波器设计模板
%   eutils.templates.signal_experiment()    信号与系统实验模板
%   eutils.templates.state_space()          状态空间设计模板
%   eutils.templates.power_electronics()    电力电子仿真模板
%
%   每个模板生成完整的 MATLAB 脚本，包含:
%   - 详细的中文注释
%   - 完整的参数设置
%   - 可视化输出
%   - 性能指标计算
%
%   See also eutils.init_project, ecalculator.control

    methods(Static)
        function pid_design()
        %PID_DESIGN PID 控制器设计模板
        %
        %   eutils.templates.pid_design()

            fprintf('📝 生成 PID 控制器设计模板...\n');

            code = { ...
                '%% PID 控制器设计实验'
                '% 本脚本演示 PID 控制器的设计与仿真'
                '% 作者: [你的名字]'
                '% 日期: %s'
                ''
                'clear; clc; close all;'
                ''
                '%% 1. 被控对象定义'
                '% 二阶系统: G(s) = K / (s^2 + as + b)'
                'K = 1;      % 系统增益'
                'a = 10;     % 阻尼系数'
                'b = 0;      % 积分项'
                'plant = tf(K, [1 a b]);'
                ''
                '%% 2. 开环系统分析'
                'figure(''Name'', ''开环系统分析'');'
                'subplot(2,1,1);'
                'step(plant);'
                'title(''开环阶跃响应'');'
                'grid on;'
                ''
                'subplot(2,1,2);'
                'bode(plant);'
                'title(''开环波特图'');'
                'grid on;'
                ''
                '%% 3. PID 参数整定'
                '% 使用 Ziegler-Nichols 方法'
                'pid_info = ecalculator.control.pid_tune(K, [1 a b], ''ziegler-nichols'');'
                ''
                'Kp = pid_info.Kp;  % 比例系数'
                'Ki = pid_info.Ki;  % 积分系数'
                'Kd = pid_info.Kd;  % 微分系数'
                ''
                'fprintf(''PID 参数: Kp=%.4f, Ki=%.4f, Kd=%.4f\\n'', Kp, Ki, Kd);'
                ''
                '%% 4. 闭环系统仿真'
                'C = pid(Kp, Ki, Kd);'
                'sys_closed = feedback(C * plant, 1);'
                ''
                'figure(''Name'', ''闭环响应'');'
                'step(sys_closed);'
                'hold on;'
                'step(feedback(plant, 1));'
                'legend(''有 PID'', ''无 PID'');'
                'title(''闭环阶跃响应对比'');'
                'grid on;'
                ''
                '%% 5. 性能指标'
                'info = stepinfo(sys_closed);'
                'fprintf(''\\n性能指标:\\n'');'
                fprintf(''   超调量: %.2f%%\\n'', info.Overshoot);'
                'fprintf(''   调节时间: %.4f s\\n'', info.SettlingTime);'
                'fprintf(''   上升时间: %.4f s\\n'', info.RiseTime);'
                'fprintf(''   峰值时间: %.4f s\\n'', info.PeakTime);'
                ''
                '%% 6. 参数扫描'
                'Kp_range = linspace(Kp*0.5, Kp*2, 10);'
                'overshoot = zeros(size(Kp_range));'
                'settling_time = zeros(size(Kp_range));'
                ''
                'for i = 1:numel(Kp_range)'
                '    C_i = pid(Kp_range(i), Ki, Kd);'
                '    sys_i = feedback(C_i * plant, 1);'
                '    info_i = stepinfo(sys_i);'
                '    overshoot(i) = info_i.Overshoot;'
                '    settling_time(i) = info_i.SettlingTime;'
                'end'
                ''
                'figure(''Name'', ''参数扫描'');'
                'subplot(2,1,1);'
                'plot(Kp_range, overshoot, ''b-o'', ''LineWidth'', 1.5);'
                'xlabel(''Kp''); ylabel(''超调量 (%)'');'
                'title(''Kp 对超调量的影响'');'
                'grid on;'
                ''
                'subplot(2,1,2);'
                'plot(Kp_range, settling_time, ''r-o'', ''LineWidth'', 1.5);'
                'xlabel(''Kp''); ylabel(''调节时间 (s)'');'
                'title(''Kp 对调节时间的影响'');'
                'grid on;'
                ''
                'fprintf(''\\n实验完成!\\n'');'
            };

            code_str = strjoin(code, '\n');
            code_str = sprintf(code_str, datestr(now, 'yyyy-mm-dd'));

            % 写入文件
            filename = 'PID_design_template.m';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', code_str);
            fclose(fid);

            fprintf('✅ 模板已生成: %s\n', filename);
        end

        function motor_control()
        %MOTOR_CONTROL 直流电机控制模板
        %
        %   eutils.templates.motor_control()

            fprintf('📝 生成直流电机控制模板...\n');

            code = { ...
                '%% 直流电机速度控制实验'
                '% 本脚本演示直流电机的建模与速度控制'
                ''
                'clear; clc; close all;'
                ''
                '%% 1. 电机参数'
                'Ra = 0.5;      % 电枢电阻 (Ω)'
                'La = 1e-3;     % 电枢电感 (H)'
                'Ke = 0.05;     % 反电动势常数 (V·s/rad)'
                'Kt = 0.05;     % 转矩常数 (N·m/A)'
                'J = 1e-4;      % 转动惯量 (kg·m²)'
                'B = 1e-5;      % 粘性摩擦系数 (N·m·s/rad)'
                ''
                '%% 2. 电机传递函数'
                '% Ω(s)/V(s) = Kt / (La*J*s^2 + (La*B + Ra*J)*s + Ra*B + Kt*Ke)'
                'num_motor = Kt;'
                'den_motor = [La*J, La*B + Ra*J, Ra*B + Kt*Ke];'
                'motor = tf(num_motor, den_motor);'
                ''
                '%% 3. 电机特性分析'
                'motor_info = ecalculator.motor.dc_motor(24, Ra, La, Ke, Kt, J, B);'
                ''
                '%% 4. PID 速度控制器设计'
                'pid_info = ecalculator.control.pid_tune(num_motor, den_motor, ''ziegler-nichols'');'
                ''
                'Kp = pid_info.Kp;'
                'Ki = pid_info.Ki;'
                'Kd = pid_info.Kd;'
                ''
                'C = pid(Kp, Ki, Kd);'
                'sys_closed = feedback(C * motor, 1);'
                ''
                '%% 5. 仿真结果'
                'figure(''Name'', ''电机速度控制'');'
                'step(sys_closed);'
                'title(''电机速度闭环响应'');'
                'xlabel(''时间 (s)'');'
                'ylabel(''转速 (rad/s)'');'
                'grid on;'
                ''
                '%% 6. 性能指标'
                'info = stepinfo(sys_closed);'
                'fprintf(''\\n性能指标:\\n'');'
                'fprintf(''   超调量: %.2f%%\\n'', info.Overshoot);'
                'fprintf(''   调节时间: %.4f s\\n'', info.SettlingTime);'
                ''
                'fprintf(''\\n实验完成!\\n'');'
            };

            code_str = strjoin(code, '\n');

            filename = 'motor_control_template.m';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', code_str);
            fclose(fid);

            fprintf('✅ 模板已生成: %s\n', filename);
        end

        function filter_design()
        %FILTER_DESIGN 数字滤波器设计模板
        %
        %   eutils.templates.filter_design()

            fprintf('📝 生成数字滤波器设计模板...\n');

            code = { ...
                '%% 数字滤波器设计实验'
                '% 本脚本演示 FIR 和 IIR 滤波器的设计与比较'
                ''
                'clear; clc; close all;'
                ''
                '%% 1. 生成测试信号'
                'Fs = 1000;           % 采样率 (Hz)'
                't = 0:1/Fs:1;       % 时间向量'
                'f1 = 50;             % 信号频率 1 (Hz)'
                'f2 = 200;            % 信号频率 2 (Hz)'
                'f_noise = 400;       % 噪声频率 (Hz)'
                ''
                'x_clean = sin(2*pi*f1*t) + 0.5*sin(2*pi*f2*t);'
                'x_noisy = x_clean + 0.3*sin(2*pi*f_noise*t) + 0.1*randn(size(t));'
                ''
                '%% 2. FIR 滤波器设计'
                'fir_order = 50;'
                'fc = 300;  % 截止频率 (Hz)'
                'b_fir = fir1(fir_order, fc/(Fs/2));'
                'x_fir = filter(b_fir, 1, x_noisy);'
                ''
                '%% 3. IIR 滤波器设计'
                '[b_iir, a_iir] = butter(4, fc/(Fs/2));'
                'x_iir = filtfilt(b_iir, a_iir, x_noisy);'
                ''
                '%% 4. 频率响应对比'
                'figure(''Name'', ''滤波器频率响应'');'
                'subplot(2,1,1);'
                '[H_fir, f] = freqz(b_fir, 1, 1024, Fs);'
                'plot(f, 20*log10(abs(H_fir)), ''b'', ''LineWidth'', 1.5);'
                'hold on;'
                '[H_iir, ~] = freqz(b_iir, a_iir, 1024, Fs);'
                'plot(f, 20*log10(abs(H_iir)), ''r'', ''LineWidth'', 1.5);'
                'legend(''FIR'', ''IIR'');'
                'xlabel(''频率 (Hz)''); ylabel(''幅值 (dB)'');'
                'title(''滤波器频率响应'');'
                'grid on;'
                ''
                'subplot(2,1,2);'
                'plot(f, angle(H_fir)*180/pi, ''b'', ''LineWidth'', 1.5);'
                'hold on;'
                'plot(f, angle(H_iir)*180/pi, ''r'', ''LineWidth'', 1.5);'
                'legend(''FIR'', ''IIR'');'
                'xlabel(''频率 (Hz)''); ylabel(''相位 (°)'');'
                'title(''相位响应'');'
                'grid on;'
                ''
                '%% 5. 滤波效果对比'
                'figure(''Name'', ''滤波效果'');'
                'subplot(3,1,1);'
                'plot(t, x_noisy, ''k'', ''LineWidth'', 0.5);'
                'title(''原始信号 (含噪声)'');'
                'grid on;'
                ''
                'subplot(3,1,2);'
                'plot(t, x_fir, ''b'', ''LineWidth'', 1.5);'
                'title(''FIR 滤波结果'');'
                'grid on;'
                ''
                'subplot(3,1,3);'
                'plot(t, x_iir, ''r'', ''LineWidth'', 1.5);'
                'title(''IIR 滤波结果'');'
                'grid on;'
                ''
                '%% 6. 性能指标'
                'rmse_fir = rms(x_clean - x_fir);'
                'rmse_iir = rms(x_clean - x_iir);'
                'fprintf(''\\n滤波性能:\\n'');'
                'fprintf(''   FIR RMSE: %.6f\\n'', rmse_fir);'
                'fprintf(''   IIR RMSE: %.6f\\n'', rmse_iir);'
                ''
                'fprintf(''\\n实验完成!\\n'');'
            };

            code_str = strjoin(code, '\n');

            filename = 'filter_design_template.m';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', code_str);
            fclose(fid);

            fprintf('✅ 模板已生成: %s\n', filename);
        end

        function signal_experiment()
        %SIGNAL_EXPERIMENT 信号与系统实验模板
        %
        %   eutils.templates.signal_experiment()

            fprintf('📝 生成信号与系统实验模板...\n');

            code = { ...
                '%% 信号与系统实验'
                '% 本脚本演示傅里叶级数、卷积、采样定理等基本概念'
                ''
                'clear; clc; close all;'
                ''
                '%% 1. 傅里叶级数展开'
                '% 方波信号的傅里叶级数逼近'
                't = linspace(0, 2*pi, 1000);'
                'n_terms = [1, 3, 5, 10, 50];'
                ''
                'figure(''Name'', ''傅里叶级数'');'
                'hold on;'
                'for k = 1:numel(n_terms)'
                '    n = n_terms(k);'
                '    y = zeros(size(t));'
                '    for i = 1:2:n'
                '        y = y + (4/pi) * sin(i*t) / i;'
                '    end'
                '    plot(t, y, ''LineWidth'', 1.5, ''DisplayName'', sprintf(''N=%d'', n));'
                'end'
                'plot(t, square(t), ''k--'', ''LineWidth'', 1, ''DisplayName'', ''方波'');'
                'xlabel(''时间''); ylabel(''幅值'');'
                'title(''方波的傅里叶级数逼近'');'
                'legend(''Location'', ''best'');'
                'grid on;'
                ''
                '%% 2. 卷积演示'
                '% 两个矩形脉冲的卷积'
                't = linspace(-5, 5, 1000);'
                'dt = t(2) - t(1);'
                ''
                '% 矩形脉冲'
                'x1 = double(abs(t) <= 1);'
                'x2 = double(abs(t) <= 0.5);'
                ''
                '% 卷积'
                'y_conv = conv(x1, x2) * dt;'
                't_conv = linspace(2*t(1), 2*t(end), numel(y_conv));'
                ''
                'figure(''Name'', ''卷积演示'');'
                'subplot(3,1,1);'
                'plot(t, x1, ''b'', ''LineWidth'', 2);'
                'title(''x1(t)'');'
                'grid on;'
                ''
                'subplot(3,1,2);'
                'plot(t, x2, ''r'', ''LineWidth'', 2);'
                'title(''x2(t)'');'
                'grid on;'
                ''
                'subplot(3,1,3);'
                'plot(t_conv, y_conv, ''k'', ''LineWidth'', 2);'
                'title(''x1 * x2 (卷积)'');'
                'grid on;'
                ''
                '%% 3. 采样定理验证'
                'Fs1 = 100;   % 满足采样定理'
                'Fs2 = 30;    % 不满足采样定理'
                'f0 = 20;     % 信号频率'
                ''
                't_cont = linspace(0, 0.2, 1000);'
                'x_cont = sin(2*pi*f0*t_cont);'
                ''
                't1 = 0:1/Fs1:0.2;'
                'x1 = sin(2*pi*f0*t1);'
                ''
                't2 = 0:1/Fs2:0.2;'
                'x2 = sin(2*pi*f0*t2);'
                ''
                'figure(''Name'', ''采样定理'');'
                'subplot(2,1,1);'
                'plot(t_cont, x_cont, ''b'', ''LineWidth'', 1);'
                'hold on;'
                'stem(t1, x1, ''r'', ''MarkerSize'', 4);'
                'title(sprintf(''Fs = %d Hz (满足采样定理)'', Fs1));'
                'grid on;'
                ''
                'subplot(2,1,2);'
                'plot(t_cont, x_cont, ''b'', ''LineWidth'', 1);'
                'hold on;'
                'stem(t2, x2, ''r'', ''MarkerSize'', 4);'
                'title(sprintf(''Fs = %d Hz (不满足采样定理)'', Fs2));'
                'grid on;'
                ''
                'fprintf(''\\n实验完成!\\n'');'
            };

            code_str = strjoin(code, '\n');

            filename = 'signal_experiment_template.m';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', code_str);
            fclose(fid);

            fprintf('✅ 模板已生成: %s\n', filename);
        end

        function state_space()
        %STATE_SPACE 状态空间设计模板
        %
        %   eutils.templates.state_space()

            fprintf('📝 生成状态空间设计模板...\n');

            code = { ...
                '%% 状态空间控制器设计实验'
                '% 本脚本演示极点配置和状态观测器设计'
                ''
                'clear; clc; close all;'
                ''
                '%% 1. 系统定义'
                '% 倒立摆模型'
                'M = 0.5;   % 小车质量 (kg)'
                'm = 0.2;   % 摆杆质量 (kg)'
                'l = 0.3;   % 摆杆长度 (m)'
                'g = 9.81;  % 重力加速度 (m/s²)'
                ''
                '% 状态空间模型'
                'A = [0 1 0 0;'
                '     0 0 -m*g/M 0;'
                '     0 0 0 1;'
                '     0 0 (M+m)*g/(M*l) 0];'
                'B = [0; 1/M; 0; -1/(M*l)];'
                'C = [1 0 0 0;'
                '     0 0 1 0];'
                'D = [0; 0];'
                ''
                'sys = ss(A, B, C, D);'
                ''
                '%% 2. 开环系统分析'
                'fprintf(''开环极点:\\n'');'
                'disp(eig(A));'
                ''
                'figure(''Name'', ''开环响应'');'
                'step(sys);'
                'title(''开环阶跃响应'');'
                'grid on;'
                ''
                '%% 3. 极点配置'
                '% 期望极点'
                'desired_poles = [-2+1i, -2-1i, -10, -12];'
                ''
                '% 计算状态反馈增益'
                'K = place(A, B, desired_poles);'
                'fprintf(''状态反馈增益 K:\\n'');'
                'disp(K);'
                ''
                '% 闭环系统'
                'A_cl = A - B*K;'
                'sys_cl = ss(A_cl, B, C, D);'
                ''
                'figure(''Name'', ''闭环响应'');'
                'step(sys_cl);'
                'title(''闭环阶跃响应 (极点配置)'');'
                'grid on;'
                ''
                '%% 4. 状态观测器设计'
                '% 观测器极点（比控制器极点快 2-3 倍）'
                'observer_poles = [-10+2i, -10-2i, -20, -25];'
                ''
                '% 计算观测器增益'
                'L = place(A'', C'', observer_poles)'';'
                'fprintf(''观测器增益 L:\\n'');'
                'disp(L);'
                ''
                '%% 5. 带观测器的闭环系统'
                'A_aug = [A-B*K, B*K;'
                '         zeros(4), A-L*C];'
                'B_aug = [B; zeros(4,1)];'
                'C_aug = [C, zeros(2,4)];'
                ''
                'sys_aug = ss(A_aug, B_aug, C_aug, D);'
                ''
                'figure(''Name'', ''带观测器的响应'');'
                'step(sys_aug);'
                'title(''带状态观测器的闭环响应'');'
                'grid on;'
                ''
                'fprintf(''\\n实验完成!\\n'');'
            };

            code_str = strjoin(code, '\n');

            filename = 'state_space_template.m';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', code_str);
            fclose(fid);

            fprintf('✅ 模板已生成: %s\n', filename);
        end

        function power_electronics()
        %POWER_ELECTRONICS 电力电子仿真模板
        %
        %   eutils.templates.power_electronics()

            fprintf('📝 生成电力电子仿真模板...\n');

            code = { ...
                '%% 电力电子仿真实验'
                '% 本脚本演示 Buck 变换器的设计与仿真'
                ''
                'clear; clc; close all;'
                ''
                '%% 1. Buck 变换器参数'
                'Vin = 24;          % 输入电压 (V)'
                'Vout = 12;         % 输出电压 (V)'
                'fsw = 100e3;       % 开关频率 (Hz)'
                'L = 100e-6;        % 电感 (H)'
                'C = 100e-6;        % 电容 (F)'
                'R = 10;            % 负载电阻 (Ω)'
                'Iout = Vout/R;     % 输出电流 (A)'
                ''
                '%% 2. 设计计算'
                'buck_info = ecalculator.power.buck_converter(Vin, Vout, fsw, L, C, Iout);'
                ''
                '%% 3. 传递函数模型'
                '% Buck 变换器小信号模型'
                'D = Vout/Vin;      % 占空比'
                'num = Vin * [1];'
                'den = [L*C, L/R, 1];'
                'plant = tf(num, den);'
                ''
                '%% 4. 补偿器设计'
                '% 电压模式控制'
                'pid_info = ecalculator.control.pid_tune(num, den, ''ziegler-nichols'');'
                ''
                'Kp = pid_info.Kp;'
                'Ki = pid_info.Ki;'
                'Kd = pid_info.Kd;'
                ''
                'C_comp = pid(Kp, Ki, Kd);'
                'sys_closed = feedback(C_comp * plant, 1);'
                ''
                '%% 5. 仿真结果'
                'figure(''Name'', ''Buck 变换器响应'');'
                'step(sys_closed * Vout);'
                'title(''Buck 变换器闭环响应'');'
                'xlabel(''时间 (s)'');'
                'ylabel(''输出电压 (V)'');'
                'grid on;'
                ''
                '%% 6. 负载突变仿真'
                'figure(''Name'', ''负载突变响应'');'
                't = 0:1e-5:5e-3;'
                'u = ones(size(t));'
                'u(t > 2e-3) = 0.5;  % 负载突变'
                'lsim(sys_closed * Vout, u, t);'
                'title(''负载突变响应'');'
                'xlabel(''时间 (s)'');'
                'ylabel(''输出电压 (V)'');'
                'grid on;'
                ''
                'fprintf(''\\n实验完成!\\n'');'
            };

            code_str = strjoin(code, '\n');

            filename = 'power_electronics_template.m';
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', code_str);
            fclose(fid);

            fprintf('✅ 模板已生成: %s\n', filename);
        end
    end
end
