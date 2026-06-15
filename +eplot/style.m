function style(fig_or_ax, preset, varargin)
%EPLOT.STYLE 一键应用论文级图表样式
%
%   eplot.style()             对当前 figure 应用默认样式 (ieee)
%   eplot.style('ieee')       应用 IEEE 期刊样式
%   eplot.style('nature')     应用 Nature 期刊样式
%   eplot.style('springer')   应用 Springer 期刊样式
%   eplot.style('thesis')     应用学位论文样式
%   eplot.style('beamer')     应用 Beamer 演示文稿样式
%   eplot.style('dark')       应用暗色主题
%   eplot.style('custom', 'FontSize', 12, 'LineWidth', 1.5)  自定义参数
%
%   可用的自定义参数:
%     'FontSize'      - 字体大小 (默认取决于预设)
%     'FontName'      - 字体名称 (默认 'Times New Roman')
%     'LineWidth'     - 线条宽度
%     'MarkerSize'    - 标记大小
%     'ColorScheme'   - 配色方案名称或自定义颜色矩阵
%     'Grid'          - 是否显示网格 'on'/'off'
%     'Box'           - 是否显示边框 'on'/'off'
%     'Interpreter'   - 文本解释器 'latex'/'tex'/'none'
%     'ExportDPI'     - 导出分辨率 (默认 300)
%
%   示例:
%     figure; plot(rand(10,3));
%     eplot.style('ieee');
%     eplot.export('my_figure.pdf');
%
%   See also eplot.export, eplot.colorscheme, eplot.batch_style

    arguments
        fig_or_ax = gcf
        preset {mustBeMember(preset, {'ieee','nature','springer','thesis','beamer','dark','default'})} = 'ieee'
    end
    arguments (Repeating)
        varargin
    end

    % 解析额外参数
    opts = parse_options(varargin{:});

    % 获取预设配置
    config = get_preset(preset, opts);

    % 确定目标是 figure 还是 axes
    if isa(fig_or_ax, 'matlab.ui.Figure')
        fig = fig_or_ax;
        axes_list = findobj(fig, 'Type', 'axes', '-not', 'Type', 'legend', '-not', 'Type', 'colorbar');
    elseif isa(fig_or_ax, 'matlab.graphics.axis.Axes')
        fig = ancestor(fig_or_ax, 'figure');
        axes_list = fig_or_ax;
    else
        error('eplot:style:invalidInput', '第一个参数必须是 figure 或 axes 对象');
    end

    % 应用 figure 级别设置
    set(fig, 'Color', config.FigColor);
    set(fig, 'Units', config.Units);
    set(fig, 'Position', config.Position);

    % 逐个 axes 应用样式
    for i = 1:numel(axes_list)
        ax = axes_list(i);
        apply_axes_style(ax, config);
    end

    % 应用配色方案
    if ~isempty(config.ColorScheme)
        eplot.colorscheme(fig, config.ColorScheme);
    end
end

function opts = parse_options(varargin)
    opts = struct();
    for i = 1:2:numel(varargin)
        key = varargin{i};
        val = varargin{i+1};
        opts.(key) = val;
    end
end

