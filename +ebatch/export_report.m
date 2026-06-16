function export_report(results, varargin)
%EBATCH.EXPORT_REPORT 导出仿真报告
%
%   ebatch.export_report(results)
%   ebatch.export_report(results, 'format', 'html')
%   ebatch.export_report(results, 'format', 'markdown', 'filename', 'my_report')
%
%   支持格式:
%     'html'     - 交互式 HTML 报告 (默认)
%     'markdown' - Markdown 报告
%     'latex'    - LaTeX 报告
%
%   See also ebatch.sweep, ebatch.plot_surface, ebatch.plot_heatmap

    opts = struct('format', 'html', 'filename', 'ebatch_report', 'output', 'ebatch_results');
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    if ~exist(opts.output, 'dir')
        mkdir(opts.output);
    end

    switch lower(opts.format)
        case 'html'
            generate_html_report(results, opts);
        case 'markdown'
            generate_markdown_report(results, opts);
        case 'latex'
            generate_latex_report(results, opts);
        otherwise
            error('ebatch:export_report:unknownFormat', '不支持的格式: %s', opts.format);
    end
end

function generate_html_report(results, opts)
    filename = fullfile(opts.output, opts.filename + ".html");
    fid = fopen(filename, 'w');
    if fid == -1
        error('ebatch:export_report:fileOpen', '无法打开文件: %s', filename);
    end

    fprintf(fid, '<!DOCTYPE html>\n<html>\n<head>\n');
    fprintf(fid, '<meta charset="UTF-8">\n');
    fprintf(fid, '<title>MatForge 批量仿真报告</title>\n');
    fprintf(fid, '<style>\n');
    fprintf(fid, 'body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 40px; background: #f5f5f5; }\n');
    fprintf(fid, '.container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }\n');
    fprintf(fid, 'h1 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }\n');
    fprintf(fid, 'h2 { color: #34495e; margin-top: 30px; }\n');
    fprintf(fid, 'table { border-collapse: collapse; width: 100%%; margin: 20px 0; }\n');
    fprintf(fid, 'th, td { border: 1px solid #ddd; padding: 12px; text-align: center; }\n');
    fprintf(fid, 'th { background: #3498db; color: white; }\n');
    fprintf(fid, 'tr:nth-child(even) { background: #f2f2f2; }\n');
    fprintf(fid, '.optimal { background: #d4edda !important; font-weight: bold; }\n');
    fprintf(fid, '.metric-card { display: inline-block; margin: 10px; padding: 20px; background: #ecf0f1; border-radius: 8px; min-width: 200px; }\n');
    fprintf(fid, '.metric-value { font-size: 24px; font-weight: bold; color: #2c3e50; }\n');
    fprintf(fid, '.metric-label { color: #7f8c8d; font-size: 14px; }\n');
    fprintf(fid, '</style>\n</head>\n<body>\n<div class="container">\n');

    % 标题
    fprintf(fid, '<h1>📊 MatForge 批量仿真报告</h1>\n');
    fprintf(fid, '<p><strong>模型:</strong> %s</p>\n', results.model);
    fprintf(fid, '<p><strong>生成时间:</strong> %s</p>\n', datestr(now));

    % 参数配置
    fprintf(fid, '<h2>⚙️ 参数配置</h2>\n');
    fprintf(fid, '<table>\n<tr>');
    for i = 1:numel(results.param_names)
        fprintf(fid, '<th>%s</th>', results.param_names{i});
    end
    fprintf(fid, '<th>组合数</th></tr>\n');

    fprintf(fid, '<tr>');
    for i = 1:numel(results.param_names)
        vals = results.param_values{i};
        fprintf(fid, '<td>%.4f ~ %.4f (%d个)</td>', vals(1), vals(end), numel(vals));
    end
    fprintf(fid, '<td>%d</td></tr>\n', results.n_combinations);
    fprintf(fid, '</table>\n');

    % 性能指标摘要
    fprintf(fid, '<h2>📈 性能指标摘要</h2>\n');
    for m = 1:numel(results.metrics)
        metric = results.metrics{m};
        data = results.data.(metric);
        valid_data = data(~isnan(data));

        if ~isempty(valid_data)
            fprintf(fid, '<div class="metric-card">\n');
            fprintf(fid, '<div class="metric-label">%s</div>\n', metric);
            fprintf(fid, '<div class="metric-value">%.4f</div>\n', min(valid_data));
            fprintf(fid, '<div class="metric-label">最小值</div>\n');
            fprintf(fid, '</div>\n');

            fprintf(fid, '<div class="metric-card">\n');
            fprintf(fid, '<div class="metric-label">%s</div>\n', metric);
            fprintf(fid, '<div class="metric-value">%.4f</div>\n', max(valid_data));
            fprintf(fid, '<div class="metric-label">最大值</div>\n');
            fprintf(fid, '</div>\n');

            fprintf(fid, '<div class="metric-card">\n');
            fprintf(fid, '<div class="metric-label">%s</div>\n', metric);
            fprintf(fid, '<div class="metric-value">%.4f</div>\n', mean(valid_data));
            fprintf(fid, '<div class="metric-label">平均值</div>\n');
            fprintf(fid, '</div>\n');
        end
    end

    % 最优参数
    fprintf(fid, '<h2>🎯 最优参数</h2>\n');
    fprintf(fid, '<table>\n<tr><th>指标</th><th>最优值</th>');
    for i = 1:numel(results.param_names)
        fprintf(fid, '<th>%s</th>', results.param_names{i});
    end
    fprintf(fid, '</tr>\n');

    for m = 1:numel(results.metrics)
        metric = results.metrics{m};
        data = results.data.(metric);
        [min_val, min_idx] = min(data(:));
        [subs{1:ndims(data)}] = ind2sub(size(data), min_idx);

        fprintf(fid, '<tr class="optimal"><td>%s</td><td>%.4f</td>', metric, min_val);
        for i = 1:numel(results.param_names)
            fprintf(fid, '<td>%.4f</td>', results.param_values{i}(subs{i}));
        end
        fprintf(fid, '</tr>\n');
    end
    fprintf(fid, '</table>\n');

    fprintf(fid, '</div>\n</body>\n</html>');
    fclose(fid);

    fprintf('✅ HTML 报告已生成: %s\n', filename);
