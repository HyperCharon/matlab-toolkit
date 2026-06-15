function animate_step(sys, filename, varargin)
%EPLOT.ANIMATE_STEP 阶跃响应动画导出
%
%   eplot.animate_step(sys, 'step_response.gif')
%   eplot.animate_step(sys, 'step_response.gif', 't', 0:0.01:5)
%   eplot.animate_step({sys1, sys2}, 'compare.gif', 'labels', {'PID', 'LQR'})
%
%   See also eplot.animate, eplot.compare_step

    opts = struct('t', [], 'labels', {{}}, 'fps', 20, 'style', '');
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    % 处理多个系统
    if iscell(sys)
        systems = sys;
    else
        systems = {sys};
    end
    n_sys = numel(systems);

    % 默认标签
    if isempty(opts.labels)
        opts.labels = arrayfun(@(i) sprintf('System %d', i), 1:n_sys, 'UniformOutput', false);
    end

    % 默认时间
    if isempty(opts.t)
        % 自动确定仿真时间
        all_poles = [];
        for i = 1:n_sys
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
        opts.t = linspace(0, t_end, 200);
    end

    % 计算完整响应
    y_all = cell(n_sys, 1);
    for i = 1:n_sys
        y_all{i} = step(systems{i}, opts.t);
    end

    % 创建 figure
    fig = figure('Position', [100 100 800 500], 'Color', 'w');
    ax = axes(fig);
    hold(ax, 'on');

    colors = lines(n_sys);
    h_lines = gobjects(n_sys, 1);
    h_dots = gobjects(n_sys, 1);

    for i = 1:n_sys
        h_lines(i) = plot(ax, NaN, NaN, 'Color', colors(i,:), 'LineWidth', 1.5);
        h_dots(i) = plot(ax, NaN, NaN, 'o', 'Color', colors(i,:), ...
            'MarkerSize', 8, 'MarkerFaceColor', colors(i,:));
    end

    yline(ax, 1, 'k--', 'LineWidth', 0.5);
    xlabel(ax, 'Time (s)');
    ylabel(ax, 'Amplitude');
    title(ax, 'Step Response');
    legend(ax, opts.labels, 'Location', 'best');
    grid(ax, 'on');

    % 设置坐标范围
    y_max = max(cellfun(@(y) max(y), y_all)) * 1.2;
    xlim(ax, [opts.t(1) opts.t(end)]);
    ylim(ax, [0 y_max]);

    % 逐帧绘制
    n_frames = numel(opts.t);
    frame_step = max(1, floor(n_frames / 100));  % 最多 100 帧

    fprintf('🎬 生成阶跃响应动画...\n');

    for k = 1:frame_step:n_frames
        for i = 1:n_sys
            set(h_lines(i), 'XData', opts.t(1:k), 'YData', y_all{i}(1:k));
            set(h_dots(i), 'XData', opts.t(k), 'YData', y_all{i}(k));
        end
        title(ax, sprintf('Step Response (t = %.3f s)', opts.t(k)));
        drawnow;

        % 保存帧
        eplot.animate(fig, filename, 'frame');
    end

    % 完成动画
    eplot.animate(fig, filename, 'finish');

    close(fig);
end
