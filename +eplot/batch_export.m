function batch_export(input_dir, output_dir, formats, varargin)
%EPLOT.BATCH_EXPORT 批量导出文件夹中所有 .fig 文件
%
%   eplot.batch_export('figs/', 'output/')           导出为 PDF
%   eplot.batch_export('figs/', 'output/', {'pdf','png'})  导出为多种格式
%   eplot.batch_export('figs/', 'output/', 'pdf', 'style', 'ieee')  导出并应用样式
%
%   参数:
%     'style'    - 导出前应用的样式预设 (默认不应用)
%     'dpi'      - 分辨率 (默认 300)
%     'prefix'   - 文件名前缀
%     'suffix'   - 文件名后缀
%
%   示例:
%     eplot.batch_export('my_figs/', 'paper_figs/', {'pdf','png'}, ...
%         'style', 'ieee', 'dpi', 600);
%
%   See also eplot.export, eplot.style

    arguments
        input_dir char
        output_dir char = 'exported_figures'
    end
    arguments (Repeating)
        varargin
    end

    % 解析参数
    formats = {'pdf'};
    opts = struct('style', '', 'dpi', 300, 'prefix', '', 'suffix', '');
    i = 1;
    while i <= numel(varargin)
        if ischar(varargin{i}) && isfield(opts, varargin{i})
            opts.(varargin{i}) = varargin{i+1};
            i = i + 2;
        else
            formats = varargin{i};
            i = i + 1;
        end
    end

    % 确保 formats 是 cell array
    if ischar(formats)
        formats = {formats};
    end

    % 创建输出目录
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    % 查找所有 .fig 文件
    fig_files = dir(fullfile(input_dir, '*.fig'));
    if isempty(fig_files)
        warning('eplot:batch_export:noFiles', '在 %s 中没有找到 .fig 文件', input_dir);
        return;
    end

    fprintf('📁 找到 %d 个 .fig 文件\n', numel(fig_files));
    fprintf('📂 输出目录: %s\n', output_dir);
    fprintf('📋 导出格式: %s\n', strjoin(formats, ', '));
    fprintf('\n');

    % 逐个处理
    success_count = 0;
    for i = 1:numel(fig_files)
        fig_path = fullfile(fig_files(i).folder, fig_files(i).name);
        [~, base_name, ~] = fileparts(fig_files(i).name);

        % 添加前缀/后缀
        out_name = opts.prefix + string(base_name) + opts.suffix;

        fprintf('[%d/%d] 处理: %s ... ', i, numel(fig_files), fig_files(i).name);

        try
            % 打开 figure
            fig = openfig(fig_path, 'invisible');

            % 应用样式
            if ~isempty(opts.style)
                eplot.style(fig, opts.style);
            end

            % 导出为各种格式
            for j = 1:numel(formats)
                out_file = fullfile(output_dir, out_name + "." + formats{j});
                eplot.export(fig, out_file, 'dpi', opts.dpi);
            end

            % 关闭 figure
            close(fig);
            success_count = success_count + 1;
            fprintf('✅\n');
        catch ME
            fprintf('❌ %s\n', ME.message);
        end
    end

    fprintf('\n🎉 完成! 成功导出 %d/%d 个文件\n', success_count, numel(fig_files));
end
