classdef statistics
%ECALCULATOR.STATISTICS 统计学工程计算器
%
%   ecalculator.statistics.confidence_interval(data, alpha)  置信区间
%   ecalculator.statistics.hypothesis_test(data1, data2)      假设检验
%   ecalculator.statistics.regression(x, y)                   回归分析
%   ecalculator.statistics.anova(groups)                      方差分析
%   ecalculator.statistics.distribution_fit(data, dist)       分布拟合
%
%   See also ecalculator.signal, edata.analyze

    methods(Static)
        function info = confidence_interval(data, alpha, dim)
        %CONFIDENCE_INTERVAL 置信区间计算
        %
        %   ecalculator.statistics.confidence_interval(data, 0.05)

            if nargin < 2, alpha = 0.05; end
            if nargin < 3, dim = 1; end

            n = size(data, dim);
            mu = mean(data, dim);
            sigma = std(data, [], dim);
            se = sigma / sqrt(n);

            % t 分布置信区间
            t_crit = tinv(1 - alpha/2, n - 1);
            ci_lower = mu - t_crit * se;
            ci_upper = mu + t_crit * se;

            fprintf('📊 置信区间分析:\n');
            fprintf('   样本量:     %d\n", n);
            fprintf('   均值:       %.4f\n", mu);
            fprintf('   标准差:     %.4f\n", sigma);
            fprintf('   标准误:     %.4f\n", se);
            fprintf('   置信水平:   %.1f%%\n", (1-alpha)*100);
            fprintf('   置信区间:   [%.4f, %.4f]\n", ci_lower, ci_upper);

            info.mu = mu;
            info.sigma = sigma;
            info.se = se;
            info.ci_lower = ci_lower;
            info.ci_upper = ci_upper;
            info.n = n;
        end

        function info = hypothesis_test(data1, data2, test_type, alpha)
        %HYPOTHESIS_TEST 假设检验
        %
        %   ecalculator.statistics.hypothesis_test(data1, data2, 'ttest2')

            if nargin < 3, test_type = 'ttest2'; end
            if nargin < 4, alpha = 0.05; end

            switch lower(test_type)
                case 'ttest2'
                    % 双样本 t 检验
                    [h, p, ci, stats] = ttest2(data1, data2, 'Alpha', alpha);
                    test_name = '双样本 t 检验';

                case 'ttest'
                    % 单样本 t 检验
                    [h, p, ci, stats] = ttest(data1, data2, 'Alpha', alpha);
                    test_name = '单样本 t 检验';

                case 'signrank'
                    % Wilcoxon 符号秩检验
                    [p, h, stats] = signrank(data1, data2, 'Alpha', alpha);
                    test_name = 'Wilcoxon 符号秩检验';

                case 'ranksum'
                    % Wilcoxon 秩和检验
                    [p, h, stats] = ranksum(data1, data2, 'Alpha', alpha);
                    test_name = 'Wilcoxon 秩和检验';

                otherwise
                    error('ecalculator:statistics:unknownTest', '未知检验类型: %s', test_type);
            end

            fprintf('📊 假设检验 (%s):\n', test_name);
            fprintf('   样本 1 均值: %.4f\n", mean(data1));
            fprintf('   样本 2 均值: %.4f\n", mean(data2));
            fprintf('   显著性水平: %.2f\n", alpha);
            fprintf('   p 值:       %.4f\n", p);

            if h
                fprintf('   ✅ 拒绝原假设 (差异显著)\n');
            else
                fprintf('   ⚠️  不能拒绝原假设 (差异不显著)\n');
            end

            info.h = h;
            info.p = p;
            info.stats = stats;
        end

        function info = regression(x, y, model_type)
        %REGRESSION 回归分析
        %
        %   ecalculator.statistics.regression(x, y, 'linear')

            if nargin < 3, model_type = 'linear'; end

            switch lower(model_type)
                case 'linear'
                    % 线性回归
                    p = polyfit(x, y, 1);
                    y_fit = polyval(p, x);
                    model_name = '线性回归';

                case 'quadratic'
                    % 二次回归
                    p = polyfit(x, y, 2);
                    y_fit = polyval(p, x);
                    model_name = '二次回归';

                case 'exponential'
                    % 指数回归
                    p = polyfit(x, log(y), 1);
                    y_fit = exp(polyval(p, x));
                    model_name = '指数回归';

                otherwise
                    error('ecalculator:statistics:unknownModel', '未知模型类型: %s', model_type);
            end

            % 计算统计量
            SS_res = sum((y - y_fit).^2);
            SS_tot = sum((y - mean(y)).^2);
            R2 = 1 - SS_res / SS_tot;
            RMSE = sqrt(SS_res / numel(y));

            fprintf('📊 回归分析 (%s):\n', model_name);
            fprintf('   系数:       %s\n", mat2str(p));
            fprintf('   R²:         %.4f\n", R2);
            fprintf('   RMSE:       %.4f\n", RMSE);

            % 绘图
            figure('Name', sprintf('Regression: %s', model_name));
            scatter(x, y, 'b.', 'DisplayName', 'Data');
            hold on;
            [x_sorted, idx] = sort(x);
            plot(x_sorted, y_fit(idx), 'r-', 'LineWidth', 2, 'DisplayName', 'Fit');
            xlabel('X');
            ylabel('Y');
            title(sprintf('%s (R² = %.4f)', model_name, R2));
            legend('Location', 'best');
            grid on;

            info.coefficients = p;
            info.R2 = R2;
            info.RMSE = RMSE;
            info.y_fit = y_fit;
        end

        function info = anova(groups)
        %ANOVA 单因素方差分析
        %
        %   ecalculator.statistics.anova({group1, group2, group3})

            n_groups = numel(groups);

            % 合并数据
            all_data = [];
            group_labels = [];
            for i = 1:n_groups
                all_data = [all_data; groups{i}(:)];
                group_labels = [group_labels; i * ones(numel(groups{i}), 1)];
            end

            % ANOVA
            [p, tbl, stats] = anova1(all_data, group_labels, 'off');

            fprintf('📊 单因素方差分析:\n');
            fprintf('   组数:       %d\n", n_groups);
            fprintf('   总样本量:   %d\n", numel(all_data));
            fprintf('   F 值:       %.4f\n", tbl{2, 5});
            fprintf('   p 值:       %.4f\n", p);

            if p < 0.05
                fprintf('   ✅ 组间差异显著\n');
            else
                fprintf('   ⚠️  组间差异不显著\n');
            end

            % 多重比较
            if p < 0.05
                fprintf('\n   多重比较 (Tukey HSD):\n');
                [c, m, h, gnames] = multcompare(stats, 'Display', 'off');
                for i = 1:size(c, 1)
                    fprintf('   组 %d vs 组 %d: p = %.4f\n", c(i,1), c(i,2), c(i, 6));
                end
            end

            info.p = p;
            info.table = tbl;
            info.stats = stats;
        end

        function info = distribution_fit(data, dist_type)
        %DISTRIBUTION_FIT 分布拟合
        %
        %   ecalculator.statistics.distribution_fit(data, 'normal')

            if nargin < 2, dist_type = 'normal'; end

            switch lower(dist_type)
                case 'normal'
                    % 正态分布拟合
                    mu = mean(data);
                    sigma = std(data);
                    dist_name = '正态分布';

                case 'exponential'
                    % 指数分布拟合
                    mu = mean(data);
                    dist_name = '指数分布';

                case 'weibull'
                    % Weibull 分布拟合
                    [mu, sigma] = wblfit(data);
                    dist_name = 'Weibull 分布';

                otherwise
                    error('ecalculator:statistics:unknownDist', '未知分布类型: %s', dist_type);
            end

            % KS 检验
            [h, p] = kstest(data);

            fprintf('📊 分布拟合 (%s):\n", dist_name);
            fprintf('   参数:       %s\n", mat2str([mu sigma]));
            fprintf('   KS 检验 p 值: %.4f\n", p);

            if h
                fprintf('   ❌ 拒绝原假设 (数据不服从该分布)\n');
            else
                fprintf('   ✅ 不能拒绝原假设 (数据可能服从该分布)\n');
            end

            % 绘图
            figure('Name', sprintf('Distribution Fit: %s', dist_name));
            histogram(data, 20, 'Normalization', 'pdf', 'FaceAlpha', 0.7);
            hold on;

            x_range = linspace(min(data), max(data), 100);
            switch lower(dist_type)
                case 'normal'
                    y_fit = normpdf(x_range, mu, sigma);
                case 'exponential'
                    y_fit = exppdf(x_range, mu);
                case 'weibull'
                    y_fit = wblpdf(x_range, mu, sigma);
            end
            plot(x_range, y_fit, 'r-', 'LineWidth', 2);
            xlabel('Value');
            ylabel('Probability Density');
            title(sprintf('%s Fit', dist_name));
            grid on;

            info.parameters = [mu sigma];
            info.p_value = p;
        end
    end
end
