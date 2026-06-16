function results = sensitivity(model_name, param_name, variations, metric, varargin)
%ESIMULINK.SENSITIVITY 参数灵敏度分析
%
%   results = esimulink.sensitivity('my_model', 'Kp', [0.5 0.8 1.0 1.2 1.5], 'overshoot')
%   results = esimulink.sensitivity('my_model', 'R', linspace(0.8, 1.2, 11)*100, 'peak_voltage')
%
%   输入:
%     model_name  - Simulink 模型名
%     param_name  - 要分析的参数名
%     variations  - 参数变化值（可以是绝对值或标称值的倍数）
%     metric      - 要观测的指标名（对应 To Workspace 变量）
%
%   可选参数:
%     'nominal'   - 标称值 (默认自动从模型读取)
%     'relative'  - variations 是否为相对值 (默认 false)
%     'plot'      - 是否绘图 (默认 true)
%     'style'     - eplot 样式
%
%   See also esimulink.check_model, ebatch.sweep

    opts = struct('nominal', [], 'relative', false, 'plot', true, 'style', '');
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    % 加载模型
    try
        load_system(model_name);
    catch
        error('esimulink:sensitivity:modelNotFound', '无法加载模型: %s', model_name);
    end

    % 获取标称值
    if isempty(opts.nominal)
        try
            opts.nominal = evalin('base', param_name);
        catch
            error('esimulink:sensitivity:paramNotFound', ...
                '无法获取参数 %s 的标称值', param_name);
        end
    end

    % 如果是相对值，转换为绝对值
    if opts.relative
        variations = opts.nominal * variations;
    end

    n = numel(variations);
    metric_values = zeros(n, 1);

    fprintf('📊 参数灵敏度分析:\n');
    fprintf('   模型:     %s\n', model_name);
    fprintf('   参数:     %s (标称值: %.4f)\n', param_name, opts.nominal);
    fprintf('   变化范围: [%.4f, %.4f] (%d 个点)\n', variations(1), variations(end), n);
    fprintf('   指标:     %s\n\n', metric);

    % 逐个仿真
    for i = 1:n
        % 设置参数
        assignin('base', param_name, variations(i));

        try
            sim_out = sim(model_name);

            % 提取指标
            if isfield(sim_out, 'yout') && ~isempty(sim_out.yout)
                y = sim_out.yout;
                if isstruct(y) && isfield(y, metric)
                    metric_values(i) = y.(metric).Data(end);
                elseif istimetable(y)
                    metric_values(i) = y.(metric)(end);
                else
                    % 尝试直接从工作区获取
                    metric_values(i) = evalin('base', metric);
                end
            else
                metric_values(i) = evalin('base', metric);
            end
        catch ME
            fprintf('   ⚠️  仿真 %d 失败: %s\n', i, ME.message);
            metric_values(i) = NaN;
        end
    end

    % 恢复标称值
    assignin('base', param_name, opts.nominal);

    % 计算灵敏度
    valid_idx = ~isnan(metric_values);
    if sum(valid_idx) >= 2
        % 线性拟合
        p = polyfit(variations(valid_idx), metric_values(valid_idx), 1);
        mean_val = mean(metric_values(valid_idx));
        if abs(mean_val) < eps
            sensitivity_coeff = NaN;
        else
            sensitivity_coeff = p(1) * opts.nominal / mean_val;
        end

        % 归一化灵敏度 (使用有效数据点的首尾)
        valid_variations = variations(valid_idx);
        valid_metrics = metric_values(valid_idx);
        delta_param = (valid_variations(end) - valid_variations(1)) / opts.nominal;
        if abs(mean_val) < eps || delta_param == 0
            normalized_sensitivity = NaN;
        else
            delta_metric = (valid_metrics(end) - valid_metrics(1)) / mean_val;
            normalized_sensitivity = delta_metric / delta_param;
        end
    else
        sensitivity_coeff = NaN;
        normalized_sensitivity = NaN;
    end

    % 结果
    results.param_name = param_name;
    results.nominal = opts.nominal;
    results.variations = variations;
    results.metric = metric;
    results.metric_values = metric_values;
    results.sensitivity_coeff = sensitivity_coeff;
    results.normalized_sensitivity = normalized_sensitivity;

    % 打印结果
    fprintf('📊 灵敏度分析结果:\n');
    fprintf('   指标范围: [%.4f, %.4f]\n', min(metric_values), max(metric_values));
    fprintf('   灵敏度系数: %.4f\n', sensitivity_coeff);
    fprintf('   归一化灵敏度: %.4f\n', normalized_sensitivity);

    if abs(normalized_sensitivity) > 1
        fprintf('   ⚠️  高灵敏度参数！小变化会导致指标大幅波动\n');
    elseif abs(normalized_sensitivity) < 0.1
        fprintf('   ✅ 低灵敏度参数，指标对参数变化不敏感\n');
    end

    % 绘图
    if opts.plot
        fig = figure('Name', sprintf('Sensitivity: %s', param_name));

        yyaxis left;
        plot(variations, metric_values, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 6);
        ylabel(metric);

        yyaxis right;
        % 相对变化
        rel_change = (variations - opts.nominal) / opts.nominal * 100;
        bar(rel_change, 0.3, 'FaceAlpha', 0.3);
        ylabel('Parameter Change (%)');

        xlabel(param_name);
        title(sprintf('Sensitivity Analysis: %s vs %s', metric, param_name));

        % 标称线
        xline(opts.nominal, 'r--', 'LineWidth', 1.5, 'Label', 'Nominal');

        grid on;

        if ~isempty(opts.style)
            eplot.style(fig, opts.style);
        end
    end
end
