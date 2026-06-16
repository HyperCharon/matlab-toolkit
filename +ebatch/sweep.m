function results = sweep(model, varargin)
%EBATCH.SWEEP 参数扫描仿真
%
%   results = ebatch.sweep('my_model.slx', 'Kp', linspace(0.1, 10, 20))
%   results = ebatch.sweep('my_model.slx', ...
%       'Kp', linspace(0.1, 10, 20), ...
%       'Ki', linspace(0.01, 5, 20))
%   results = ebatch.sweep('my_model.slx', ...
%       'Kp', linspace(0.1, 10, 10), ...
%       'Ki', linspace(0.01, 5, 10), ...
%       'parallel', true, ...
%       'metrics', {'overshoot', 'settling_time', 'steady_state_error'})
%
%   输入:
%     model   - Simulink 模型名称 (不含 .slx)
%     名值对  - 参数名和扫描范围
%
%   可选参数:
%     'parallel'  - 是否并行计算 (默认 false)
%     'metrics'   - 要计算的性能指标列表
%     'output'    - 输出目录 (默认 'ebatch_results')
%     'timeout'   - 单次仿真超时时间 (秒, 默认 60)
%
%   输出:
%     results - 结构体，包含参数组合和对应的仿真结果
%
%   示例:
%     results = ebatch.sweep('motor_control', ...
%         'Kp', [0.5 1 2 5], ...
%         'Ki', [0.1 0.5 1], ...
%         'parallel', true, ...
%         'metrics', {'overshoot', 'settling_time'});
%
%   See also ebatch.plot_surface, ebatch.plot_heatmap, ebatch.export_report

    % 解析输入参数
    opts = struct('parallel', false, 'metrics', {{'overshoot', 'settling_time'}}, ...
                  'output', 'ebatch_results', 'timeout', 60, 'reference', 1);
    params = struct();
    param_names = {};
    param_values = {};

    i = 1;
    while i <= numel(varargin)
        if isfield(opts, varargin{i})
            opts.(varargin{i}) = varargin{i+1};
            i = i + 2;
        else
            name = varargin{i};
            value = varargin{i+1};
            params.(name) = value;
            param_names{end+1} = name;
            param_values{end+1} = value;
            i = i + 2;
        end
    end

    if isempty(param_names)
        error('ebatch:sweep:noParams', '至少需要指定一个扫描参数');
    end

    % 确保 metrics 是 cell array
    if ischar(opts.metrics)
        opts.metrics = {opts.metrics};
    end

    % 生成参数网格
    [grid_values{1:numel(param_names)}] = ndgrid(param_values{:});
    n_combinations = numel(grid_values{1});

    fprintf('🔄 参数扫描配置:\n');
    fprintf('   模型:     %s\n', model);
    for i = 1:numel(param_names)
        fprintf('   %s:       %d 个值 [%.4f ... %.4f]\n', ...
            param_names{i}, numel(param_values{i}), param_values{i}(1), param_values{i}(end));
    end
    fprintf('   总组合数: %d\n', n_combinations);
    fprintf('   并行:     %s\n', mat2str(opts.parallel));
    fprintf('   指标:     %s\n', strjoin(opts.metrics, ', '));
    fprintf('\n');

    % 创建输出目录
    if ~exist(opts.output, 'dir')
        mkdir(opts.output);
    end

    % 加载模型
    try
        load_system(model);
    catch
        error('ebatch:sweep:modelNotFound', '无法加载模型: %s', model);
    end

    % 初始化结果存储
    results.model = model;
    results.param_names = param_names;
    results.param_values = param_values;
    results.grid_values = grid_values;
    results.n_combinations = n_combinations;
    results.metrics = opts.metrics;
    results.data = struct();

    % 初始化指标数组
    for m = 1:numel(opts.metrics)
        results.data.(opts.metrics{m}) = zeros(size(grid_values{1}));
    end

    % 执行仿真
    fprintf('⏳ 开始仿真...\n');
    t_start = tic;

    % 初始化临时存储
    metric_results = struct();
    for m = 1:numel(opts.metrics)
        metric_results.(opts.metrics{m}) = zeros(n_combinations, 1);
    end

    if opts.parallel && license('test', 'Distrib_Computing_Toolbox')
        % 并行仿真
        fprintf('   使用并行计算 (parfor)\n');
        parfor idx = 1:n_combinations
            local_metrics = run_single_sim(model, param_names, grid_values, idx, opts);
            for m = 1:numel(opts.metrics)
                metric_results.(opts.metrics{m})(idx) = local_metrics.(opts.metrics{m});
            end
        end
    else
        % 串行仿真
        if opts.parallel
            warning('ebatch:sweep:noParallel', '未检测到 Parallel Computing Toolbox，使用串行计算');
        end

        for idx = 1:n_combinations
            % 显示进度
            if mod(idx, max(1, floor(n_combinations/20))) == 0 || idx == 1
                fprintf('   [%d/%d] %.1f%%\n', idx, n_combinations, idx/n_combinations*100);
            end

            % 设置参数
            for p = 1:numel(param_names)
                assignin('base', param_names{p}, grid_values{p}(idx));
            end

            % 运行仿真
            try
                sim_out = sim(model, 'Timeout', opts.timeout);

                % 提取指标
                metrics = extract_metrics(sim_out, opts.metrics, opts);
                for m = 1:numel(opts.metrics)
                    metric_results.(opts.metrics{m})(idx) = metrics.(opts.metrics{m});
                end
            catch ME
                fprintf('   ⚠️  仿真 %d 失败: %s\n', idx, ME.message);
                for m = 1:numel(opts.metrics)
                    metric_results.(opts.metrics{m})(idx) = NaN;
                end
            end
        end
    end

    % 将结果存入结构体
    for m = 1:numel(opts.metrics)
        results.data.(opts.metrics{m}) = reshape(metric_results.(opts.metrics{m}), size(grid_values{1}));
    end

    elapsed = toc(t_start);
    fprintf('\n✅ 仿真完成! 耗时: %.1f 秒\n', elapsed);
    fprintf('   平均每次: %.2f 秒\n', elapsed / n_combinations);

    % 保存结果
    save(fullfile(opts.output, 'sweep_results.mat'), 'results');
    fprintf('💾 结果已保存到: %s/sweep_results.mat\n', opts.output);
