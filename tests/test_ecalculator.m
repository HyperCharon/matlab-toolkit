classdef test_ecalculator < matlab.unittest.TestCase
%TEST_ECALCULATOR ecalculator 模块单元测试

    methods (Test)
        % 控制系统测试
        function test_bode_plot(testCase)
            fig = figure('Visible', 'off');
            info = ecalculator.control.bode_plot([1], [1 2 1]);
            testCase.verifyTrue(isfield(info, 'Gm_dB'));
            testCase.verifyTrue(isfield(info, 'Pm'));
            testCase.verifyTrue(isfield(info, 'stable'));
            close(fig);
        end

        function test_step_response(testCase)
            fig = figure('Visible', 'off');
            info = ecalculator.control.step_response([1], [1 2 1]);
            testCase.verifyTrue(isfield(info, 'Overshoot'));
            testCase.verifyTrue(isfield(info, 'SettlingTime'));
            testCase.verifyTrue(isfield(info, 'RiseTime'));
            close(fig);
        end

        function test_stability_stable(testCase)
            info = ecalculator.control.stability([1], [1 3 3 1]);
            testCase.verifyTrue(info.stable);
        end

        function test_stability_unstable(testCase)
            info = ecalculator.control.stability([1], [1 -2 1]);
            testCase.verifyFalse(info.stable);
        end

        % 电路测试
        function test_voltage_divider(testCase)
            info = ecalculator.circuit.voltage_divider(12, 10e3, 10e3);
            testCase.verifyEqual(info.Vout, 6, 'AbsTol', 0.001);
        end

        function test_rc_filter(testCase)
            info = ecalculator.circuit.rc_filter(10e3, 100e-9, 'lowpass');
            expected_fc = 1 / (2 * pi * 10e3 * 100e-9);
            testCase.verifyEqual(info.fc, expected_fc, 'RelTol', 0.01);
        end

        function test_opamp_inverting(testCase)
            info = ecalculator.circuit.opamp_gain(100e3, 10e3, 'inverting');
            testCase.verifyEqual(info.gain, -10, 'AbsTol', 0.001);
        end

        function test_opamp_noninverting(testCase)
            info = ecalculator.circuit.opamp_gain(100e3, 10e3, 'noninverting');
            testCase.verifyEqual(info.gain, 11, 'AbsTol', 0.001);
        end

        function test_power(testCase)
            info = ecalculator.circuit.power(12, 0.5);
            testCase.verifyEqual(info.P, 6, 'AbsTol', 0.001);
            testCase.verifyEqual(info.R, 24, 'AbsTol', 0.001);
        end

        % 信号处理测试
        function test_sampling_check_valid(testCase)
            info = ecalculator.signal.sampling_check(1000, 8000);
            testCase.verifyTrue(info.valid);
            testCase.verifyEqual(info.ratio, 8, 'AbsTol', 0.01);
        end

        function test_sampling_check_invalid(testCase)
            info = ecalculator.signal.sampling_check(1000, 1500);
            testCase.verifyFalse(info.valid);
        end

        function test_snr(testCase)
            signal = ones(1, 1000);
            noise = 0.1 * randn(1, 1000);
            val = ecalculator.signal.snr(signal, noise);
            testCase.verifyGreaterThan(val, 10);
        end

        % 热力学测试
        function test_conduction(testCase)
            info = ecalculator.thermal.conduction(385, 0.01, 50, 0.1);
            expected_Q = 385 * 0.01 * 50 / 0.1;
            testCase.verifyEqual(info.Q, expected_Q, 'RelTol', 0.01);
        end

        function test_convection(testCase)
            info = ecalculator.thermal.convection(50, 0.01, 50);
            expected_Q = 50 * 0.01 * 50;
            testCase.verifyEqual(info.Q, expected_Q, 'RelTol', 0.01);
        end

        function test_heatsink(testCase)
            info = ecalculator.thermal.heatsink(150, 40, 10, 1.5, 0.5);
            expected_Rth = (150 - 40) / 10 - 1.5 - 0.5;
            testCase.verifyEqual(info.Rth_sa_max, expected_Rth, 'RelTol', 0.01);
        end

        % 流体力学测试
        function test_reynolds_laminar(testCase)
            info = ecalculator.fluid.reynolds(1000, 0.01, 0.01, 1e-3);
            testCase.verifyEqual(info.Re, 100, 'AbsTol', 1);
            testCase.verifyEqual(info.regime, 'laminar');
        end

        function test_reynolds_turbulent(testCase)
            info = ecalculator.fluid.reynolds(1000, 1, 0.01, 1e-3);
            testCase.verifyEqual(info.Re, 10000, 'AbsTol', 1);
            testCase.verifyEqual(info.regime, 'turbulent');
        end

        function test_pitot(testCase)
            v = ecalculator.fluid.pitot(1.225, 100);
            expected_v = sqrt(2 * 100 / 1.225);
            testCase.verifyEqual(v, expected_v, 'RelTol', 0.01);
        end

        % 材料力学测试
        function test_stress(testCase)
            info = ecalculator.material.stress(1000, 0.001);
            testCase.verifyEqual(info.sigma, 1e6, 'RelTol', 0.01);
        end

        function test_strain(testCase)
            info = ecalculator.material.strain(0.001, 1);
            testCase.verifyEqual(info.epsilon, 0.001, 'RelTol', 0.01);
        end

        % 电机测试
        function test_dc_motor(testCase)
            info = ecalculator.motor.dc_motor(24, 0.5, 1e-3, 0.05, 0.05, 1e-4, 1e-5);
            testCase.verifyGreaterThan(info.I_stall, 0);
            testCase.verifyGreaterThan(info.RPM_no_load, 0);
            testCase.verifyGreaterThan(info.tau_e, 0);
            testCase.verifyGreaterThan(info.tau_m, 0);
        end
    end
end
