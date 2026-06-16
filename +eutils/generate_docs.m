function generate_docs(project_root, varargin)
%EUTILS.GENERATE_DOCS 生成工具箱文档
%
%   eutils.generate_docs('.')
%   eutils.generate_docs('.', 'format', 'html')
%   eutils.generate_docs('.', 'format', 'markdown', 'output', 'docs/')
%
%   基于 MATLAB 最佳实践的文档生成:
%   1. README.md
%   2. Contents.m
%   3. functionSignatures.json
%   4. GettingStarted.m
%   5. API 文档
%   6. 示例脚本
%
%   可选参数:
%     'format'  - 输出格式 'html'/'markdown' (默认 'markdown')
%     'output'  - 输出目录 (默认 'docs/')
%     'name'    - 工具箱名称
%
%   See also eutils.init_project, eutils.package_toolbox

    opts = struct('format', 'markdown', 'output', 'docs', 'name', '');
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    if isempty(opts.name)
        [~, opts.name, ~] = fileparts(project_root);
    end

    output_dir = fullfile(project_root, opts.output);
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    fprintf('📚 生成文档: %s\n', opts.name);
    fprintf('   格式: %s\n', opts.format);
    fprintf('   输出: %s\n\n', output_dir);

    %% 1. 生成 README.md
    fprintf('📝 1. 生成 README.md\n');
    generate_readme(project_root, opts);

    %% 2. 生成 Contents.m
    fprintf('\n📝 2. 生成 Contents.m\n');
    generate_contents(project_root, opts);

    %% 3. 生成 functionSignatures.json
    fprintf('\n📝 3. 生成 functionSignatures.json\n');
    generate_signatures(project_root);

    %% 4. 生成 API 文档
    fprintf('\n📝 4. 生成 API 文档\n');
    generate_api_docs(project_root, opts);

    %% 5. 生成示例
    fprintf('\n📝 5. 生成示例\n');
    generate_examples(project_root, opts);

    %% 6. 生成 GettingStarted.m
    fprintf('\n📝 6. 生成 GettingStarted.m\n');
    generate_getting_started(project_root, opts);

    fprintf('\n🎉 文档生成完成!\n');
    fprintf('   输出目录: %s\n', output_dir);
end

function generate_readme(project_root, opts)
    readme_file = fullfile(project_root, 'README.md');
    if exist(readme_file, 'file')
        fprintf('   ✅ README.md 已存在\n');
        return;
    end

    fid = fopen(readme_file, 'w');

    fprintf(fid, '# %s\n\n', opts.name);
    fprintf(fid, '## 简介\n\n');
    fprintf(fid, 'TODO: 添加工具箱简介\n\n');

    fprintf(fid, '## 安装\n\n');
    fprintf(fid, '```matlab\n');
    fprintf(fid, 'addpath(genpath(''%s''));\n', opts.name);
    fprintf(fid, '```\n\n');

    fprintf(fid, '## 快速开始\n\n');
    fprintf(fid, '```matlab\n');
    fprintf(fid, '%% TODO: 添加快速开始示例\n');
    fprintf(fid, '```\n\n');

    fprintf(fid, '## 功能模块\n\n');
    fprintf(fid, '| 模块 | 描述 |\n');
    fprintf(fid, '|------|------|\n');

    modules = {'eplot', 'ecalculator', 'ebatch', 'edata', 'eutils', 'esimulink'};
    descriptions = {'出图美化', '工程计算器', '批量仿真', '数据处理', '实用工具', 'Simulink 辅助'};

    for i = 1:numel(modules)
        module_dir = fullfile(project_root, ['+' modules{i}]);
        if exist(module_dir, 'dir')
            fprintf(fid, '| %s | %s |\n', modules{i}, descriptions{i});
        end
    end

    fprintf(fid, '\n## 文档\n\n');
    fprintf(fid, '- [API 参考](docs/API.md)\n');
    fprintf(fid, '- [快速开始](docs/QUICKSTART.md)\n');
    fprintf(fid, '- [示例](examples/)\n\n');

    fprintf(fid, '## 许可证\n\n');
    fprintf(fid, 'MIT License\n');

    fclose(fid);
    fprintf('   ✅ README.md 已生成\n');
end

