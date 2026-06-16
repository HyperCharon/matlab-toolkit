function colors = get_default_colors(n)
%GET_DEFAULT_COLORS 获取默认配色方案
%
%   colors = get_default_colors(n)
%
%   返回 n x 3 的 RGB 颜色矩阵，用于多曲线对比图。
%   当 n <= 8 时使用预定义配色，否则使用 hsv 自动生成。
%
%   See also eplot.compare_bode, eplot.compare_step

    base = [
        0.00 0.45 0.74;  % 蓝
        0.85 0.33 0.10;  % 红
        0.00 0.60 0.50;  % 绿
        0.93 0.69 0.13;  % 黄
        0.49 0.18 0.56;  % 紫
        0.47 0.67 0.19;  % 浅绿
        0.30 0.60 0.85;  % 浅蓝
        0.80 0.20 0.40;  % 粉红
    ];
    if n <= size(base, 1)
        colors = base(1:n, :);
    else
        colors = hsv(n);
    end
end
