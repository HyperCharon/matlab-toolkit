function data = batch_read(file_pattern, varargin)
%EDATA.BATCH_READ 批量读取多个文件
%
%   data = edata.batch_read('data/*.csv')
%   data = edata.batch_read('data/*.csv', 'combine', true)
%   data = edata.batch_read({'file1.csv', 'file2.csv', 'file3.csv'})
%
%   可选参数:
%     'combine'    - 是否合并为一个 table (默认 true)
%     'id_column'  - 添加文件标识列 (默认 'filename')
%     'clean'      - 是否自动清洗 (默认 false)
%
%   See also edata.read, edata.clean, edata.export

    opts = struct('combine', true, 'id_column', 'filename', 'clean', false);
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    % 获取文件列表
    if ischar(file_pattern) || isstring(file_pattern)
        files = dir(file_pattern);
        file_paths = fullfile({files.folder}, {files.name});
    elseif iscell(file_pattern)
        file_paths = file_pattern;
    else
        error('edata:batch_read:invalidInput', '输入必须是文件模式或文件列表');
    end

    n_files = numel(file_paths);
    fprintf('📁 批量读取: %d 个文件\n', n_files);

    data_list = cell(n_files, 1);

    for i = 1:n_files
        fprintf('[%d/%d] 读取: %s ... ', i, n_files, file_paths{i});
        try
            d = edata.read(file_paths{i});

            % 添加文件标识列
            [~, fname, ~] = fileparts(file_paths{i});
            if istable(d)
                d.(opts.id_column) = repmat(string(fname), height(d), 1);
            end

            if opts.clean && istable(d)
                d = edata.clean(d, 'remove_nan', true);
            end

            data_list{i} = d;
            fprintf('✅ (%d 行)\n', height(d));
        catch ME
            fprintf('❌ %s\n', ME.message);
            data_list{i} = [];
        end
    end

    % 合并数据
    if opts.combine
        % 只保留 table 类型
        valid_idx = cellfun(@(x) ~isempty(x) && istable(x), data_list);
        valid_data = data_list(valid_idx);

        if isempty(valid_data)
            error('edata:batch_read:noValidData', '没有成功读取任何文件');
        end

        % 找到共同的列名
        common_cols = valid_data{1}.Properties.VariableNames;
        for i = 2:numel(valid_data)
            common_cols = intersect(common_cols, valid_data{i}.Properties.VariableNames);
        end

        % 只保留共同列
        for i = 1:numel(valid_data)
            valid_data{i} = valid_data{i}(:, common_cols);
        end

        data = vertcat(valid_data{:});
        fprintf('\n✅ 合并完成: %d 行, %d 列\n', height(data), width(data));
    else
        data = data_list;
    end
end
