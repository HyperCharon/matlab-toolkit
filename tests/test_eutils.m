classdef test_eutils < matlab.unittest.TestCase
%TEST_EUTILS eutils 模块单元测试

    methods (Test)
        % 单位换算测试
        function test_length_m_to_ft(testCase)
            result = eutils.units.convert(1, 'm', 'ft');
            testCase.verifyEqual(result, 3.28084, 'AbsTol', 0.001);
        end

        function test_pressure_atm_to_pa(testCase)
            result = eutils.units.convert(1, 'atm', 'Pa');
            testCase.verifyEqual(result, 101325, 'AbsTol', 1);
        end

        function test_temperature_c_to_f(testCase)
            result = eutils.units.convert(100, 'celsius', 'fahrenheit');
            testCase.verifyEqual(result, 212, 'AbsTol', 0.01);
        end

        function test_temperature_f_to_k(testCase)
            result = eutils.units.convert(32, 'fahrenheit', 'kelvin');
            testCase.verifyEqual(result, 273.15, 'AbsTol', 0.01);
        end

        function test_energy_j_to_cal(testCase)
            result = eutils.units.convert(4184, 'J', 'kcal');
            testCase.verifyEqual(result, 1, 'AbsTol', 0.01);
        end

        function test_power_hp_to_w(testCase)
            result = eutils.units.convert(1, 'hp', 'W');
            testCase.verifyEqual(result, 745.7, 'AbsTol', 1);
        end

        function test_velocity_kmh_to_ms(testCase)
            result = eutils.units.convert(36, 'kmh', 'ms');
            testCase.verifyEqual(result, 10, 'AbsTol', 0.01);
        end

        function test_frequency_rpm_to_hz(testCase)
            result = eutils.units.convert(60, 'rpm', 'Hz');
            testCase.verifyEqual(result, 1, 'AbsTol', 0.01);
        end

        function test_category_mismatch(testCase)
            testCase.verifyError(@() eutils.units.convert(1, 'm', 'kg'), ...
                'eutils:units:categoryMismatch');
        end

        % 物理常数测试
        function test_constant_c(testCase)
            testCase.verifyEqual(eutils.constants.c, 299792458);
        end

        function test_constant_g(testCase)
            testCase.verifyEqual(eutils.constants.g, 9.80665, 'AbsTol', 0.0001);
        end

        function test_constant_e(testCase)
            testCase.verifyEqual(eutils.constants.e, 1.602176634e-19, 'RelTol', 0.001);
        end

        function test_constant_get(testCase)
            val = eutils.constants.get('c');
            testCase.verifyEqual(val, 299792458);
        end

        % 代码检查测试
        function test_check_code(testCase)
            % 创建临时测试文件
            temp_dir = tempname;
            mkdir(temp_dir);
            fid = fopen(fullfile(temp_dir, 'test.m'), 'w');
            fprintf(fid, 'x = 1;\n');
            fprintf(fid, 'y = eval(''sin(1)'');\n');
            fprintf(fid, '% comment\n');
            fclose(fid);

            issues = eutils.check_code(temp_dir, 'verbose', false);
            testCase.verifyGreaterThan(numel(issues), 0);

            % 清理
            rmdir(temp_dir, 's');
        end

        % 项目初始化测试
        function test_init_project(testCase)
            temp_dir = tempname;
            project_name = fullfile(temp_dir, 'test_project');

            eutils.init_project(project_name, 'type', 'control', 'git', false);

            testCase.verifyTrue(exist(project_name, 'dir') > 0);
            testCase.verifyTrue(exist(fullfile(project_name, 'main.m'), 'file') > 0);
            testCase.verifyTrue(exist(fullfile(project_name, 'config.m'), 'file') > 0);
            testCase.verifyTrue(exist(fullfile(project_name, 'README.md'), 'file') > 0);

            % 清理
            rmdir(temp_dir, 's');
        end
    end
end
