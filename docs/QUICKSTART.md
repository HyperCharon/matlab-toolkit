# MatForge 快速开始指南

## 安装

```matlab
% 1. 将 MatForge 添加到 MATLAB 路径
addpath(genpath('/path/to/matlab-toolkit'));

% 2. 或者使用 eutils 工具
eutils.add_path('/path/to/matlab-toolkit', 'save', true);
```

## 模块概览

| 模块 | 功能 | 使用场景 |
|------|------|----------|
| `eplot` | 出图美化 | 论文出图、报告图表 |
| `ecalculator` | 工程计算 | 快速计算、参数验证 |
| `ebatch` | 批量仿真 | 参数扫描、优化 |
| `edata` | 数据处理 | 实验数据、仿真结果 |
| `eutils` | 实用工具 | 项目管理、代码检查 |
| `esimulink` | Simulink 辅助 | 模型文档、参数管理 |

## 快速示例

### 1. 出图美化

```matlab
% 创建图表
x = linspace(0, 2*pi, 100);
figure; plot(x, sin(x), x, cos(x));
xlabel('X'); ylabel('Y'); title('三角函数');

% 一键美化
eplot.style('ieee');

% 导出
eplot.export('my_figure.pdf', 'dpi', 600);
```

### 2. 工程计算

```matlab
% 控制系统
ecalculator.control.bode_plot([1], [1 2 1]);
ecalculator.control.step_response([1], [1 2 1]);

% 电路计算
ecalculator.circuit.voltage_divider(12, 10e3, 4.7e3);
ecalculator.circuit.rc_filter(10e3, 100e-9, 'lowpass');

% 信号处理
ecalculator.signal.fft_analyze(x, 1000);
ecalculator.signal.sampling_check(1000, 8000);
```

### 3. 批量仿真

```matlab
% 参数扫描
results = ebatch.sweep('my_model', ...
    'Kp', linspace(0.1, 10, 20), ...
    'Ki', linspace(0.01, 5, 20));

% 可视化
ebatch.plot_surface(results, 'Kp', 'Ki', 'overshoot');
ebatch.plot_heatmap(results, 'Kp', 'Ki', 'settling_time');

% 导出报告
ebatch.export_report(results, 'format', 'html');
```

### 4. 数据处理

```matlab
% 读取数据
data = edata.read('sensor_data.csv');

% 清洗数据
data = edata.clean(data, 'remove_nan', true, 'smooth', 5);

% 分析数据
info = edata.analyze(data, 'plot', true);

% 导出数据
edata.export(data, 'cleaned_data.xlsx');
```

### 5. 项目管理

```matlab
% 创建新项目
eutils.init_project('my_project', 'type', 'control');

% 检查代码质量
issues = eutils.check_code('src/');
```

### 6. Simulink 辅助

```matlab
% 生成模型文档
esimulink.generate_docs('my_model', 'format', 'html');

% 检查模型
issues = esimulink.check_model('my_model');

% 导出参数
esimulink.export_params('my_model', 'format', 'csv');
```

## 自定义样式

```matlab
% 创建自定义样式
eplot.style('custom', ...
    'FontSize', 12, ...
    'FontName', 'Arial', ...
    'LineWidth', 2, ...
    'ColorScheme', [0 0.5 1; 1 0 0; 0 0.8 0]);
```

## 配色方案

```matlab
% 查看可用配色
schemes = eplot.colorscheme('list');

% 应用配色
eplot.colorscheme('nature');
eplot.colorscheme('dark');
eplot.colorscheme('viridis');
```

## 批量处理

```matlab
% 批量美化 .fig 文件
eplot.batch_style('figs/', 'ieee');

% 批量导出
eplot.batch_export('figs/', 'output/', {'pdf', 'png'}, 'style', 'ieee');

% 批量读取数据
data = edata.batch_read('data/*.csv', 'combine', true);
```

## 常见问题

### Q: 如何在 LaTeX 中使用导出的图表？

```matlab
% 导出为 EPS
eplot.export('figure.eps', 'dpi', 600, 'colorspace', 'cmyk');

% 在 LaTeX 中使用
% \includegraphics{figure.eps}
```

### Q: 如何自定义配色方案？

```matlab
% 创建自定义颜色矩阵 (Nx3)
my_colors = [
    0 0.5 1;    % 蓝色
    1 0 0;      % 红色
    0 0.8 0;    % 绿色
];

% 应用
eplot.colorscheme(my_colors);
```

### Q: 如何并行运行批量仿真？

```matlab
% 需要 Parallel Computing Toolbox
results = ebatch.sweep('my_model', ...
    'Kp', linspace(0.1, 10, 100), ...
    'parallel', true);
```

### Q: 如何检查 MATLAB 代码质量？

```matlab
% 检查整个项目
issues = eutils.check_code('src/', 'verbose', true);

% 查看详细报告
for i = 1:numel(issues)
    fprintf('%s (行 %d): %s\n', issues{i}.file, issues{i}.line, issues{i}.message);
end
```

## 更多示例

参见 `examples/` 目录：
- `example_plot.m` - 出图美化示例
- `example_calculator.m` - 工程计算器示例
- `example_batch.m` - 批量仿真示例
