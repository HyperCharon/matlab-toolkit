classdef sysid
%ECALCULATOR.SYSID 系统辨识工程计算器
%
%   ecalculator.sysid.estimate(u, y, Fs)              从实验数据估计传递函数
%   ecalculator.sysid.compare_sim_exp(sim, exp, Fs)    仿真与实验对比
%   ecalculator.sysid.model_order(u, y, Fs, max_order) 模型阶次选择
%   ecalculator.sysid.step_response_id(y, Fs)           阶跃响应辨识
%
%   See also ecalculator.control, ecalculator.vibration

    methods(Static)
        function info = estimate(u, y, Fs, varargin)
        %ESTIMATE 从输入输出数据估计传递函数
        %
        %   info = ecalculator.sysid.estimate(u, y, 10000)
        %   info = ecalculator.sysid.estimate(u, y, 10000, 'order', 3)

            opts = struct('order', [], 'method', 'etfe', 'delay', false, 'plot', true);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            u = u(:);
            y = y(:);
            N = min(numel(u), numel(y));
            u = u(1:N);
            y = y(1:N);

            % 创建 iddata 对象
            Ts = 1/Fs;
            data = iddata(y, u, Ts);

            % 自动选择阶次
            if isempty(opts.order)
                opts.order = select_order(data, 5);
                fprintf('   自动选择阶次: %d\n', opts.order);
            end

            % 辨识
            switch lower(opts.method)
                case 'arx'
                    model = arx(data, [opts.order opts.order 1]);
                    model_name = 'ARX';

                case 'oe'
                    model = oe(data, [opts.order opts.order 1]);
                    model_name = 'OE (输出误差)';

                case 'tf'
                    model = tfest(data, opts.order);
                    model_name = '传递函数';

                case 'ss'
                    model = ssest(data, opts.order);
                    model_name = '状态空间';

                case 'etfe'
                    % 经验传递函数估计
                    model = etfe(data);
                    model_name = 'ETFE';

                otherwise
                    error('ecalculator:sysid:unknownMethod', '未知方法: %s', opts.method);
            end

            % 拟合度评估
            [y_sim, fit] = compare(data, model);

            fprintf('📊 系统辨识结果:\n');
            fprintf('   方法:     %s\n', model_name);
            fprintf('   模型阶次: %d\n', opts.order);
            fprintf('   拟合度:   %.2f%%\n', fit);

            % 获取传递函数参数
            [num, den] = tfdata(model, 'v');
            fprintf('   传递函数: ');
            fprintf('num = %s\n', mat2str(num));
            fprintf('             den = %s\n', mat2str(den));

            % 绘图
            if opts.plot
                fig = figure('Name', 'System Identification');

                % 时域对比
                subplot(2,1,1);
                t = (0:N-1) / Fs;
                plot(t, y, 'b-', 'LineWidth', 1, 'DisplayName', '实验数据');
                hold on;
                plot(t, y_sim.OutputData, 'r--', 'LineWidth', 1.5, 'DisplayName', '模型输出');
                xlabel('Time (s)');
                ylabel('Output');
                title(sprintf('拟合度: %.2f%%', fit));
                legend('Location', 'best');
                grid on;

                % 频率响应
                subplot(2,1,2);
                [mag, phase, w] = bode(model);
                mag = squeeze(mag);
                phase = squeeze(phase);
                semilogx(w, 20*log10(mag), 'b-', 'LineWidth', 1.5);
                xlabel('Frequency (rad/s)');
                ylabel('Magnitude (dB)');
                title('估计的频率响应');
                grid on;
            end

            info.model = model;
            info.num = num;
            info.den = den;
            info.fit = fit;
            info.method = model_name;
            info.order = opts.order;
        end

        function info = compare_sim_exp(sim_data, exp_data, Fs, varargin)
        %COMPARE_SIM_EXP 仿真数据与实验数据对比
        %
        %   info = ecalculator.sysid.compare_sim_exp(sim_y, exp_y, 10000)

            opts = struct('align', true, 'normalize', true, 'plot', true);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            sim_data = sim_data(:);
            exp_data = exp_data(:);

            % 对齐
            if opts.align
                [sim_data, exp_data] = align_signals(sim_data, exp_data);
            end

            N = min(numel(sim_data), numel(exp_data));
            sim_data = sim_data(1:N);
            exp_data = exp_data(1:N);

            % 归一化
            if opts.normalize
                sim_data = sim_data / max(abs(sim_data));
                exp_data = exp_data / max(abs(exp_data));
            end

            % 计算误差指标
            error_signal = exp_data - sim_data;
            rmse_val = rms(error_signal);
            mae_val = mean(abs(error_signal));
            max_error = max(abs(error_signal));

            % 相关系数
            R = corrcoef(sim_data, exp_data);
            correlation = R(1,2);

            % 拟合度
            fit = 100 * (1 - norm(exp_data - sim_data) / norm(exp_data - mean(exp_data)));

            fprintf('📊 仿真 vs 实验对比:\n');
            fprintf('   数据长度: %d 点\n', N);
            fprintf('   RMSE:     %.6f\n', rmse_val);
            fprintf('   MAE:      %.6f\n', mae_val);
            fprintf('   最大误差: %.6f\n', max_error);
            fprintf('   相关系数: %.4f\n', correlation);
            fprintf('   拟合度:   %.2f%%\n', fit);

            if fit > 90
                fprintf('   ✅ 拟合度优秀\n');
            elseif fit > 70
                fprintf('   ⚠️  拟合度一般，建议检查模型参数\n');
            else
                fprintf('   ❌ 拟合度较差，需要重新辨识\n');
            end

            % 绘图
            if opts.plot
                fig = figure('Name', 'Simulation vs Experiment');
                t = (0:N-1) / Fs;

                subplot(3,1,1);
                plot(t, exp_data, 'b-', 'LineWidth', 1, 'DisplayName', '实验');
                hold on;
                plot(t, sim_data, 'r--', 'LineWidth', 1.5, 'DisplayName', '仿真');
                xlabel('Time (s)');
                ylabel('Amplitude');
                title(sprintf('仿真 vs 实验 (拟合度: %.2f%%)', fit));
                legend('Location', 'best');
                grid on;

                subplot(3,1,2);
                plot(t, error_signal, 'k-', 'LineWidth', 1);
                xlabel('Time (s)');
                ylabel('Error');
                title('误差信号');
                grid on;

                subplot(3,1,3);
                histogram(error_signal, 50, 'FaceAlpha', 0.7);
                xlabel('Error');
                ylabel('Count');
                title('误差分布');
                grid on;
            end

            info.rmse = rmse_val;
            info.mae = mae_val;
            info.max_error = max_error;
            info.correlation = correlation;
            info.fit = fit;
            info.error_signal = error_signal;
        end

        function info = step_response_id(y, Fs, varargin)
        %STEP_RESPONSE_ID 从阶跃响应数据辨识一阶/二阶系统
        %
        %   info = ecalculator.sysid.step_response_id(y, 10000)

            opts = struct('order', 'auto', 'plot', true);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            y = y(:);
            N = numel(y);
            t = (0:N-1) / Fs;

            % 归一化
            y_norm = y / y(end);
            y_final = y(end);

            % 找到阶跃响应参数
            % 上升时间 (10% - 90%)
            idx_10 = find(y_norm >= 0.1, 1);
            idx_90 = find(y_norm >= 0.9, 1);
            t_rise = t(idx_90) - t(idx_10);

            % 超调量
            peak = max(y_norm);
            overshoot = max(0, (peak - 1) * 100);

            % 调节时间 (2%)
            idx_settle = find(abs(y_norm - 1) > 0.02, 1, 'last');
            if ~isempty(idx_settle)
                t_settle = t(idx_settle);
            else
                t_settle = 0;
            end

            % 自动选择模型阶次
            if strcmp(opts.order, 'auto')
                if overshoot < 1
                    % 一阶系统
                    opts.order = 1;
                else
                    % 二阶系统
                    opts.order = 2;
                end
            end

            switch opts.order
                case 1
                    % 一阶系统: G(s) = K / (τs + 1)
                    % 用 63.2% 点估计时间常数
                    idx_63 = find(y_norm >= 0.632, 1);
                    tau = t(idx_63);
                    K = y_final;

                    num = K;
                    den = [tau 1];
                    model_name = '一阶系统';

                    fprintf('📊 阶跃响应辨识 (%s):\n', model_name);
                    fprintf('   增益 K:   %.4f\n', K);
                    fprintf('   时间常数 τ: %.4f s\n', tau);
                    fprintf('   带宽:     %.2f Hz\n', 1/(2*pi*tau));

                case 2
                    % 二阶系统: G(s) = K·ωn² / (s² + 2ζωn·s + ωn²)
                    if overshoot > 0
                        % 欠阻尼
                        zeta = sqrt(log(overshoot/100)^2 / (pi^2 + log(overshoot/100)^2));
                        omega_n = pi / (t_rise * sqrt(1 - zeta^2));
                    else
                        % 过阻尼或临界阻尼
                        zeta = 1;
                        omega_n = 4 / t_settle;
                    end

                    K = y_final;
                    num = K * omega_n^2;
                    den = [1 2*zeta*omega_n omega_n^2];
                    model_name = '二阶系统';

                    fprintf('📊 阶跃响应辨识 (%s):\n', model_name);
                    fprintf('   增益 K:   %.4f\n', K);
                    fprintf('   固有频率 ωn: %.4f rad/s (%.2f Hz)\n', omega_n, omega_n/(2*pi));
                    fprintf('   阻尼比 ζ: %.4f\n', zeta);
            end

            % 绘图
            if opts.plot
                fig = figure('Name', 'Step Response Identification');

                sys = tf(num, den);
                [y_model, t_model] = step(sys, t);

                plot(t, y, 'b-', 'LineWidth', 1, 'DisplayName', '实验数据');
                hold on;
                plot(t_model, y_model, 'r--', 'LineWidth', 1.5, 'DisplayName', '辨识模型');
                xlabel('Time (s)');
                ylabel('Amplitude');
                title(sprintf('阶跃响应辨识: %s', model_name));
                legend('Location', 'best');
                grid on;
            end

            info.num = num;
            info.den = den;
            info.order = opts.order;
            info.model_name = model_name;
            info.overshoot = overshoot;
            info.t_rise = t_rise;
            info.t_settle = t_settle;
        end
    end
end

function order = select_order(data, max_order)
    % 简单的阶次选择：基于拟合度
    best_fit = -Inf;
    order = 1;

    for n = 1:max_order
        try
            model = arx(data, [n n 1]);
            [~, fit] = compare(data, model);
            if fit > best_fit
                best_fit = fit;
                order = n;
            end
        catch
            continue;
        end
    end
end

function [sig1_aligned, sig2_aligned] = align_signals(sig1, sig2)
    % 使用互相关对齐两个信号
    N = min(numel(sig1), numel(sig2));
    sig1 = sig1(1:N);
    sig2 = sig2(1:N);

    [c, lags] = xcorr(sig1, sig2);
    [~, idx] = max(c);
    delay = lags(idx);

    if delay > 0
        sig1_aligned = sig1(delay+1:end);
        sig2_aligned = sig2(1:end-delay);
    elseif delay < 0
        sig1_aligned = sig1(1:end+delay);
        sig2_aligned = sig2(-delay+1:end);
    else
        sig1_aligned = sig1;
        sig2_aligned = sig2;
    end
end
