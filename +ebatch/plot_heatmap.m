function plot_heatmap(results, x_param, y_param, metric, varargin)
%EBATCH.PLOT_HEATMAP 绘制热力图
%
%   ebatch.plot_heatmap(results, 'Kp', 'Ki', 'overshoot')
%   ebatch.plot_heatmap(results, 'Kp', 'Ki', 'overshoot', 'style', 'ieee')
%
%   See also ebatch.sweep, ebatch.plot_surface, ebatch.export_report

    opts = struct('style', '', 'colormap', 'hot', 'annotate', true, 'colorbar_label', '');
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    % 获取参数索引
    x_idx = find(strcmp(results.param_names, x_param));
    y_idx = find(strcmp(results.param_names, y_param));

    if isempty(x_idx) || isempty(y_idx)
        error('ebatch:plot_heatmap:paramNotFound', '参数名不存在');
    end

    % 获取数据
    x_vals = results.param_values{x_idx};
    y_vals = results.param_values{y_idx};
    z_data = results.data.(metric);

    % 绘图
    fig = figure('Name', sprintf('%s Heatmap', metric));

    imagesc(x_vals, y_vals, z_data');
    colorbar;
    colormap(opts.colormap);
    set(gca, 'YDir', 'normal');

    xlabel(x_param, 'FontSize', 12);
    ylabel(y_param, 'FontSize', 12);
    title(sprintf('%s Heatmap', metric), 'FontSize', 14);

    % 添加数值标注
    if opts.annotate && numel(x_vals) <= 20 && numel(y_vals) <= 20
        for i = 1:numel(x_vals)
            for j = 1:numel(y_vals)
                val = z_data(i, j);
                if ~isnan(val)
                    text(x_vals(i), y_vals(j), sprintf('%.2f', val), ...
                        'HorizontalAlignment', 'center', ...
                        'FontSize', 8, ...
                        'Color', get_text_color(val, z_data));
                end
            end
        end
    end

    % 找到最优点
    [min_val, min_idx] = min(z_data(:));
    [row, col] = ind2sub(size(z_data), min_idx);
    optimal_x = x_vals(row);
    optimal_y = y_vals(col);

    hold on;
    plot(optimal_x, optimal_y, 'g*', 'MarkerSize', 15, 'LineWidth', 2);

    fprintf('📊 热力图分析:\n');
    fprintf('   最优 %s: %.4f @ %s=%.4f, %s=%.4f\n', ...
        metric, min_val, x_param, optimal_x, y_param, optimal_y);

    % 应用样式
    if ~isempty(opts.style)
        eplot.style(fig, opts.style);
    end
end

function color = get_text_color(val, data)
    % 根据背景色自动选择文字颜色
    normalized = (val - min(data(:))) / (max(data(:)) - min(data(:)) + eps);
    if normalized > 0.5
        color = 'w';
    else
        color = 'k';
    end
end
