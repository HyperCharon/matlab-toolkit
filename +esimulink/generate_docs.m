function generate_docs(model_name, varargin)
%ESIMULINK.GENERATE_DOCS 自动生成 Simulink 模型文档
%
%   esimulink.generate_docs('my_model')
%   esimulink.generate_docs('my_model', 'format', 'html')
%   esimulink.generate_docs('my_model', 'format', 'markdown')
%
%   支持格式:
%     'html'     - 交互式 HTML 文档 (默认)
%     'markdown' - Markdown 文档
%     'latex'    - LaTeX 文档
%
%   可选参数:
%     'format'      - 输出格式 (默认 'html')
%     'output'      - 输出目录 (默认 'docs')
%     'screenshot'  - 是否截取模型图 (默认 true)
%     'parameters'  - 是否导出参数 (默认 true)
%
%   See also esimulink.check_model, esimulink.export_params

    opts = struct('format', 'html', 'output', 'docs', 'screenshot', true, 'parameters', true);
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    % 加载模型
    try
        load_system(model_name);
    catch
        error('esimulink:generate_docs:modelNotFound', '无法加载模型: %s', model_name);
    end

    % 创建输出目录
    if ~exist(opts.output, 'dir')
        mkdir(opts.output);
    end

    fprintf('📄 生成 Simulink 模型文档: %s\n', model_name);

    % 获取模型信息
    info = get_model_info(model_name);

    % 截取模型图
    if opts.screenshot
        screenshot_path = fullfile(opts.output, sprintf('%s_model.png', model_name));
        try
            print(['-s' model_name], '-dpng', '-r150', screenshot_path);
            info.screenshot = screenshot_path;
            fprintf('   ✅ 模型截图已保存\n');
        catch
            fprintf('   ⚠️  模型截图失败\n');
        end
    end

    % 根据格式生成文档
    switch lower(opts.format)
        case 'html'
            generate_html(model_name, info, opts);
        case 'markdown'
            generate_markdown(model_name, info, opts);
        case 'latex'
            generate_latex(model_name, info, opts);
    end

    fprintf('✅ 文档生成完成: %s/\n', opts.output);
end

function info = get_model_info(model_name)
    info = struct();
    info.name = model_name;
    info.description = get_param(model_name, 'Description');
    info.created = get_param(model_name, 'Created');
    info.modified = get_param(model_name, 'LastModified');
    info.version = get_param(model_name, 'ModelVersion');

    % 获取所有模块
    blocks = find_system(model_name, 'Type', 'block');
    info.n_blocks = numel(blocks);
    info.blocks = {};

    for i = 1:min(numel(blocks), 100)  % 限制最多 100 个
        block = struct();
        block.path = blocks{i};
        block.name = get_param(blocks{i}, 'Name');
        block.type = get_param(blocks{i}, 'BlockType');
        block.description = get_param(blocks{i}, 'Description');
        info.blocks{end+1} = block;
    end

    % 获取子系统
    subsystems = find_system(model_name, 'BlockType', 'SubSystem');
    info.n_subsystems = numel(subsystems);
    info.subsystems = {};

    for i = 1:numel(subsystems)
        sub = struct();
        sub.path = subsystems{i};
        sub.name = get_param(subsystems{i}, 'Name');
        sub.description = get_param(subsystems{i}, 'Description');
        info.subsystems{end+1} = sub;
    end

    % 获取信号线
    lines = find_system(model_name, 'FindAll', 'on', 'Type', 'line');
    info.n_lines = numel(lines);

    % 获取工作区参数
    try
        ws = get_param(model_name, 'ModelWorkspace');
        vars = whos(ws);
        info.n_variables = numel(vars);
        info.variables = {};
        for i = 1:numel(vars)
            v = struct();
            v.name = vars(i).name;
            v.size = vars(i).size;
            v.class = vars(i).class;
            info.variables{end+1} = v;
        end
    catch
        info.n_variables = 0;
        info.variables = {};
    end
end

