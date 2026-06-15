function data = read(filename, varargin)
%EDATA.READ 智能数据读取
%
%   data = edata.read('data.csv')
%   data = edata.read('data.xlsx', 'Sheet', 'Sheet1')
%   data = edata.read('data.mat')
%   data = edata.read('data.json')
%   data = edata.read('data.h5', 'Dataset', '/sensor/temperature')
%
%   支持格式:
%     CSV, TSV, Excel (.xlsx/.xls), MAT, JSON, HDF5, TXT, DAT
%
%   可选参数:
%     'Sheet'      - Excel 工作表名称或索引
%     'Range'      - Excel 数据范围 (如 'A1:D100')
%     'Dataset'    - HDF5 数据集路径
%     'Delimiter'  - 文本文件分隔符
%     'Header'     - 是否有表头 (默认自动检测)
%     'Encoding'   - 文件编码 (默认 'UTF-8')
%
%   示例:
%     data = edata.read('sensor_data.csv', 'Delimiter', ',');
%     data = edata.read('experiment.xlsx', 'Sheet', 'Trial1');
%
%   See also edata.clean, edata.export, edata.batch_read

    opts = struct('Sheet', 1, 'Range', '', 'Dataset', '/', ...
                  'Delimiter', 'auto', 'Header', 'auto', 'Encoding', 'UTF-8');
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    % 检查文件是否存在
    if ~isfile(filename)
        error('edata:read:fileNotFound', '文件不存在: %s', filename);
    end

    % 根据扩展名选择读取方式
    [~, ~, ext] = fileparts(filename);

    switch lower(ext)
        case '.csv'
            data = read_csv(filename, opts);
        case '.tsv'
            opts.Delimiter = '\t';
            data = read_csv(filename, opts);
        case {'.xlsx', '.xls'}
            data = read_excel(filename, opts);
        case '.mat'
            data = read_mat(filename);
        case '.json'
            data = read_json(filename);
        case {'.h5', '.hdf5'}
            data = read_hdf5(filename, opts);
        case {'.txt', '.dat', '.log'}
            data = read_text(filename, opts);
        otherwise
            error('edata:read:unsupportedFormat', '不支持的文件格式: %s', ext);
    end

    % 显示读取摘要
    if istable(data)
        fprintf('✅ 已读取: %s\n', filename);
        fprintf('   行数: %d, 列数: %d\n', height(data), width(data));
        fprintf('   列名: %s\n', strjoin(data.Properties.VariableNames, ', '));
    elseif isstruct(data)
        fprintf('✅ 已读取: %s (struct)\n', filename);
        fprintf('   字段: %s\n', strjoin(fieldnames(data), ', '));
    elseif isnumeric(data)
        fprintf('✅ 已读取: %s\n', filename);
        fprintf('   大小: %s\n', mat2str(size(data)));
    end
end

function data = read_csv(filename, opts)
    opts_read = {'VariableNamingRule', 'preserve'};

    if ~strcmp(opts.Delimiter, 'auto')
        opts_read = [opts_read, {'Delimiter', opts.Delimiter}];
    end

    if islogical(opts.Header)
        if ~opts.Header
            opts_read = [opts_read, {'ReadVariableNames', false}];
        end
    end

    data = readtable(filename, opts_read{:});
end

function data = read_excel(filename, opts)
    opts_read = {};

    if ischar(opts.Sheet) || isstring(opts.Sheet)
        opts_read = [opts_read, {'Sheet', opts.Sheet}];
    elseif isnumeric(opts.Sheet)
        opts_read = [opts_read, {'Sheet', opts.Sheet}];
    end

    if ~isempty(opts.Range)
        opts_read = [opts_read, {'Range', opts.Range}];
    end

    data = readtable(filename, opts_read{:}, 'VariableNamingRule', 'preserve');
end

function data = read_mat(filename)
    loaded = load(filename);
    fields = fieldnames(loaded);

    if numel(fields) == 1
        data = loaded.(fields{1});
    else
        data = loaded;
    end
end

function data = read_json(filename)
    text = fileread(filename);
    data = jsondecode(text);
end

function data = read_hdf5(filename, opts)
    data = h5read(filename, opts.Dataset);
end

function data = read_text(filename, opts)
    delimiter = opts.Delimiter;
    if strcmp(delimiter, 'auto')
        % 自动检测分隔符
        first_lines = read_first_lines(filename, 5);
        if contains(first_lines(1), ',')
            delimiter = ',';
        elseif contains(first_lines(1), char(9))
            delimiter = '\t';
        elseif contains(first_lines(1), ';')
            delimiter = ';';
        else
            delimiter = ' ';
        end
    end

    opts_read = {'Delimiter', delimiter};

    if islogical(opts.Header) && ~opts.Header
        opts_read = [opts_read, {'ReadVariableNames', false}];
    end

    data = readtable(filename, opts_read{:}, 'VariableNamingRule', 'preserve');
end

function lines = read_first_lines(filename, n)
    fid = fopen(filename, 'r');
    lines = strings(n, 1);
    for i = 1:n
        line = fgetl(fid);
        if ischar(line)
            lines(i) = string(line);
        else
            break;
        end
    end
    fclose(fid);
end
