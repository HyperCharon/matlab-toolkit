classdef control
%ECALCULATOR.CONTROL 控制系统工程计算器
%
%   ecalculator.control.bode_plot(num, den)          绘制波特图
%   ecalculator.control.step_response(num, den)      绘制阶跃响应
%   ecalculator.control.pid_tune(plant, method)      PID 自动整定
%   ecalculator.control.stability(num, den)          稳定性分析
%   ecalculator.control.root_locus(num, den)         根轨迹
%
%   示例:
%     % 绘制二阶系统波特图
%     ecalculator.control.bode_plot([1], [1 2 1]);
%
%     % PID 自动整定
%     ecalculator.control.pid_tune([1], [1 10 0], 'ziegler-nichols');
%
%   See also ecalculator.circuit, ecalculator.signal

    methods(Static)
        function varargout = bode_plot(num, den, varargin)
        %BODE_PLOT 绘制波特图并显示关键指标
        %
        %   ecalculator.control.bode_plot(num, den)
        %   ecalculator.control.bode_plot(num, den, 'w', logspace(-2,3,1000))
        %
        %   可选参数:
        %     'w'        - 频率范围 (rad/s)
        %     'title'    - 图表标题
        %     'style'    - eplot 样式预设

            opts = struct('w', [], 'title', 'Bode Plot', 'style', '');
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            sys = tf(num, den);

            if isempty(opts.w)
                w = logspace(-2, 3, 1000);
            else
                w = opts.w;
            end

            [mag, phase, wout] = bode(sys, w);
            mag = squeeze(mag);
            phase = squeeze(phase);

            % 计算关键指标
            [Gm, Pm, Wcg, Wcp] = margin(sys);

            % 绘图
            fig = figure('Name', 'Bode Plot');

            subplot(2,1,1);
            semilogx(wout, 20*log10(mag), 'b-', 'LineWidth', 1.5);
            hold on;
            yline(0, 'k--', 'LineWidth', 0.5);
            if isfinite(Gm)
                semilogx(Wcg, 0, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
                text(Wcg, 3, sprintf('G_m = %.1f dB', 20*log10(Gm)), ...
                    'FontSize', 9, 'Color', 'r');
            end
            ylabel('Magnitude (dB)');
            title(opts.title);
            grid on;

            subplot(2,1,2);
            semilogx(wout, phase, 'b-', 'LineWidth', 1.5);
            hold on;
            yline(-180, 'k--', 'LineWidth', 0.5);
            if isfinite(Pm)
                semilogx(Wcp, -180+Pm, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
                text(Wcp, -180+Pm+5, sprintf('P_m = %.1f°', Pm), ...
                    'FontSize', 9, 'Color', 'r');
            end
            xlabel('Frequency (rad/s)');
            ylabel('Phase (deg)');
            grid on;

            if ~isempty(opts.style)
                eplot.style(fig, opts.style);
            end

            % 打印关键指标
            fprintf('📊 Bode Plot 分析结果:\n');
            fprintf('   增益裕度: %.2f dB (at %.2f rad/s)\n', 20*log10(Gm), Wcg);
            fprintf('   相位裕度: %.2f° (at %.2f rad/s)\n', Pm, Wcp);

            if isfinite(Gm) && Gm > 1 && isfinite(Pm) && Pm > 30
                fprintf('   ✅ 系统稳定\n');
            elseif isfinite(Gm) && isfinite(Pm)
                fprintf('   ⚠️  裕度不足，建议调整参数\n');
            else
                fprintf('   ❌ 系统不稳定\n');
            end

            if nargout > 0
                info.Gm_dB = 20*log10(Gm);
                info.Pm = Pm;
                info.Wcg = Wcg;
                info.Wcp = Wcp;
                info.stable = isfinite(Gm) && Gm > 1 && isfinite(Pm) && Pm > 30;
                varargout{1} = info;
            end
        end

        function varargout = step_response(num, den, varargin)
        %STEP_RESPONSE 绘制阶跃响应并显示性能指标
        %
        %   ecalculator.control.step_response(num, den)
        %   ecalculator.control.step_response(num, den, 't', 0:0.01:10)

            opts = struct('t', [], 'title', 'Step Response', 'style', '');
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            sys = tf(num, den);

            if isempty(opts.t)
                [y, t] = step(sys);
            else
                [y, t] = step(sys, opts.t);
            end

            % 计算性能指标
            info = stepinfo(sys);

            % 绘图
            fig = figure('Name', 'Step Response');
            plot(t, y, 'b-', 'LineWidth', 1.5);
            hold on;
            yline(1, 'k--', 'LineWidth', 0.5);

            % 标注关键点
            if isfinite(info.SettlingTime)
                xline(info.SettlingTime, 'g--', 'LineWidth', 1);
                text(info.SettlingTime, 0.5, sprintf('T_s = %.3f s', info.SettlingTime), ...
                    'FontSize', 9, 'Color', 'g');
            end
            if isfinite(info.Overshoot) && info.Overshoot > 0
                peak_val = 1 + info.Overshoot/100;
                plot(info.PeakTime, peak_val, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
                text(info.PeakTime, peak_val+0.02, sprintf('OS = %.1f%%', info.Overshoot), ...
                    'FontSize', 9, 'Color', 'r');
            end

            xlabel('Time (s)');
            ylabel('Amplitude');
            title(opts.title);
            grid on;

            if ~isempty(opts.style)
                eplot.style(fig, opts.style);
            end

            % 打印性能指标
            fprintf('📊 阶跃响应性能指标:\n');
            fprintf('   上升时间: %.4f s\n', info.RiseTime);
            fprintf('   峰值时间: %.4f s\n', info.PeakTime);
            fprintf('   超调量:   %.2f%%\n', info.Overshoot);
            fprintf('   调节时间: %.4f s\n', info.SettlingTime);
            fprintf('   稳态值:   %.4f\n', y(end));

            if nargout > 0
                varargout{1} = info;
            end
        end

        function info = pid_tune(plant_num, plant_den, method, varargin)
        %PID_TUNE PID 自动整定
        %
        %   info = ecalculator.control.pid_tune([1], [1 10 0])
        %   info = ecalculator.control.pid_tune([1], [1 10 0], 'ziegler-nichols')
        %
        %   支持的整定方法:
        %     'ziegler-nichols'  - Ziegler-Nichols 临界比例法
        %     'cohen-coon'       - Cohen-Coon 方法
        %     'imc'              - 内模控制法
        %     'lambda'           - Lambda 整定法

            opts = struct('show_plot', true, 'lambda', 1);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            if nargin < 3 || isempty(method)
                method = 'ziegler-nichols';
            end

            plant = tf(plant_num, plant_den);

            % 获取系统特性
            [dc_gain, ~] = dcgain(plant);
            poles = pole(plant);
            real_poles = real(poles(poles == real(poles)));

            % 简化的整定方法
            switch lower(method)
                case 'ziegler-nichols'
                    % 临界比例法
                    % 需要找到使系统临界稳定的 Ku 和 Tu
                    Ku = find_ultimate_gain(plant);
                    Tu = find_ultimate_period(plant);

                    info.Kp = 0.6 * Ku;
                    info.Ki = 2 * info.Kp / Tu;
                    info.Kd = info.Kp * Tu / 8;

                case 'cohen-coon'
                    % Cohen-Coon 方法
                    [K, L, T] = identify_fopdt(plant);
                    info.Kp = (1/(K*L/T)) * (1 + L/(3*T));
                    info.Ki = info.Kp / (L * (30 + 3*L/T) / (9 + 20*L/T));
                    info.Kd = info.Kp * L * (4/(11 + 2*L/T));

                case 'imc'
                    % 内模控制法
                    lambda = opts.lambda;
                    [K, L, T] = identify_fopdt(plant);
                    info.Kp = (2*T + L) / (2*K*lambda);
                    info.Ki = info.Kp / (T + L/2);
                    info.Kd = info.Kp * T*L / (2*T + L);

                case 'lambda'
                    % Lambda 整定法
                    lambda = opts.lambda;
                    [K, L, T] = identify_fopdt(plant);
                    info.Kp = T / (K * (lambda + L));
                    info.Ki = info.Kp / T;
                    info.Kd = 0;

                otherwise
                    error('ecalculator:control:unknownMethod', ...
                        '未知整定方法: %s', method);
            end

            info.method = method;

            % 打印结果
            fprintf('🎛️  PID 参数整定结果 (%s):\n', method);
            fprintf('   Kp = %.4f\n', info.Kp);
            fprintf('   Ki = %.4f\n', info.Ki);
            fprintf('   Kd = %.4f\n', info.Kd);
            fprintf('   传递函数: C(s) = %.4f + %.4f/s + %.4f*s\n', ...
                info.Kp, info.Ki, info.Kd);

            % 绘制对比图
            if opts.show_plot
                C = pid(info.Kp, info.Ki, info.Kd);
                sys_open = C * plant;
                sys_closed = feedback(sys_open, 1);

                fig = figure('Name', 'PID Tuning Result');
                step(sys_closed);
                hold on;
                step(feedback(plant, 1));
                legend('With PID', 'Without PID', 'Location', 'best');
                title(sprintf('PID Tuning: %s', method));
                grid on;
            end
        end

        function info = stability(num, den)
        %STABILITY 稳定性分析
        %
        %   ecalculator.control.stability([1], [1 2 1])

            sys = tf(num, den);
            poles = pole(sys);

            fprintf('📊 稳定性分析:\n');
            fprintf('   极点:\n');
            for i = 1:numel(poles)
                if imag(poles(i)) == 0
                    fprintf('     p%d = %.4f\n', i, real(poles(i)));
                else
                    fprintf('     p%d = %.4f + %.4fj\n', i, real(poles(i)), imag(poles(i)));
                end
            end

            unstable = any(real(poles) > 0);
            marginally = any(abs(real(poles)) < 1e-10);

            if unstable
                fprintf('   ❌ 系统不稳定 (存在右半平面极点)\n');
            elseif marginally
                fprintf('   ⚠️  系统临界稳定 (存在虚轴上极点)\n');
            else
                fprintf('   ✅ 系统稳定 (所有极点在左半平面)\n');
            end

            % 劳斯判据
            fprintf('\n   劳斯表:\n');
            routh_table = routh_array(den);
            disp(routh_table);

            info.poles = poles;
            info.stable = ~unstable;
            info.routh_table = routh_table;
        end

        function root_locus(num, den)
        %ROOT_LOCUS 绘制根轨迹
        %
        %   ecalculator.control.root_locus([1], [1 2 1])

            sys = tf(num, den);
            figure('Name', 'Root Locus');
            rlocus(sys);
            title('Root Locus');
            grid on;
        end
    end
end

function Ku = find_ultimate_gain(plant)
    % 简化的临界增益查找
    Ku = 1;
    for k = logspace(-2, 4, 1000)
        sys_cl = feedback(k * plant, 1);
        poles = pole(sys_cl);
        if any(abs(real(poles)) < 1e-6 & imag(poles) > 0)
            Ku = k;
            break;
        end
    end
end

function Tu = find_ultimate_period(plant)
    % 简化的临界周期查找
    Ku = find_ultimate_gain(plant);
    sys_cl = feedback(Ku * plant, 1);
    poles = pole(sys_cl);
    osc_poles = poles(abs(real(poles)) < 1e-6 & imag(poles) > 0);
    if ~isempty(osc_poles)
        Tu = 2*pi / abs(imag(osc_poles(1)));
    else
        Tu = 1;  % 默认值
    end
end

function [K, L, T] = identify_fopdt(plant)
    % 识别一阶加延迟模型
    [y, t] = step(plant);
    y = y / y(end);  % 归一化

    % 找到 63.2% 点
    idx_63 = find(y >= 0.632, 1);
    T = t(idx_63);

    % 找到切线与时间轴的交点作为延迟
    dy = gradient(y, t);
    [~, max_idx] = max(dy);
    L = t(max_idx) - y(max_idx) / dy(max_idx);
    if L < 0, L = 0; end

    K = y(end);
end

function table = routh_array(coeffs)
    % 计算劳斯表
    n = numel(coeffs);
    m = ceil(n/2);

    table = zeros(n, m);

    % 前两行
    row1_idx = 1:2:n;
    row2_idx = 2:2:n;

    for i = 1:numel(row1_idx)
        if row1_idx(i) <= n
            table(1, i) = coeffs(row1_idx(i));
        end
    end
    for i = 1:numel(row2_idx)
        if row2_idx(i) <= n
            table(2, i) = coeffs(row2_idx(i));
        end
    end

    % 后续行
    for i = 3:n
        for j = 1:m-1
            if table(i-1, 1) == 0
                table(i-1, 1) = 1e-10;  % 避免除零
            end
            table(i, j) = (table(i-1, 1)*table(i-2, j+1) - table(i-2, 1)*table(i-1, j+1)) / table(i-1, 1);
        end
    end
end
