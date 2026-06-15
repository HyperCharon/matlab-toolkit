function report(output_dir, varargin)
%EUTILS.REPORT 自动生成实验报告
%
%   eutils.report('report/')
%   eutils.report('report/', 'title', 'PID 控制实验')
%   eutils.report('report/', 'format', 'html', 'figures', fig_handles)
%
%   自动收集当前工作区的:
%   - 所有打开的 figure
%   - 关键变量和性能指标
%   - 生成格式化的实验报告
%
%   可选参数:
%     'title'    - 报告标题
%     'author'   - 作者
%     'format'   - 输出格式 'html'/'markdown'/'latex' (默认 'html')
%     'figures'  - figure 句柄列表 (默认所有打开的 figure)
%     'variables'- 要记录的变量名列表
%     'template' - 报告模板 ('experiment'/'analysis'/'custom')
%
%   See also eplot.export, edata.export

    opts = struct('title', '实验报告', 'author', '', 'date', datestr(now, 'yyyy-mm-dd'), ...
                  'format', 'html', 'figures', [], 'variables', {{}}, ...
                  'template', 'experiment');
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    % 创建输出目录
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    % 获取 figure 列表
    if isempty(opts.figures)
        opts.figures = findall(0, 'Type', 'figure');
    end
    n_figures = numel(opts.figures);

    fprintf('📝 生成实验报告:\n');
    fprintf('   标题: %s\n', opts.title);
    fprintf('   图表: %d 个\n', n_figures);
    fprintf('   格式: %s\n', opts.format);

    % 导出图表
    figures_dir = fullfile(output_dir, 'figures');
    if ~exist(figures_dir, 'dir')
        mkdir(figures_dir);
    end

    figure_files = cell(n_figures, 1);
    figure_captions = cell(n_figures, 1);

    for i = 1:n_figures
        fig = opts.figures(i);
        fig_name = get(fig, 'Name');
        if isempty(fig_name)
            fig_name = sprintf('Figure_%d', i);
        end

        filename = fullfile(figures_dir, sprintf('fig_%02d_%s.png', i, strrep(fig_name, ' ', '_')));
        eplot.export(fig, filename, 'dpi', 300);
        figure_files{i} = filename;
        figure_captions{i} = fig_name;
    end

    % 收集变量信息
    variables_info = struct();
    if ~isempty(opts.variables)
        for i = 1:numel(opts.variables)
            var_name = opts.variables{i};
            if evalin('base', sprintf('exist(''%s'', ''var'')', var_name))
                val = evalin('base', var_name);
                variables_info.(var_name) = val;
            end
        end
    end

    % 生成报告
    switch lower(opts.format)
        case 'html'
            generate_html_report(output_dir, opts, figure_files, figure_captions, variables_info);
        case 'markdown'
            generate_markdown_report(output_dir, opts, figure_files, figure_captions, variables_info);
        case 'latex'
            generate_latex_report(output_dir, opts, figure_files, figure_captions, variables_info);
    end

    fprintf('✅ 报告已生成: %s/\n', output_dir);
end