end

function generate_markdown_report(results, opts)
    filename = fullfile(opts.output, opts.filename + ".md");
    fid = fopen(filename, 'w');
    if fid == -1
        error('ebatch:export_report:fileOpen', '无法打开文件: %s', filename);
    end

    fprintf(fid, '# 📊 MatForge 批量仿真报告\n\n');
    fprintf(fid, '- **模型:** %s\n', results.model);
    fprintf(fid, '- **生成时间:** %s\n', datestr(now));
    fprintf(fid, '- **参数组合数:** %d\n\n', results.n_combinations);

    % 参数配置
    fprintf(fid, '## ⚙️ 参数配置\n\n');
    fprintf(fid, '| 参数 | 范围 | 数量 |\n');
    fprintf(fid, '|------|------|------|\n');
    for i = 1:numel(results.param_names)
        vals = results.param_values{i};
        fprintf(fid, '| %s | %.4f ~ %.4f | %d |\n', results.param_names{i}, vals(1), vals(end), numel(vals));
    end

    % 最优参数
    fprintf(fid, '\n## 🎯 最优参数\n\n');
    fprintf(fid, '| 指标 | 最优值');
    for i = 1:numel(results.param_names)
        fprintf(fid, ' | %s', results.param_names{i});
    end
    fprintf(fid, ' |\n');
    fprintf(fid, '|------|-------');
    for i = 1:numel(results.param_names)
        fprintf(fid, '|------');
    end
    fprintf(fid, '|\n');

    for m = 1:numel(results.metrics)
        metric = results.metrics{m};
        data = results.data.(metric);
        [min_val, min_idx] = min(data(:));
        [subs{1:ndims(data)}] = ind2sub(size(data), min_idx);

        fprintf(fid, '| %s | %.4f', metric, min_val);
        for i = 1:numel(results.param_names)
            fprintf(fid, ' | %.4f', results.param_values{i}(subs{i}));
        end
        fprintf(fid, ' |\n');
    end

    fclose(fid);
    fprintf('✅ Markdown 报告已生成: %s\n', filename);
end

function generate_latex_report(results, opts)
    filename = fullfile(opts.output, opts.filename + ".tex");
    fid = fopen(filename, 'w');
    if fid == -1
        error('ebatch:export_report:fileOpen', '无法打开文件: %s', filename);
    end

    fprintf(fid, '\\documentclass{article}\n');
    fprintf(fid, '\\usepackage{booktabs}\n');
    fprintf(fid, '\\usepackage{graphicx}\n');
    fprintf(fid, '\\usepackage{amsmath}\n');
    fprintf(fid, '\\title{MatForge 批量仿真报告}\n');
    fprintf(fid, '\\author{MatForge}\n');
    fprintf(fid, '\\date{%s}\n', datestr(now, 'yyyy-mm-dd'));
    fprintf(fid, '\\begin{document}\n');
    fprintf(fid, '\\maketitle\n\n');

    fprintf(fid, '\\section{参数配置}\n');
    fprintf(fid, '\\begin{table}[h]\n\\centering\n');
    fprintf(fid, '\\begin{tabular}{lcc}\n\\toprule\n');
    fprintf(fid, '参数 & 范围 & 数量 \\\\\n\\midrule\n');
    for i = 1:numel(results.param_names)
        vals = results.param_values{i};
        fprintf(fid, '%s & $%.4f \\sim %.4f$ & %d \\\\\n', results.param_names{i}, vals(1), vals(end), numel(vals));
    end
    fprintf(fid, '\\bottomrule\n\\end{tabular}\n');
    fprintf(fid, '\\caption{参数配置}\n\\end{table}\n\n');

    fprintf(fid, '\\section{最优参数}\n');
    fprintf(fid, '\\begin{table}[h]\n\\centering\n');
    fprintf(fid, '\\begin{tabular}{l');
    for i = 1:numel(results.param_names)
        fprintf(fid, 'c');
    end
    fprintf(fid, '}\n\\toprule\n');
    fprintf(fid, '指标 & 最优值');
    for i = 1:numel(results.param_names)
        fprintf(fid, ' & %s', results.param_names{i});
    end
    fprintf(fid, ' \\\\\n\\midrule\n');

    for m = 1:numel(results.metrics)
        metric = results.metrics{m};
        data = results.data.(metric);
        [min_val, min_idx] = min(data(:));
        [subs{1:ndims(data)}] = ind2sub(size(data), min_idx);

        fprintf(fid, '%s & $%.4f$', metric, min_val);
        for i = 1:numel(results.param_names)
            fprintf(fid, ' & $%.4f$', results.param_values{i}(subs{i}));
        end
        fprintf(fid, ' \\\\\n');
    end
    fprintf(fid, '\\bottomrule\n\\end{tabular}\n');
    fprintf(fid, '\\caption{最优参数}\n\\end{table}\n\n');

    fprintf(fid, '\\end{document}\n');
    fclose(fid);

    fprintf('✅ LaTeX 报告已生成: %s\n', filename);
end
