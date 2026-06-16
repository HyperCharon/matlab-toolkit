function fig = waterfall(x, y, z, varargin)
%EPLOT.WATERFALL 瀑布图（频响随参数变化）
%
%   eplot.waterfall(x, y, z)
%   eplot.waterfall(w, params, mag_data, 'xlabel', 'Frequency (Hz)')
%
%   输入:
%     x - 1D 向量，X 轴数据（如频率向量）
%     y - 1D 向量，参数值（如温度、时间等）
%     z - 2D 矩阵 [numel(y) x numel(x)]，每个参数对应的响应数据
%
%   典型用途：不同温度/频率/参数下的频率响应对比
%
%   可选参数:
%     'style'    - eplot 样式预设 (默认 '')
%     'colormap' - 配色方案名 (默认 'jet')
%     'xlabel'   - X 轴标签 (默认 'X')
%     'ylabel'   - Y 轴标签 (默认 'Y')
%     'zlabel'   - Z 轴标签 (默认 'Z')
%     'title'    - 图标题 (默认 'Waterfall Plot')
%     'view'     - 3D 视角 [azimuth, elevation] (默认 [-37.5 30])
%     'alpha'    - 线条透明度 0-1 (默认 0.8)
%
%   See also eplot.style, eplot.compare_bode

    opts = struct('style', '', 'colormap', 'jet', 'xlabel', 'X', ...
                  'ylabel', 'Y', 'zlabel', 'Z', 'title', 'Waterfall Plot', ...
                  'view', [-37.5 30], 'alpha', 0.8);
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    fig = figure('Name', 'Waterfall Plot');

    % 绘制瀑布图
    n_lines = size(z, 1);

    % 获取颜色映射
    cmap_func = str2func(opts.colormap);
    cmap = cmap_func(n_lines);

    hold on;
    for i = 1:n_lines
        plot3(x, y(i)*ones(size(x)), z(i,:), ...
            'Color', [cmap(i, :) opts.alpha], ...
            'LineWidth', 1.5);
    end

    xlabel(opts.xlabel);
    ylabel(opts.ylabel);
    zlabel(opts.zlabel);
    title(opts.title);
    view(opts.view);
    grid on;
    colormap(opts.colormap);
    cb = colorbar;
    ylabel(cb, opts.ylabel);

    if ~isempty(opts.style)
        eplot.style(fig, opts.style);
    end
end