function generate_html_report(output_dir, opts, figure_files, figure_captions, variables_info)
    filename = fullfile(output_dir, 'report.html');
    fid = fopen(filename, 'w');

    fprintf(fid, '<!DOCTYPE html>\n<html>\n<head>\n');
    fprintf(fid, '<meta charset="UTF-8">\n');
    fprintf(fid, '<title>%s</title>\n', opts.title);
    fprintf(fid, '<style>\n');
    fprintf(fid, 'body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; margin: 40px auto; max-width: 900px; line-height: 1.6; color: #333; }\n');
    fprintf(fid, 'h1 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }\n');
    fprintf(fid, 'h2 { color: #34495e; margin-top: 30px; }\n');
    fprintf(fid, '.meta { color: #7f8c8d; font-size: 14px; margin-bottom: 30px; }\n');
    fprintf(fid, 'figure { margin: 20px 0; text-align: center; }\n');
    fprintf(fid, 'figure img { max-width: 100%; border: 1px solid #ddd; border-radius: 4px; }\n');
    fprintf(fid, 'figcaption { color: #666; font-style: italic; margin-top: 8px; }\n');
    fprintf(fid, 'table { border-collapse: collapse; width: 100%%; margin: 20px 0; }\n');
    fprintf(fid, 'th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }\n');
    fprintf(fid, 'th { background: #3498db; color: white; }\n');
    fprintf(fid, 'code { background: #f4f4f4; padding: 2px 6px; border-radius: 3px; font-family: Consolas, monospace; }\n');
    fprintf(fid, '</style>\n</head>\n<body>\n');

    % 标题
    fprintf(fid, '<h1>%s</h1>\n', opts.title);
    fprintf(fid, '<div class="meta">\n');
    if ~isempty(opts.author)
        fprintf(fid, '<p><strong>作者:</strong> %s</p>\n', opts.author);
    end
    fprintf(fid, '<p><strong>日期:</strong> %s</p>\n', opts.date);
    fprintf(fid, '</div>\n');

    % 实验目的
    fprintf(fid, '<h2>1. 实验目的</h2>\n');
    fprintf(fid, '<p>[请填写实验目的]</p>\n');

    % 实验原理
    fprintf(fid, '<h2>2. 实验原理</h2>\n');
    fprintf(fid, '<p>[请填写实验原理]</p>\n');

    % 实验设备
    fprintf(fid, '<h2>3. 实验设备</h2>\n');
    fprintf(fid, '<ul>\n');
    fprintf(fid, '<li>MATLAB R2022b+</li>\n');
    fprintf(fid, '<li>[请补充其他设备]</li>\n');
    fprintf(fid, '</ul>\n');

    % 实验步骤
    fprintf(fid, '<h2>4. 实验步骤</h2>\n');
    fprintf(fid, '<p>[请填写实验步骤]</p>\n');

    % 实验结果
    fprintf(fid, '<h2>5. 实验结果</h2>\n');

    % 变量信息
    if ~isempty(fieldnames(variables_info))
        fprintf(fid, '<h3>5.1 关键参数</h3>\n');
        fprintf(fid, '<table>\n<tr><th>参数</th><th>值</th></tr>\n');
        fields = fieldnames(variables_info);
        for i = 1:numel(fields)
            val = variables_info.(fields{i});
            if isnumeric(val)
                if numel(val) == 1
                    fprintf(fid, '<tr><td><code>%s</code></td><td>%.6f</td></tr>\n', fields{i}, val);
                else
                    fprintf(fid, '<tr><td><code>%s</code></td><td>%s</td></tr>\n', fields{i}, mat2str(val));
                end
            end
        end
        fprintf(fid, '</table>\n');
    end

    % 图表
    fprintf(fid, '<h3>5.2 实验图表</h3>\n');
    for i = 1:numel(figure_files)
        [~, fname, ext] = fileparts(figure_files{i});
        rel_path = sprintf('figures/%s%s', fname, ext);
        fprintf(fid, '<figure>\n');
        fprintf(fid, '<img src="%s" alt="%s">\n', rel_path, figure_captions{i});
        fprintf(fid, '<figcaption>图 %d: %s</figcaption>\n', i, figure_captions{i});
        fprintf(fid, '</figure>\n');
    end

    % 结论
    fprintf(fid, '<h2>6. 实验结论</h2>\n');
    fprintf(fid, '<p>[请填写实验结论]</p>\n');

    % 参考文献
    fprintf(fid, '<h2>参考文献</h2>\n');
    fprintf(fid, '<ol>\n');
    fprintf(fid, '<li>[请添加参考文献]</li>\n');
    fprintf(fid, '</ol>\n');

    fprintf(fid, '</body>\n</html>');
    fclose(fid);

    fprintf('   ✅ HTML 报告: %s\n', filename);
end

function generate_markdown_report(output_dir, opts, figure_files, figure_captions, variables_info)
    filename = fullfile(output_dir, 'report.md');
    fid = fopen(filename, 'w');

    fprintf(fid, '# %s\n\n', opts.title);
    if ~isempty(opts.author)
        fprintf(fid, '- **作者:** %s\n', opts.author);
    end
    fprintf(fid, '- **日期:** %s\n\n', opts.date);

    fprintf(fid, '## 1. 实验目的\n\n');
    fprintf(fid, '[请填写实验目的]\n\n');

    fprintf(fid, '## 2. 实验原理\n\n');
    fprintf(fid, '[请填写实验原理]\n\n');

    fprintf(fid, '## 3. 实验设备\n\n');
    fprintf(fid, '- MATLAB R2022b+\n');
    fprintf(fid, '- [请补充其他设备]\n\n');

    fprintf(fid, '## 4. 实验步骤\n\n');
    fprintf(fid, '[请填写实验步骤]\n\n');

    fprintf(fid, '## 5. 实验结果\n\n');

    % 变量信息
    if ~isempty(fieldnames(variables_info))
        fprintf(fid, '### 5.1 关键参数\n\n');
        fprintf(fid, '| 参数 | 值 |\n');
        fprintf(fid, '|------|----|\n');
        fields = fieldnames(variables_info);
        for i = 1:numel(fields)
            val = variables_info.(fields{i});
            if isnumeric(val)
                if numel(val) == 1
                    fprintf(fid, '| `%s` | %.6f |\n', fields{i}, val);
                else
                    fprintf(fid, '| `%s` | %s |\n', fields{i}, mat2str(val));
                end
            end
        end
        fprintf(fid, '\n');
    end

    % 图表
    fprintf(fid, '### 5.2 实验图表\n\n');
    for i = 1:numel(figure_files)
        [~, fname, ext] = fileparts(figure_files{i});
        rel_path = sprintf('figures/%s%s', fname, ext);
        fprintf(fid, '![图 %d: %s](%s)\n\n', i, figure_captions{i}, rel_path);
    end

    fprintf(fid, '## 6. 实验结论\n\n');
    fprintf(fid, '[请填写实验结论]\n\n');

    fprintf(fid, '## 参考文献\n\n');
    fprintf(fid, '1. [请添加参考文献]\n');

    fclose(fid);

    fprintf('   ✅ Markdown 报告: %s\n', filename);