function generate_html(model_name, info, opts)
    filename = fullfile(opts.output, sprintf('%s_docs.html', model_name));
    fid = fopen(filename, 'w');

    fprintf(fid, '<!DOCTYPE html>\n<html>\n<head>\n');
    fprintf(fid, '<meta charset="UTF-8">\n');
    fprintf(fid, '<title>%s - 模型文档</title>\n', model_name);
    fprintf(fid, '<style>\n');
    fprintf(fid, 'body { font-family: -apple-system, sans-serif; margin: 40px; }\n');
    fprintf(fid, 'h1 { color: #2c3e50; }\n');
    fprintf(fid, 'h2 { color: #34495e; border-bottom: 1px solid #eee; padding-bottom: 5px; }\n');
    fprintf(fid, 'table { border-collapse: collapse; width: 100%%; margin: 20px 0; }\n');
    fprintf(fid, 'th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }\n');
    fprintf(fid, 'th { background: #3498db; color: white; }\n');
    fprintf(fid, '.info-box { background: #ecf0f1; padding: 15px; border-radius: 5px; margin: 10px 0; }\n');
    fprintf(fid, '</style>\n</head>\n<body>\n');

    fprintf(fid, '<h1>📊 %s - Simulink 模型文档</h1>\n', model_name);
    fprintf(fid, '<p>%s</p>\n', info.description);

    fprintf(fid, '<div class="info-box">\n');
    fprintf(fid, '<p><strong>版本:</strong> %s</p>\n', info.version);
    fprintf(fid, '<p><strong>创建时间:</strong> %s</p>\n', info.created);
    fprintf(fid, '<p><strong>修改时间:</strong> %s</p>\n', info.modified);
    fprintf(fid, '<p><strong>模块数:</strong> %d</p>\n', info.n_blocks);
    fprintf(fid, '<p><strong>子系统数:</strong> %d</p>\n', info.n_subsystems);
    fprintf(fid, '<p><strong>信号线数:</strong> %d</p>\n', info.n_lines);
    fprintf(fid, '</div>\n');

    % 模型截图
    if isfield(info, 'screenshot') && exist(info.screenshot, 'file')
        fprintf(fid, '<h2>🖼️ 模型图</h2>\n');
        fprintf(fid, '<img src="%s" style="max-width:100%%">\n', ...
            sprintf('%s_model.png', model_name));
    end

    % 子系统列表
    if ~isempty(info.subsystems)
        fprintf(fid, '<h2>📦 子系统</h2>\n');
        fprintf(fid, '<table>\n<tr><th>名称</th><th>路径</th><th>描述</th></tr>\n');
        for i = 1:numel(info.subsystems)
            sub = info.subsystems{i};
            fprintf(fid, '<tr><td>%s</td><td>%s</td><td>%s</td></tr>\n', ...
                sub.name, sub.path, sub.description);
        end
        fprintf(fid, '</table>\n');
    end

    % 变量列表
    if info.n_variables > 0
        fprintf(fid, '<h2>📐 工作区变量</h2>\n');
        fprintf(fid, '<table>\n<tr><th>名称</th><th>类型</th><th>大小</th></tr>\n');
        for i = 1:numel(info.variables)
            v = info.variables{i};
            fprintf(fid, '<tr><td>%s</td><td>%s</td><td>%s</td></tr>\n', ...
                v.name, v.class, mat2str(v.size));
        end
        fprintf(fid, '</table>\n');
    end

    fprintf(fid, '</body>\n</html>');
    fclose(fid);

    fprintf('   ✅ HTML 文档: %s\n', filename);
end

function generate_markdown(model_name, info, opts)
    filename = fullfile(opts.output, sprintf('%s_docs.md', model_name));
    fid = fopen(filename, 'w');

    fprintf(fid, '# %s - Simulink 模型文档\n\n', model_name);
    fprintf(fid, '%s\n\n', info.description);

    fprintf(fid, '## 基本信息\n\n');
    fprintf(fid, '- **版本:** %s\n', info.version);
    fprintf(fid, '- **创建时间:** %s\n', info.created);
    fprintf(fid, '- **修改时间:** %s\n', info.modified);
    fprintf(fid, '- **模块数:** %d\n', info.n_blocks);
    fprintf(fid, '- **子系统数:** %d\n', info.n_subsystems);
    fprintf(fid, '- **信号线数:** %d\n\n', info.n_lines);

    if isfield(info, 'screenshot') && exist(info.screenshot, 'file')
        fprintf(fid, '## 模型图\n\n');
        fprintf(fid, '![Model](%s_model.png)\n\n', model_name);
    end

    if ~isempty(info.subsystems)
        fprintf(fid, '## 子系统\n\n');
        fprintf(fid, '| 名称 | 路径 | 描述 |\n');
        fprintf(fid, '|------|------|------|\n');
        for i = 1:numel(info.subsystems)
            sub = info.subsystems{i};
            fprintf(fid, '| %s | %s | %s |\n', sub.name, sub.path, sub.description);
        end
        fprintf(fid, '\n');
    end

    fclose(fid);
    fprintf('   ✅ Markdown 文档: %s\n', filename);
end

function generate_latex(model_name, info, opts)
    filename = fullfile(opts.output, sprintf('%s_docs.tex', model_name));
    fid = fopen(filename, 'w');

    fprintf(fid, '\\documentclass{article}\n');
    fprintf(fid, '\\usepackage{graphicx}\n');
    fprintf(fid, '\\usepackage{booktabs}\n');
    fprintf(fid, '\\title{%s - Simulink 模型文档}\n', model_name);
    fprintf(fid, '\\date{%s}\n', datestr(now, 'yyyy-mm-dd'));
    fprintf(fid, '\\begin{document}\n');
    fprintf(fid, '\\maketitle\n\n');

    fprintf(fid, '\\section{基本信息}\n');
    fprintf(fid, '\\begin{itemize}\n');
    fprintf(fid, '\\item 版本: %s\n', info.version);
    fprintf(fid, '\\item 模块数: %d\n', info.n_blocks);
    fprintf(fid, '\\item 子系统数: %d\n', info.n_subsystems);
    fprintf(fid, '\\end{itemize}\n\n');

    if isfield(info, 'screenshot') && exist(info.screenshot, 'file')
        fprintf(fid, '\\section{模型图}\n');
        fprintf(fid, '\\includegraphics[width=\\textwidth]{%s_model.png}\n\n', model_name);
    end

    fprintf(fid, '\\end{document}\n');
    fclose(fid);

    fprintf('   ✅ LaTeX 文档: %s\n', filename);
end
