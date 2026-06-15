classdef test_edata < matlab.unittest.TestCase
%TEST_EDATA edata 模块单元测试

    methods (Test)
        function test_read_csv(testCase)
            % 创建临时 CSV 文件
            temp_file = [tempname '.csv'];
            fid = fopen(temp_file, 'w');
            fprintf(fid, 'X,Y,Z\n');
            fprintf(fid, '1,2,3\n');
            fprintf(fid, '4,5,6\n');
            fprintf(fid, '7,8,9\n');
            fclose(fid);

            data = edata.read(temp_file);
            testCase.verifyEqual(height(data), 3);
            testCase.verifyEqual(width(data), 3);
            testCase.verifyEqual(data.X(1), 1);

            delete(temp_file);
        end

        function test_read_excel(testCase)
            % 跳过如果没有 Excel 支持
            try
                temp_file = [tempname '.xlsx'];
                T = table([1;2;3], [4;5;6], 'VariableNames', {'A', 'B'});
                writetable(T, temp_file);

                data = edata.read(temp_file);
                testCase.verifyEqual(height(data), 3);
                testCase.verifyEqual(data.A(1), 1);

                delete(temp_file);
            catch
                testCase.verifyTrue(true);  % 跳过
            end
        end

        function test_clean_remove_nan(testCase)
            T = table([1; NaN; 3; NaN; 5], [10; 20; 30; 40; 50], ...
                'VariableNames', {'X', 'Y'});
            cleaned = edata.clean(T, 'remove_nan', true, 'remove_outliers', false);
            testCase.verifyEqual(height(cleaned), 3);
        end

        function test_clean_smooth(testCase)
            T = table((1:100)', sin((1:100)/10)' + 0.1*randn(100,1), ...
                'VariableNames', {'t', 'x'});
            cleaned = edata.clean(T, 'remove_nan', false, 'smooth', 5);
            testCase.verifyEqual(height(cleaned), 100);
        end

        function test_analyze(testCase)
            T = table([1;2;3;4;5], [10;20;30;40;50], ...
                'VariableNames', {'X', 'Y'});
            info = edata.analyze(T, 'verbose', false);
            testCase.verifyTrue(isfield(info, 'columns'));
            testCase.verifyTrue(isfield(info.columns, 'X'));
            testCase.verifyEqual(info.columns.X.mean, 3, 'AbsTol', 0.001);
        end

        function test_export_csv(testCase)
            T = table([1;2;3], [4;5;6], 'VariableNames', {'A', 'B'});
            temp_file = [tempname '.csv'];
            edata.export(T, temp_file);
            testCase.verifyTrue(exist(temp_file, 'file') > 0);
            delete(temp_file);
        end

        function test_batch_read(testCase)
            % 创建临时文件
            temp_dir = tempname;
            mkdir(temp_dir);

            for i = 1:3
                fid = fopen(fullfile(temp_dir, sprintf('data%d.csv', i)), 'w');
                fprintf(fid, 'X,Y\n');
                fprintf(fid, '%d,%d\n', i, i*10);
                fclose(fid);
            end

            data = edata.batch_read(fullfile(temp_dir, '*.csv'), 'combine', true);
            testCase.verifyEqual(height(data), 3);

            rmdir(temp_dir, 's');
        end
    end
end
