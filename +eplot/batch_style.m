function batch_style(input_dir, preset, varargin)
%EPLOT.BATCH_STYLE 批量对文件夹中所有 .fig 文件应用样式
%
%   eplot.batch_style('figs/', 'ieee')       批量应用 IEEE 样式
%   eplot.batch_style('figs/', 'nature', 'FontSize', 9)  自定义参数
%
%   参数:
%     'save'   - 是否保存修改后的 .fig 文件 (默认 true)
%     'export' - 是否同时导出 (默认 false)
%     'format' - 导出格式 (默认 'pdf')
%
%   See also eplot.style, eplot.batch_export

    arguments
        input_dir char
        preset {mustBeMember(preset, {'ieee','nature','springer','thesis','beamer','dark','default'})} = 'ieee'
    end
    arguments (Repeating)
        varargin
    end

    % 解析参数
    opts = struct('save', true, 'export', false, 'format', 'pdf');
    custom_args = {};
    i = 1;
    while i + 1 <= numel(varargin)
        if isfield(opts, varargin{i})
            opts.(varargin{i}) = varargin{i+1};
        else
            custom_args = [custom_args varargin(i:i+1)];
        end
        i = i + 2;
    end
    if i == numel(varargin)
        warning('eplot:batch_style:oddArgs', '参数 "%s" 缺少对应的值', varargin{i});
    end

    % 查找 .fig 文件
    fig_files = dir(fullfile(input_dir, '*.fig'));
    if isempty(fig_files)
        warning('eplot:batch_style:noFiles', '在 %s 中没有找到 .fig 文件', input_dir);
        return;
    end

    fprintf('🎨 批量应用 "%s" 样式到 %d 个文件\n', preset, numel(fig_files));

    for i = 1:numel(fig_files)
        fig_path = fullfile(fig_files(i).folder, fig_files(i).name);
        fprintf('[%d/%d] %s ... ', i, numel(fig_files), fig_files(i).name);

        try
            fig = openfig(fig_path, 'invisible');
            eplot.style(fig, preset, custom_args{:});

            if opts.save
                savefig(fig, fig_path);
            end

            if opts.export
                [~, name, ~] = fileparts(fig_files(i).name);
                eplot.export(fig, fullfile(input_dir, name + "." + opts.format));
            end

            close(fig);
            fprintf('✅\n');
        catch ME
            fprintf('❌ %s\n', ME.message);
        end
    end

    fprintf('🎉 完成!\n');
end
