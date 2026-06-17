function package_toolbox(varargin)
%EUTILS.PACKAGE_TOOLBOX 打包 MATLAB 工具箱
%
%   eutils.package_toolbox('MyToolbox')
%   eutils.package_toolbox('MyToolbox', 'version', '1.0.0')
%   eutils.package_toolbox('MyToolbox', 'version', '1.0.0', 'output', 'release/')
%
%   基于 MATLAB 最佳实践的工具箱打包流程:
%   1. 验证项目结构
%   2. 检查代码质量
%   3. 运行测试
%   4. 生成文档
%   5. 打包 .mltbx
%   6. 验证包
%
%   可选参数:
%     'version'    - 版本号 (默认 '1.0.0')
%     'output'     - 输出目录 (默认 'release/')
%     'name'       - 工具箱名称
%     'description'- 工具箱描述
%     'author'     - 作者
%     'skip_tests' - 是否跳过测试 (默认 false)
%
%   See also eutils.init_project, eutils.check_code

    opts = struct('version', '1.0.0', 'output', 'release/', ...
                  'name', '', 'description', '', 'author', '', ...
                  'skip_tests', false);
    args = {};
    i = 1;
    while i <= numel(varargin)
        if isfield(opts, varargin{i})
            opts.(varargin{i}) = varargin{i+1};
            i = i + 2;
        else
            args{end+1} = varargin{i};
            i = i + 1;
        end
    end

    if isempty(args)
        project_root = pwd;
    else
        project_root = args{1};
    end

    if isempty(opts.name)
        [~, opts.name, ~] = fileparts(project_root);
    end

    fprintf('📦 打包工具箱: %s\n', opts.name);
    fprintf('   版本: %s\n', opts.version);
    fprintf('   目录: %s\n\n', project_root);

    %% Step 1: 验证项目结构
    fprintf('📋 Step 1: 验证项目结构\n');
    validate_structure(project_root);

    %% Step 2: 检查代码质量
    fprintf('\n📋 Step 2: 检查代码质量\n');
    issues = eutils.check_code(project_root, 'verbose', false);
    n_errors = sum(cellfun(@(x) strcmp(x.severity, 'error'), issues));
    n_warnings = sum(cellfun(@(x) strcmp(x.severity, 'warning'), issues));
    fprintf('   错误: %d, 警告: %d\n', n_errors, n_warnings);

    if n_errors > 0
        fprintf('   ❌ 存在错误，请先修复\n');
        for i = 1:numel(issues)
            if strcmp(issues{i}.severity, 'error')
                fprintf('      %s (行 %d): %s\n', issues{i}.file, issues{i}.line, issues{i}.message);
            end
        end
        return;
    end

    %% Step 3: 运行测试
    if ~opts.skip_tests
        fprintf('\n📋 Step 3: 运行测试\n');
        test_dir = fullfile(project_root, 'tests');
        if exist(test_dir, 'dir')
            try
                results = runtests(test_dir);
                n_passed = sum([results.Passed]);
                n_failed = sum([results.Failed]);
                fprintf('   通过: %d, 失败: %d\n', n_passed, n_failed);

                if n_failed > 0
                    fprintf('   ⚠️  有测试失败，建议修复后打包\n');
                end
            catch ME
                fprintf('   ⚠️  测试运行失败: %s\n', ME.message);
            end
        else
            fprintf('   ⚠️  未找到测试目录\n');
        end
    else
        fprintf('\n📋 Step 3: 跳过测试\n');
    end

    %% Step 4: 生成文档
    fprintf('\n📋 Step 4: 生成文档\n');
    generate_docs(project_root, opts);

    %% Step 5: 打包 .mltbx
    fprintf('\n📋 Step 5: 打包 .mltbx\n');
    output_dir = fullfile(project_root, opts.output);
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    mltbx_file = fullfile(output_dir, sprintf('%s.mltbx', opts.name));

    try
        % 创建打包选项
        opts_pkg = matlab.addons.toolbox.ToolboxOptions(project_root);

        % 设置选项
        opts_pkg.ToolboxName = opts.name;
        opts_pkg.ToolboxVersion = opts.version;
        opts_pkg.Description = opts.description;
        opts_pkg.Author = opts.author;
        opts_pkg.OutputFile = mltbx_file;

        % 打包
        matlab.addons.toolbox.packageToolbox(opts_pkg);

        fprintf('   ✅ 打包成功: %s\n', mltbx_file);
    catch ME
        fprintf('   ❌ 打包失败: %s\n', ME.message);
        return;
    end

    %% Step 6: 验证包
    fprintf('\n📋 Step 6: 验证包\n');
    if exist(mltbx_file, 'file')
        info = dir(mltbx_file);
        fprintf('   文件: %s\n', mltbx_file);
        fprintf('   大小: %.1f KB\n', info.bytes/1024);
        fprintf('   ✅ 验证通过\n');
    else
        fprintf('   ❌ 包文件不存在\n');
        return;
    end

    %% 完成
    fprintf('\n🎉 打包完成!\n');
    fprintf('   输出: %s\n', mltbx_file);
    fprintf('   安装命令: matlab.addons.toolbox.installToolbox(''%s'')\n', mltbx_file);
