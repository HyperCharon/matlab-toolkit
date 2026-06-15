function colorscheme(fig, scheme)
%EPLOT.COLORSCHEME 应用配色方案
%
%   eplot.colorscheme('ieee')        应用 IEEE 推荐配色
%   eplot.colorscheme('nature')      应用 Nature 推荐配色
%   eplot.colorscheme('colorbrewer') 应用 ColorBrewer 配色
%   eplot.colorscheme('dark')        应用暗色主题配色
%   eplot.colorscheme(my_colors)     应用自定义颜色矩阵 (Nx3)
%
%   返回可用的配色方案列表:
%   schemes = eplot.colorscheme('list')
%
%   See also eplot.style, eplot.export

    arguments
        fig = gcf
        scheme = 'ieee'
    end

    % 处理第一个参数是 scheme 字符串的情况
    if ischar(fig) || isstring(fig)
        scheme = fig;
        fig = gcf;
    end

    % 如果请求列表
    if ischar(scheme) && strcmp(scheme, 'list')
        fig = get_available_schemes();
        return;
    end

    % 获取颜色矩阵
    colors = get_colors(scheme);

    % 获取所有 axes
    if isa(fig, 'matlab.ui.Figure')
        axes_list = findobj(fig, 'Type', 'axes', '-not', 'Type', 'legend', '-not', 'Type', 'colorbar');
    else
        axes_list = fig;
    end

    % 应用颜色
    for i = 1:numel(axes_list)
        ax = axes_list(i);
        lines = findobj(ax, 'Type', 'line');
        bars = findobj(ax, 'Type', 'bar');
        patches = findobj(ax, 'Type', 'patch');

        % 设置 axes 颜色顺序
        set(ax, 'ColorOrder', colors);

        % 对已有的 line 对象应用颜色
        for j = 1:numel(lines)
            color_idx = mod(j-1, size(colors, 1)) + 1;
            set(lines(j), 'Color', colors(color_idx, :));
        end

        % 对 bar 对象应用颜色
        for j = 1:numel(bars)
            color_idx = mod(j-1, size(colors, 1)) + 1;
            set(bars(j), 'FaceColor', colors(color_idx, :));
        end
    end
end

function colors = get_colors(scheme)
    if isnumeric(scheme) && size(scheme, 2) == 3
        colors = scheme;
        return;
    end

    switch lower(scheme)
        case 'ieee'
            % IEEE 推荐：高对比度，适合黑白打印
            colors = [
                0.00 0.00 0.00;  % 黑
                0.00 0.45 0.74;  % 蓝
                0.85 0.33 0.10;  % 红
                0.00 0.60 0.50;  % 青
                0.93 0.69 0.13;  % 黄
                0.49 0.18 0.56;  % 紫
                0.47 0.67 0.19;  % 绿
                0.30 0.30 0.30;  % 深灰
            ];

        case 'nature'
            % Nature 风格：柔和但清晰
            colors = [
                0.10 0.36 0.65;  % 深蓝
                0.77 0.15 0.15;  % 深红
                0.10 0.60 0.40;  % 深绿
                0.90 0.60 0.10;  % 橙
                0.55 0.25 0.65;  % 紫
                0.10 0.70 0.80;  % 天蓝
                0.80 0.40 0.60;  % 粉
                0.40 0.40 0.40;  % 灰
            ];

        case 'springer'
            % Springer 风格
            colors = [
                0.00 0.45 0.74;
                0.85 0.33 0.10;
                0.00 0.60 0.50;
                0.93 0.69 0.13;
                0.49 0.18 0.56;
                0.47 0.67 0.19;
                0.30 0.60 0.85;
                0.80 0.20 0.40;
            ];

        case 'thesis'
            % 学位论文：沉稳大方
            colors = [
                0.15 0.25 0.55;  % 深蓝
                0.70 0.15 0.15;  % 深红
                0.10 0.50 0.35;  % 深绿
                0.85 0.55 0.10;  % 橙
                0.45 0.20 0.55;  % 紫
                0.10 0.60 0.70;  % 青
                0.60 0.30 0.10;  % 棕
                0.35 0.35 0.35;  % 灰
            ];

        case 'beamer'
            % 演示文稿：鲜艳醒目
            colors = [
                0.00 0.45 0.74;
                0.85 0.33 0.10;
                0.00 0.60 0.50;
                0.93 0.69 0.13;
                0.49 0.18 0.56;
                0.47 0.67 0.19;
                0.80 0.40 0.60;
                0.00 0.75 0.90;
            ];

        case 'dark'
            % 暗色主题：在深色背景上清晰可见
            colors = [
                0.40 0.80 1.00;  % 亮蓝
                1.00 0.50 0.30;  % 亮红
                0.30 0.90 0.60;  % 亮绿
                1.00 0.85 0.30;  % 亮黄
                0.80 0.50 1.00;  % 亮紫
                0.50 1.00 0.90;  % 亮青
                1.00 0.60 0.70;  % 亮粉
                0.70 0.70 0.70;  % 浅灰
            ];

        case 'colorbrewer'
            % ColorBrewer Set2 - 适合分类数据
            colors = [
                0.40 0.76 0.65;
                0.99 0.55 0.38;
                0.55 0.63 0.80;
                0.91 0.54 0.76;
                0.65 0.85 0.33;
                1.00 0.85 0.18;
                0.90 0.77 0.58;
                0.70 0.70 0.70;
            ];

        case 'viridis'
            % Viridis - 感知均匀，适合热力图
            n = 256;
            colors = viridis_colormap(n);

        case 'parula'
            % MATLAB 默认 parula 的改进版
            n = 256;
            colors = parula(n);

        otherwise
            warning('eplot:colorscheme:unknown', '未知配色方案 "%s"，使用默认配色', scheme);
            colors = get_colors('ieee');
    end
end

function schemes = get_available_schemes()
    schemes = {'ieee', 'nature', 'springer', 'thesis', 'beamer', 'dark', 'colorbrewer', 'viridis', 'parula'};
end

function cmap = viridis_colormap(n)
    % 生成 Viridis 配色表
    if nargin < 1, n = 256; end
    % Viridis 关键点
    key_colors = [
        0.267004 0.004874 0.329415;
        0.282327 0.140926 0.457517;
        0.253935 0.265254 0.529983;
        0.206756 0.371758 0.553117;
        0.163625 0.471133 0.558148;
        0.127568 0.566949 0.550556;
        0.134692 0.658636 0.517649;
        0.266941 0.748751 0.440573;
        0.477504 0.821444 0.318195;
        0.741388 0.873449 0.149561;
        0.993248 0.906157 0.143936;
    ];
    x_keys = linspace(0, 1, size(key_colors, 1));
    x_query = linspace(0, 1, n);
    cmap = interp1(x_keys, key_colors, x_query, 'pchip');
    cmap = max(0, min(1, cmap));
end
