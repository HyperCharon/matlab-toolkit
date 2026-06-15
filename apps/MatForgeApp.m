classdef MatForgeApp < handle
%MATFORGEAPP MatForge 图形界面
%
%   app = MatForgeApp();
%   app.run();
%
%   或直接:
%   MatForgeApp.run();
%
%   See also eplot, ecalculator, ebatch

    properties
        UIFigure
        TabGroup
        PlotTab
        CalcTab
        BatchTab
        DataTab
        SettingsTab

        % 出图模块控件
        PlotStyleDropDown
        PlotExportFormatDropDown
        PlotFileEdit
        PlotDPIEdit

        % 计算模块控件
        CalcTypeDropDown
        CalcParamPanel

        % 状态
        StatusLabel
    end

    methods (Static)
        function run()
            app = MatForgeApp();
            app.createUI();
        end
    end

    methods
        function createUI(app)
            % 创建主窗口
            app.UIFigure = uifigure('Name', 'MatForge 🔧', ...
                'Position', [100 100 800 600], ...
                'Resize', 'on');

            % 创建标签页
            app.TabGroup = uitabgroup(app.UIFigure, 'Position', [10 60 780 530]);

            % 各模块标签页
            app.createPlotTab();
            app.createCalcTab();
            app.createBatchTab();
            app.createDataTab();
            app.createSettingsTab();

            % 状态栏
            app.StatusLabel = uilabel(app.UIFigure, ...
                'Position', [10 10 780 30], ...
                'Text', '✅ MatForge 已就绪', ...
                'FontSize', 12);
        end

        function createPlotTab(app)
            app.PlotTab = uitab(app.TabGroup, 'Title', '🎨 出图美化');

            % 样式选择
            uilabel(app.PlotTab, 'Position', [20 470 100 22], 'Text', '样式预设:');
            app.PlotStyleDropDown = uidropdown(app.PlotTab, ...
                'Position', [130 470 150 22], ...
                'Items', {'ieee', 'nature', 'springer', 'thesis', 'beamer', 'dark'}, ...
                'Value', 'ieee');

            % 应用按钮
            uibutton(app.PlotTab, 'push', ...
                'Position', [300 470 120 22], ...
                'Text', '应用样式', ...
                'ButtonPushedFcn', @(~,~) app.applyPlotStyle());

            % 导出设置
            uilabel(app.PlotTab, 'Position', [20 430 100 22], 'Text', '导出格式:');
            app.PlotExportFormatDropDown = uidropdown(app.PlotTab, ...
                'Position', [130 430 150 22], ...
                'Items', {'pdf', 'eps', 'png', 'tiff', 'svg'}, ...
                'Value', 'pdf');

            uilabel(app.PlotTab, 'Position', [20 390 100 22], 'Text', 'DPI:');
            app.PlotDPIEdit = uieditfield(app.PlotTab, 'numeric', ...
                'Position', [130 390 150 22], ...
                'Value', 300);

            uilabel(app.PlotTab, 'Position', [20 350 100 22], 'Text', '文件名:');
            app.PlotFileEdit = uieditfield(app.PlotTab, 'text', ...
                'Position', [130 350 300 22], ...
                'Value', 'my_figure');

            % 导出按钮
            uibutton(app.PlotTab, 'push', ...
                'Position', [450 350 120 22], ...
                'Text', '导出图表', ...
                'ButtonPushedFcn', @(~,~) app.exportPlot());

            % 说明文本
            uilabel(app.PlotTab, 'Position', [20 280 740 60], ...
                'Text', sprintf(['使用方法:\n' ...
                    '1. 在 MATLAB 中创建图表\n' ...
                    '2. 选择样式预设，点击"应用样式"\n' ...
                    '3. 设置导出参数，点击"导出图表"']), ...
                'FontSize', 11);
        end

        function createCalcTab(app)
            app.CalcTab = uitab(app.TabGroup, 'Title', '🧮 工程计算');

            % 计算类型
            uilabel(app.CalcTab, 'Position', [20 470 100 22], 'Text', '计算类型:');
            app.CalcTypeDropDown = uidropdown(app.CalcTab, ...
                'Position', [130 470 200 22], ...
                'Items', {'分压计算', 'RC滤波器', '波特图', '阶跃响应', 'PID整定', 'FFT分析'}, ...
                'Value', '分压计算', ...
                'ValueChangedFcn', @(~,~) app.updateCalcPanel());

            % 参数面板
            app.CalcParamPanel = uipanel(app.CalcTab, ...
                'Position', [20 100 350 350], ...
                'Title', '参数');

            % 运行按钮
            uibutton(app.CalcTab, 'push', ...
                'Position', [20 60 120 30], ...
                'Text', '计算', ...
                'FontSize', 14, ...
                'ButtonPushedFcn', @(~,~) app.runCalculation());

            % 初始化面板
            app.updateCalcPanel();
        end

        function createBatchTab(app)
            app.BatchTab = uitab(app.TabGroup, 'Title', '🔄 批量仿真');

            uilabel(app.BatchTab, 'Position', [20 470 740 30], ...
                'Text', '批量仿真功能请使用命令行:', ...
                'FontSize', 14, 'FontWeight', 'bold');

            uilabel(app.BatchTab, 'Position', [20 420 740 100], ...
                'Text', sprintf(['%s\n%s\n%s\n%s'], ...
                    'results = ebatch.sweep(''my_model'', ''Kp'', linspace(0.1, 10, 20));', ...
                    'ebatch.plot_surface(results, ''Kp'', ''Ki'', ''overshoot'');', ...
                    'ebatch.plot_heatmap(results, ''Kp'', ''Ki'', ''settling_time'');', ...
                    'ebatch.export_report(results, ''format'', ''html'');'), ...
                'FontName', 'Consolas', 'FontSize', 11);
        end

        function createDataTab(app)
            app.DataTab = uitab(app.TabGroup, 'Title', '📊 数据处理');

            uilabel(app.DataTab, 'Position', [20 470 740 30], ...
                'Text', '数据处理功能请使用命令行:', ...
                'FontSize', 14, 'FontWeight', 'bold');

            uilabel(app.DataTab, 'Position', [20 420 740 100], ...
                'Text', sprintf(['%s\n%s\n%s\n%s'], ...
                    'data = edata.read(''data.csv'');', ...
                    'data = edata.clean(data, ''remove_nan'', true, ''smooth'', 5);', ...
                    'info = edata.analyze(data, ''plot'', true);', ...
                    'edata.export(data, ''output.xlsx'');'), ...
                'FontName', 'Consolas', 'FontSize', 11);
        end

        function createSettingsTab(app)
            app.SettingsTab = uitab(app.TabGroup, 'Title', '⚙️ 设置');

            uilabel(app.SettingsTab, 'Position', [20 470 200 22], ...
                'Text', 'MatForge 版本: 1.0.0', 'FontSize', 14);

            uilabel(app.SettingsTab, 'Position', [20 440 400 22], ...
                'Text', '工科生的 MATLAB 瑞士军刀', 'FontSize', 12);

            uilabel(app.SettingsTab, 'Position', [20 380 740 60], ...
                'Text', sprintf(['模块:\n' ...
                    '  eplot - 出图美化\n' ...
                    '  ecalculator - 工程计算器\n' ...
                    '  ebatch - 批量仿真\n' ...
                    '  edata - 数据处理\n' ...
                    '  eutils - 实用工具\n' ...
                    '  esimulink - Simulink 辅助']), ...
                'FontSize', 11);
        end

        function applyPlotStyle(app)
            style = app.PlotStyleDropDown.Value;
            try
                eplot.style(gcf, style);
                app.StatusLabel.Text = sprintf('✅ 已应用样式: %s', style);
            catch ME
                app.StatusLabel.Text = sprintf('❌ 错误: %s', ME.message);
            end
        end

        function exportPlot(app)
            fmt = app.PlotExportFormatDropDown.Value;
            dpi = app.PlotDPIEdit.Value;
            fname = app.PlotFileEdit.Value;
            filename = sprintf('%s.%s', fname, fmt);

            try
                eplot.export(gcf, filename, 'dpi', dpi);
                app.StatusLabel.Text = sprintf('✅ 已导出: %s', filename);
            catch ME
                app.StatusLabel.Text = sprintf('❌ 错误: %s', ME.message);
            end
        end

        function updateCalcPanel(app)
            % 清空面板
            delete(app.CalcParamPanel.Children);

            type = app.CalcTypeDropDown.Value;
            y = 300;

            switch type
                case '分压计算'
                    createLabelEdit(app.CalcParamPanel, 'Vin (V):', 20, y, '12');
                    createLabelEdit(app.CalcParamPanel, 'R1 (Ω):', 20, y-40, '10000');
                    createLabelEdit(app.CalcParamPanel, 'R2 (Ω):', 20, y-80, '4700');

                case 'RC滤波器'
                    createLabelEdit(app.CalcParamPanel, 'R (Ω):', 20, y, '10000');
                    createLabelEdit(app.CalcParamPanel, 'C (F):', 20, y-40, '100e-9');
                    createLabelEdit(app.CalcParamPanel, '类型:', 20, y-80, 'lowpass');

                case '波特图'
                    createLabelEdit(app.CalcParamPanel, '分子:', 20, y, '[1]');
                    createLabelEdit(app.CalcParamPanel, '分母:', 20, y-40, '[1 2 1]');

                case '阶跃响应'
                    createLabelEdit(app.CalcParamPanel, '分子:', 20, y, '[1]');
                    createLabelEdit(app.CalcParamPanel, '分母:', 20, y-40, '[1 2 1]');

                case 'PID整定'
                    createLabelEdit(app.CalcParamPanel, '分子:', 20, y, '[1]');
                    createLabelEdit(app.CalcParamPanel, '分母:', 20, y-40, '[1 10 0]');
                    createLabelEdit(app.CalcParamPanel, '方法:', 20, y-80, 'ziegler-nichols');

                case 'FFT分析'
                    createLabelEdit(app.CalcParamPanel, '采样率:', 20, y, '1000');
                    createLabelEdit(app.CalcParamPanel, '时长 (s):', 20, y-40, '1');
            end
        end

        function runCalculation(app)
            type = app.CalcTypeDropDown.Value;
            try
                switch type
                    case '分压计算'
                        Vin = getEditValue(app.CalcParamPanel, 1);
                        R1 = getEditValue(app.CalcParamPanel, 2);
                        R2 = getEditValue(app.CalcParamPanel, 3);
                        ecalculator.circuit.voltage_divider(Vin, R1, R2);

                    case 'RC滤波器'
                        R = getEditValue(app.CalcParamPanel, 1);
                        C = getEditValue(app.CalcParamPanel, 2);
                        type_str = getEditString(app.CalcParamPanel, 3);
                        ecalculator.circuit.rc_filter(R, C, type_str);

                    case '波特图'
                        num = getEditArray(app.CalcParamPanel, 1);
                        den = getEditArray(app.CalcParamPanel, 2);
                        ecalculator.control.bode_plot(num, den);

                    case '阶跃响应'
                        num = getEditArray(app.CalcParamPanel, 1);
                        den = getEditArray(app.CalcParamPanel, 2);
                        ecalculator.control.step_response(num, den);

                    case 'PID整定'
                        num = getEditArray(app.CalcParamPanel, 1);
                        den = getEditArray(app.CalcParamPanel, 2);
                        method = getEditString(app.CalcParamPanel, 3);
                        ecalculator.control.pid_tune(num, den, method);

                    case 'FFT分析'
                        Fs = getEditValue(app.CalcParamPanel, 1);
                        duration = getEditValue(app.CalcParamPanel, 2);
                        t = 0:1/Fs:duration;
                        x = sin(2*pi*50*t) + 0.5*sin(2*pi*120*t) + 0.2*randn(size(t));
                        ecalculator.signal.fft_analyze(x, Fs);
                end
                app.StatusLabel.Text = sprintf('✅ %s 计算完成', type);
            catch ME
                app.StatusLabel.Text = sprintf('❌ 错误: %s', ME.message);
            end
        end
    end
end

function createLabelEdit(panel, label, x, y, default)
    uilabel(panel, 'Position', [x y 80 22], 'Text', label);
    uieditfield(panel, 'text', 'Position', [x+90 y 180 22], 'Value', default);
end

function val = getEditValue(panel, idx)
    edits = findobj(panel, 'Type', 'uieditfield');
    val = str2double(edits(end-idx+1).Value);
end

function val = getEditString(panel, idx)
    edits = findobj(panel, 'Type', 'uieditfield');
    val = edits(end-idx+1).Value;
end

function val = getEditArray(panel, idx)
    edits = findobj(panel, 'Type', 'uieditfield');
    val = str2num(edits(end-idx+1).Value);  % str2num for array parsing
end
