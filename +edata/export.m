function export(data, filename, varargin)
%EDATA.EXPORT 数据导出
%
%   edata.export(data, 'output.csv')
%   edata.export(data, 'output.xlsx', 'Sheet', 'Results')
%   edata.export(data, 'output.json')
%   edata.export(data, 'output.mat')
%
%   支持格式: CSV, XLSX, JSON, MAT, TXT, LaTeX
%
%   可选参数:
%     'Sheet'    - Excel 工作表名称
%     'Precision' - 数值精度 (小数位数, 默认 6)
%     'Delimiter' - CSV 分隔符 (默认 ',')
%
%   See also edata.read, edata.clean, edata.batch_read

    opts = struct('Sheet', 'Sheet1', 'Precision', 6, 'Delimiter', ',');
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    [~, ~, ext] = fileparts(filename);

    switch lower(ext)
        case '.csv'
            writetable(data, filename, 'Delimiter', opts.Delimiter);
        case {'.xlsx', '.xls'}
            writetable(data, filename, 'Sheet', opts.Sheet);
        case '.json'
            json_text = jsonencode(data, 'PrettyPrint', true);
            fid = fopen(filename, 'w');
            fprintf(fid, '%s', json_text);
            fclose(fid);
        case '.mat'
            save(filename, 'data');
        case '.tex'
            export_latex(data, filename, opts);
        otherwise
            writetable(data, filename);
    end

    fprintf('✅ 已导出: %s\n', filename);
end

function export_latex(data, filename, opts)
    fid = fopen(filename, 'w');

    fprintf(fid, '\\begin{table}[h]\n\\centering\n');
    fprintf(fid, '\\begin{tabular}{');
    for i = 1:width(data)
        fprintf(fid, 'c');
    end
    fprintf(fid, '}\n\\toprule\n');

    % 表头
    var_names = data.Properties.VariableNames;
    for i = 1:numel(var_names)
        if i > 1, fprintf(fid, ' & '); end
        fprintf(fid, '%s', var_names{i});
    end
    fprintf(fid, ' \\\\\n\\midrule\n');

    % 数据行
    for row = 1:height(data)
        for col = 1:width(data)
            if col > 1, fprintf(fid, ' & '); end
            val = data{row, col};
            if isnumeric(val)
                fprintf(fid, '%.*f', opts.Precision, val);
            else
                fprintf(fid, '%s', string(val));
            end
        end
        fprintf(fid, ' \\\\\n');
    end

    fprintf(fid, '\\bottomrule\n\\end{tabular}\n');
    fprintf(fid, '\\caption{Data Table}\n\\end{table}\n');
    fclose(fid);
end
