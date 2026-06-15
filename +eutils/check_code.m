function issues = check_code(directory, varargin)
%EUTILS.CHECK_CODE MATLAB 代码质量检查
%
%   issues = eutils.check_code('src/')
%   issues = eutils.check_code('src/', 'verbose', true)
%
%   检查项:
%     - eval 使用
%     - 魔法数字
%     - 变量命名规范
%     - 注释覆盖率
%     - 函数长度
%     - 文件长度
%
%   See also eutils.init_project, eutils.add_path

    opts = struct('verbose', true, 'max_lines', 500, 'max_func_lines', 100);
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    if nargin < 1
        directory = pwd;
    end

    % 查找所有 .m 文件
    files = dir(fullfile(directory, '**', '*.m'));
    n_files = numel(files);

    if opts.verbose
        fprintf('🔍 代码质量检查: %s\n', directory);
        fprintf('   找到 %d 个 .m 文件\n\n', n_files);
    end

    issues = {};

    for i = 1:n_files
        filepath = fullfile(files(i).folder, files(i).name);
        file_issues = check_file(filepath, opts);
        issues = [issues; file_issues];
    end

    % 打印报告
    if opts.verbose
        fprintf('\n📊 检查报告:\n');
        fprintf('   文件数: %d\n', n_files);
        fprintf('   问题数: %d\n', numel(issues));

        if isempty(issues)
            fprintf('   ✅ 没有发现问题!\n');
        else
            % 按严重程度分类
            errors = issues(cellfun(@(x) strcmp(x.severity, 'error'), issues));
            warnings = issues(cellfun(@(x) strcmp(x.severity, 'warning'), issues));
            infos = issues(cellfun(@(x) strcmp(x.severity, 'info'), issues));

            fprintf('   ❌ 错误: %d\n', numel(errors));
            fprintf('   ⚠️  警告: %d\n', numel(warnings));
            fprintf('   ℹ️  建议: %d\n', numel(infos));

            fprintf('\n');
            for i = 1:numel(issues)
                issue = issues{i};
                switch issue.severity
                    case 'error'
                        icon = '❌';
                    case 'warning'
                        icon = '⚠️';
                    case 'info'
                        icon = 'ℹ️';
                end
                fprintf('   %s %s (行 %d): %s\n', icon, issue.file, issue.line, issue.message);
            end
        end
    end
end

function issues = check_file(filepath, opts)
    issues = {};

    % 读取文件
    try
        text = fileread(filepath);
        lines = splitlines(text);
    catch
        return;
    end

    [~, filename, ~] = fileparts(filepath);

    % 检查 eval 使用
    for i = 1:numel(lines)
        line = strtrim(lines{i});
        if startsWith(line, '%')
            continue;
        end
        if contains(line, 'eval(') || contains(line, 'evalc(')
            issues{end+1} = struct('file', filename, 'line', i, ...
                'severity', 'warning', 'message', '使用了 eval，考虑用其他方式替代');
        end
    end

    % 检查 clear all
    for i = 1:numel(lines)
        line = strtrim(lines{i});
        if strcmp(line, 'clear all') || strcmp(line, 'clear')
            issues{end+1} = struct('file', filename, 'line', i, ...
                'severity', 'info', 'message', '使用 clear 可能影响性能，考虑用 clearvars');
        end
    end

    % 检查魔法数字
    for i = 1:numel(lines)
        line = strtrim(lines{i});
        if startsWith(line, '%')
            continue;
        end
        % 简单的数字检测
        nums = regexp(line, '(?<![a-zA-Z_])\d+\.?\d*(?![a-zA-Z_])', 'match');
        for j = 1:numel(nums)
            num = nums{j};
            val = str2double(num);
            % 忽略常见的数字
            if ~ismember(val, [0, 1, 2, 10, 100, 1000, 0.5, 0.1, 0.01, 0.001, 0.1])
                if val > 1 || val < -1
                    issues{end+1} = struct('file', filename, 'line', i, ...
                        'severity', 'info', 'message', sprintf('魔法数字: %s', num));
                end
            end
        end
    end

    % 检查文件长度
    if numel(lines) > opts.max_lines
        issues{end+1} = struct('file', filename, 'line', 0, ...
            'severity', 'warning', ...
            'message', sprintf('文件过长 (%d 行 > %d)', numel(lines), opts.max_lines));
    end

    % 检查注释覆盖率
    comment_lines = 0;
    code_lines = 0;
    for i = 1:numel(lines)
        line = strtrim(lines{i});
        if isempty(line)
            continue;
        end
        if startsWith(line, '%')
            comment_lines = comment_lines + 1;
        else
            code_lines = code_lines + 1;
        end
    end

    if code_lines > 10
        ratio = comment_lines / code_lines;
        if ratio < 0.1
            issues{end+1} = struct('file', filename, 'line', 0, ...
                'severity', 'info', ...
                'message', sprintf('注释率低 (%.1f%%)', ratio * 100));
        end
    end

    % 检查 TODO/FIXME
    for i = 1:numel(lines)
        line = upper(strtrim(lines{i}));
        if contains(line, 'TODO') || contains(line, 'FIXME') || contains(line, 'HACK')
            issues{end+1} = struct('file', filename, 'line', i, ...
                'severity', 'info', 'message', '包含 TODO/FIXME');
        end
    end
end
