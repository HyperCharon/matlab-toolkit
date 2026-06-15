classdef experiment
%EDATA.EXPERIMENT 实验数据处理流水线
%
%   exp = edata.experiment('data_folder/');
%   exp.load('*.csv');
%   exp.preprocess('remove_dc', true, 'filter', 1000);
%   exp.analyze('fft', 'Fs', 10000);
%   exp.export('results/');
%
%   实验数据从采集到分析的完整流水线:
%   1. 批量加载多格式实验数据
%   2. 标准化预处理（去直流、滤波、去趋势、重采样）
%   3. 批量分析（FFT、统计、特征提取）
%   4. 结果导出与报告生成
%
%   See also edata.read, edata.clean, edata.batch_read

    properties
        data_folder     % 数据文件夹路径
        files           % 文件列表
        raw_data        % 原始数据
        processed_data  % 处理后数据
        metadata        % 实验元数据
        results         % 分析结果
        config          % 配置参数
    end

    methods
        function obj = experiment(folder)
        %EXPERIMENT 创建实验数据处理对象
        %
        %   exp = edata.experiment('data_folder/');

            obj.data_folder = folder;
            obj.raw_data = {};
            obj.processed_data = {};
            obj.metadata = struct();
            obj.results = struct();
            obj.config = struct( ...
                'Fs', 1000, ...
                'channels', {{}}, ...
                'remove_dc', true, ...
                'detrend', false, ...
                'filter_fc', [], ...
                'filter_type', 'lowpass', ...
                'resample_factor', 1 ...
            );

            if ~exist(folder, 'dir')
                error('edata:experiment:folderNotFound', '文件夹不存在: %s', folder);
            end
        end

        function obj = load(obj, pattern, varargin)
        %LOAD 批量加载实验数据
        %
        %   exp = exp.load('*.csv');
        %   exp = exp.load('*.csv', 'delimiter', ',');

            opts = struct('delimiter', 'auto', 'header', true);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            % 查找文件
            obj.files = dir(fullfile(obj.data_folder, pattern));

            if isempty(obj.files)
                warning('edata:experiment:noFiles', '未找到匹配文件: %s', pattern);
                return;
            end

            fprintf('📂 加载实验数据: %s\n', obj.data_folder);
            fprintf('   找到 %d 个文件\n', numel(obj.files));

            % 批量加载
            obj.raw_data = cell(numel(obj.files), 1);
            for i = 1:numel(obj.files)
                filepath = fullfile(obj.files(i).folder, obj.files(i).name);
                fprintf('   [%d/%d] %s ... ', i, numel(obj.files), obj.files(i).name);

                try
                    obj.raw_data{i} = edata.read(filepath, 'Delimiter', opts.delimiter);
                    fprintf('✅ (%d 行)\n', height(obj.raw_data{i}));
                catch ME
                    fprintf('❌ %s\n', ME.message);
                    obj.raw_data{i} = [];
                end
            end

            % 记录元数据
            obj.metadata.load_time = datestr(now);
            obj.metadata.n_files = numel(obj.files);
            obj.metadata.file_names = {obj.files.name}';
        end

        function obj = set_config(obj, varargin)
        %SET_CONFIG 设置预处理参数
        %
        %   exp = exp.set_config('Fs', 10000, 'remove_dc', true, 'filter_fc', 2000);

            for i = 1:2:numel(varargin)
                obj.config.(varargin{i}) = varargin{i+1};
            end

            fprintf('⚙️  配置已更新:\n');
            fprintf('   采样率: %d Hz\n', obj.config.Fs);
            fprintf('   去直流: %s\n', mat2str(obj.config.remove_dc));
            if ~isempty(obj.config.filter_fc)
                fprintf('   滤波: %s @ %d Hz\n', obj.config.filter_type, obj.config.filter_fc);
            end
        end

        function obj = preprocess(obj, varargin)
        %PREPROCESS 批量预处理
        %
        %   exp = exp.preprocess();
        %   exp = exp.preprocess('remove_dc', true, 'filter_fc', 2000);

            % 更新配置
            for i = 1:2:numel(varargin)
                obj.config.(varargin{i}) = varargin{i+1};
            end

            fprintf('🔧 批量预处理...\n');

            obj.processed_data = cell(numel(obj.raw_data), 1);

            for i = 1:numel(obj.raw_data)
                if isempty(obj.raw_data{i})
                    obj.processed_data{i} = [];
                    continue;
                end

                data = obj.raw_data{i};

                % 提取数值列
                numeric_cols = varfun(@isnumeric, data, 'OutputFormat', 'uniform');
                numeric_names = data.Properties.VariableNames(numeric_cols);

                for j = 1:numel(numeric_names)
                    x = data.(numeric_names{j});

                    % 去直流
                    if obj.config.remove_dc
                        x = x - mean(x);
                    end

                    % 去趋势
                    if obj.config.detrend
                        x = detrend(x);
                    end

                    % 滤波
                    if ~isempty(obj.config.filter_fc)
                        [b, a] = butter(4, obj.config.filter_fc/(obj.config.Fs/2), obj.config.filter_type);
                        x = filtfilt(b, a, x);
                    end

                    % 重采样
                    if obj.config.resample_factor ~= 1
                        x = resample(x, obj.config.resample_factor, 1);
                    end

                    data.(numeric_names{j}) = x;
                end

                obj.processed_data{i} = data;
                fprintf('   [%d/%d] 已处理\n', i, numel(obj.raw_data));
            end

            fprintf('✅ 预处理完成\n');
        end

        function obj = analyze(obj, method, varargin)
        %ANALYZE 批量分析
        %
        %   exp = exp.analyze('fft', 'Fs', 10000);
        %   exp = exp.analyze('stats');
        %   exp = exp.analyze('peaks');

            opts = struct('Fs', obj.config.Fs, 'channels', {{}});
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            fprintf('📊 批量分析: %s\n', method);

            obj.results.(method) = cell(numel(obj.processed_data), 1);

            for i = 1:numel(obj.processed_data)
                if isempty(obj.processed_data{i})
                    continue;
                end

                data = obj.processed_data{i};
                numeric_cols = varfun(@isnumeric, data, 'OutputFormat', 'uniform');
                numeric_names = data.Properties.VariableNames(numeric_cols);

                switch lower(method)
                    case 'fft'
                        result = struct();
                        for j = 1:numel(numeric_names)
                            x = data.(numeric_names{j});
                            N = numel(x);
                            nfft = 2^nextpow2(N);
                            X = fft(x, nfft);
                            X = X(1:nfft/2+1);
                            f = opts.Fs * (0:nfft/2) / nfft;
                            mag = 2 * abs(X) / N;

                            result.(numeric_names{j}).f = f;
                            result.(numeric_names{j}).magnitude = mag;
                            result.(numeric_names{j}).peak_freq = f(mag == max(mag(2:end)));
                        end
                        obj.results.fft{i} = result;

                    case 'stats'
                        result = struct();
                        for j = 1:numel(numeric_names)
                            x = data.(numeric_names{j});
                            result.(numeric_names{j}).mean = mean(x);
                            result.(numeric_names{j}).std = std(x);
                            result.(numeric_names{j}).rms = rms(x);
                            result.(numeric_names{j}).peak = max(abs(x));
                            result.(numeric_names{j}).crest = max(abs(x)) / rms(x);
                        end
                        obj.results.stats{i} = result;

                    case 'peaks'
                        result = struct();
                        for j = 1:numel(numeric_names)
                            x = data.(numeric_names{j});
                            [pks, locs] = findpeaks(x, 'MinPeakHeight', std(x));
                            result.(numeric_names{j}).n_peaks = numel(pks);
                            result.(numeric_names{j}).peak_values = pks;
                            result.(numeric_names{j}).peak_locations = locs;
                        end
                        obj.results.peaks{i} = result;
                end

                fprintf('   [%d/%d] 已分析\n", i, numel(obj.processed_data));
            end

            fprintf('✅ 分析完成\n');
        end

        function obj = export(obj, output_dir, varargin)
        %EXPORT 导出处理后数据和分析结果
        %
        %   exp = exp.export('results/');
        %   exp = exp.export('results/', 'format', 'xlsx');

            opts = struct('format', 'csv', 'include_raw', false, 'report', true);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            if ~exist(output_dir, 'dir')
                mkdir(output_dir);
            end

            fprintf('💾 导出结果到: %s\n', output_dir);

            % 导出处理后数据
            processed_dir = fullfile(output_dir, 'processed');
            if ~exist(processed_dir, 'dir')
                mkdir(processed_dir);
            end

            for i = 1:numel(obj.processed_data)
                if isempty(obj.processed_data{i})
                    continue;
                end
                [~, name, ~] = fileparts(obj.files(i).name);
                outfile = fullfile(processed_dir, [name '_processed.' opts.format]);
                edata.export(obj.processed_data{i}, outfile);
            end

            % 导出分析结果
            if ~isempty(fieldnames(obj.results))
                results_dir = fullfile(output_dir, 'results');
                if ~exist(results_dir, 'dir')
                    mkdir(results_dir);
                end

                methods = fieldnames(obj.results);
                for m = 1:numel(methods)
                    method = methods{m};
                    outfile = fullfile(results_dir, [method '_results.mat']);
                    results_data = obj.results.(method);
                    save(outfile, 'results_data');
                    fprintf('   ✅ %s 结果已导出\n', method);
                end
            end

            % 生成报告
            if opts.report
                generate_report(obj, output_dir);
            end

            fprintf('✅ 导出完成\n');
        end

        function summary = get_summary(obj)
        %GET_SUMMARY 获取实验数据摘要
        %
        %   summary = exp.get_summary();

            summary = struct();
            summary.n_files = numel(obj.files);
            summary.n_processed = sum(cellfun(@(x) ~isempty(x), obj.processed_data));

            if ~isempty(obj.raw_data) && ~isempty(obj.raw_data{1})
                summary.n_channels = width(obj.raw_data{1});
                summary.n_samples = height(obj.raw_data{1});
                summary.channel_names = obj.raw_data{1}.Properties.VariableNames;
            end

            fprintf('📊 实验数据摘要:\n');
            fprintf('   文件数: %d\n', summary.n_files);
            fprintf('   已处理: %d\n', summary.n_processed);
            if isfield(summary, 'n_channels')
                fprintf('   通道数: %d\n", summary.n_channels);
                fprintf('   采样点: %d\n", summary.n_samples);
            end
        end
    end
end

function generate_report(obj, output_dir)
    report_file = fullfile(output_dir, 'experiment_report.md');
    fid = fopen(report_file, 'w');

    fprintf(fid, '# 实验数据处理报告\n\n');
    fprintf(fid, '- 生成时间: %s\n', datestr(now));
    fprintf(fid, '- 数据文件夹: %s\n', obj.data_folder);
    fprintf(fid, '- 文件数量: %d\n\n', numel(obj.files));

    fprintf(fid, '## 配置参数\n\n');
    fprintf(fid, '- 采样率: %d Hz\n', obj.config.Fs);
    fprintf(fid, '- 去直流: %s\n', mat2str(obj.config.remove_dc));
    if ~isempty(obj.config.filter_fc)
        fprintf(fid, '- 滤波: %s @ %d Hz\n', obj.config.filter_type, obj.config.filter_fc);
    end

    if isfield(obj.results, 'stats')
        fprintf(fid, '\n## 统计结果\n\n');
        fprintf(fid, '| 文件 | 均值 | 标准差 | RMS | 峰值 |\n');
        fprintf(fid, '|------|------|--------|-----|------|\n');
        for i = 1:numel(obj.results.stats)
            if isempty(obj.results.stats{i})
                continue;
            end
            stats = obj.results.stats{i};
            fields = fieldnames(stats);
            s = stats.(fields{1});
            fprintf(fid, '| %s | %.4f | %.4f | %.4f | %.4f |\n', ...
                obj.files(i).name, s.mean, s.std, s.rms, s.peak);
        end
    end

    fclose(fid);
    fprintf('   ✅ 报告已生成: %s\n', report_file);
end