function generate_contents(project_root, opts)
    contents_file = fullfile(project_root, 'Contents.m');
    if exist(contents_file, 'file')
        fprintf('   ✅ Contents.m 已存在\n');
        return;
    end

    fid = fopen(contents_file, 'w');

    fprintf(fid, '%% %s\n', upper(opts.name));
    fprintf(fid, '%% Version 1.0.0 %s\n', datestr(now, 'dd-mmm-yyyy'));
    fprintf(fid, '%%\n');
    fprintf(fid, '%% MATLAB 工程工具箱\n');
    fprintf(fid, '%%\n');

    % 列出所有模块
    modules = {'eplot', 'ecalculator', 'ebatch', 'edata', 'eutils', 'esimulink'};
    descriptions = {'出图美化模块', '工程计算器模块', '批量仿真模块', ...
                   '数据处理模块', '实用工具模块', 'Simulink 辅助模块'};

    for i = 1:numel(modules)
        module_dir = fullfile(project_root, ['+' modules{i}]);
        if exist(module_dir, 'dir')
            fprintf(fid, '%%\n');
            fprintf(fid, '%% %s - %s\n', modules{i}, descriptions{i});

            % 列出模块中的函数
            m_files = dir(fullfile(module_dir, '*.m'));
            for j = 1:numel(m_files)
                [~, func_name, ~] = fileparts(m_files(j).name);
                h1 = get_h1_line(fullfile(module_dir, m_files(j).name));
                if ~isempty(h1)
                    fprintf(fid, '%%   %s - %s\n', func_name, h1);
                end
            end
        end
    end

    fclose(fid);
    fprintf('   ✅ Contents.m 已生成\n');
end

function h1 = get_h1_line(filepath)
    h1 = '';
    try
        text = fileread(filepath);
        lines = splitlines(text);
        for i = 1:min(20, numel(lines))
            line = strtrim(lines{i});
            if startsWith(line, '%') && ~startsWith(line, '%%')
                h1 = strtrim(line(2:end));
                break;
            end
        end
    catch
    end
end

function generate_signatures(project_root)
    sigs_dir = fullfile(project_root, 'resources');
    sigs_file = fullfile(sigs_dir, 'functionSignatures.json');

    if exist(sigs_file, 'file')
        fprintf('   ✅ functionSignatures.json 已存在\n');
        return;
    end

    if ~exist(sigs_dir, 'dir')
        mkdir(sigs_dir);
    end

    % 收集所有函数
    m_files = dir(fullfile(project_root, '**', '*.m'));
    sigs = struct();

    for i = 1:numel(m_files)
        [~, func_name, ~] = fileparts(m_files(i).name);

        % 跳过特殊文件
        if startsWith(func_name, 'test_') || startsWith(func_name, 'Contents')
            continue;
        end

        % 读取函数签名
        try
            sig = extract_signature(fullfile(m_files(i).folder, m_files(i).name));
            if ~isempty(sig)
                sigs.(func_name) = sig;
            end
        catch
        end
    end

    % 写入 JSON
    json_text = jsonencode(sigs, 'PrettyPrint', true);
    fid = fopen(sigs_file, 'w');
    fprintf(fid, '%s', json_text);
    fclose(fid);

    fprintf('   ✅ functionSignatures.json 已生成\n');
end

function sig = extract_signature(filepath)
    sig = [];
    text = fileread(filepath);
    lines = splitlines(text);

    % 找到函数声明
    for i = 1:min(20, numel(lines))
        line = strtrim(lines{i});
        if startsWith(line, 'function')
            % 解析函数签名
            sig = struct();
            sig.description = '';

            % 找到 H1 行
            for j = i+1:min(i+5, numel(lines))
                h1_line = strtrim(lines{j});
                if startsWith(h1_line, '%')
                    sig.description = strtrim(h1_line(2:end));
                    break;
                end
            end

            break;
        end
    end
end

function generate_api_docs(project_root, opts)
    api_file = fullfile(project_root, opts.output, 'API.md');
    if exist(api_file, 'file')
        fprintf('   ✅ API.md 已存在\n');
        return;
    end

    fid = fopen(api_file, 'w');

    fprintf(fid, '# %s API 参考\n\n', opts.name);

    % 列出所有模块
    modules = {'eplot', 'ecalculator', 'ebatch', 'edata', 'eutils', 'esimulink'};
    descriptions = {'出图美化', '工程计算器', '批量仿真', '数据处理', '实用工具', 'Simulink 辅助'};

    for i = 1:numel(modules)
        module_dir = fullfile(project_root, ['+' modules{i}]);
        if exist(module_dir, 'dir')
            fprintf(fid, '## %s — %s\n\n', modules{i}, descriptions{i});

            % 列出模块中的函数
            m_files = dir(fullfile(module_dir, '*.m'));
            for j = 1:numel(m_files)
                [~, func_name, ~] = fileparts(m_files(j).name);
                h1 = get_h1_line(fullfile(module_dir, m_files(j).name));

                fprintf(fid, '### %s\n', func_name);
                if ~isempty(h1)
                    fprintf(fid, '%s\n\n', h1);
                end

                % 提取用法示例
                usage = extract_usage(fullfile(module_dir, m_files(j).name));
                if ~isempty(usage)
                    fprintf(fid, '```matlab\n%s\n```\n\n', usage);
                end
            end
        end
    end

    fclose(fid);
    fprintf('   ✅ API.md 已生成\n');
end

function usage = extract_usage(filepath)
    usage = '';
    try
        text = fileread(filepath);
        lines = splitlines(text);

        % 找到用法示例
        in_example = false;
        example_lines = {};

        for i = 1:numel(lines)
            line = strtrim(lines{i});

            if contains(line, 'Example') || contains(line, '示例')
                in_example = true;
                continue;
            end

            if in_example
                if startsWith(line, '%')
                    code = strtrim(line(2:end));
                    if ~isempty(code)
                        example_lines{end+1} = code;
                    end
                elseif isempty(line)
                    break;
                end
            end
        end

        if ~isempty(example_lines)
            usage = strjoin(example_lines, '\n');
        end
    catch
    end
