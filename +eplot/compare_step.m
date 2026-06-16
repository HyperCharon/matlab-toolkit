function fig = compare_step(systems, varargin)
%EPLOT.COMPARE_STEP 多系统阶跃响应对比图
%
%   eplot.compare_step({sys1, sys2, sys3})
%   eplot.compare_step({sys1, sys2}, 'labels', {'PID', 'LQR'})
%   eplot.compare_step({sys1, sys2}, 'style', 'ieee', 'metrics', true)
%
%   输入:
%     systems - tf/ss/zpk 对象的 cell array
%
%   可选参数:
%     'labels'   - 系统名称列表
%     'style'    - eplot 样式预设
%     'metrics'  - 是否标注性能指标 (默认 true)
%     't'        - 仿真时间向量
%     'title'    - 图表标题
%
%   See also eplot.compare_bode, eplot.style

    arguments
        systems cell
    end
    arguments (Repeating)
        varargin
    end

    opts = struct('labels', {[]}, 'style', '', 'metrics', true, 't', [], 'title', 'Step Response Comparison');
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    n = numel(systems);

    % 默认标签
    if isempty(opts.labels)
        opts.labels = arrayfun(@(i) sprintf('System %d', i), 1:n, 'UniformOutput', false);
    end

    % 默认时间
    if isempty(opts.t)
        % 自动确定仿真时间
        all_poles = [];
        for i = 1:n
            p = pole(systems{i});
            all_poles = [all_poles; p(:)];
        end
        stable_poles = all_poles(real(all_poles) < 0);
        if ~isempty(stable_poles)
            slowest = min(abs(real(stable_poles)));
            t_end = max(10 / slowest, 5);
        else
            t_end = 10;
        end
        opts.t = linspace(0, t_end, 1000);
    end

    % 绘图
    fig = figure('Name', 'Step Response Comparison');

    % 颜色
    colors = get_default_colors(n);
    metrics_data = cell(n, 1);

    hold on;
    for i = 1:n
        [y, t] = step(systems{i}, opts.t);
        plot(t, y, 'Color', colors(i,:), 'LineWidth', 1.5, 'DisplayName', opts.labels{i});

        % 计算性能指标
        if opts.metrics
            try
                info = stepinfo(systems{i});
                metrics_data{i} = info;
            catch
                metrics_data{i} = [];
            end
        end
    end

    % 参考线
    yline(1, 'k--', 'LineWidth', 0.5, 'HandleVisibility', 'off');

    % 标注指标
    if opts.metrics
        y_offset = 0;
        for i = 1:n
            if ~isempty(metrics_data{i})
                info = metrics_data{i};
                text_str = sprintf('%s: OS=%.1f%%, Ts=%.2fs', ...
                    opts.labels{i}, info.Overshoot, info.SettlingTime);
                text(0.02, 0.98 - y_offset, text_str, ...
                    'Units', 'normalized', 'FontSize', 8, ...
                    'Color', colors(i,:), 'VerticalAlignment', 'top');
                y_offset = y_offset + 0.06;
            end
        end
    end

    xlabel('Time (s)');
    ylabel('Amplitude');
    title(opts.title);
    legend('Location', 'best');
    grid on;

    if ~isempty(opts.style)
        eplot.style(fig, opts.style);
    end
end
