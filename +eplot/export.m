function export(fig, filename, varargin)
%EPLOT.EXPORT 导出论文级图表
%
%   eplot.export('figure1.pdf')           导出当前 figure 为 PDF
%   eplot.export('figure1.pdf', 'dpi', 600)  指定分辨率
%   eplot.export(fig, 'figure1.eps')      导出指定 figure
%   eplot.export({'fig1.pdf', 'fig2.eps'})  批量导出当前 figure 为多种格式
%
%   支持格式: PDF, EPS, PNG, TIFF, SVG, FIG
%
%   参数:
%     'dpi'      - 分辨率 (默认 300)
%     'renderer' - 渲染器 'painters'(矢量)/'opengl'(位图) (默认自动选择)
%     'crop'     - 是否裁剪白边 true/false (默认 true)
%     'colorspace' - 色彩空间 'rgb'/'cmyk' (默认 'rgb')
%
%   示例:
%     figure; plot(rand(10));
%     eplot.style('ieee');
%     eplot.export('my_fig.pdf', 'dpi', 600, 'colorspace', 'cmyk');
%
%   See also eplot.style, eplot.colorscheme, eplot.batch_export

    arguments
        fig = gcf
        filename string = ""
    end
    arguments (Repeating)
        varargin
    end

    % 处理批量导出 (filename 是 cell array)
    if iscell(filename)
        for i = 1:numel(filename)
            eplot.export(fig, filename{i}, varargin{:});
        end
        return;
    end

    % 处理 fig 参数是文件名的情况
    if ischar(fig) || isstring(fig)
        if ischar(filename) || isstring(filename)
            varargin = [{filename} varargin];
        end
        filename = string(fig);
        fig = gcf;
    end

    % 如果没有指定文件名，使用默认名
    if strlength(filename) == 0
        filename = "figure_" + string(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
    end

    % 解析参数
    opts = struct('dpi', 300, 'renderer', 'auto', 'crop', true, 'colorspace', 'rgb');
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    % 确保 figure 在前台
    figure(fig);

    % 获取文件格式
    [~, ~, ext] = fileparts(char(filename));
    if isempty(ext)
        filename = filename + ".pdf";
        ext = ".pdf";
    end

    % 选择渲染器
    if strcmp(opts.renderer, 'auto')
        if any(strcmp(ext, {'.pdf', '.eps', '.svg'}))
            renderer = '-painters';
        else
            renderer = '-opengl';
        end
    else
        renderer = ['-d' opts.renderer];
    end

    % 设置导出参数
    print_args = {char(filename), renderer};

    % 分辨率
    if any(strcmp(ext, {'.png', '.tiff', '.tif', '.jpg', '.jpeg'}))
        print_args = [print_args, ['-r' num2str(opts.dpi)]];
    end

    % CMYK 色彩空间 (主要用于 EPS/PDF)
    if strcmp(opts.colorspace, 'cmyk') && any(strcmp(ext, {'.eps', '.pdf'}))
        print_args = [print_args, '-cmyk'];
    end

    % 裁剪白边
    if opts.crop
        % 保存原始属性
        orig_Units = get(fig, 'Units');
        orig_PaperPositionMode = get(fig, 'PaperPositionMode');
        orig_PaperUnits = get(fig, 'PaperUnits');
        orig_PaperSize = get(fig, 'PaperSize');

        set(fig, 'Units', 'centimeters');
        pos = get(fig, 'Position');
        set(fig, 'PaperPositionMode', 'auto');
        set(fig, 'PaperUnits', 'centimeters');
        set(fig, 'PaperSize', [pos(3) pos(4)]);
    end

    % 执行导出
    try
        print(print_args{:});
        fprintf('✅ 已导出: %s\n', char(filename));
    catch ME
        % 如果 painters 失败，回退到 opengl
        if contains(ME.message, 'painters')
            print_args{2} = '-opengl';
            print_args = [print_args, ['-r' num2str(opts.dpi)]];
            print(print_args{:});
            fprintf('✅ 已导出 (opengl): %s\n', char(filename));
        else
            rethrow(ME);
        end
    end

    % 恢复原始属性
    if opts.crop
        set(fig, 'Units', orig_Units);
        set(fig, 'PaperPositionMode', orig_PaperPositionMode);
        set(fig, 'PaperUnits', orig_PaperUnits);
        set(fig, 'PaperSize', orig_PaperSize);
    end
end