end

function generate_latex_report(output_dir, opts, figure_files, figure_captions, variables_info)
    filename = fullfile(output_dir, 'report.tex');
    fid = fopen(filename, 'w');

    fprintf(fid, '\\documentclass[a4paper,12pt]{article}\n');
    fprintf(fid, '\\usepackage[utf8]{inputenc}\n');
    fprintf(fid, '\\usepackage{graphicx}\n');
    fprintf(fid, '\\usepackage{booktabs}\n');
    fprintf(fid, '\\usepackage{amsmath}\n');
    fprintf(fid, '\\usepackage{geometry}\n');
    fprintf(fid, '\\geometry{margin=2.5cm}\n\n');

    fprintf(fid, '\\title{%s}\n', opts.title);
    if ~isempty(opts.author)
        fprintf(fid, '\\author{%s}\n', opts.author);
    end
    fprintf(fid, '\\date{%s}\n\n', opts.date);

    fprintf(fid, '\\begin{document}\n\n');
    fprintf(fid, '\\maketitle\n\n');

    fprintf(fid, '\\section{实验目的}\n');
    fprintf(fid, '[请填写实验目的]\n\n');

    fprintf(fid, '\\section{实验原理}\n');
    fprintf(fid, '[请填写实验原理]\n\n');

    fprintf(fid, '\\section{实验设备}\n');
    fprintf(fid, '\\begin{itemize}\n');
    fprintf(fid, '\\item MATLAB R2022b+\n');
    fprintf(fid, '\\item [请补充其他设备]\n');
    fprintf(fid, '\\end{itemize}\n\n');

    fprintf(fid, '\\section{实验步骤}\n');
    fprintf(fid, '[请填写实验步骤]\n\n');

    fprintf(fid, '\\section{实验结果}\n\n');

    % 变量信息
    if ~isempty(fieldnames(variables_info))
        fprintf(fid, '\\subsection{关键参数}\n');
        fprintf(fid, '\\begin{table}[h]\n\\centering\n');
        fprintf(fid, '\\begin{tabular}{lc}\n\\toprule\n');
        fprintf(fid, '参数 & 值 \\\\\n\\midrule\n');
        fields = fieldnames(variables_info);
        for i = 1:numel(fields)
            val = variables_info.(fields{i});
            if isnumeric(val)
                if numel(val) == 1
                    fprintf(fid, '\\texttt{%s} & %.6f \\\\\n', fields{i}, val);
                end
            end
        end
        fprintf(fid, '\\bottomrule\n\\end{tabular}\n');
        fprintf(fid, '\\caption{关键参数}\n\\end{table}\n\n');
    end

    % 图表
    fprintf(fid, '\\subsection{实验图表}\n\n');
    for i = 1:numel(figure_files)
        [~, fname, ext] = fileparts(figure_files{i});
        rel_path = sprintf('figures/%s%s', fname, ext);
        fprintf(fid, '\\begin{figure}[h]\n\\centering\n');
        fprintf(fid, '\\includegraphics[width=0.8\\textwidth]{%s}\n', rel_path);
        fprintf(fid, '\\caption{图 %d: %s}\n', i, figure_captions{i});
        fprintf(fid, '\\end{figure}\n\n');
    end

    fprintf(fid, '\\section{实验结论}\n');
    fprintf(fid, '[请填写实验结论]\n\n');

    fprintf(fid, '\\begin{thebibliography}{9}\n');
    fprintf(fid, '\\bibitem{ref1} [请添加参考文献]\n');
    fprintf(fid, '\\end{thebibliography}\n\n');

    fprintf(fid, '\\end{document}\n');
    fclose(fid);

    fprintf('   ✅ LaTeX 报告: %s\n', filename);
end
