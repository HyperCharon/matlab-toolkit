classdef test_optimization < matlab.unittest.TestCase
%TEST_OPTIMIZATION 测试优化决策模块

    methods(Test)
        function test_topsis_basic(testCase)
            % 测试 TOPSIS 基本功能
            D = [80 90 85; 70 80 90; 90 85 80];
            W = [0.3, 0.3, 0.4];
            type = [1, 1, 1];  % 全部效益型

            info = ecalculator.optimization.topsis(D, W, type);

            % 验证输出字段
            testCase.verifyTrue(isfield(info, 'C'));
            testCase.verifyTrue(isfield(info, 'rank'));
            testCase.verifyTrue(isfield(info, 'D_plus'));
            testCase.verifyTrue(isfield(info, 'D_minus'));

            % 验证维度
            testCase.verifyEqual(size(info.C), [3, 1]);
            testCase.verifyEqual(size(info.rank), [3, 1]);

            % 验证接近度在 [0, 1] 范围内
            testCase.verifyTrue(all(info.C >= 0) && all(info.C <= 1));

            % 验证排名是 1 到 3 的排列
            testCase.verifyEqual(sort(info.rank), [1; 2; 3]');
        end

        function test_topsis_cost_type(testCase)
            % 测试 TOPSIS 成本型指标
            D = [250 90 5; 200 85 3; 300 95 7];
            W = [0.4, 0.3, 0.3];
            type = [2, 1, 2];  % 价格和交货时间是成本型

            info = ecalculator.optimization.topsis(D, W, type);

            % 方案 B 应该排名最高（低价、短交期）
            testCase.verifyEqual(info.rank(2), 1);
        end

        function test_ahp_consistent(testCase)
            % 测试 AHP 一致性检验
            A = [1 3 5; 1/3 1 2; 1/5 1/2 1];

            info = ecalculator.optimization.ahp(A);

            % 验证输出字段
            testCase.verifyTrue(isfield(info, 'weights'));
            testCase.verifyTrue(isfield(info, 'lambda_max'));
            testCase.verifyTrue(isfield(info, 'CI'));
            testCase.verifyTrue(isfield(info, 'CR'));
            testCase.verifyTrue(isfield(info, 'consistent'));

            % 验证权重和为 1
            testCase.verifyEqual(sum(info.weights), 1, 'AbsTol', 1e-6);

            % 验证一致性
            testCase.verifyTrue(info.consistent);
            testCase.verifyLessThan(info.CR, 0.1);
        end

        function test_grey_predict(testCase)
            % 测试灰色预测
            X0 = [2.874, 3.278, 3.337, 3.390, 3.679];

            info = ecalculator.optimization.grey_predict(X0, 3);

            % 验证输出字段
            testCase.verifyTrue(isfield(info, 'predictions'));
            testCase.verifyTrue(isfield(info, 'a'));
            testCase.verifyTrue(isfield(info, 'b'));
            testCase.verifyTrue(isfield(info, 'R2'));

            % 验证预测长度
            testCase.verifyEqual(numel(info.predictions), 8);  % 5 原始 + 3 预测

            % 验证 R² 合理
            testCase.verifyGreaterThan(info.R2, 0.9);
        end

        function test_monte_carlo_pi(testCase)
            % 测试蒙特卡洛估算 π
            rng(42);  % 固定随机种子
            func = @(x) 4 * (x(:,1).^2 + x(:,2).^2 <= 1);

            info = ecalculator.optimization.monte_carlo(func, 100000, ...
                'x1', [0, 1], 'x2', [0, 1]);

            % 验证输出字段
            testCase.verifyTrue(isfield(info, 'mean'));
            testCase.verifyTrue(isfield(info, 'std'));
            testCase.verifyTrue(isfield(info, 'CI_95'));

            % 验证 π 估计值在合理范围内
            testCase.verifyGreaterThan(info.mean, 3.0);
            testCase.verifyLessThan(info.mean, 3.3);
        end

        function test_curve_fit_linear(testCase)
            % 测试线性曲线拟合
            x = linspace(0, 10, 50)';
            y = 2.5 * x + 5 + randn(50, 1) * 0.5;

            info = ecalculator.optimization.curve_fit(x, y, 'linear');

            % 验证输出字段
            testCase.verifyTrue(isfield(info, 'coefficients'));
            testCase.verifyTrue(isfield(info, 'R2'));
            testCase.verifyTrue(isfield(info, 'RMSE'));

            % 验证 R² 接近 1
            testCase.verifyGreaterThan(info.R2, 0.95);

            % 验证系数接近 [2.5, 5]
            testCase.verifyEqual(info.coefficients(1), 2.5, 'AbsTol', 0.2);
            testCase.verifyEqual(info.coefficients(2), 5, 'AbsTol', 1);
        end

        function test_sensitivity_analysis(testCase)
            % 测试灵敏度分析
            func = @(x) x(1)^2 + 2*x(2)^2;
            x0 = [1, 1];

            info = ecalculator.optimization.sensitivity_analysis(func, x0, ...
                {'x1', 'x2'}, 'delta', 0.1, 'plot', false);

            % 验证输出字段
            testCase.verifyTrue(isfield(info, 'sensitivity'));
            testCase.verifyTrue(isfield(info, 'rank'));

            % 验证 x2 比 x1 更灵敏（系数为 2 vs 1）
            testCase.verifyGreaterThan(info.sensitivity(2), info.sensitivity(1));
        end
    end
end
