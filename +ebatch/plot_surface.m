function plot_surface(results, x_param, y_param, metric, varargin)
%EBATCH.PLOT_SURFACE 绘制 3D 响应曲面
%
%   ebatch.plot_surface(results, 'Kp', 'Ki', 'overshoot')
%   ebatch.plot_surface(results, 'Kp', 'Ki', 'overshoot', 'style', 'ieee')
%
%   See also ebatch.sweep, ebatch.plot_heatmap, ebatch.export_report

    opts = struct('style', '', 'colormap', 'parula', 'view', [30 30], 'contour', false);
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    % 获取参数索引
    x_idx = find(strcmp(results.param_names, x_param));
    y_idx = find(strcmp(results.param_names, y_param));

    if isempty(x_idx) || isempty(y_idx)
        error('ebatch:plot_surface:paramNotFound', '参数名不存在');
    end

    % 获取数据
    x_vals = results.param_values{x_idx};
    y_vals = results.param_values{y_idx};
    z_data = results.data.(metric);

    % 创建网格
    [X, Y] = ndgrid(x_vals, y_vals);

    % 绘图
    fig = figure('Name', sprintf('%s Response Surface', metric));

    if opts.contour
        % 等高线图
        contourf(X, Y, z_data, 20, 'LineWidth', 0.5);
        colorbar;
        colormap(opts.colormap);
    else
        % 3D 曲面
        surf(X, Y, z_data, 'EdgeColor', 'none', 'FaceAlpha', 0.9);
        colorbar;
        colormap(opts.colormap);
        view(opts.view);
        lighting gouraud;
        camlight;
    end

    xlabel(x_param, 'FontSize', 12);
    ylabel(y_param, 'FontSize', 12);
    zlabel(metric, 'FontSize', 12);
    title(sprintf('%s vs %s & %s', metric, x_param, y_param), 'FontSize', 14);
    grid on;

    % 找到最优点
    [min_val, min_idx] = min(z_data(:));
    [row, col] = ind2sub(size(z_data), min_idx);
    optimal_x = x_vals(row);
    optimal_y = y_vals(col);

    hold on;
    if ~opts.contour
        plot3(optimal_x, optimal_y, min_val, 'r*', 'MarkerSize', 15, 'LineWidth', 2);
    else
        plot(optimal_x, optimal_y, 'r*', 'MarkerSize', 15, 'LineWidth', 2);
    end

    fprintf('📊 响应曲面分析:\n');
    fprintf('   最优 %s: %.4f @ %s=%.4f, %s=%.4f\n', ...
        metric, min_val, x_param, optimal_x, y_param, optimal_y);

    % 应用样式
    if ~isempty(opts.style)
        eplot.style(fig, opts.style);
    end
end
