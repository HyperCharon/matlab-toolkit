classdef recommend
%ECALCULATOR.RECOMMEND 问题分类与模型推荐引擎
%
%   ecalculator.recommend.models(problem_type)       推荐模型
%   ecalculator.recommend.compare(methods, data)     多模型对比
%   ecalculator.recommend.workflow(problem_type)     生成工作流
%
%   See also ecalculator.optimization, ecalculator.statistics

    methods(Static)
        function info = models(problem_type, data_chars)
        %MODELS 根据问题类型推荐模型
        %
        %   info = ecalculator.recommend.models('prediction')
        %   info = ecalculator.recommend.models('optimization', 'small_sample')
        %
        %   输入:
        %     problem_type - 问题类型:
        %       'prediction'   - 预测问题
        %       'optimization' - 优化问题
        %       'evaluation'   - 评价问题
        %       'classification' - 分类问题
        %       'clustering'   - 聚类问题
        %       'scheduling'   - 调度问题
        %       'fitting'      - 拟合问题
        %     data_chars - 数据特征 (可选):
        %       'small_sample'   - 小样本
        %       'large_sample'   - 大样本
        %       'time_series'    - 时间序列
        %       'multi_criteria' - 多指标
        %       'uncertain'      - 不确定性
        %
        %   输出:
        %     info.methods    - 推荐方法列表
        %     info.rationale  - 推荐理由
        %     info.complexity - 复杂度评级
        %
        %   示例:
        %     info = ecalculator.recommend.models('prediction', 'small_sample')

            if nargin < 2, data_chars = ''; end

            methods_list = {};
            rationale = {};
            complexity = {};

            switch lower(problem_type)
                case 'prediction'
                    if contains(data_chars, 'small_sample')
                        methods_list = {'grey_predict', 'exponential_smoothing', 'curve_fit'};
                        rationale = {
                            '灰色预测 GM(1,1): 适合小样本 (4-6个数据点)'
                            '指数平滑: 适合有趋势的时间序列'
                            '曲线拟合: 适合有明确函数关系的数据'
                        };
                        complexity = {'低', '低', '低'};
                    elseif contains(data_chars, 'time_series')
                        methods_list = {'arima_forecast', 'exponential_smoothing', 'decompose'};
                        rationale = {
                            'ARIMA: 适合平稳/可差分平稳的时间序列'
                            '指数平滑: 适合有趋势和季节性的数据'
                            '时间序列分解: 分析趋势和季节成分'
                        };
                        complexity = {'中', '低', '低'};
                    else
                        methods_list = {'regression', 'curve_fit', 'ml.svm_classification'};
                        rationale = {
                            '回归分析: 适合有明确因果关系的数据'
                            '曲线拟合: 适合有函数关系的数据'
                            'SVM: 适合高维非线性数据'
                        };
                        complexity = {'低', '低', '中'};
                    end

                case 'optimization'
                    if contains(data_chars, 'multi_criteria')
                        methods_list = {'topsis', 'ahp', 'grey_predict'};
                        rationale = {
                            'TOPSIS: 多指标综合评价，客观赋权'
                            'AHP: 层次分析法，主观赋权'
                            '灰色关联分析: 适合指标间关系不明确'
                        };
                        complexity = {'低', '低', '中'};
                    else
                        methods_list = {'linear_programming', 'monte_carlo', 'sensitivity_analysis'};
                        rationale = {
                            '线性规划: 适合线性约束优化问题'
                            '蒙特卡洛模拟: 适合复杂约束/随机问题'
                            '灵敏度分析: 分析参数对结果的影响'
                        };
                        complexity = {'中', '中', '低'};
                    end

                case 'evaluation'
                    methods_list = {'topsis', 'ahp', 'statistics.anova'};
                    rationale = {
                        'TOPSIS: 逼近理想解排序，客观评价'
                        'AHP: 层次分析法，适合多层指标体系'
                        '方差分析: 比较多个组的差异显著性'
                    };
                    complexity = {'低', '低', '中'};

                case 'classification'
                    methods_list = {'ml.svm_classification', 'ml.kmeans_analysis', 'ml.feature_importance'};
                    rationale = {
                        'SVM: 适合小样本高维分类'
                        'K-means: 无监督聚类分析'
                        '特征重要性: 理解分类关键因素'
                    };
                    complexity = {'中', '低', '低'};

                case 'clustering'
                    methods_list = {'ml.kmeans_analysis', 'ml.pca_analysis'};
                    rationale = {
                        'K-means: 最常用的聚类算法'
                        'PCA: 降维后可视化聚类结构'
                    };
                    complexity = {'低', '低'};

                case 'fitting'
                    methods_list = {'curve_fit', 'statistics.regression', 'ml.pca_analysis'};
                    rationale = {
                        '曲线拟合: 支持多种函数模型'
                        '回归分析: 线性/非线性回归'
                        'PCA: 多变量降维分析'
                    };
                    complexity = {'低', '低', '中'};

                case 'scheduling'
                    methods_list = {'optimization.topsis', 'optimization.ahp', 'optimization.monte_carlo'};
                    rationale = {
                        'TOPSIS: 多目标调度方案评价'
                        'AHP: 调度优先级层次分析'
                        '蒙特卡洛: 调度风险评估'
                    };
                    complexity = {'低', '低', '中'};

                otherwise
                    methods_list = {'statistics.regression', 'ml.kmeans_analysis'};
                    rationale = {
                        '回归分析: 通用数据分析方法'
                        '聚类分析: 发现数据内在结构'
                    };
                    complexity = {'低', '低'};
            end

            fprintf('📊 模型推荐 (问题类型: %s):\n', problem_type);
            if ~isempty(data_chars)
                fprintf('   数据特征: %s\n', data_chars);
            end
            fprintf('   ───── 推荐方法 ─────\n');
            for i = 1:numel(methods_list)
                fprintf('   %d. %s\n', i, methods_list{i});
                fprintf('      理由: %s\n', rationale{i});
                fprintf('      复杂度: %s\n', complexity{i});
            end

            info.methods = methods_list;
            info.rationale = rationale;
            info.complexity = complexity;
            info.problem_type = problem_type;
        end

        function info = compare(methods, data, labels)
        %COMPARE 多模型对比框架
        %
        %   info = ecalculator.recommend.compare(methods, data, labels)
        %
        %   输入:
        %     methods - 方法列表 (cell array of function handles)
        %     data    - 数据矩阵
        %     labels  - 方法名称 (可选)
        %
        %   输出:
        %     info.results  - 各方法结果
        %     info.timing   - 运行时间
        %     info.comparison - 对比表
        %
        %   示例:
        %     methods = {@(d) ecalculator.statistics.regression(d(:,1), d(:,2)), ...
        %                @(d) ecalculator.optimization.curve_fit(d(:,1), d(:,2))};
        %     info = ecalculator.recommend.compare(methods, data);

            n_methods = numel(methods);

            if nargin < 3 || isempty(labels)
                labels = arrayfun(@(i) sprintf('Method %d', i), 1:n_methods, 'UniformOutput', false);
            end

            results = cell(n_methods, 1);
            timing = zeros(n_methods, 1);

            fprintf('📊 多模型对比:\n');
            fprintf('   方法数: %d\n', n_methods);
            fprintf('   ───── 执行结果 ─────\n');

            for i = 1:n_methods
                try
                    tic;
                    results{i} = methods{i}(data);
                    timing(i) = toc;

                    fprintf('   %s: 完成 (%.3f 秒)\n', labels{i}, timing(i));

                    % 提取 R² (如果存在)
                    if isstruct(results{i}) && isfield(results{i}, 'R2')
                        fprintf('     R² = %.4f\n', results{i}.R2);
                    end
                catch ME
                    fprintf('   %s: 失败 (%s)\n', labels{i}, ME.message);
                    results{i} = [];
                    timing(i) = NaN;
                end
            end

            % 生成对比表
            fprintf('\n   ───── 对比表 ─────\n');
            fprintf('   %-20s %10s %10s\n', '方法', '时间(s)', 'R²');
            fprintf('   %s\n', repmat('-', 1, 42));
            for i = 1:n_methods
                R2_str = 'N/A';
                if ~isempty(results{i}) && isstruct(results{i}) && isfield(results{i}, 'R2')
                    R2_str = sprintf('%.4f', results{i}.R2);
                end
                fprintf('   %-20s %10.3f %10s\n', labels{i}, timing(i), R2_str);
            end

            info.results = results;
            info.timing = timing;
            info.labels = labels;
        end

        function info = workflow(problem_type)
        %WORKFLOW 生成数模工作流脚本
        %
        %   info = ecalculator.recommend.workflow('prediction')
        %
        %   输入:
        %     problem_type - 问题类型
        %
        %   输出:
        %     info.steps   - 工作流步骤
        %     info.code    - 生成的 MATLAB 代码
        %
        %   示例:
        %     info = ecalculator.recommend.workflow('evaluation');

            steps = {};
            code_lines = {};

            switch lower(problem_type)
                case 'prediction'
                    steps = {
                        '1. 数据预处理: edata.read + edata.clean'
                        '2. 平稳性检验: timeseries.stationarity_test'
                        '3. 模型选择: recommend.models'
                        '4. 模型拟合: timeseries.arima_forecast 或 optimization.grey_predict'
                        '5. 结果验证: 对比预测值与实际值'
                        '6. 可视化: eplot.style + eplot.export'
                    };
                    code_lines = {
                        '% 步骤1: 数据预处理'
                        'data = edata.read(''data.csv'');'
                        'data = edata.clean(data, ''remove_nan'', true);'
                        ''
                        '% 步骤2: 平稳性检验'
                        'stat_info = ecalculator.timeseries.stationarity_test(data.y);'
                        ''
                        '% 步骤3: 模型拟合'
                        'if stat_info.is_stationary'
                        '    result = ecalculator.timeseries.arima_forecast(data.y, 10);'
                        'else'
                        '    result = ecalculator.optimization.grey_predict(data.y, 3);'
                        'end'
                        ''
                        '% 步骤4: 可视化'
                        'eplot.style(''ieee'');'
                        'eplot.export(''prediction_result.pdf'');'
                    };

                case 'optimization'
                    steps = {
                        '1. 问题定义: 目标函数、约束条件'
                        '2. 数据准备: edata.read'
                        '3. 模型选择: recommend.models'
                        '4. 求解: optimization.topsis 或 linprog'
                        '5. 灵敏度分析: optimization.sensitivity_analysis'
                        '6. 结果输出: eplot.export'
                    };
                    code_lines = {
                        '% 步骤1: 定义问题'
                        'D = [数据矩阵];'
                        'W = [权重向量];'
                        'type = [指标类型];'
                        ''
                        '% 步骤2: TOPSIS 评价'
                        'result = ecalculator.optimization.topsis(D, W, type);'
                        ''
                        '% 步骤3: 灵敏度分析'
                        'sens = ecalculator.optimization.sensitivity_analysis(...);'
                        ''
                        '% 步骤4: 可视化'
                        'eplot.style(''ieee'');'
                    };

                case 'evaluation'
                    steps = {
                        '1. 建立指标体系'
                        '2. 数据标准化'
                        '3. 确定权重 (AHP/熵权法)'
                        '4. 综合评价 (TOPSIS/灰色关联)'
                        '5. 结果分析与可视化'
                    };
                    code_lines = {
                        '% 步骤1: AHP 确定权重'
                        'A = [判断矩阵];'
                        'ahp_info = ecalculator.optimization.ahp(A);'
                        ''
                        '% 步骤2: TOPSIS 评价'
                        'D = [决策矩阵];'
                        'topsis_info = ecalculator.optimization.topsis(D, ahp_info.weights, type);'
                        ''
                        '% 步骤3: 可视化'
                        'eplot.style(''ieee'');'
                    };

                otherwise
                    steps = {'通用工作流: 数据读取 -> 分析 -> 可视化'};
                    code_lines = {
                        '% 通用模板'
                        'data = edata.read(''data.csv'');'
                        'info = edata.analyze(data);'
                        'eplot.style(''ieee'');'
                    };
            end

            fprintf('📊 数模工作流 (%s):\n', problem_type);
            fprintf('   ───── 步骤 ─────\n');
            for i = 1:numel(steps)
                fprintf('   %s\n', steps{i});
            end

            fprintf('\n   ───── 代码模板 ─────\n');
            for i = 1:numel(code_lines)
                fprintf('   %s\n', code_lines{i});
            end

            info.steps = steps;
            info.code = strjoin(code_lines, '\n');
            info.problem_type = problem_type;
        end
    end
end
