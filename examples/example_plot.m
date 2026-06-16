%% MatForge 出图美化示例
% 本脚本演示 eplot 模块的各种功能

clear; clc; close all;

%% 1. 基础出图美化
fprintf('=== 1. 基础出图美化 ===\n\n');

% 生成数据
x = linspace(0, 2*pi, 100);
y1 = sin(x);
y2 = cos(x);
y3 = sin(x + pi/4);

% 创建图表
fig1 = figure('Name', '基础美化示例');
plot(x, y1, '-o', x, y2, '-s', x, y3, '-^');
xlabel('时间 (s)');
ylabel('幅值');
title('三角函数波形');
legend('sin(x)', 'cos(x)', 'sin(x+\pi/4)', 'Location', 'best');
grid on;

% 应用 IEEE 样式
eplot.style(fig1, 'ieee');
fprintf('✅ 已应用 IEEE 样式\n\n');

%% 2. 不同样式对比
fprintf('=== 2. 不同样式对比 ===\n\n');

styles = {'ieee', 'nature', 'thesis', 'beamer', 'dark'};
for i = 1:numel(styles)
    fig = figure('Name', sprintf('样式: %s', styles{i}));
    plot(x, y1, x, y2, x, y3);
    xlabel('X'); ylabel('Y'); title(sprintf('样式: %s', styles{i}));
    legend('sin', 'cos', 'sin+shift');
    eplot.style(fig, styles{i});
    fprintf('   %s: ✅\n', styles{i});
end

%% 3. 配色方案
fprintf('\n=== 3. 配色方案 ===\n\n');

fig3 = figure('Name', '配色方案示例');
for i = 1:8
    plot(x, sin(x + i*pi/4), 'LineWidth', 1.5);
    hold on;
end
xlabel('X'); ylabel('Y'); title('配色方案对比');
legend(arrayfun(@(i) sprintf('Phase %d', i), 1:8, 'UniformOutput', false));

% 应用 Nature 配色
eplot.colorscheme(fig3, 'nature');
fprintf('✅ 已应用 Nature 配色\n\n');

%% 4. 子图美化
fprintf('=== 4. 子图美化 ===\n\n');

fig4 = figure('Name', '子图美化');

subplot(2,2,1);
plot(x, sin(x));
title('sin(x)');
xlabel('X'); ylabel('Y');

subplot(2,2,2);
plot(x, cos(x));
title('cos(x)');
xlabel('X'); ylabel('Y');

subplot(2,2,3);
bar([1 2 3 4 5], [10 25 15 30 20]);
title('柱状图');
xlabel('类别'); ylabel('值');

subplot(2,2,4);
pie([30 25 20 15 10], {'A', 'B', 'C', 'D', 'E'});
title('饼图');

% 对整个 figure 应用样式
eplot.style(fig4, 'thesis');
fprintf('✅ 已美化子图\n\n');

%% 5. 导出图表
fprintf('=== 5. 导出图表 ===\n\n');

% 创建输出目录
if ~exist('output_figures', 'dir')
    mkdir('output_figures');
end

% 导出为 PDF
eplot.export(fig1, fullfile('output_figures', 'sin_cos_ieee.pdf'), 'dpi', 600);
fprintf('✅ 已导出 PDF\n');

% 导出为 PNG
eplot.export(fig1, fullfile('output_figures', 'sin_cos_ieee.png'), 'dpi', 300);
fprintf('✅ 已导出 PNG\n');

% 导出为 EPS (用于 LaTeX)
eplot.export(fig1, fullfile('output_figures', 'sin_cos_ieee.eps'), 'dpi', 600);
fprintf('✅ 已导出 EPS\n');

%% 6. 高级功能
fprintf('\n=== 6. 高级功能 ===\n\n');

% 生成复杂数据
t = 0:0.01:5;
y_noise = sin(2*pi*t) + 0.5*randn(size(t));
y_smooth = movmean(y_noise, 10);

fig5 = figure('Name', '高级功能示例');
plot(t, y_noise, 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);
hold on;
plot(t, y_smooth, 'b-', 'LineWidth', 2);
plot(t, sin(2*pi*t), 'r--', 'LineWidth', 1.5);

xlabel('时间 (s)');
ylabel('幅值');
title('信号平滑处理');
legend('原始信号', '平滑信号', '真实信号', 'Location', 'best');

% 添加标注
text(1, 1.5, sprintf('SNR = %.1f dB', 10*log10(var(sin(2*pi*t)) / var(y_noise - sin(2*pi*t)))), ...
    'FontSize', 10, 'BackgroundColor', 'w', 'EdgeColor', 'k');

% 应用样式
eplot.style(fig5, 'ieee');

% 导出
eplot.export(fig5, fullfile('output_figures', 'smoothing_example.pdf'));
fprintf('✅ 高级功能示例完成\n');

fprintf('\n🎉 所有示例完成!\n');
fprintf('   输出目录: output_figures/\n');
