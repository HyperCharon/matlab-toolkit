function info = analyze(data, varargin)
%EDATA.ANALYZE 数据统计分析
%
%   info = edata.analyze(data)
%   info = edata.analyze(data, 'columns', {'col1', 'col2'})
%   info = edata.analyze(data, 'plot', true)
%
%   See also edata.read, edata.clean, edata.export

    opts = struct('columns', [], 'plot', false, 'verbose', true);
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    if istable(data)
        if isempty(opts.columns)
            numeric_cols = varfun(@isnumeric, data, 'OutputFormat', 'uniform');
            col_names = data.Properties.VariableNames(numeric_cols);
        else
            col_names = opts.columns;
        end

        info = struct();
        info.n_rows = height(data);
        info.n_cols = width(data);
        info.columns = struct();

        if opts.verbose
            fprintf('📊 数据分析报告:\n');
            fprintf('   行数: %d, 列数: %d\n', info.n_rows, info.n_cols);
            fprintf('\n');
        end

        for i = 1:numel(col_names)
            col = data.(col_names{i});
            if ~isnumeric(col) || ~isvector(col)
                continue;
            end

            stats = struct();
            stats.mean = mean(col, 'omitnan');
            stats.median = median(col, 'omitnan');
            stats.std = std(col, 'omitnan');
            stats.min = min(col);
            stats.max = max(col);
            stats.range = stats.max - stats.min;
            stats.q25 = prctile(col, 25);
            stats.q75 = prctile(col, 75);
            stats.iqr = stats.q75 - stats.q25;
            stats.skewness = skewness(col);
            stats.kurtosis = kurtosis(col);
            stats.n_nan = sum(isnan(col));
            stats.n_unique = numel(unique(col));

            info.columns.(col_names{i}) = stats;

            if opts.verbose
                fprintf('   %s:\n', col_names{i});
                fprintf('     均值: %.4f, 中位数: %.4f, 标准差: %.4f\n', ...
                    stats.mean, stats.median, stats.std);
                fprintf('     范围: [%.4f, %.4f], IQR: %.4f\n', ...
                    stats.min, stats.max, stats.iqr);
                fprintf('     偏度: %.4f, 峰度: %.4f\n', stats.skewness, stats.kurtosis);
                fprintf('     NaN: %d, 唯一值: %d\n', stats.n_nan, stats.n_unique);
                fprintf('\n');
            end
        end

        % 绘图
        if opts.plot
            figure('Name', 'Data Analysis');
            n_plots = min(numel(col_names), 6);
            for i = 1:n_plots
                subplot(2, 3, i);
                histogram(data.(col_names{i}), 20, 'FaceAlpha', 0.7);
                title(col_names{i});
                xlabel(col_names{i});
                ylabel('Frequency');
                grid on;
            end
        end

    elseif isnumeric(data)
        info.mean = mean(data(:), 'omitnan');
        info.std = std(data(:), 'omitnan');
        info.min = min(data(:));
        info.max = max(data(:));

        if opts.verbose
            fprintf('📊 数值数据分析:\n');
            fprintf('   均值: %.4f, 标准差: %.4f\n', info.mean, info.std);
            fprintf('   范围: [%.4f, %.4f]\n', info.min, info.max);
        end
    end
end
