function results = benchmark(varargin)
%EUTILS.BENCHMARK 性能基准测试工具
%
%   results = eutils.benchmark('my_function', 'inputs', {arg1, arg2})
%   results = eutils.benchmark(@func_handle, 'iterations', 100)
%   eutils.benchmark('compare', func1, func2, 'inputs', {args})
%
%   可选参数:
%     'inputs'      - 函数输入参数 (cell array)
%     'iterations'  - 测量迭代次数 (默认 100)
%     'warmup'      - 预热次数 (默认 5)
%     'verbose'     - 是否显示详细信息 (默认 true)
%
%   See also eutils.optimize, timeit, gputimeit

    % 解析输入
    if ischar(varargin{1}) && strcmp(varargin{1}, 'compare')
        % 比较模式
        func1 = varargin{2};
        func2 = varargin{3};
        varargin = varargin(4:end);
        compare_mode = true;
    else
        func = varargin{1};
        varargin = varargin(2:end);
        compare_mode = false;
    end

    opts = struct('inputs', {[]}, 'iterations', 100, 'warmup', 5, 'verbose', true);
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    if compare_mode
        results = run_comparison(func1, func2, opts);
    else
        results = run_single(func, opts);
    end
end

function results = run_single(func, opts)
    % 获取函数句柄
    if ischar(func)
        func_name = func;
        func_handle = str2func(func);
    else
        func_name = func2str(func);
        func_handle = func;
    end

    fprintf('⏱️  性能基准测试: %s\n', func_name);
    fprintf('   迭代次数: %d\n', opts.iterations);
    fprintf('   预热次数: %d\n\n', opts.warmup);

    % 预热
    fprintf('   预热中...\n');
    for i = 1:opts.warmup
        try
            if isempty(opts.inputs)
                func_handle();
            else
                func_handle(opts.inputs{:});
            end
        catch
        end
    end

    % 正式测量
    fprintf('   测量中...\n');
    times = zeros(opts.iterations, 1);

    for i = 1:opts.iterations
        tic;
        try
            if isempty(opts.inputs)
                func_handle();
            else
                func_handle(opts.inputs{:});
            end
        catch ME
            fprintf('   ⚠️  迭代 %d 失败: %s\n', i, ME.message);
            times(i) = NaN;
            continue;
        end
        times(i) = toc;
    end

    % 统计分析
    valid_times = times(~isnan(times));
    results.func_name = func_name;
    results.iterations = numel(valid_times);
    results.times = valid_times;
    results.mean = mean(valid_times);
    results.median = median(valid_times);
    results.std = std(valid_times);
    results.min = min(valid_times);
    results.max = max(valid_times);
    results.p5 = prctile(valid_times, 5);
    results.p95 = prctile(valid_times, 95);
    results.iqr = results.p95 - results.p5;

    % 使用 timeit 获取精确测量
    try
        if isempty(opts.inputs)
            results.timeit = timeit(func_handle);
        else
            f = @() func_handle(opts.inputs{:});
            results.timeit = timeit(f);
        end
    catch
        results.timeit = NaN;
    end

    % 显示结果
    if opts.verbose
        fprintf('\n📊 基准测试结果:\n');
        fprintf('   函数:     %s\n', func_name);
        fprintf('   有效迭代: %d\n', results.iterations);
        fprintf('   ───── 统计 ─────\n');
        fprintf('   均值:     %.6f s\n', results.mean);
        fprintf('   中位数:   %.6f s\n', results.median);
        fprintf('   标准差:   %.6f s\n', results.std);
        fprintf('   最小值:   %.6f s\n', results.min);
        fprintf('   最大值:   %.6f s\n', results.max);
        fprintf('   P5:       %.6f s\n', results.p5);
        fprintf('   P95:      %.6f s\n', results.p95);
        if ~isnan(results.timeit)
            fprintf('   ───── timeit ─────\n');
            fprintf('   timeit:   %.6f s\n', results.timeit);
        end
    end
end

function results = run_comparison(func1, func2, opts)
    % 获取函数信息
    if ischar(func1)
        name1 = func1;
        handle1 = str2func(func1);
    else
        name1 = func2str(func1);
        handle1 = func1;
    end

    if ischar(func2)
        name2 = func2;
        handle2 = str2func(func2);
    else
        name2 = func2str(func2);
        handle2 = func2;
    end

    fprintf('🏁 性能对比测试\n');
    fprintf('   函数 1: %s\n', name1);
    fprintf('   函数 2: %s\n', name2);
    fprintf('   迭代次数: %d\n\n', opts.iterations);

    % 测试函数 1
    fprintf('   测试 %s...\n', name1);
    results1 = run_single(handle1, opts);

    % 测试函数 2
    fprintf('\n   测试 %s...\n', name2);
    results2 = run_single(handle2, opts);

    % 对比分析
    results.func1 = results1;
    results.func2 = results2;
    results.speedup = results1.mean / results2.mean;
    results.faster = name1;
    if results.speedup < 1
        results.speedup = 1 / results.speedup;
        results.faster = name2;
    end

    % 统计显著性检验
    try
        [h, p] = ttest2(results1.times, results2.times);
        results.ttest_h = h;
        results.ttest_p = p;
        results.significant = h;
    catch
        results.ttest_h = NaN;
        results.ttest_p = NaN;
        results.significant = NaN;
    end

    % 显示对比结果
    fprintf('\n📊 对比结果:\n');
    fprintf('   %-30s %12s %12s\n', '指标', name1, name2);
    fprintf('   %s\n', repmat('-', 1, 56));
    fprintf('   %-30s %12.6f %12.6f\n', '均值 (s)', results1.mean, results2.mean);
    fprintf('   %-30s %12.6f %12.6f\n', '中位数 (s)', results1.median, results2.median);
    fprintf('   %-30s %12.6f %12.6f\n', '标准差 (s)', results1.std, results2.std);
    fprintf('   %-30s %12.6f %12.6f\n', '最小值 (s)', results1.min, results2.min);
    fprintf('   %-30s %12.6f %12.6f\n', 'P95 (s)', results1.p95, results2.p95);

    fprintf('\n   🏆 %s 快 %.2fx\n', results.faster, results.speedup);

    if ~isnan(results.significant)
        if results.significant
            fprintf('   ✅ 差异统计显著 (p = %.4f)\n', results.ttest_p);
        else
            fprintf('   ⚠️  差异统计不显著 (p = %.4f)\n', results.ttest_p);
        end
    end
end
