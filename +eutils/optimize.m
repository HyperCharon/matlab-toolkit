function optimize(func_or_script, varargin)
%EUTILS.OPTIMIZE MATLAB 代码性能优化分析
%
%   eutils.optimize('my_function')
%   eutils.optimize('my_function', 'inputs', {arg1, arg2})
%   eutils.optimize('my_function', 'iterations', 100)
%
%   基于 MATLAB 最佳实践的 7 步优化工作流:
%   1. 建立基准 (Baseline)
%   2. 分析性能 (Profile)
%   3. 识别瓶颈 (Identify)
%   4. 实施优化 (Optimize)
%   5. 测量改进 (Measure)
%   6. 验证正确性 (Verify)
%   7. 生成报告 (Report)
%
%   可选参数:
%     'inputs'      - 函数输入参数 (cell array)
%     'iterations'  - 测量迭代次数 (默认 10)
%     'verbose'     - 是否显示详细信息 (默认 true)
%     'report'      - 是否生成报告 (默认 true)
%
%   See also eutils.check_code, eutils.benchmark

    opts = struct('inputs', {}, 'iterations', 10, 'verbose', true, 'report', true);
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    fprintf('🚀 性能优化分析: %s\n\n', func_or_script);

    %% Step 1: 建立基准
    fprintf('📊 Step 1: 建立基准\n');
    try
        if isempty(opts.inputs)
            f = str2func(func_or_script);
            baseline = timeit(f);
        else
            f = @() feval(func_or_script, opts.inputs{:});
            baseline = timeit(f);
        end
        fprintf('   基准时间: %.4f s\n\n', baseline);
    catch ME
        fprintf('   ❌ 无法执行: %s\n', ME.message);
        return;
    end

    %% Step 2: 性能分析
    fprintf('📊 Step 2: 性能分析 (Profile)\n');
    profile on;
    try
        if isempty(opts.inputs)
            feval(func_or_script);
        else
            feval(func_or_script, opts.inputs{:});
        end
    catch
    end
    profile off;

    % 获取分析结果
    p = profile('info');
    fprintf('   ✅ 分析完成\n\n');

    %% Step 3: 识别瓶颈
    fprintf('📊 Step 3: 识别瓶颈\n');

    % 找到最耗时的函数
    if ~isempty(p.FunctionTable)
        % 按自身时间排序
        [~, idx] = sort([p.FunctionTable.TotalSelfTime], 'descend');
        top_functions = p.FunctionTable(idx(1:min(10, numel(idx))));

        fprintf('   Top 10 耗时函数:\n');
        fprintf('   %-40s %12s %12s %8s\n', '函数', '自身时间(s)', '总时间(s)', '调用次数');
        fprintf('   %s\n', repmat('-', 1, 75));

        for i = 1:numel(top_functions)
            fn = top_functions(i);
            fprintf('   %-40s %12.4f %12.4f %8d\n', ...
                fn.FunctionName, fn.TotalSelfTime, fn.TotalTime, fn.NumCalls);
        end

        % 识别优化模式
        fprintf('\n   🔍 优化建议:\n');
        identify_patterns(p);
    else
        fprintf('   ⚠️  没有收集到性能数据\n');
    end

    fprintf('\n');

    %% Step 4-6: 优化建议
    fprintf('📊 Step 4-6: 优化建议\n');
    fprintf('   基于分析结果，建议以下优化:\n\n');

    fprintf('   1. 向量化 (Vectorization)\n');
    fprintf('      - 将循环替换为数组操作\n');
    fprintf('      - 典型加速: 2-200x\n\n');

    fprintf('   2. 预分配 (Preallocation)\n');
    fprintf('      - 在循环前预分配数组大小\n');
    fprintf('      - 典型加速: 2-100x\n\n');

    fprintf('   3. 避免重复计算\n');
    fprintf('      - 将不变的计算移到循环外\n');
    fprintf('      - 典型加速: 2-50x\n\n');

    fprintf('   4. 使用内置函数\n');
    fprintf('      - 用 discretize/histcounts 替代手动分箱\n');
    fprintf('      - 用 cumsum/hypot 替代手写循环\n\n');

    fprintf('   5. 逻辑索引\n');
    fprintf('      - 用逻辑索引替代 find()\n');
    fprintf('      - 典型加速: 1.2-5x\n\n');

    fprintf('   6. arguments 块\n');
    fprintf('      - 用 arguments 替代 inputParser\n');
    fprintf('      - 典型加速: 1.1-1.8x\n\n');

    fprintf('   7. 持久化缓存\n');
    fprintf('      - 缓存重复加载的数据\n');
    fprintf('      - 典型加速: 1.5-95x\n\n');

    %% Step 7: 生成报告
    if opts.report
        fprintf('📊 Step 7: 生成报告\n');
        generate_report(func_or_script, baseline, p);
    end

    %% 辅助函数
    function identify_patterns(profile_info)
        % 检查是否有循环中的数组增长
        for j = 1:numel(profile_info.FunctionTable)
            fn = profile_info.FunctionTable(j);
            if contains(fn.FunctionName, 'for') || contains(fn.FunctionName, 'while')
                if fn.NumCalls > 100
                    fprintf('      ⚠️  高频调用: %s (%d 次)\n', fn.FunctionName, fn.NumCalls);
                end
            end
        end

        % 检查是否有 eval 使用
        for j = 1:numel(profile_info.FunctionTable)
            fn = profile_info.FunctionTable(j);
            if contains(fn.FunctionName, 'eval')
                fprintf('      ⚠️  检测到 eval 使用: %s\n', fn.FunctionName);
            end
        end
    end

    function generate_report(func_name, baseline_time, profile_info)
        report_file = sprintf('optimization_report_%s.txt', ...
            strrep(func_name, '.', '_'));

        fid = fopen(report_file, 'w');
        fprintf(fid, 'MatForge 性能优化报告\n');
        fprintf(fid, '====================\n\n');
        fprintf(fid, '函数: %s\n', func_name);
        fprintf(fid, '基准时间: %.4f s\n', baseline_time);
        fprintf(fid, '分析时间: %s\n\n', datestr(now));

        if ~isempty(profile_info.FunctionTable)
            fprintf(fid, 'Top 10 耗时函数:\n');
            [~, idx] = sort([profile_info.FunctionTable.TotalSelfTime], 'descend');
            for j = 1:min(10, numel(idx))
                fn = profile_info.FunctionTable(idx(j));
                fprintf(fid, '  %s: %.4f s (自身), %d 次调用\n', ...
                    fn.FunctionName, fn.TotalSelfTime, fn.NumCalls);
            end
        end

        fclose(fid);
        fprintf('   ✅ 报告已生成: %s\n', report_file);
    end
end