end

function metrics = extract_metrics(sim_out, metric_names, opts)
    metrics = struct();
    y = sim_out.yout;
    t = sim_out.tout;

    for i = 1:numel(metric_names)
        switch lower(metric_names{i})
            case 'overshoot'
                if ~isempty(y)
                    y_data = y{1}.Values.Data;
                    peak = max(y_data);
                    steady = y_data(end);
                    if steady ~= 0
                        metrics.overshoot = max(0, (peak - steady) / abs(steady) * 100);
                    else
                        metrics.overshoot = 0;
                    end
                else
                    metrics.overshoot = NaN;
                end

            case 'settling_time'
                if ~isempty(y)
                    y_data = y{1}.Values.Data;
                    steady = y_data(end);
                    tol = 0.02 * abs(steady);
                    settled = find(abs(y_data - steady) > tol, 1, 'last');
                    if ~isempty(settled)
                        metrics.settling_time = t(settled);
                    else
                        metrics.settling_time = 0;
                    end
                else
                    metrics.settling_time = NaN;
                end

            case 'rise_time'
                if ~isempty(y)
                    y_data = y{1}.Values.Data;
                    steady = y_data(end);
                    idx_10 = find(y_data >= 0.1*steady, 1);
                    idx_90 = find(y_data >= 0.9*steady, 1);
                    if ~isempty(idx_10) && ~isempty(idx_90)
                        metrics.rise_time = t(idx_90) - t(idx_10);
                    else
                        metrics.rise_time = NaN;
                    end
                else
                    metrics.rise_time = NaN;
                end

            case 'steady_state_error'
                if ~isempty(y)
                    y_data = y{1}.Values.Data;
                    metrics.steady_state_error = abs(opts.reference - y_data(end));
                else
                    metrics.steady_state_error = NaN;
                end

            case 'peak_value'
                if ~isempty(y)
                    metrics.peak_value = max(y{1}.Values.Data);
                else
                    metrics.peak_value = NaN;
                end

            case 'final_value'
                if ~isempty(y)
                    metrics.final_value = y{1}.Values.Data(end);
                else
                    metrics.final_value = NaN;
                end

            case 'iae'
                % 积分绝对误差
                if ~isempty(y)
                    y_data = y{1}.Values.Data;
                    t_data = t;
                    error_signal = opts.reference - y_data;
                    metrics.iae = trapz(t_data, abs(error_signal));
                else
                    metrics.iae = NaN;
                end

            case 'ise'
                % 积分平方误差
                if ~isempty(y)
                    y_data = y{1}.Values.Data;
                    t_data = t;
                    error_signal = opts.reference - y_data;
                    metrics.ise = trapz(t_data, error_signal.^2);
                else
                    metrics.ise = NaN;
                end

            otherwise
                warning('ebatch:unknownMetric', '未知指标: %s', metric_names{i});
                metrics.(metric_names{i}) = NaN;
        end
    end
end

function metrics = run_single_sim(model, param_names, grid_values, idx, opts)
    % 设置参数
    for p = 1:numel(param_names)
        assignin('base', param_names{p}, grid_values{p}(idx));
    end

    % 初始化指标
    metrics = struct();
    for m = 1:numel(opts.metrics)
        metrics.(opts.metrics{m}) = NaN;
    end

    % 运行仿真
    try
        sim_out = sim(model, 'Timeout', opts.timeout);
        metrics = extract_metrics(sim_out, opts.metrics, opts);
    catch ME
        warning('ebatch:sweep:simFailed', '仿真失败: %s', ME.message);
    end
end
