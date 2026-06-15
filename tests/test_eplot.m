classdef test_eplot < matlab.unittest.TestCase
%TEST_EPLOT eplot 模块单元测试

    methods (Test)
        function test_style_ieee(testCase)
            fig = figure('Visible', 'off');
            plot([1 2 3], [1 4 9]);
            eplot.style(fig, 'ieee');
            testCase.verifyTrue(isvalid(fig));
            close(fig);
        end

        function test_style_nature(testCase)
            fig = figure('Visible', 'off');
            plot([1 2 3], [1 4 9]);
            eplot.style(fig, 'nature');
            testCase.verifyTrue(isvalid(fig));
            close(fig);
        end

        function test_style_thesis(testCase)
            fig = figure('Visible', 'off');
            plot([1 2 3], [1 4 9]);
            eplot.style(fig, 'thesis');
            testCase.verifyTrue(isvalid(fig));
            close(fig);
        end

        function test_style_custom(testCase)
            fig = figure('Visible', 'off');
            plot([1 2 3], [1 4 9]);
            eplot.style(fig, 'custom', 'FontSize', 14, 'LineWidth', 2);
            testCase.verifyTrue(isvalid(fig));
            close(fig);
        end

        function test_colorscheme(testCase)
            fig = figure('Visible', 'off');
            plot([1 2 3], [1 4 9]);
            eplot.colorscheme(fig, 'nature');
            testCase.verifyTrue(isvalid(fig));
            close(fig);
        end

        function test_export_pdf(testCase)
            fig = figure('Visible', 'off');
            plot([1 2 3], [1 4 9]);
            temp_file = [tempname '.pdf'];
            eplot.export(fig, temp_file);
            testCase.verifyTrue(exist(temp_file, 'file') > 0);
            delete(temp_file);
            close(fig);
        end

        function test_export_png(testCase)
            fig = figure('Visible', 'off');
            plot([1 2 3], [1 4 9]);
            temp_file = [tempname '.png'];
            eplot.export(fig, temp_file, 'dpi', 150);
            testCase.verifyTrue(exist(temp_file, 'file') > 0);
            delete(temp_file);
            close(fig);
        end

        function test_compare_step(testCase)
            sys1 = tf([1], [1 2 1]);
            sys2 = tf([1], [1 3 2]);
            fig = eplot.compare_step({sys1, sys2}, 'labels', {'S1', 'S2'});
            testCase.verifyTrue(isvalid(fig));
            close(fig);
        end

        function test_compare_bode(testCase)
            sys1 = tf([1], [1 2 1]);
            sys2 = tf([1], [1 3 2]);
            fig = eplot.compare_bode({sys1, sys2}, 'labels', {'S1', 'S2'});
            testCase.verifyTrue(isvalid(fig));
            close(fig);
        end

        function test_nyquist_styled(testCase)
            sys = tf([1], [1 2 1]);
            fig = eplot.nyquist_styled(sys);
            testCase.verifyTrue(isvalid(fig));
            close(fig);
        end

        function test_export_tikz(testCase)
            fig = figure('Visible', 'off');
            plot([1 2 3], [1 4 9]);
            temp_file = [tempname '.tex'];
            eplot.export_tikz(fig, temp_file);
            testCase.verifyTrue(exist(temp_file, 'file') > 0);
            delete(temp_file);
            close(fig);
        end
    end
end
