function data = clean(data, varargin)
%EDATA.CLEAN 数据清洗
%
%   data = edata.clean(data)
%   data = edata.clean(data, 'remove_nan', true, 'remove_outliers', true)
%
%   可选参数:
%     'remove_nan'      - 移除 NaN 行 (默认 true)
%     'remove_outliers' - 移除离群值 (默认 false)
%     'outlier_method'  - 离群值检测方法 'iqr'/'zscore' (默认 'iqr')
%     'outlier_factor'  - 离群值因子 (默认 1.5)
%     'interpolate'     - 插值方法 'linear'/'spline'/'nearest' (默认 'linear')
%     'smooth'          - 平滑窗口大小 (默认 0, 不平滑)
%     'normalize'       - 归一化方法 'minmax'/'zscore'/'none' (默认 'none')
%     'rename_columns'  - 重命名列 (struct 或 containers.Map)
%     'remove_duplicates' - 移除重复行 (默认 false)
%
%   示例:
%     data = edata.clean(data, ...
%         'remove_nan', true, ...
%         'remove_outliers', true, ...
%         'outlier_method', 'iqr', ...
%         'smooth', 5, ...
%         'normalize', 'zscore');
%
%   See also edata.read, edata.export, edata.analyze

    opts = struct(...
        'remove_nan', true, ...
        'remove_outliers', false, ...
        'outlier_method', 'iqr', ...
        'outlier_factor', 1.5, ...
        'interpolate', 'linear', ...
        'smooth', 0, ...
        'normalize', 'none', ...
        'rename_columns', [], ...
        'remove_duplicates', false);
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    original_height = height(data);
    fprintf('🧹 数据清洗开始 (原始数据: %d 行)\n', original_height);

    % 重命名列
    if ~isempty(opts.rename_columns)
        if isstruct(opts.rename_columns)
            fields = fieldnames(opts.rename_columns);
            for i = 1:numel(fields)
                old_name = fields{i};
                new_name = opts.rename_columns.(old_name);
                if ismember(old_name, data.Properties.VariableNames)
                    data.Properties.VariableNames{old_name} = new_name;
                    fprintf('   重命名: %s → %s\n', old_name, new_name);
                end
            end
        end
    end

    % 移除重复行
    if opts.remove_duplicates
        n_before = height(data);
        data = unique(data, 'rows', 'stable');
        n_removed = n_before - height(data);
        if n_removed > 0
            fprintf('   移除重复行: %d\n', n_removed);
        end
    end

    % 移除 NaN
    if opts.remove_nan
        n_before = height(data);
        data = rmmissing(data);
        n_removed = n_before - height(data);
        if n_removed > 0
            fprintf('   移除 NaN 行: %d\n', n_removed);
        end
    end

    % 移除离群值
    if opts.remove_outliers
        numeric_cols = varfun(@isnumeric, data, 'OutputFormat', 'uniform');
        numeric_names = data.Properties.VariableNames(numeric_cols);

        for i = 1:numel(numeric_names)
            col = data.(numeric_names{i});
            if isnumeric(col) && isvector(col)
                switch lower(opts.outlier_method)
                    case 'iqr'
                        Q1 = prctile(col, 25);
                        Q3 = prctile(col, 75);
                        IQR_val = Q3 - Q1;
                        lower_bound = Q1 - opts.outlier_factor * IQR_val;
                        upper_bound = Q3 + opts.outlier_factor * IQR_val;
                        outlier_mask = col < lower_bound | col > upper_bound;

                    case 'zscore'
                        col_std = std(col);
                        if col_std == 0
                            outlier_mask = false(size(col));
                        else
                            z = abs((col - mean(col)) / col_std);
                            outlier_mask = z > opts.outlier_factor;
                        end

                    otherwise
                        outlier_mask = false(size(col));
                end

                n_outliers = sum(outlier_mask);
                if n_outliers > 0
                    data(outlier_mask, :) = [];
                    fprintf('   移除离群值 (%s): %d\n', numeric_names{i}, n_outliers);
                end
            end
        end
    end

    % 插值填充
    if ~strcmp(opts.interpolate, 'none')
        numeric_cols = varfun(@isnumeric, data, 'OutputFormat', 'uniform');
        numeric_names = data.Properties.VariableNames(numeric_cols);

        for i = 1:numel(numeric_names)
            col = data.(numeric_names{i});
            if isnumeric(col) && isvector(col)
                nan_mask = isnan(col);
                if any(nan_mask)
                    x = 1:numel(col);
                    x_valid = x(~nan_mask);
                    col(nan_mask) = interp1(x_valid, col(~nan_mask), x(nan_mask), opts.interpolate);
                    data.(numeric_names{i}) = col;
                    fprintf('   插值填充 (%s): %d 个点\n', numeric_names{i}, sum(nan_mask));
                end
            end
        end
    end

    % 平滑
    if opts.smooth > 0
        numeric_cols = varfun(@isnumeric, data, 'OutputFormat', 'uniform');
        numeric_names = data.Properties.VariableNames(numeric_cols);

        for i = 1:numel(numeric_names)
            col = data.(numeric_names{i});
            if isnumeric(col) && isvector(col)
                data.(numeric_names{i}) = movmean(col, opts.smooth);
                fprintf('   平滑 (%s): 窗口大小 %d\n', numeric_names{i}, opts.smooth);
            end
        end
    end

    % 归一化
    if ~strcmp(opts.normalize, 'none')
        numeric_cols = varfun(@isnumeric, data, 'OutputFormat', 'uniform');
        numeric_names = data.Properties.VariableNames(numeric_cols);

        for i = 1:numel(numeric_names)
            col = data.(numeric_names{i});
            if isnumeric(col) && isvector(col)
                switch lower(opts.normalize)
                    case 'minmax'
                        col_min = min(col, [], 'omitnan');
                        col_max = max(col, [], 'omitnan');
                        if col_max == col_min
                            data.(numeric_names{i}) = zeros(size(col));
                        else
                            data.(numeric_names{i}) = (col - col_min) / (col_max - col_min);
                        end
                    case 'zscore'
                        col_std = std(col, 'omitnan');
                        if col_std == 0
                            data.(numeric_names{i}) = zeros(size(col));
                        else
                            data.(numeric_names{i}) = (col - mean(col, 'omitnan')) / col_std;
                        end
                end
                fprintf('   归一化 (%s): %s\n', numeric_names{i}, opts.normalize);
            end
        end
    end

    final_height = height(data);
    fprintf('✅ 清洁完成 (最终数据: %d 行, 移除: %d)\n', ...
        final_height, original_height - final_height);
end