end

function generate_examples(project_root, opts)
    examples_dir = fullfile(project_root, 'examples');
    if ~exist(examples_dir, 'dir')
        mkdir(examples_dir);
    end

    % 检查是否已有示例
    existing = dir(fullfile(examples_dir, '*.m'));
    if ~isempty(existing)
        fprintf('   ✅ 示例已存在 (%d 个)\n', numel(existing));
        return;
    end

    % 生成示例
    modules = {'eplot', 'ecalculator', 'ebatch', 'edata'};
    for i = 1:numel(modules)
        example_file = fullfile(examples_dir, sprintf('example_%s.m', modules{i}));
        if ~exist(example_file, 'file')
            generate_module_example(example_file, modules{i});
        end
    end

    fprintf('   ✅ 示例已生成\n');
end

function generate_module_example(filepath, module)
    fid = fopen(filepath, 'w');

    fprintf(fid, '%% %s 示例\n', upper(module));
    fprintf(fid, '%% 本脚本演示 %s 模块的各种功能\n\n', module);

    fprintf(fid, 'clear; clc; close all;\n\n');

    switch module
        case 'eplot'
            fprintf(fid, '%% 1. 基础出图\n');
            fprintf(fid, 'x = linspace(0, 2*pi, 100);\n');
            fprintf(fid, 'figure; plot(x, sin(x), x, cos(x));\n');
            fprintf(fid, 'xlabel(''X''); ylabel(''Y''); title(''三角函数'');\n\n');

            fprintf(fid, '%% 2. 应用样式\n');
            fprintf(fid, 'eplot.style(''ieee'');\n\n');

            fprintf(fid, '%% 3. 导出图表\n');
            fprintf(fid, 'eplot.export(''example_plot.pdf'');\n');

        case 'ecalculator'
            fprintf(fid, '%% 1. 控制系统\n');
            fprintf(fid, 'ecalculator.control.bode_plot([1], [1 2 1]);\n\n');

            fprintf(fid, '%% 2. 电路计算\n');
            fprintf(fid, 'ecalculator.circuit.voltage_divider(12, 10e3, 4.7e3);\n\n');

            fprintf(fid, '%% 3. 信号处理\n');
            fprintf(fid, 'ecalculator.signal.sampling_check(1000, 8000);\n');

        case 'ebatch'
            fprintf(fid, '%% 批量仿真示例\n');
            fprintf(fid, '%% 注意: 需要 Simulink 模型\n\n');

            fprintf(fid, '%% results = ebatch.sweep(''my_model'', ...\n');
            fprintf(fid, '%%     ''Kp'', linspace(0.1, 10, 20));\n');

        case 'edata'
            fprintf(fid, '%% 1. 读取数据\n');
            fprintf(fid, '%% data = edata.read(''data.csv'');\n\n');

            fprintf(fid, '%% 2. 清洗数据\n');
            fprintf(fid, '%% data = edata.clean(data, ''remove_nan'', true);\n\n');

            fprintf(fid, '%% 3. 分析数据\n');
            fprintf(fid, '%% info = edata.analyze(data, ''plot'', true);\n');
    end

    fclose(fid);
end

function generate_getting_started(project_root, opts)
    gs_file = fullfile(project_root, 'GettingStarted.m');
    if exist(gs_file, 'file')
        fprintf('   ✅ GettingStarted.m 已存在\n');
        return;
    end

    fid = fopen(gs_file, 'w');

    fprintf(fid, '%%%% %s 快速开始\n', opts.name);
    fprintf(fid, '%% 本脚本帮助您快速上手 %s 工具箱\n\n', opts.name);

    fprintf(fid, '%% 1. 添加路径\n');
    fprintf(fid, 'addpath(genpath(fileparts(mfilename(''fullpath''))));\n\n');

    fprintf(fid, '%% 2. 出图美化示例\n');
    fprintf(fid, 'x = linspace(0, 2*pi, 100);\n');
    fprintf(fid, 'figure; plot(x, sin(x), x, cos(x));\n');
    fprintf(fid, 'eplot.style(''ieee'');\n\n');

    fprintf(fid, '%% 3. 工程计算示例\n');
    fprintf(fid, 'ecalculator.circuit.voltage_divider(12, 10e3, 4.7e3);\n\n');

    fprintf(fid, '%% 4. 单位换算示例\n');
    fprintf(fid, 'eutils.units.convert(100, ''mph'', ''kmh'');\n\n');

    fprintf(fid, '%% 5. 公式速查\n');
    fprintf(fid, 'eutils.formulas.control();\n\n');

    fprintf(fid, 'fprintf(''\\n🎉 快速开始完成!\\n'');\n');

    fclose(fid);
    fprintf('   ✅ GettingStarted.m 已生成\n');
end