function config = get_preset(preset, opts)
    % 基础配置
    config = struct();
    config.FontName = 'Times New Roman';
    config.FontSize = 10;
    config.TitleFontSize = 12;
    config.AxisLabelFontSize = 11;
    config.LineWidth = 1.5;
    config.MarkerSize = 6;
    config.Grid = 'off';
    config.Box = 'on';
    config.Interpreter = 'latex';
    config.ColorScheme = '';
    config.ExportDPI = 300;
    config.FigColor = 'w';
    config.Units = 'centimeters';
    config.Position = [0 0 8.6 6.45];  % 单栏宽度
    config.MinorGrid = 'off';
    config.TickDir = 'out';
    config.TickLength = [0.015 0.015];

    switch preset
        case 'ieee'
            config.FontSize = 9;
            config.TitleFontSize = 10;
            config.AxisLabelFontSize = 10;
            config.LineWidth = 1.2;
            config.MarkerSize = 5;
            config.Position = [0 0 8.6 6.45];  % IEEE 单栏
            config.ColorScheme = 'ieee';

        case 'nature'
            config.FontSize = 8;
            config.TitleFontSize = 10;
            config.AxisLabelFontSize = 9;
            config.LineWidth = 1.0;
            config.MarkerSize = 4;
            config.Position = [0 0 8.9 5.8];  % Nature 单栏
            config.ColorScheme = 'nature';
            config.Interpreter = 'tex';

        case 'springer'
            config.FontSize = 9;
            config.LineWidth = 1.0;
            config.MarkerSize = 5;
            config.Position = [0 0 8.4 6.3];
            config.ColorScheme = 'springer';

        case 'thesis'
            config.FontSize = 11;
            config.TitleFontSize = 13;
            config.AxisLabelFontSize = 12;
            config.LineWidth = 1.5;
            config.MarkerSize = 6;
            config.Position = [0 0 14 10];  % 较大尺寸
            config.ColorScheme = 'thesis';

        case 'beamer'
            config.FontSize = 14;
            config.TitleFontSize = 16;
            config.AxisLabelFontSize = 15;
            config.LineWidth = 2.0;
            config.MarkerSize = 8;
            config.Position = [0 0 12 8];
            config.ColorScheme = 'beamer';
            config.Interpreter = 'tex';

        case 'dark'
            config.FontSize = 10;
            config.LineWidth = 1.5;
            config.FigColor = [0.15 0.15 0.18];
            config.ColorScheme = 'dark';
            config.Grid = 'on';

        case 'default'
            % 使用基础配置，不做修改
    end

    % 用户自定义参数覆盖预设
    user_fields = fieldnames(opts);
    for i = 1:numel(user_fields)
        config.(user_fields{i}) = opts.(user_fields{i});
    end
end

function apply_axes_style(ax, config)
    % 字体
    set(ax, 'FontName', config.FontName);
    set(ax, 'FontSize', config.FontSize);

    % 坐标轴标签
    if ~isempty(ax.XLabel)
        set(ax.XLabel, 'FontSize', config.AxisLabelFontSize);
        set(ax.XLabel, 'FontName', config.FontName);
        set(ax.XLabel, 'Interpreter', config.Interpreter);
    end
    if ~isempty(ax.YLabel)
        set(ax.YLabel, 'FontSize', config.AxisLabelFontSize);
        set(ax.YLabel, 'FontName', config.FontName);
        set(ax.YLabel, 'Interpreter', config.Interpreter);
    end
    if ~isempty(ax.ZLabel)
        set(ax.ZLabel, 'FontSize', config.AxisLabelFontSize);
        set(ax.ZLabel, 'FontName', config.FontName);
        set(ax.ZLabel, 'Interpreter', config.Interpreter);
    end

    % 标题
    if ~isempty(ax.Title)
        set(ax.Title, 'FontSize', config.TitleFontSize);
        set(ax.Title, 'FontName', config.FontName);
        set(ax.Title, 'Interpreter', config.Interpreter);
    end

    % 线条样式
    lines = findobj(ax, 'Type', 'line');
    for j = 1:numel(lines)
        set(lines(j), 'LineWidth', config.LineWidth);
        if strcmp(get(lines(j), 'Marker'), 'none') == 0
            set(lines(j), 'MarkerSize', config.MarkerSize);
        end
    end

    % 网格
    ax.XGrid = config.Grid;
    ax.YGrid = config.Grid;
    ax.ZGrid = config.Grid;
    ax.XMinorGrid = config.MinorGrid;
    ax.YMinorGrid = config.MinorGrid;

    % 边框
    ax.Box = config.Box;

    % 刻度方向
    ax.TickDir = config.TickDir;
    ax.TickLength = config.TickLength;

    % 图例样式
    leg = findobj(ancestor(ax, 'figure'), 'Type', 'legend');
    for k = 1:numel(leg)
        set(leg(k), 'FontName', config.FontName);
        set(leg(k), 'FontSize', config.FontSize - 1);
        set(leg(k), 'Interpreter', config.Interpreter);
        set(leg(k), 'Location', 'best');
        set(leg(k), 'EdgeColor', [0.8 0.8 0.8]);
    end

    % colorbar 样式
    cb = findobj(ancestor(ax, 'figure'), 'Type', 'colorbar');
    for k = 1:numel(cb)
        set(cb(k), 'FontName', config.FontName);
        set(cb(k), 'FontSize', config.FontSize);
    end
end
