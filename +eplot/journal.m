function journal(fig, preset, varargin)
%EPLOT.JOURNAL 期刊论文图表一键格式化
%
%   eplot.journal('ieee')             IEEE 单栏图
%   eplot.journal('ieee-double')      IEEE 双栏图
%   eplot.journal('elsevier')         Elsevier 期刊
%   eplot.journal('nature')           Nature 期刊
%   eplot.journal('springer')         Springer 期刊
%   eplot.journal('thesis-cn')        中文学位论文
%   eplot.journal('beamer')           PPT 演示文稿
%
%   每种预设包含：字号、字体、图宽、线宽、导出格式等完整规范
%
%   See also eplot.style, eplot.export

    arguments
        fig = gcf
        preset char = 'ieee'
    end
    arguments (Repeating)
        varargin
    end

    % 处理第一个参数是 preset 的情况
    if ischar(fig) && ~isempty(fig) && ~isgraphics(fig)
        varargin = [{preset} varargin];
        preset = fig;
        fig = gcf;
    end

    % 获取期刊配置
    cfg = get_journal_config(preset);

    % 应用样式
    apply_journal_style(fig, cfg);

    % 导出（如果指定了导出）
    if numel(varargin) >= 1 && ischar(varargin{1})
        export_fig(fig, varargin{1}, cfg, varargin{2:end});
    end

    fprintf('✅ 已应用 %s 期刊样式\n', upper(preset));
    fprintf('   图宽: %.1f cm, 字号: %d pt, 线宽: %.1f pt\n', ...
        cfg.fig_width, cfg.font_size, cfg.line_width);
end

function cfg = get_journal_config(preset)
    cfg = struct();

    switch lower(preset)
        case 'ieee'
            % IEEE 单栏图：3.5 inch = 8.89 cm
            cfg.fig_width = 8.89;
            cfg.fig_height = 6.67;
            cfg.font_name = 'Times New Roman';
            cfg.font_size = 9;
            cfg.label_size = 10;
            cfg.title_size = 10;
            cfg.line_width = 1.0;
            cfg.marker_size = 5;
            cfg.export_format = 'pdf';
            cfg.dpi = 600;
            cfg.colorspace = 'rgb';

        case 'ieee-double'
            % IEEE 双栏图：7.16 inch = 18.19 cm
            cfg.fig_width = 18.19;
            cfg.fig_height = 10;
            cfg.font_name = 'Times New Roman';
            cfg.font_size = 9;
            cfg.label_size = 10;
            cfg.title_size = 10;
            cfg.line_width = 1.0;
            cfg.marker_size = 5;
            cfg.export_format = 'pdf';
            cfg.dpi = 600;
            cfg.colorspace = 'rgb';

        case 'elsevier'
            % Elsevier 期刊：单栏 90mm, 1.5栏 140mm, 双栏 190mm
            cfg.fig_width = 9;
            cfg.fig_height = 6.75;
            cfg.font_name = 'Times New Roman';
            cfg.font_size = 8;
            cfg.label_size = 9;
            cfg.title_size = 9;
            cfg.line_width = 0.75;
            cfg.marker_size = 4;
            cfg.export_format = 'tif';
            cfg.dpi = 600;
            cfg.colorspace = 'rgb';

        case 'nature'
            % Nature 期刊：单栏 89mm, 双栏 183mm
            cfg.fig_width = 8.9;
            cfg.fig_height = 6;
            cfg.font_name = 'Helvetica';
            cfg.font_size = 7;
            cfg.label_size = 8;
            cfg.title_size = 8;
            cfg.line_width = 0.75;
            cfg.marker_size = 4;
            cfg.export_format = 'pdf';
            cfg.dpi = 600;
            cfg.colorspace = 'cmyk';

        case 'springer'
            % Springer 期刊
            cfg.fig_width = 8.4;
            cfg.fig_height = 6.3;
            cfg.font_name = 'Times New Roman';
            cfg.font_size = 9;
            cfg.label_size = 10;
            cfg.title_size = 10;
            cfg.line_width = 0.8;
            cfg.marker_size = 5;
            cfg.export_format = 'pdf';
            cfg.dpi = 600;
            cfg.colorspace = 'rgb';

        case 'thesis-cn'
            % 中文学位论文：正文小四号(12pt)，图中文字五号(10.5pt)
            cfg.fig_width = 14;
            cfg.fig_height = 10;
            cfg.font_name = '宋体';
            cfg.font_size = 10.5;
            cfg.label_size = 12;
            cfg.title_size = 12;
            cfg.line_width = 1.5;
            cfg.marker_size = 6;
            cfg.export_format = 'pdf';
            cfg.dpi = 300;
            cfg.colorspace = 'rgb';

        case 'beamer'
            % PPT 演示文稿
            cfg.fig_width = 12;
            cfg.fig_height = 8;
            cfg.font_name = 'Arial';
            cfg.font_size = 14;
            cfg.label_size = 16;
            cfg.title_size = 16;
            cfg.line_width = 2.0;
            cfg.marker_size = 8;
            cfg.export_format = 'png';
            cfg.dpi = 300;
            cfg.colorspace = 'rgb';

        otherwise
            error('eplot:journal:unknownPreset', '未知期刊预设: %s', preset);
    end
