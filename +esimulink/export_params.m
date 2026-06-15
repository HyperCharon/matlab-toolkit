function export_params(model_name, varargin)
%ESIMULINK.EXPORT_PARAMS 导出 Simulink 模型参数
%
%   esimulink.export_params('my_model')
%   esimulink.export_params('my_model', 'format', 'csv')
%   esimulink.export_params('my_model', 'format', 'mat', 'filename', 'params')
%
%   支持格式:
%     'csv'      - CSV 文件 (默认)
%     'xlsx'     - Excel 文件
%     'mat'      - MAT 文件
%     'json'     - JSON 文件
%     'markdown' - Markdown 表格
%
%   See also esimulink.generate_docs, esimulink.check_model

    opts = struct('format', 'csv', 'filename', '', 'output', 'docs');
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    if isempty(opts.filename)
        opts.filename = sprintf('%s_params', model_name);
    end

    % 加载模型
    try
        load_system(model_name);
    catch
        error('esimulink:export_params:modelNotFound', '无法加载模型: %s', model_name);
    end

    % 创建输出目录
    if ~exist(opts.output, 'dir')
        mkdir(opts.output);
    end

    fprintf('📤 导出 Simulink 模型参数: %s\n', model_name);

    % 获取所有可调参数
    params = get_tunable_params(model_name);

    fprintf('   找到 %d 个可调参数\n', numel(params));

    % 创建 table
    param_table = table(...
        {params.name}', {params.block}', {params.type}', ...
        {params.value}', {params.description}', ...
        'VariableNames', {'参数名', '模块', '类型', '当前值', '描述'});

    % 导出
    switch lower(opts.format)
        case 'csv'
            filepath = fullfile(opts.output, opts.filename + ".csv");
            writetable(param_table, filepath);

        case 'xlsx'
            filepath = fullfile(opts.output, opts.filename + ".xlsx");
            writetable(param_table, filepath);

        case 'mat'
            filepath = fullfile(opts.output, opts.filename + ".mat");
            save(filepath, 'params');

        case 'json'
            filepath = fullfile(opts.output, opts.filename + ".json");
            json_text = jsonencode(params, 'PrettyPrint', true);
            fid = fopen(filepath, 'w');
            fprintf(fid, '%s', json_text);
            fclose(fid);

        case 'markdown'
            filepath = fullfile(opts.output, opts.filename + ".md");
            fid = fopen(filepath, 'w');
            fprintf(fid, '# %s - 模型参数\n\n', model_name);
            fprintf(fid, '| 参数名 | 模块 | 类型 | 当前值 | 描述 |\n');
            fprintf(fid, '|--------|------|------|--------|------|\n');
            for i = 1:numel(params)
                fprintf(fid, '| %s | %s | %s | %s | %s |\n', ...
                    params(i).name, params(i).block, params(i).type, ...
                    params(i).value, params(i).description);
            end
            fclose(fid);

        otherwise
            error('esimulink:export_params:unknownFormat', '不支持的格式: %s', opts.format);
    end

    fprintf('✅ 参数已导出: %s\n', filepath);
end

function params = get_tunable_params(model_name)
    params = struct('name', {}, 'block', {}, 'type', {}, 'value', {}, 'description', {});

    % 获取所有模块
    blocks = find_system(model_name, 'LookUnderMasks', 'all');

    for i = 1:numel(blocks)
        block = blocks{i};
        try
            % 获取模块对话参数
            dialog_params = get_param(block, 'DialogParameters');

            if isempty(dialog_params)
                continue;
            end

            param_names = fieldnames(dialog_params);

            for j = 1:numel(param_names)
                param_name = param_names{j};

                % 检查是否可调
                try
                    param_info = dialog_params.(param_name);
                    if isfield(param_info, 'ReadOnly') && param_info.ReadOnly
                        continue;
                    end

                    % 获取当前值
                    value = get_param(block, param_name);

                    % 添加到列表
                    p = struct();
                    p.name = param_name;
                    p.block = block;
                    p.type = class(value);
                    if isnumeric(value)
                        p.value = mat2str(value);
                    else
                        p.value = char(value);
                    end
                    if isfield(param_info, 'Attributes') && iscell(param_info.Attributes)
                        p.description = strjoin(param_info.Attributes, ' ');
                    else
                        p.description = '';
                    end

                    params(end+1) = p;
                catch
                    % 忽略无法读取的参数
                end
            end
        catch
            % 忽略无法处理的模块
        end
    end

    % 去重
    if ~isempty(params)
        [~, idx] = unique({params.name, params.block}, 'rows');
        params = params(idx);
    end
end
