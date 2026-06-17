classdef timeseries
%ECALCULATOR.TIMESERIES 时间序列分析工具
%
%   ecalculator.timeseries.decompose(y, period)           趋势/季节分解
%   ecalculator.timeseries.stationarity_test(y)           平稳性检验
%   ecalculator.timeseries.exponential_smoothing(y, alpha) 指数平滑
%   ecalculator.timeseries.arima_forecast(y, n_forecast)   ARIMA 预测
%   ecalculator.timeseries.autocorrelation_analysis(y)    自相关分析
%
%   See also ecalculator.statistics, ecalculator.optimization

    methods(Static)
        function info = decompose(y, period)
        %DECOMPOSE 时间序列分解 (趋势 + 季节 + 残差)
        %
        %   info = ecalculator.timeseries.decompose(y, period)
        %
        %   输入:
        %     y      - 时间序列数据
        %     period - 季节周期 (如月度数据 period=12)
        %
        %   输出:
        %     info.trend     - 趋势分量
        %     info.seasonal  - 季节分量
        %     info.remainder - 残差分量
        %     info.R2        - 解释方差比例
        %
        %   示例:
        %     y = randn(100,1) + (1:100)'*0.1 + 5*sin(2*pi*(1:100)'/12);
        %     info = ecalculator.timeseries.decompose(y, 12)

            if nargin < 2, period = 12; end

            y = y(:);
            n = numel(y);

            % 1. 提取趋势 (移动平均)
            if mod(period, 2) == 0
                % 偶数周期: 2x12 移动平均
                window = period;
                trend = movmean(y, [window/2, window/2]);
            else
                % 奇数周期: 中心移动平均
                window = period;
                trend = movmean(y, floor(window/2));
            end

            % 2. 去趋势
            detrended = y - trend;

            % 3. 提取季节分量 (按周期平均)
            seasonal = zeros(n, 1);
            for i = 1:period
                idx = i:period:n;
                season_mean = mean(detrended(idx), 'omitnan');
                seasonal(idx) = season_mean;
            end

            % 4. 调整季节分量使其均值为 0
            seasonal = seasonal - mean(seasonal);

            % 5. 残差
            remainder = y - trend - seasonal;

            % 6. 计算解释方差
            SS_total = sum((y - mean(y)).^2);
            SS_remainder = sum(remainder.^2, 'omitnan');
            R2 = 1 - SS_remainder / SS_total;

            fprintf('📊 时间序列分解:\n');
            fprintf('   数据长度:   %d\n', n);
            fprintf('   季节周期:   %d\n', period);
            fprintf('   解释方差:   %.2f%%\n', R2*100);
            fprintf('   趋势范围:   [%.2f, %.2f]\n', min(trend), max(trend));
            fprintf('   季节振幅:   %.2f\n', (max(seasonal) - min(seasonal))/2);

            % 绘图
            figure('Name', 'Time Series Decomposition');
            subplot(4,1,1);
            plot(y, 'b-', 'LineWidth', 1);
            ylabel('原始数据');
            title('时间序列分解');
            grid on;

            subplot(4,1,2);
            plot(trend, 'r-', 'LineWidth', 1.5);
            ylabel('趋势');
            grid on;

            subplot(4,1,3);
            plot(seasonal, 'g-', 'LineWidth', 1);
            ylabel('季节');
            grid on;

            subplot(4,1,4);
            plot(remainder, 'k-', 'LineWidth', 0.5);
            ylabel('残差');
            xlabel('时间');
            grid on;

            info.trend = trend;
            info.seasonal = seasonal;
            info.remainder = remainder;
            info.R2 = R2;
            info.period = period;
        end

        function info = stationarity_test(y)
        %STATIONARITY_TEST 时间序列平稳性检验 (ADF 和 KPSS)
        %
        %   info = ecalculator.timeseries.stationarity_test(y)
        %
        %   输出:
        %     info.adf_stat   - ADF 统计量
        %     info.adf_p      - ADF p 值
        %     info.kpss_stat  - KPSS 统计量
        %     info.is_stationary - 是否平稳
        %
        %   示例:
        %     y = randn(100, 1);
        %     info = ecalculator.timeseries.stationarity_test(y)

            y = y(:);
            n = numel(y);

            % 差分序列
            dy = diff(y);

            % ADF 检验 (Augmented Dickey-Fuller)
            % 回归: dy(t) = a + b*y(t-1) + c*t + e(t)
            y_lag = y(1:end-1);
            t_idx = (2:n)';

            X = [ones(n-1,1), y_lag, t_idx];
            b = X \ dy;
            residuals = dy - X * b;

            % 计算 ADF 统计量 (使用 \ 代替 inv 提高数值稳定性)
            se = sqrt(sum(residuals.^2) / (n-4)) * sqrt(diag((X'*X) \ eye(size(X,2))));
            adf_stat = b(2) / se(2,2);

            % 近似 p 值 (MacKinnon 临界值)
            if adf_stat < -3.43
                adf_p = 0.01;
            elseif adf_stat < -2.86
                adf_p = 0.05;
            elseif adf_stat < -2.57
                adf_p = 0.10;
            else
                adf_p = 0.50;
            end

            % KPSS 检验 (Kwiatkowski-Phillips-Schmidt-Shin)
            % 原假设: 序列平稳
            y_demean = y - mean(y);
            S = cumsum(y_demean);
            kpss_stat = sum(S.^2) / (n^2 * var(y));

            % KPSS 临界值 (10% 和 5%)
            if kpss_stat > 0.739
                kpss_reject = true;  % 非平稳
            elseif kpss_stat > 0.463
                kpss_reject = true;  % 非平稳
            else
                kpss_reject = false; % 平稳
            end

            % 综合判断
            is_stationary = (adf_p < 0.05) && ~kpss_reject;

            fprintf('📊 平稳性检验:\n');
            fprintf('   数据长度: %d\n', n);
            fprintf('   ───── ADF 检验 ─────\n');
            fprintf('   统计量:   %.4f\n', adf_stat);
            fprintf('   p 值:     %.4f\n', adf_p);
            if adf_p < 0.05
                fprintf('   结论:     拒绝原假设 (序列平稳)\n');
            else
                fprintf('   结论:     不能拒绝原假设 (序列非平稳)\n');
            end
            fprintf('   ───── KPSS 检验 ─────\n');
            fprintf('   统计量:   %.4f\n', kpss_stat);
            if kpss_reject
                fprintf('   结论:     拒绝原假设 (序列非平稳)\n');
            else
                fprintf('   结论:     不能拒绝原假设 (序列平稳)\n');
            end
            fprintf('   ───── 综合判断 ─────\n');
            if is_stationary
                fprintf('   ✅ 序列是平稳的\n');
            else
                fprintf('   ⚠️  序列可能是非平稳的，建议差分处理\n');
            end

            info.adf_stat = adf_stat;
            info.adf_p = adf_p;
            info.kpss_stat = kpss_stat;
            info.kpss_reject = kpss_reject;
            info.is_stationary = is_stationary;
        end

        function info = exponential_smoothing(y, alpha, varargin)
        %EXPONENTIAL_SMOOTHING 指数平滑预测
        %
        %   info = ecalculator.timeseries.exponential_smoothing(y, alpha)
        %   info = ecalculator.timeseries.exponential_smoothing(y, 0.3, 'method', 'double', 'beta', 0.3)
        %   info = ecalculator.timeseries.exponential_smoothing(y, 0.3, 'method', 'triple', 'beta', 0.3, 'gamma', 0.3, 'period', 12)
        %
        %   输入:
        %     y      - 时间序列
        %     alpha  - 平滑系数 (0~1, 默认 0.3)
        %
        %   可选参数:
        %     'method' - 'simple', 'double' (Holt), 'triple' (Holt-Winters)
        %     'beta'   - 趋势平滑系数 (double/triple, 默认 0.3)
        %     'gamma'  - 季节平滑系数 (triple, 默认 0.3)
        %     'period' - 季节周期 (triple, 默认 12)
        %
        %   输出:
        %     info.forecast - 预测值
        %     info.level    - 水平分量
        %     info.trend    - 趋势分量 (double/triple)
        %     info.RMSE     - 预测误差
        %
        %   示例:
        %     y = (1:100)' + randn(100,1)*2;
        %     info = ecalculator.timeseries.exponential_smoothing(y, 0.3, 'method', 'double')

            if nargin < 2, alpha = 0.3; end

            opts = struct('method', 'simple', 'beta', 0.3, 'gamma', 0.3, 'period', 12);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end
            method = opts.method;

            y = y(:);
            n = numel(y);

            switch lower(method)
                case 'simple'
                    % 简单指数平滑
                    level = zeros(n, 1);
                    level(1) = y(1);

                    for t = 2:n
                        level(t) = alpha * y(t) + (1-alpha) * level(t-1);
                    end

                    forecast = level;
                    trend = [];

                case 'double'
                    % Holt 双参数指数平滑
                    beta = opts.beta;  % 趋势平滑系数

                    level = zeros(n, 1);
                    trend = zeros(n, 1);

                    level(1) = y(1);
                    trend(1) = y(2) - y(1);

                    for t = 2:n
                        level(t) = alpha * y(t) + (1-alpha) * (level(t-1) + trend(t-1));
                        trend(t) = beta * (level(t) - level(t-1)) + (1-beta) * trend(t-1);
                    end

                    forecast = level + trend;

                case 'triple'
                    % Holt-Winters 三参数指数平滑 (加法模型)
                    period = opts.period;  % 季节周期
                    beta = opts.beta;
                    gamma = opts.gamma;  % 季节平滑系数

                    level = zeros(n, 1);
                    trend = zeros(n, 1);
                    seasonal = zeros(n, 1);

                    % 初始化
                    level(1) = mean(y(1:period));
                    trend(1) = (mean(y(period+1:2*period)) - mean(y(1:period))) / period;
                    for i = 1:period
                        seasonal(i) = y(i) - level(1);
                    end

                    for t = period+1:n
                        level(t) = alpha * (y(t) - seasonal(t-period)) + ...
                                   (1-alpha) * (level(t-1) + trend(t-1));
                        trend(t) = beta * (level(t) - level(t-1)) + (1-beta) * trend(t-1);
                        seasonal(t) = gamma * (y(t) - level(t)) + (1-gamma) * seasonal(t-period);
                    end

                    forecast = level + trend + seasonal;

                otherwise
                    error('ecalculator:timeseries:unknownMethod', ...
                        '未知方法: %s (支持: simple, double, triple)', method);
            end

            % 计算误差
            residuals = y - forecast;
            RMSE = sqrt(mean(residuals.^2, 'omitnan'));
            MAE = mean(abs(residuals), 'omitnan');

            fprintf('📊 指数平滑 (%s):\n', method);
            fprintf('   平滑系数 α: %.2f\n', alpha);
            fprintf('   RMSE: %.4f\n', RMSE);
            fprintf('   MAE:  %.4f\n', MAE);

            % 绘图
            figure('Name', 'Exponential Smoothing');
            plot(y, 'b-', 'LineWidth', 1, 'DisplayName', '原始数据');
            hold on;
            plot(forecast, 'r-', 'LineWidth', 1.5, 'DisplayName', '平滑/预测');
            xlabel('时间');
            ylabel('值');
            title(sprintf('指数平滑 (%s, α=%.2f)', method, alpha));
            legend('Location', 'best');
            grid on;

            info.forecast = forecast;
            info.level = level;
            info.trend = trend;
            info.residuals = residuals;
            info.RMSE = RMSE;
            info.MAE = MAE;
        end

        function info = autocorrelation_analysis(y, max_lag)
        %AUTOCORRELATION_ANALYSIS 自相关和偏自相关分析
        %
        %   info = ecalculator.timeseries.autocorrelation_analysis(y, max_lag)
        %
        %   输入:
        %     y       - 时间序列
        %     max_lag - 最大滞后阶数 (默认 min(20, n/3))
        %
        %   输出:
        %     info.acf  - 自相关系数
        %     info.pacf - 偏自相关系数
        %     info.Q_stat - Ljung-Box Q 统计量
        %
        %   示例:
        %     y = randn(100, 1);
        %     info = ecalculator.timeseries.autocorrelation_analysis(y)

            y = y(:);
            n = numel(y);

            if nargin < 2, max_lag = min(20, floor(n/3)); end

            % 计算 ACF
            y_mean = mean(y);
            y_var = var(y);
            acf = zeros(max_lag, 1);

            for k = 1:max_lag
                acf(k) = sum((y(1:n-k) - y_mean) .* (y(k+1:n) - y_mean)) / ((n-1) * y_var);
            end

            % 计算 PACF (Durbin-Levinson 递推)
            pacf = zeros(max_lag, 1);
            pacf(1) = acf(1);

            if max_lag > 1
                phi = zeros(max_lag, max_lag);
                phi(1,1) = acf(1);

                for k = 2:max_lag
                    phi(k,k) = (acf(k) - sum(phi(1:k-1, k-1) .* acf(k-1:-1:1))) / ...
                               (1 - sum(phi(1:k-1, k-1) .* acf(1:k-1)));
                    for j = 1:k-1
                        phi(k,j) = phi(k-1,j) - phi(k,k) * phi(k-1,k-j);
                    end
                    pacf(k) = phi(k,k);
                end
            end

            % Ljung-Box Q 统计量
            Q_stat = zeros(max_lag, 1);
            for k = 1:max_lag
                Q_stat(k) = n*(n+2) * sum(acf(1:k).^2 ./ (n-(1:k)'));
            end

            % 95% 置信区间
            CI = 1.96 / sqrt(n);

            fprintf('📊 自相关分析:\n');
            fprintf('   数据长度:   %d\n', n);
            fprintf('   最大滞后:   %d\n', max_lag);
            fprintf('   显著滞后 (ACF > %.3f):\n', CI);
            significant_lags = find(abs(acf) > CI);
            if ~isempty(significant_lags)
                fprintf('   %s\n', mat2str(significant_lags'));
            else
                fprintf('   无显著滞后\n');
            end

            % 绘图
            figure('Name', 'ACF/PACF Analysis');

            subplot(2,1,1);
            stem(1:max_lag, acf, 'b-', 'LineWidth', 1);
            hold on;
            plot([1, max_lag], [CI, CI], 'r--', 'LineWidth', 1);
            plot([1, max_lag], [-CI, -CI], 'r--', 'LineWidth', 1);
            xlabel('滞后阶数');
            ylabel('ACF');
            title('自相关函数 (ACF)');
            grid on;

            subplot(2,1,2);
            stem(1:max_lag, pacf, 'b-', 'LineWidth', 1);
            hold on;
            plot([1, max_lag], [CI, CI], 'r--', 'LineWidth', 1);
            plot([1, max_lag], [-CI, -CI], 'r--', 'LineWidth', 1);
            xlabel('滞后阶数');
            ylabel('PACF');
            title('偏自相关函数 (PACF)');
            grid on;

            info.acf = acf;
            info.pacf = pacf;
            info.Q_stat = Q_stat;
            info.CI = CI;
            info.significant_lags = significant_lags;
        end

        function info = arima_forecast(y, n_forecast, order)
        %ARIMA_FORECAST ARIMA 模型预测
        %
        %   info = ecalculator.timeseries.arima_forecast(y, n_forecast, order)
        %
        %   输入:
        %     y         - 时间序列
        %     n_forecast - 预测步数 (默认 10)
        %     order     - [p, d, q] 阶数 (默认自动选择)
        %
        %   输出:
        %     info.forecast - 预测值
        %     info.CI_95    - 95% 置信区间
        %     info.order    - 使用的 ARIMA 阶数
        %
        %   示例:
        %     y = cumsum(randn(100,1)) + 50;
        %     info = ecalculator.timeseries.arima_forecast(y, 10)

            if nargin < 2, n_forecast = 10; end
            if nargin < 3, order = []; end

            y = y(:);
            n = numel(y);

            % 自动选择阶数 (基于 ACF/PACF)
            if isempty(order)
                % 简单启发式: 检查差分次数
                d = 0;
                y_test = y;
                for i = 1:2
                    stat_info = ecalculator.timeseries.stationarity_test(y_test);
                    if stat_info.is_stationary
                        break;
                    end
                    y_test = diff(y_test);
                    d = d + 1;
                end

                % 基于 PACF 选择 p, 基于 ACF 选择 q
                acf_info = ecalculator.timeseries.autocorrelation_analysis(y_test, 10);
                p = find(abs(acf_info.pacf) > acf_info.CI, 1, 'last');
                q = find(abs(acf_info.acf) > acf_info.CI, 1, 'last');

                if isempty(p), p = 1; end
                if isempty(q), q = 1; end
                order = [min(p, 3), d, min(q, 3)];  % 限制阶数
            end

            p = order(1);
            d = order(2);
            q = order(3);

            % 差分
            y_diff = y;
            for i = 1:d
                y_diff = diff(y_diff);
            end

            n_diff = numel(y_diff);

            % AR 模型简化实现 (不依赖 Econometrics Toolbox)
            if p > 0
                % 构建 AR 设计矩阵
                X_ar = zeros(n_diff - p, p);
                for i = 1:p
                    X_ar(:, i) = y_diff(p-i+1:n_diff-i);
                end
                y_ar_target = y_diff(p+1:end);

                % 最小二乘估计
                ar_coeffs = X_ar \ y_ar_target;
                ar_residuals = y_ar_target - X_ar * ar_coeffs;
            else
                ar_coeffs = [];
                ar_residuals = y_diff;
            end

            % 预测 (简化: 仅使用 AR 部分)
            y_forecast_diff = zeros(n_forecast, 1);
            recent_values = y_diff(end-p+1:end);

            for h = 1:n_forecast
                if p > 0
                    y_forecast_diff(h) = ar_coeffs' * recent_values(end:-1:end-p+1);
                else
                    y_forecast_diff(h) = mean(y_diff);
                end
                recent_values = [recent_values; y_forecast_diff(h)];
            end

            % 还原差分
            forecast = y(end);
            for i = 1:d
                forecast = cumsum([forecast; y_forecast_diff]);
                forecast = forecast(2:end);
            end

            % 置信区间 (基于残差标准差)
            residual_std = std(ar_residuals);
            CI_width = 1.96 * residual_std * sqrt(1:n_forecast)';
            CI_lower = forecast - CI_width;
            CI_upper = forecast + CI_width;

            fprintf('📊 ARIMA 预测:\n');
            fprintf('   阶数:     (%d, %d, %d)\n', p, d, q);
            fprintf('   预测步数: %d\n', n_forecast);
            fprintf('   ───── 预测值 ─────\n');
            for h = 1:n_forecast
                fprintf('   第 %d 步: %.2f [%.2f, %.2f]\n', ...
                    h, forecast(h), CI_lower(h), CI_upper(h));
            end

            % 绘图
            figure('Name', 'ARIMA Forecast');
            t_hist = 1:n;
            t_fore = n+1:n+n_forecast;

            plot(t_hist, y, 'b-', 'LineWidth', 1.5, 'DisplayName', '历史数据');
            hold on;
            plot(t_fore, forecast, 'r-', 'LineWidth', 2, 'DisplayName', '预测');
            fill([t_fore, fliplr(t_fore)], [CI_lower', fliplr(CI_upper')], ...
                'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'DisplayName', '95% CI');
            xlabel('时间');
            ylabel('值');
            title(sprintf('ARIMA(%d,%d,%d) 预测', p, d, q));
            legend('Location', 'best');
            grid on;

            info.forecast = forecast;
            info.CI_lower = CI_lower;
            info.CI_upper = CI_upper;
            info.order = order;
            info.ar_coeffs = ar_coeffs;
            info.residual_std = residual_std;
        end
    end
end