end

function apply_journal_style(fig, cfg)
    % 设置 figure 尺寸
    set(fig, 'Units', 'centimeters');
    set(fig, 'Position', [1 1 cfg.fig_width cfg.fig_height]);
    set(fig, 'Color', 'w');

    % 获取所有 axes
    axes_list = findobj(fig, 'Type', 'axes', '-not', 'Type', 'legend', '-not', 'Type', 'colorbar');

    for i = 1:numel(axes_list)
        ax = axes_list(i);

        % 字体
        set(ax, 'FontName', cfg.font_name);
        set(ax, 'FontSize', cfg.font_size);

        % 坐标轴标签
        if ~isempty(ax.XLabel)
            set(ax.XLabel, 'FontSize', cfg.label_size);
            set(ax.XLabel, 'FontName', cfg.font_name);
        end
        if ~isempty(ax.YLabel)
            set(ax.YLabel, 'FontSize', cfg.label_size);
            set(ax.YLabel, 'FontName', cfg.font_name);
        end
        if ~isempty(ax.ZLabel)
            set(ax.ZLabel, 'FontSize', cfg.label_size);
            set(ax.ZLabel, 'FontName', cfg.font_name);
        end

        % 标题
        if ~isempty(ax.Title)
            set(ax.Title, 'FontSize', cfg.title_size);
            set(ax.Title, 'FontName', cfg.font_name);
        end

        % 线条
        lines = findobj(ax, 'Type', 'line');
        for j = 1:numel(lines)
            set(lines(j), 'LineWidth', cfg.line_width);
            if ~strcmp(get(lines(j), 'Marker'), 'none')
                set(lines(j), 'MarkerSize', cfg.marker_size);
            end
        end

        % 刻度
        ax.TickDir = 'out';
        ax.TickLength = [0.015 0.015];
        ax.Box = 'on';
    end

    % 图例
    legs = findobj(fig, 'Type', 'legend');
    for i = 1:numel(legs)
        set(legs(i), 'FontName', cfg.font_name);
        set(legs(i), 'FontSize', cfg.font_size - 1);
        set(legs(i), 'Location', 'best');
        set(legs(i), 'EdgeColor', [0.8 0.8 0.8]);
    end
end

function export_fig(fig, filename, cfg, varargin)
    % 解析额外参数
    opts = struct();
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    % 确定文件扩展名
    [~, ~, ext] = fileparts(filename);
    if isempty(ext)
        filename = [filename '.' cfg.export_format];
    end

    % 设置导出参数
    set(fig, 'PaperPositionMode', 'auto');
    set(fig, 'PaperUnits', 'centimeters');
    pos = get(fig, 'Position');
    set(fig, 'PaperSize', [pos(3) pos(4)]);

    % 导出
    print(fig, filename, ['-d' cfg.export_format(1:end)], ...
        ['-r' num2str(cfg.dpi)]);

    fprintf('   已导出: %s\n', filename);
end
