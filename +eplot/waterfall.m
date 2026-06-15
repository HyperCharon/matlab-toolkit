function fig = waterfall(x, y, z, varargin)
%EPLOT.WATERFALL 瀑布图（频响随参数变化）
%
%   eplot.waterfall(w, params, mag_data)
%   eplot.waterfall(freqs, temps, responses, 'xlabel', 'Frequency (Hz)')
%
%   典型用途：不同温度/频率/参数下的频率响应对比
%
%   See also eplot.style, eplot.surface

    opts = struct('style', '', 'colormap', 'jet', 'xlabel', 'X', ...
                  'ylabel', 'Y', 'zlabel', 'Z', 'title', 'Waterfall Plot', ...
                  'view', [-37.5 30], 'alpha', 0.8);
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    fig = figure('Name', 'Waterfall Plot');

    % 绘制瀑布图
    n_lines = size(z, 1);
    cmap = colormap(opts.colormap);
    color_idx = round(linspace(1, size(cmap, 1), n_lines));

    hold on;
    for i = 1:n_lines
        if nargin >= 3 && ismatrix(z)
            % z 是矩阵，每行是一条曲线
            plot3(x, y(i)*ones(size(x)), z(i,:), ...
                'Color', [cmap(color_idx(i), :) opts.alpha], ...
                'LineWidth', 1.5);
        else
            plot3(x, y(i)*ones(size(x)), z(i,:), ...
                'Color', [cmap(color_idx(i), :) opts.alpha], ...
                'LineWidth', 1.5);
        end
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