end

function validate_structure(project_root)
    % 检查必要的文件和目录
    required_files = {};
    recommended_dirs = {'+eplot', '+ecalculator', '+ebatch', '+edata', '+eutils', '+esimulink'};

    % 检查 .m 文件
    m_files = dir(fullfile(project_root, '**', '*.m'));
    fprintf('   找到 %d 个 .m 文件\n', numel(m_files));

    % 检查推荐的目录
    for i = 1:numel(recommended_dirs)
        dir_path = fullfile(project_root, recommended_dirs{i});
        if exist(dir_path, 'dir')
            fprintf('   ✅ %s\n', recommended_dirs{i});
        else
            fprintf('   ⚠️  %s (可选)\n', recommended_dirs{i});
        end
    end

    % 检查 README
    if exist(fullfile(project_root, 'README.md'), 'file')
        fprintf('   ✅ README.md\n');
    else
        fprintf('   ⚠️  缺少 README.md\n');
    end

    % 检查 tests 目录
    if exist(fullfile(project_root, 'tests'), 'dir')
        fprintf('   ✅ tests/\n');
    else
        fprintf('   ⚠️  缺少 tests/ 目录\n');
    end

    % 检查 examples 目录
    if exist(fullfile(project_root, 'examples'), 'dir')
        fprintf('   ✅ examples/\n');
    else
        fprintf('   ⚠️  缺少 examples/ 目录\n');
    end
end

function generate_docs(project_root, opts)
    % 生成 Contents.m
    contents_file = fullfile(project_root, 'Contents.m');
    if ~exist(contents_file, 'file')
        fprintf('   生成 Contents.m...\n');
        generate_contents(project_root, opts);
    else
        fprintf('   ✅ Contents.m 已存在\n');
    end

    % 生成 functionSignatures.json
    sigs_file = fullfile(project_root, 'resources', 'functionSignatures.json');
    if ~exist(sigs_file, 'file')
        fprintf('   生成 functionSignatures.json...\n');
        generate_signatures(project_root);
    else
        fprintf('   ✅ functionSignatures.json 已存在\n');
    end
end

function generate_contents(project_root, opts)
    contents_file = fullfile(project_root, 'Contents.m');
    fid = fopen(contents_file, 'w');

    fprintf(fid, '%% %s\n', upper(opts.name));
    fprintf(fid, '%% Version %s %s\n', opts.version, datestr(now, 'dd-mmm-yyyy'));
    fprintf(fid, '%%\n');
    fprintf(fid, '%% %s\n', opts.description);
    fprintf(fid, '%%\n');

    % 列出所有模块
    modules = {'eplot', 'ecalculator', 'ebatch', 'edata', 'eutils', 'esimulink'};
    for i = 1:numel(modules)
        module_dir = fullfile(project_root, ['+' modules{i}]);
        if exist(module_dir, 'dir')
            fprintf(fid, '%% %s - %s\n', modules{i}, get_module_description(modules{i}));
        end
    end

    fclose(fid);
end

function desc = get_module_description(module)
    switch module
        case 'eplot'
            desc = '出图美化模块';
        case 'ecalculator'
            desc = '工程计算器模块';
        case 'ebatch'
            desc = '批量仿真模块';
        case 'edata'
            desc = '数据处理模块';
        case 'eutils'
            desc = '实用工具模块';
        case 'esimulink'
            desc = 'Simulink 辅助模块';
        otherwise
            desc = '';
    end
end

function generate_signatures(project_root)
    sigs_file = fullfile(project_root, 'resources', 'functionSignatures.json');
    sigs_dir = fileparts(sigs_file);
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
        catch ME
            warning('ecalculator:package:sigFailed', ...
                '读取函数签名失败 %s: %s', func_name, ME.message);
        end
    end

    % 写入 JSON
    json_text = jsonencode(sigs, 'PrettyPrint', true);
    fid = fopen(sigs_file, 'w');
    fprintf(fid, '%s', json_text);
    fclose(fid);
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
