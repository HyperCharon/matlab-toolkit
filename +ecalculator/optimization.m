classdef optimization
%ECALCULATOR.OPTIMIZATION 优化与决策分析工具
%
%   ecalculator.optimization.topsis(D, W, type)           TOPSIS 综合评价
%   ecalculator.optimization.ahp(A)                       层次分析法
%   ecalculator.optimization.grey_predict(X0, n_predict)   灰色预测 GM(1,1)
%   ecalculator.optimization.linear_programming(f, A, b)   线性规划
%   ecalculator.optimization.multi_objective(X, objs)      多目标优化
%   ecalculator.optimization.sensitivity_analysis(func, x0, params)  灵敏度分析
%
%   See also ecalculator.statistics, ecalculator.ml

    methods(Static)
        function info = topsis(D, W, type)
        %TOPSIS 逼近理想解排序法 (TOPSIS)
        %
        %   info = ecalculator.optimization.topsis(D, W, type)
        %
        %   输入:
        %     D    - 决策矩阵 (m x n)，m 个方案，n 个指标
        %     W    - 权重向量 (1 x n)，各指标权重
        %     type - 指标类型 (1 x n)，1=效益型，2=成本型
        %
        %   输出:
        %     info.C      - 相对接近度
        %     info.rank   - 排名
        %     info.D_plus - 到正理想解距离
        %     info.D_minus- 到负理想解距离
        %
        %   示例:
        %     D = [80 90 85; 70 80 90; 90 85 80];
        %     W = [0.3, 0.3, 0.4];
        %     type = [1, 1, 1];
        %     info = ecalculator.optimization.topsis(D, W, type)

            [m, n] = size(D);

            % 参数验证
            if numel(W) ~= n
                error('ecalculator:optimization:dimMismatch', ...
                    '权重数量 (%d) 与指标数量 (%d) 不匹配', numel(W), n);
            end
            if abs(sum(W) - 1) > 1e-6
                warning('ecalculator:optimization:weightSum', ...
                    '权重之和不为 1 (%.4f)，已自动归一化', sum(W));
                W = W / sum(W);
            end

            % 向量化归一化
            D_norm = D ./ sqrt(sum(D.^2));

            % 加权归一化
            V = D_norm .* W;

            % 确定正负理想解
            V_plus = zeros(1, n);
            V_minus = zeros(1, n);
            for j = 1:n
                if type(j) == 1  % 效益型
                    V_plus(j) = max(V(:, j));
                    V_minus(j) = min(V(:, j));
                else  % 成本型
                    V_plus(j) = min(V(:, j));
                    V_minus(j) = max(V(:, j));
                end
            end

            % 计算距离
            D_plus = sqrt(sum((V - V_plus).^2, 2));
            D_minus = sqrt(sum((V - V_minus).^2, 2));

            % 相对接近度
            C = D_minus ./ (D_plus + D_minus);

            % 排名
            [~, rank_idx] = sort(C, 'descend');
            rank = zeros(m, 1);
            rank(rank_idx) = 1:m;

            fprintf('📊 TOPSIS 综合评价结果:\n');
            fprintf('   方案数: %d, 指标数: %d\n', m, n);
            fprintf('   ───── 排名 ─────\n');
            for i = 1:m
                fprintf('   第 %d 名: 方案 %d (C=%.4f)\n', i, rank_idx(i), C(rank_idx(i)));
            end

            info.C = C;
            info.rank = rank;
            info.D_plus = D_plus;
            info.D_minus = D_minus;
            info.V = V;
            info.V_plus = V_plus;
            info.V_minus = V_minus;
        end

        function info = ahp(A)
        %AHP 层次分析法 (Analytic Hierarchy Process)
        %
        %   info = ecalculator.optimization.ahp(A)
        %
        %   输入:
        %     A - 判断矩阵 (n x n)，必须为正互反矩阵
        %
        %   输出:
        %     info.weights     - 权重向量
        %     info.lambda_max  - 最大特征值
        %     info.CI          - 一致性指标
        %     info.CR          - 一致性比率
        %     info.consistent  - 是否通过一致性检验
        %
        %   示例:
        %     A = [1 1/3 1/5; 3 1 1/2; 5 2 1];
        %     info = ecalculator.optimization.ahp(A)

            n = size(A, 1);

            % 参数验证
            if size(A, 2) ~= n
                error('ecalculator:optimization:notSquare', '判断矩阵必须是方阵');
            end

            % 计算特征值和特征向量
            [V, D] = eig(A);
            eigenvalues = diag(D);
            [lambda_max, idx] = max(real(eigenvalues));
            w = real(V(:, idx));
            w = w / sum(w);  % 归一化

            % 一致性检验
            CI = (lambda_max - n) / (n - 1);
            RI_table = [0 0 0.58 0.90 1.12 1.24 1.32 1.41 1.45 1.49];
            if n <= numel(RI_table)
                RI = RI_table(n);
            else
                RI = 1.49;  % 最大值
            end
            CR = CI / RI;

            consistent = CR < 0.1;

            fprintf('📊 层次分析法 (AHP) 结果:\n');
            fprintf('   矩阵阶数: %d\n', n);
            fprintf('   ───── 权重 ─────\n');
            for i = 1:n
                fprintf('   W%d = %.4f\n', i, w(i));
            end
            fprintf('   ───── 一致性检验 ─────\n');
            fprintf('   最大特征值: %.4f\n', lambda_max);
            fprintf('   CI: %.4f\n', CI);
            fprintf('   RI: %.4f\n', RI);
            fprintf('   CR: %.4f\n', CR);

            if consistent
                fprintf('   ✅ 通过一致性检验 (CR < 0.1)\n');
            else
                fprintf('   ❌ 未通过一致性检验，需要调整判断矩阵\n');
            end

            info.weights = w;
            info.lambda_max = lambda_max;
            info.CI = CI;
            info.RI = RI;
            info.CR = CR;
            info.consistent = consistent;
        end

        function info = grey_predict(X0, n_predict)
        %GREY_PREDICT 灰色预测 GM(1,1)
        %
        %   info = ecalculator.optimization.grey_predict(X0, n_predict)
        %
        %   输入:
        %     X0        - 原始数据序列 (1 x n)
        %     n_predict - 预测期数 (默认 3)
        %
        %   输出:
        %     info.predictions - 预测值（含原始数据拟合和未来预测）
        %     info.a           - 发展系数
        %     info.b           - 灰色作用量
        %     info.R2          - 拟合优度
        %     info.relative_error - 相对误差
        %
        %   示例:
        %     X0 = [2.874, 3.278, 3.337, 3.390, 3.679];
        %     info = ecalculator.optimization.grey_predict(X0, 3)

            if nargin < 2, n_predict = 3; end

            X0 = X0(:)';  % 确保行向量
            n = numel(X0);

            % 累加生成序列 (AGO)
            X1 = cumsum(X0);

            % 紧邻均值生成序列
            Z1 = 0.5 * (X1(1:end-1) + X1(2:end));

            % 最小二乘求参数
            B = [-Z1', ones(n-1, 1)];
            Y = X0(2:end)';
            u = B \ Y;
            a = u(1);
            b = u(2);

            % 预测累加序列
            X1_hat = zeros(n + n_predict, 1);
            X1_hat(1) = X1(1);
            for k = 2:n + n_predict
                X1_hat(k) = (X0(1) - b/a) * exp(-a*(k-1)) + b/a;
            end

            % 还原预测值
            X0_hat = diff([0; X1_hat]);

            % 计算拟合优度
            X0_fit = X0_hat(1:n);
            SS_res = sum((X0 - X0_fit).^2);
            SS_tot = sum((X0 - mean(X0)).^2);
            R2 = 1 - SS_res / SS_tot;

            % 相对误差
            relative_error = abs(X0 - X0_fit) ./ X0 * 100;

            fprintf('📊 灰色预测 GM(1,1) 结果:\n');
            fprintf('   原始数据点: %d\n', n);
            fprintf('   预测期数:   %d\n', n_predict);
            fprintf('   ───── 模型参数 ─────\n');
            fprintf('   发展系数 a: %.6f\n', a);
            fprintf('   灰作用量 b: %.6f\n', b);
            fprintf('   拟合优度 R²: %.4f\n', R2);
            fprintf('   ───── 预测结果 ─────\n');
            for i = 1:n + n_predict
                if i <= n
                    fprintf('   第 %d 期: %.4f (实际: %.4f, 误差: %.2f%%)\n', ...
                        i, X0_hat(i), X0(i), relative_error(i));
                else
                    fprintf('   第 %d 期: %.4f (预测)\n', i, X0_hat(i));
                end
            end

            % 级比检验
            lambda = X0(1:end-1) ./ X0(2:end);
            lambda_ok = all(lambda > exp(-2/(n+1))) && all(lambda < exp(2/(n+1)));
            if lambda_ok
                fprintf('   ✅ 级比检验通过\n');
            else
                fprintf('   ⚠️  级比检验未通过，预测精度可能较低\n');
            end

            info.predictions = X0_hat';
            info.a = a;
            info.b = b;
            info.R2 = R2;
            info.relative_error = relative_error';
            info.lambda = lambda;
            info.lambda_ok = lambda_ok;
        end

        function info = monte_carlo(func, n_samples, varargin)
        %MONTE_CARLO 蒙特卡洛模拟
        %
        %   info = ecalculator.optimization.monte_carlo(func, n_samples, ...)
        %
        %   输入:
        %     func      - 目标函数句柄
        %     n_samples - 模拟次数
        %     名值对    - 参数范围 'x1', [min, max], 'x2', [min, max], ...
        %
        %   输出:
        %     info.mean    - 期望值
        %     info.std     - 标准差
        %     info.CI_95   - 95% 置信区间
        %     info.samples - 样本值
        %
        %   示例:
        %     func = @(x) x(:,1).^2 + x(:,2).^2;
        %     info = ecalculator.optimization.monte_carlo(func, 10000, 'x1', [-1,1], 'x2', [-1,1])

            % 解析参数范围
            params = struct();
            param_names = {};
            i = 1;
            while i <= numel(varargin)
                param_names{end+1} = varargin{i};
                params.(varargin{i}) = varargin{i+1};
                i = i + 2;
            end

            n_params = numel(param_names);

            % 生成随机样本
            X = zeros(n_samples, n_params);
            for i = 1:n_params
                range = params.(param_names{i});
                X(:, i) = range(1) + (range(2) - range(1)) * rand(n_samples, 1);
            end

            % 计算目标函数值
            try
                Y = func(X);
            catch
                % 如果批量调用失败，逐个调用
                Y = zeros(n_samples, 1);
                for i = 1:n_samples
                    Y(i) = func(X(i, :));
                end
            end

            % 统计分析
            Y_mean = mean(Y);
            Y_std = std(Y);
            Y_sorted = sort(Y);
            CI_95 = [Y_sorted(round(0.025*n_samples)), Y_sorted(round(0.975*n_samples))];

            fprintf('📊 蒙特卡洛模拟结果:\n');
            fprintf('   模拟次数: %d\n', n_samples);
            fprintf('   参数数量: %d\n', n_params);
            fprintf('   ───── 统计结果 ─────\n');
            fprintf('   期望值:   %.6f\n', Y_mean);
            fprintf('   标准差:   %.6f\n', Y_std);
            fprintf('   95%% CI:   [%.6f, %.6f]\n', CI_95(1), CI_95(2));
            fprintf('   最小值:   %.6f\n', min(Y));
            fprintf('   最大值:   %.6f\n', max(Y));

            info.mean = Y_mean;
            info.std = Y_std;
            info.CI_95 = CI_95;
            info.samples = Y;
            info.X = X;
        end

        function info = sensitivity_analysis(func, x0, param_names, varargin)
        %SENSITIVITY_ANALYSIS 灵敏度分析
        %
        %   info = ecalculator.optimization.sensitivity_analysis(func, x0, param_names, ...)
        %
        %   输入:
        %     func        - 目标函数句柄
        %     x0          - 标称参数值 (1 x n)
        %     param_names - 参数名称 (cell array)
        %     'delta'     - 变化幅度 (默认 0.1，即 ±10%)
        %
        %   输出:
        %     info.sensitivity - 各参数灵敏度系数
        %     info.rank        - 灵敏度排名
        %
        %   示例:
        %     func = @(x) x(1)^2 + 2*x(2)^2;
        %     info = ecalculator.optimization.sensitivity_analysis(func, [1, 1], {'x1', 'x2'})

            opts = struct('delta', 0.1, 'n_points', 11, 'plot', true);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            n_params = numel(x0);
            y0 = func(x0);

            % 计算各参数灵敏度
            sensitivity = zeros(n_params, 1);
            param_variations = linspace(-opts.delta, opts.delta, opts.n_points);
            y_curves = zeros(opts.n_points, n_params);

            for i = 1:n_params
                y_values = zeros(opts.n_points, 1);
                for j = 1:opts.n_points
                    x_test = x0;
                    x_test(i) = x0(i) * (1 + param_variations(j));
                    y_values(j) = func(x_test);
                end
                y_curves(:, i) = y_values;

                % 灵敏度系数 = dy/dx * x/y
                p = polyfit(param_variations', y_values, 1);
                sensitivity(i) = abs(p(1) * x0(i) / y0);
            end

            % 排名
            [sensitivity_sorted, rank_idx] = sort(sensitivity, 'descend');
            rank = zeros(n_params, 1);
            rank(rank_idx) = 1:n_params;

            fprintf('📊 灵敏度分析结果:\n');
            fprintf('   标称输出值: %.6f\n', y0);
            fprintf('   变化幅度:   ±%.1f%%\n', opts.delta*100);
            fprintf('   ───── 灵敏度排名 ─────\n');
            for i = 1:n_params
                idx = rank_idx(i);
                fprintf('   第 %d 名: %s (灵敏度: %.4f)\n', ...
                    i, param_names{idx}, sensitivity_sorted(i));
            end

            % 绘图
            if opts.plot
                figure('Name', 'Sensitivity Analysis');
                subplot(1,2,1);
                bar(sensitivity);
                set(gca, 'XTickLabel', param_names);
                ylabel('灵敏度系数');
                title('参数灵敏度');
                grid on;

                subplot(1,2,2);
                plot(param_variations*100, y_curves, 'LineWidth', 1.5);
xlabel('参数变化 (%)');
ylabel('输出值');
title('参数变化对输出的影响');
legend(param_names, 'Location', 'best');
grid on;
            end

            info.sensitivity = sensitivity;
            info.rank = rank;
            info.y0 = y0;
            info.param_variations = param_variations;
            info.y_curves = y_curves;
        end

        function info = curve_fit(x, y, model_type)
        %CURVE_FIT 曲线拟合工具
        %
        %   info = ecalculator.optimization.curve_fit(x, y, 'linear')
        %
        %   输入:
        %     x, y       - 数据点
        %     model_type - 拟合模型: 'linear', 'quadratic', 'cubic',
        %                  'exponential', 'logarithmic', 'power'
        %
        %   输出:
        %     info.coefficients - 拟合系数
        %     info.R2           - 拟合优度
        %     info.RMSE         - 均方根误差
        %     info.y_fit        - 拟合值
        %
        %   示例:
        %     x = linspace(0, 2*pi, 50)';
        %     y = sin(x) + 0.1*randn(50,1);
        %     info = ecalculator.optimization.curve_fit(x, y, 'cubic');

            if nargin < 3, model_type = 'linear'; end

            x = x(:);
            y = y(:);

            switch lower(model_type)
                case 'linear'
                    p = polyfit(x, y, 1);
                    y_fit = polyval(p, x);
                    model_name = '线性拟合';

                case 'quadratic'
                    p = polyfit(x, y, 2);
                    y_fit = polyval(p, x);
                    model_name = '二次拟合';

                case 'cubic'
                    p = polyfit(x, y, 3);
                    y_fit = polyval(p, x);
                    model_name = '三次拟合';

                case 'exponential'
                    % y = a * exp(b*x)
                    valid = y > 0;
                    p = polyfit(x(valid), log(y(valid)), 1);
                    y_fit = exp(polyval(p, x));
                    p = [exp(p(2)), p(1)];  % [a, b]
                    model_name = '指数拟合';

                case 'logarithmic'
                    % y = a + b*ln(x)
                    valid = x > 0;
                    p = polyfit(log(x(valid)), y(valid), 1);
                    y_fit = polyval(p, log(x));
                    model_name = '对数拟合';

                case 'power'
                    % y = a * x^b
                    valid = x > 0 & y > 0;
                    p = polyfit(log(x(valid)), log(y(valid)), 1);
                    y_fit = exp(polyval(p, log(x)));
                    p = [exp(p(2)), p(1)];  % [a, b]
                    model_name = '幂函数拟合';

                otherwise
                    error('ecalculator:optimization:unknownModel', ...
                        '未知模型类型: %s', model_type);
            end

            % 计算统计量
            SS_res = sum((y - y_fit).^2);
            SS_tot = sum((y - mean(y)).^2);
            R2 = 1 - SS_res / SS_tot;
            RMSE = sqrt(SS_res / numel(y));

            fprintf('📊 曲线拟合 (%s):\n', model_name);
            fprintf('   数据点数: %d\n', numel(x));
            fprintf('   拟合系数: %s\n', mat2str(p, 4));
            fprintf('   R²:       %.4f\n', R2);
            fprintf('   RMSE:     %.6f\n', RMSE);

            % 绘图
            figure('Name', sprintf('Curve Fit: %s', model_name));
            scatter(x, y, 30, 'b', 'filled', 'DisplayName', '数据');
            hold on;
            [x_sorted, idx] = sort(x);
            plot(x_sorted, y_fit(idx), 'r-', 'LineWidth', 2, 'DisplayName', '拟合');
            xlabel('X');
            ylabel('Y');
            title(sprintf('%s (R² = %.4f)', model_name, R2));
            legend('Location', 'best');
            grid on;

            info.coefficients = p;
            info.R2 = R2;
            info.RMSE = RMSE;
            info.y_fit = y_fit;
            info.model_type = model_type;
        end
    end
end
