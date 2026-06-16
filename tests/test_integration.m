classdef test_integration < matlab.unittest.TestCase
%TEST_INTEGRATION 集成测试 - 模拟真实数模场景

    methods(Test)
        function test_supplier_selection(testCase)
            % 场景：供应商选择问题
            % 使用 TOPSIS 评估 5 个供应商

            % 决策矩阵：价格、质量、交货期、服务
            D = [250 90 5 85;
                 200 85 3 90;
                 300 95 7 80;
                 220 80 4 95;
                 280 88 6 75];

            W = [0.3, 0.25, 0.25, 0.2];
            type = [2, 1, 2, 1];  % 价格和交货期是成本型

            info = ecalculator.optimization.topsis(D, W, type);

            % 验证所有输出维度一致
            testCase.verifyEqual(size(info.C), [5, 1]);
            testCase.verifyEqual(size(info.rank), [5, 1]);

            % 验证排名唯一
            testCase.verifyEqual(sort(info.rank), (1:5)');

            % 验证接近度排序与排名一致
            [~, C_order] = sort(info.C, 'descend');
            rank_order = zeros(5, 1);
            for i = 1:5
                rank_order(i) = find(info.rank == i);
            end
            testCase.verifyEqual(C_order, rank_order);
        end

        function test_gdp_prediction(testCase)
            % 场景：GDP 预测
            % 使用灰色预测 GM(1,1)

            % 历史 GDP 数据（亿元）
            X0 = [90.03, 99.09, 101.60, 114.37, 121.02];

            info = ecalculator.optimization.grey_predict(X0, 3);

            % 验证预测值趋势合理（应呈增长趋势）
            predictions = info.predictions;
            for i = 2:numel(predictions)
                testCase.verifyGreaterThan(predictions(i), predictions(i-1) * 0.95);
            end

            % 验证 R² 合理
            testCase.verifyGreaterThan(info.R2, 0.8);
        end

        function test_school_selection(testCase)
            % 场景：研究生院选择
            % 使用 AHP 确定权重

            % 判断矩阵：学术声誉、地理位置、科研经费、校园生活
            A = [1   3    2    5;
                 1/3 1    1/2  2;
                 1/2 2    1    3;
                 1/5 1/2  1/3  1];

            info = ecalculator.optimization.ahp(A);

            % 验证通过一致性检验
            testCase.verifyTrue(info.consistent);

            % 验证学术声誉权重最高
            [~, max_idx] = max(info.weights);
            testCase.verifyEqual(max_idx, 1);

            % 验证权重排序合理
            testCase.verifyGreaterThan(info.weights(1), info.weights(3));
            testCase.verifyGreaterThan(info.weights(3), info.weights(2));
            testCase.verifyGreaterThan(info.weights(2), info.weights(4));
        end

        function test_cooling_curve_fit(testCase)
            % 场景：冷却过程曲线拟合
            % 测试不同拟合模型

            % 实验数据
            t = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50]';
            T = [95, 82, 71, 63, 56, 51, 47, 44, 42, 40, 39]';

            % 测试线性拟合
            info_linear = ecalculator.optimization.curve_fit(t, T, 'linear');
            testCase.verifyTrue(isfield(info_linear, 'R2'));

            % 测试二次拟合
            info_quad = ecalculator.optimization.curve_fit(t, T, 'quadratic');
            testCase.verifyTrue(isfield(info_quad, 'R2'));

            % 测试指数拟合
            info_exp = ecalculator.optimization.curve_fit(t, T, 'exponential');
            testCase.verifyTrue(isfield(info_exp, 'R2'));

            % 验证指数拟合应该比线性拟合更好（冷却过程）
            testCase.verifyGreaterThan(info_exp.R2, info_linear.R2);
        end

        function test_parameter_sensitivity(testCase)
            % 场景：电机参数灵敏度分析

            % 简化的电机效率模型
            efficiency = @(x) x(1) * x(2) / (x(1) * x(2) + x(3)^2);

            % 标称参数：电压、电流、电阻
            x0 = [24, 5, 0.5];

            info = ecalculator.optimization.sensitivity_analysis(...
                efficiency, x0, {'V', 'I', 'R'}, 'delta', 0.1, 'plot', false);

            % 验证灵敏度为正值
            testCase.verifyTrue(all(info.sensitivity >= 0));

            % 验证输出字段完整
            testCase.verifyTrue(isfield(info, 'rank'));
            testCase.verifyTrue(isfield(info, 'y0'));
        end

        function test_multiple_modules(testCase)
            % 场景：综合使用多个模块

            % 1. 统计分析
            data = randn(100, 1) * 5 + 20;
            ci_info = ecalculator.statistics.confidence_interval(data, 0.05);
            testCase.verifyTrue(isfield(ci_info, 'ci_lower'));
            testCase.verifyTrue(isfield(ci_info, 'ci_upper'));

            % 2. 电路计算
            circuit_info = ecalculator.circuit.voltage_divider(12, 10e3, 4.7e3);
            testCase.verifyTrue(isfield(circuit_info, 'Vout'));
            testCase.verifyEqual(circuit_info.Vout, 12 * 4.7e3 / (10e3 + 4.7e3), ...
                'AbsTol', 0.001);

            % 3. 信号处理
            Fs = 1000;
            t = 0:1/Fs:1;
            x = sin(2*pi*50*t);
            snr_info = ecalculator.signal.snr(x, 0.1*randn(size(t)));
            testCase.verifyTrue(isfield(snr_info, 'snr_dB'));
            testCase.verifyGreaterThan(snr_info.snr_dB, 0);
        end
    end
end
