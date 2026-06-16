function export_tikz(fig, filename, varargin)
%EPLOT.EXPORT_TIKZ 导出为 LaTeX tikz 代码
%
%   eplot.export_tikz(gcf, 'figure.tex')
%   eplot.export_tikz(gcf, 'figure.tex', 'width', '\textwidth')
%   eplot.export_tikz('figure.tex')  % 使用当前 figure
%
%   依赖: matlab2tikz (可选，如果没有则生成简化版本)
%
%   See also eplot.export

    % 处理第一个参数是文件名的情况
    if ischar(fig) || isstring(fig)
        varargin = [{filename} varargin];
        filename = fig;
        fig = gcf;
    end

    opts = struct('width', '\textwidth', 'height', '', 'standalone', false);
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    % 检查是否有 matlab2tikz
    if exist('matlab2tikz', 'file')
        % 使用 matlab2tikz
        args = {'filename', filename, 'width', opts.width};
        if ~isempty(opts.height)
            args = [args, {'height', opts.height}];
        end
        matlab2tikz(args{:});
    else
        % 生成简化版 tikz 代码
        generate_simple_tikz(fig, filename, opts);
    end

    fprintf('✅ tikz 代码已导出: %s\n', filename);
end

function generate_simple_tikz(fig, filename, opts)
    fid = fopen(filename, 'w');
    if fid == -1
        error('eplot:export_tikz:fileOpen', '无法打开文件: %s', filename);
    end

    if opts.standalone
        fprintf(fid, '\\documentclass{standalone}\n');
        fprintf(fid, '\\usepackage{pgfplots}\n');
        fprintf(fid, '\\pgfplotsset{compat=1.18}\n');
        fprintf(fid, '\\begin{document}\n');
    end

    fprintf(fid, '%% eplot 导出的 tikz 代码\n');
    fprintf(fid, '%% 生成时间: %s\n\n', datestr(now));

    % 获取所有 axes
    axes_list = findobj(fig, 'Type', 'axes');

    for ax_idx = 1:numel(axes_list)
        ax = axes_list(ax_idx);

        fprintf(fid, '\\begin{tikzpicture}\n');
        fprintf(fid, '\\begin{axis}[\n');
        fprintf(fid, '  width=%s,\n', opts.width);
        if ~isempty(opts.height)
            fprintf(fid, '  height=%s,\n', opts.height);
        end
        fprintf(fid, '  xlabel={%s},\n', get(get(ax, 'XLabel'), 'String'));
        fprintf(fid, '  ylabel={%s},\n', get(get(ax, 'YLabel'), 'String'));
        fprintf(fid, '  title={%s},\n', get(get(ax, 'Title'), 'String'));
        fprintf(fid, '  grid=major,\n');
        fprintf(fid, '  legend style={at={(0.98,0.98)},anchor=north east},\n');

        % X/Y 范围
        xl = xlim(ax);
        yl = ylim(ax);
        fprintf(fid, '  xmin=%.4f, xmax=%.4f,\n', xl(1), xl(2));
        fprintf(fid, '  ymin=%.4f, ymax=%.4f,\n', yl(1), yl(2));

        % 是否对数坐标
        if strcmp(get(ax, 'XScale'), 'log')
            fprintf(fid, '  xmode=log,\n');
        end
        if strcmp(get(ax, 'YScale'), 'log')
            fprintf(fid, '  ymode=log,\n');
        end

        fprintf(fid, ']\n\n');

        % 导出每条线
        lines = findobj(ax, 'Type', 'line');
        for i = numel(lines):-1:1
            line = lines(i);
            x_data = get(line, 'XData');
            y_data = get(line, 'YData');
            color = get(line, 'Color');
            line_width = get(line, 'LineWidth');
            display_name = get(line, 'DisplayName');

            % 颜色
            color_str = sprintf('{rgb,255:red,%d;green,%d;blue,%d}', ...
                round(color(1)*255), round(color(2)*255), round(color(3)*255));

            fprintf(fid, '\\addplot[\n');
            fprintf(fid, '  color=%s,\n', color_str);
            fprintf(fid, '  line width=%.1fpt,\n', line_width);

            % 线型
            line_style = get(line, 'LineStyle');
            switch line_style
                case '--'
                    fprintf(fid, '  dashed,\n');
                case ':'
                    fprintf(fid, '  dotted,\n');
                case '-.'
                    fprintf(fid, '  dash dot,\n');
            end

            % 标记
            marker = get(line, 'Marker');
            if ~strcmp(marker, 'none')
                fprintf(fid, '  mark=%s,\n', lower(marker));
                fprintf(fid, '  mark size=%.1fpt,\n', get(line, 'MarkerSize'));
            end

            fprintf(fid, ']\n');

            % 数据点（采样，避免过多点）
            n_points = numel(x_data);
            if n_points > 200
                step = ceil(n_points / 200);
                x_data = x_data(1:step:end);
                y_data = y_data(1:step:end);
            end

            fprintf(fid, 'coordinates {\n');
            for j = 1:numel(x_data)
                fprintf(fid, '  (%.6f, %.6f)\n', x_data(j), y_data(j));
            end
            fprintf(fid, '};\n');

            % 图例
            if ~isempty(display_name) && ~strcmp(display_name, '')
                fprintf(fid, '\\addlegendentry{%s}\n\n', display_name);
            end
        end

        fprintf(fid, '\\end{axis}\n');
        fprintf(fid, '\\end{tikzpicture}\n\n');
    end

    if opts.standalone
        fprintf(fid, '\\end{document}\n');
    end

    fclose(fid);
end
