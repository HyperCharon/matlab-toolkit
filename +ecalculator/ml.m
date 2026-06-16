classdef ml
%ECALCULATOR.ML 机器学习工程计算器
%
%   ecalculator.ml.pca_analysis(data)           主成分分析
%   ecalculator.ml.kmeans_analysis(data, k)     K-means 聚类
%   ecalculator.ml.svm_classification(X, y)     SVM 分类
%   ecalculator.ml.cross_validation(X, y, k)    交叉验证
%   ecalculator.ml.feature_importance(X, y)     特征重要性
%
%   See also ecalculator.statistics, edata.analyze

    methods(Static)
        function info = pca_analysis(data, varargin)
        %PCA_ANALYSIS 主成分分析
        %
        %   ecalculator.ml.pca_analysis(data)
        %   ecalculator.ml.pca_analysis(data, 'n_components', 3)

            opts = struct('n_components', [], 'plot', true, 'standardize', true);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            % 标准化
            if opts.standardize
                data_std = (data - mean(data)) ./ std(data);
            else
                data_std = data;
            end

            % PCA
            [coeff, score, latent, ~, explained] = pca(data_std);

            % 选择主成分数量
            if isempty(opts.n_components)
                % 选择解释 95% 方差的主成分
                cumulative_explained = cumsum(explained);
                opts.n_components = find(cumulative_explained >= 95, 1);
            end

            fprintf('📊 主成分分析:\n');
            fprintf('   原始维度:   %d\n', size(data, 2));
            fprintf('   主成分数:   %d\n', opts.n_components);
            fprintf('   解释方差:   %.2f%%\n', sum(explained(1:opts.n_components)));

            % 打印各主成分解释方差
            fprintf('\n   各主成分解释方差:\n');
            for i = 1:min(10, numel(explained))
                fprintf('   PC%d: %.2f%%\n', i, explained(i));
            end

            % 绘图
            if opts.plot
                figure('Name', 'PCA Analysis');

                % 碎石图
                subplot(2,1,1);
                bar(explained, 'FaceAlpha', 0.7);
                hold on;
                plot(cumsum(explained), 'r-o', 'LineWidth', 2);
                xlabel('主成分');
                ylabel('解释方差 (%)');
                title('PCA 碎石图');
                legend('单个主成分', '累积', 'Location', 'best');
                grid on;

                % 前两个主成分散点图
                if size(score, 2) >= 2
                    subplot(2,1,2);
                    scatter(score(:,1), score(:,2), 50, 'filled', 'FaceAlpha', 0.6);
                    xlabel(sprintf('PC1 (%.1f%%)', explained(1)));
                    ylabel(sprintf('PC2 (%.1f%%)', explained(2)));
                    title('前两个主成分');
                    grid on;
                end
            end

            info.coeff = coeff;
            info.score = score;
            info.latent = latent;
            info.explained = explained;
            info.n_components = opts.n_components;
        end

        function info = kmeans_analysis(data, k, varargin)
        %KMEANS_ANALYSIS K-means 聚类分析
        %
        %   ecalculator.ml.kmeans_analysis(data, 3)
        %   ecalculator.ml.kmeans_analysis(data, 3, 'replicates', 10)

            opts = struct('replicates', 10, 'plot', true, 'max_iter', 100);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            % K-means 聚类
            [idx, C, sumd] = kmeans(data, k, 'Replicates', opts.replicates, ...
                'MaxIter', opts.max_iter);

            % 计算轮廓系数
            s = silhouette(data, idx);
            mean_s = mean(s);

            fprintf('📊 K-means 聚类分析:\n');
            fprintf('   聚类数:     %d\n', k);
            fprintf('   样本量:     %d\n', size(data, 1));
            fprintf('   轮廓系数:   %.4f\n', mean_s);

            % 打印各簇统计
            fprintf('\n   各簇统计:\n');
            for i = 1:k
                cluster_size = sum(idx == i);
                fprintf('   簇 %d: %d 个样本 (%.1f%%)\n', i, cluster_size, cluster_size/numel(idx)*100);
            end

            % 绘图
            if opts.plot && size(data, 2) >= 2
                figure('Name', 'K-means Clustering');
                gscatter(data(:,1), data(:,2), idx);
                hold on;
                plot(C(:,1), C(:,2), 'kx', 'MarkerSize', 15, 'LineWidth', 3);
                xlabel('Feature 1');
                ylabel('Feature 2');
                title(sprintf('K-means Clustering (k=%d)', k));
                legend('Location', 'best');
                grid on;
            end

            info.idx = idx;
            info.C = C;
            info.sumd = sumd;
            info.silhouette = s;
            info.mean_silhouette = mean_s;
        end

        function info = svm_classification(X, y, varargin)
        %SVM_CLASSIFICATION SVM 分类
        %
        %   ecalculator.ml.svm_classification(X, y)
        %   ecalculator.ml.svm_classification(X, y, 'kernel', 'rbf')

            opts = struct('kernel', 'rbf', 'cross_val', 5, 'plot', true);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            % 训练 SVM
            svm_model = fitcsvm(X, y, 'KernelFunction', opts.kernel, ...
                'Standardize', true);

            % 交叉验证
            cv_model = crossval(svm_model, 'KFold', opts.cross_val);
            cv_loss = kfoldLoss(cv_model);

            % 预测
            y_pred = predict(svm_model, X);
            accuracy = sum(y_pred == y) / numel(y);

            fprintf('📊 SVM 分类:\n');
            fprintf('   核函数:     %s\n', opts.kernel);
            fprintf('   训练准确率: %.2f%%\n', accuracy*100);
            fprintf('   交叉验证:   %.2f%%\n', (1-cv_loss)*100);

            % 混淆矩阵
            cm = confusionmat(y, y_pred);
            fprintf('\n   混淆矩阵:\n');
            disp(cm);

            % 绘图
            if opts.plot && size(X, 2) == 2
                figure('Name', 'SVM Classification');

                % 决策边界
                h = 0.02;
                x_range = [min(X(:,1))-1, max(X(:,1))+1];
                y_range = [min(X(:,2))-1, max(X(:,2))+1];
                [xx, yy] = meshgrid(x_range(1):h:x_range(2), y_range(1):h:y_range(2));
                X_grid = [xx(:), yy(:)];
                [labels, ~] = predict(svm_model, X_grid);

                gscatter(xx(:), yy(:), labels, 'rgb', '.', 1, 'off');
                hold on;
                gscatter(X(:,1), X(:,2), y, 'rgb', 'o', 8);
                xlabel('Feature 1');
                ylabel('Feature 2');
                title('SVM 决策边界');
                legend('Location', 'best');
                grid on;
            end

            info.model = svm_model;
            info.accuracy = accuracy;
            info.cv_accuracy = 1 - cv_loss;
            info.confusion_matrix = cm;
        end

        function info = cross_validation(X, y, k, model_type)
        %CROSS_VALIDATION K 折交叉验证
        %
        %   ecalculator.ml.cross_validation(X, y, 10, 'svm')

            if nargin < 4, model_type = 'svm'; end

            % 创建交叉验证分区
            cv = cvpartition(numel(y), 'KFold', k);

            accuracy = zeros(k, 1);
            precision = zeros(k, 1);
            recall = zeros(k, 1);
            f1 = zeros(k, 1);

            for i = 1:k
                % 训练集和测试集
                train_idx = training(cv, i);
                test_idx = test(cv, i);

                X_train = X(train_idx, :);
                y_train = y(train_idx);
                X_test = X(test_idx, :);
                y_test = y(test_idx);

                % 训练模型
                switch lower(model_type)
                    case 'svm'
                        model = fitcsvm(X_train, y_train, 'KernelFunction', 'rbf');
                    case 'tree'
                        model = fitctree(X_train, y_train);
                    case 'knn'
                        model = fitcknn(X_train, y_train, 'NumNeighbors', 5);
                    otherwise
                        error('ecalculator:ml:unknownModel', '未知模型类型: %s', model_type);
                end

                % 预测
                y_pred = predict(model, X_test);

                % 计算指标
                accuracy(i) = sum(y_pred == y_test) / numel(y_test);

                % 计算精确率、召回率、F1
                classes = unique(y);
                if numel(classes) == 2
                    tp = sum(y_pred == 1 & y_test == 1);
                    fp = sum(y_pred == 1 & y_test == 0);
                    fn = sum(y_pred == 0 & y_test == 1);

                    precision(i) = tp / (tp + fp + eps);
                    recall(i) = tp / (tp + fn + eps);
                    f1(i) = 2 * precision(i) * recall(i) / (precision(i) + recall(i) + eps);
                end
            end

            fprintf('📊 %d 折交叉验证 (%s):\n', k, model_type);
            fprintf('   准确率: %.2f%% ± %.2f%%\n', mean(accuracy)*100, std(accuracy)*100);
            if numel(unique(y)) == 2
                fprintf('   精确率: %.2f%% ± %.2f%%\n', mean(precision)*100, std(precision)*100);
                fprintf('   召回率: %.2f%% ± %.2f%%\n', mean(recall)*100, std(recall)*100);
                fprintf('   F1:     %.2f%% ± %.2f%%\n', mean(f1)*100, std(f1)*100);
            end

            info.accuracy = accuracy;
            info.precision = precision;
            info.recall = recall;
            info.f1 = f1;
            info.mean_accuracy = mean(accuracy);
        end

        function info = feature_importance(X, y, method)
        %FEATURE_IMPORTANCE 特征重要性分析
        %
        %   ecalculator.ml.feature_importance(X, y, 'tree')

            if nargin < 3, method = 'tree'; end

            switch lower(method)
                case 'tree'
                    % 决策树特征重要性
                    model = fitctree(X, y);
                    importance = predictorImportance(model);
                    method_name = '决策树';

                case 'forest'
                    % 随机森林特征重要性
                    model = fitcensemble(X, y, 'Method', 'Bag');
                    importance = predictorImportance(model);
                    method_name = '随机森林';

                otherwise
                    error('ecalculator:ml:unknownMethod', '未知方法: %s', method);
            end

            % 排序
            [sorted_imp, idx] = sort(importance, 'descend');

            fprintf('📊 特征重要性 (%s):\n', method_name);
            for i = 1:numel(importance)
                fprintf('   特征 %d: %.4f\n', idx(i), sorted_imp(i));
            end

            % 绘图
            figure('Name', 'Feature Importance');
            bar(importance(idx), 'FaceAlpha', 0.7);
            xlabel('特征');
            ylabel('重要性');
            title(sprintf('特征重要性 (%s)', method_name));
            grid on;

            info.importance = importance;
            info.sorted_idx = idx;
            info.model = model;
        end
    end
end
