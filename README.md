# MatForge 🔧

**工科生的 MATLAB 瑞士军刀**

一套开箱即用的 MATLAB 工程工具箱，覆盖出图美化、工程计算、批量仿真、数据处理、项目管理、Simulink 辅助六大场景。

## ✨ 为什么选择 MatForge？

- 🎯 **开箱即用** — 一行代码解决常见工程问题
- 📐 **工程导向** — 专为工科生设计，不是通用工具库
- 🎨 **论文级出图** — 内置 IEEE/Nature/Springer 等期刊样式
- ⚡ **高效开发** — 批量处理、自动化工作流
- 📚 **中文友好** — 完整中文文档和注释
- 🔧 **功能全面** — 70+ 个函数，覆盖 14 个工程领域
- 📦 **专业打包** — 完整的工具箱打包和发布流程

## 📊 功能概览

| 模块 | 功能 | 函数数 |
|------|------|--------|
| 🎨 **eplot** | 出图美化、配色方案、批量导出、tikz | 10 |
| 🧮 **ecalculator** | 控制/电路/信号/电机/热/流体/材料/通信/电力/统计/ML/DSP/系统辨识/振动/优化决策/时间序列/图论/推荐 | 18 类 100+ 函数 |
| 🔄 **ebatch** | 参数扫描、并行仿真、报告生成 | 4 |
| 📊 **edata** | 数据读取/清洗/分析/导出 | 4 |
| 🛠️ **eutils** | 项目管理/单位换算/常数/公式速查/性能优化/打包 | 11 |
| 🔌 **esimulink** | 模型文档/检查/参数导出/灵敏度 | 4 |
| 🖥️ **apps** | GUI 界面 | 1 |

## 🚀 快速开始

```matlab
% 1. 添加到路径
addpath(genpath('matlab-toolkit'));

% 2. 出图美化
x = linspace(0, 2*pi, 100);
figure; plot(x, sin(x), x, cos(x));
eplot.style('ieee');          % 一键应用 IEEE 样式
eplot.export('fig1.pdf');     % 导出为 PDF

% 3. 工程计算
ecalculator.control.bode_plot([1], [1 2 1]);
ecalculator.circuit.rc_filter(10e3, 100e-9, 'lowpass');

% 4. 批量仿真
results = ebatch.sweep('my_model.slx', ...
    'Kp', linspace(0.1, 10, 20), ...
    'Ki', linspace(0.01, 5, 20));
ebatch.plot_surface(results, 'Kp', 'Ki', 'overshoot');

% 5. 单位换算
eutils.units.convert(100, 'mph', 'kmh')

% 6. 公式速查
eutils.formulas.control();

% 7. 性能优化
eutils.optimize('my_function');

% 8. 打包工具箱
eutils.package_toolbox('MyToolbox', 'version', '1.0.0');
```

## 📦 模块详解

### 🎨 eplot — 出图美化

```matlab
% 一键美化
eplot.style('ieee');           % IEEE 期刊样式
eplot.style('nature');         % Nature 期刊样式
eplot.style('thesis');         % 学位论文样式

% 配色方案
eplot.colorscheme('ieee');     % 应用配色
eplot.colorscheme('viridis');  % Viridis 配色

% 对比图
eplot.compare_step({sys1, sys2}, 'labels', {'PID', 'LQR'});
eplot.compare_bode({sys1, sys2});
eplot.nyquist_styled(sys);

% 导出
eplot.export('figure.pdf', 'dpi', 600);
eplot.export_tikz(gcf, 'figure.tex');  % LaTeX tikz

% 批量处理
eplot.batch_style('figs/', 'ieee');
eplot.batch_export('figs/', 'output/', {'pdf', 'png'});
```

### 🧮 ecalculator — 工程计算器

#### 控制系统
```matlab
ecalculator.control.bode_plot([1], [1 2 1]);           % 波特图
ecalculator.control.step_response([1], [1 2 1]);       % 阶跃响应
ecalculator.control.pid_tune([1], [1 10 0], 'ziegler-nichols');  % PID 整定
ecalculator.control.stability([1], [1 3 3 1]);         % 稳定性分析
```

#### 电路计算
```matlab
ecalculator.circuit.voltage_divider(12, 10e3, 4.7e3);  % 分压
ecalculator.circuit.rc_filter(10e3, 100e-9, 'lowpass'); % RC 滤波
ecalculator.circuit.rlc_resonance(10, 10e-3, 100e-9);  % RLC 谐振
ecalculator.circuit.opamp_gain(100e3, 10e3, 'inverting'); % 运放
```

#### 信号处理
```matlab
ecalculator.signal.fft_analyze(x, 1000);               % FFT 分析
ecalculator.signal.filter_design('butterworth', spec);  % 滤波器设计
ecalculator.signal.sampling_check(1000, 8000);          % 采样定理
ecalculator.signal.snr(signal, noise);                  % 信噪比
```

#### 热力学
```matlab
ecalculator.thermal.conduction(385, 0.01, 50, 0.1);    % 热传导
ecalculator.thermal.convection(50, 0.01, 50);          % 对流换热
ecalculator.thermal.radiation(0.9, 0.01, 373, 293);    % 辐射换热
ecalculator.thermal.heatsink(150, 40, 10, 1.5, 0.5);   % 散热器选型
```

#### 流体力学
```matlab
ecalculator.fluid.reynolds(1000, 1, 0.01, 1e-3);       % 雷诺数
ecalculator.fluid.pipe_flow(1000, 1e-3, 0.01, 10, 1);  % 管道流动
ecalculator.fluid.nozzle(101325, 300, 50000, 1.4);     % 喷管
ecalculator.fluid.pitot(1.225, 100);                    % 皮托管
```

#### 材料力学
```matlab
ecalculator.material.stress(1000, 0.001);               % 应力
ecalculator.material.strain(0.001, 1);                  % 应变
ecalculator.material.beam_deflection(1000, 1, 200e9, 1e-6, 'cantilever');
ecalculator.material.pressure_vessel(1e6, 0.1, 0.005); % 压力容器
ecalculator.material.fatigue(200, 150, 500);            % 疲劳分析
```

#### 通信工程
```matlab
info = ecalculator.communications.snr_db(100, 1);        % 信噪比
info = ecalculator.communications.ber_bpsk(10);          % BPSK BER
info = ecalculator.communications.link_budget(20, 10, 10, 3, 1000, 2.4e9);
info = ecalculator.communications.channel_capacity(20, 10e6);  % Shannon 容量
```

#### 电力电子
```matlab
ecalculator.power.buck_converter(24, 12, 100e3, 100e-6, 100e-6, 5);
ecalculator.power.boost_converter(12, 24, 100e3, 100e-6, 100e-6, 5);
ecalculator.power.inverter(400, 50, 10, 1e-3, 'SPWM');
ecalculator.power.pfc(220, 1000, 65e3, 'boost');
```

#### 统计学
```matlab
ecalculator.statistics.confidence_interval(data, 0.05);  % 置信区间
ecalculator.statistics.hypothesis_test(data1, data2, 'ttest2');  % 假设检验
ecalculator.statistics.regression(x, y, 'linear');  % 回归分析
ecalculator.statistics.anova({group1, group2, group3});  % 方差分析
ecalculator.statistics.distribution_fit(data, 'normal');  % 分布拟合
```

#### 机器学习
```matlab
ecalculator.ml.pca_analysis(data, 'n_components', 3);  % 主成分分析
ecalculator.ml.kmeans_analysis(data, 3);  % K-means 聚类
ecalculator.ml.svm_classification(X, y, 'kernel', 'rbf');  % SVM 分类
ecalculator.ml.cross_validation(X, y, 10, 'svm');  % 交叉验证
ecalculator.ml.feature_importance(X, y, 'tree');  % 特征重要性
```

#### 数字信号处理
```matlab
ecalculator.dsp.fir_design(spec);  % FIR 滤波器设计
ecalculator.dsp.iir_design(spec);  % IIR 滤波器设计
ecalculator.dsp.resample_signal(x, 3, 2, 8000);  % 采样率转换
ecalculator.dsp.window_analysis('hanning', 100);  % 窗函数分析
ecalculator.dsp.spectrogram_analysis(x, 1000);  % 时频分析
```

#### 系统辨识
```matlab
ecalculator.sysid.step_response_id(y, Fs);  % 阶跃响应辨识
ecalculator.sysid.arx_model(u, y, na, nb);  % ARX 模型
ecalculator.sysid.bode_compare(sys1, sys2);  % 频率响应对比
```

#### 振动分析
```matlab
ecalculator.vibration.fft_guided(x, Fs);  % FFT 引导式分析
ecalculator.vibration.signal_check(x, Fs);  % 信号质量检查
ecalculator.vibration.transfer_function(u, y, Fs);  % 传递函数估计
ecalculator.vibration.psd(x, Fs);  % 功率谱密度
ecalculator.vibration.rms_envelope(x, Fs, 'win', 0.1);  % RMS 包络
```

#### 优化决策
```matlab
% TOPSIS 综合评价
D = [80 90 85; 70 80 90; 90 85 80];
info = ecalculator.optimization.topsis(D, [0.3, 0.3, 0.4], [1, 1, 1]);

% 层次分析法 (AHP)
A = [1 1/3 1/5; 3 1 1/2; 5 2 1];
info = ecalculator.optimization.ahp(A);

% 灰色预测 GM(1,1)
X0 = [2.874, 3.278, 3.337, 3.390, 3.679];
info = ecalculator.optimization.grey_predict(X0, 3);

% 蒙特卡洛模拟
func = @(x) x(:,1).^2 + x(:,2).^2;
info = ecalculator.optimization.monte_carlo(func, 10000, 'x1', [-1,1], 'x2', [-1,1]);

% 灵敏度分析
func = @(x) x(1)^2 + 2*x(2)^2;
info = ecalculator.optimization.sensitivity_analysis(func, [1, 1], {'x1', 'x2'});

% 曲线拟合
x = linspace(0, 2*pi, 50)';
info = ecalculator.optimization.curve_fit(x, sin(x), 'cubic');
```

### 🔄 ebatch — 批量仿真

```matlab
% 参数扫描
results = ebatch.sweep('my_model', ...
    'Kp', linspace(0.1, 10, 20), ...
    'Ki', linspace(0.01, 5, 20), ...
    'parallel', true);

% 可视化
ebatch.plot_surface(results, 'Kp', 'Ki', 'overshoot');
ebatch.plot_heatmap(results, 'Kp', 'Ki', 'settling_time');

% 导出报告
ebatch.export_report(results, 'format', 'html');
```

### 📊 edata — 数据处理

```matlab
% 智能读取
data = edata.read('data.csv');
data = edata.read('data.xlsx', 'Sheet', 'Sheet1');

% 数据清洗
data = edata.clean(data, 'remove_nan', true, 'smooth', 5);

% 统计分析
info = edata.analyze(data, 'plot', true);

% 批量读取
data = edata.batch_read('data/*.csv', 'combine', true);
```

### 🛠️ eutils — 实用工具

```matlab
% 项目管理
eutils.init_project('my_project', 'type', 'control');

% 单位换算
eutils.units.convert(100, 'mph', 'kmh');
eutils.units.convert(1, 'atm', 'Pa');

% 物理常数
c = eutils.constants.c;
eutils.constants.list('all');

% 公式速查
eutils.formulas.control();
eutils.formulas.circuit();
eutils.formulas.mechanical();

% 性能优化
eutils.optimize('my_function');
results = eutils.benchmark('func1', 'func2', 'inputs', {args});

% 代码检查
issues = eutils.check_code('src/', 'verbose', true);

% 打包工具箱
eutils.package_toolbox('MyToolbox', 'version', '1.0.0');

% 生成文档
eutils.generate_docs('.', 'format', 'markdown');
```

### 🔌 esimulink — Simulink 辅助

```matlab
% 模型文档
esimulink.generate_docs('my_model', 'format', 'html');

% 模型检查
issues = esimulink.check_model('my_model');

% 参数导出
esimulink.export_params('my_model', 'format', 'csv');

% 灵敏度分析
results = esimulink.sensitivity('my_model', 'Kp', ...
    [0.5 0.8 1.0 1.2 1.5], 'overshoot');
```

## 🎯 兼容性

- **MATLAB 版本:** R2022b 及以上
- **必需工具箱:** 无（核心功能）
- **可选工具箱:**
  - Signal Processing Toolbox（信号处理功能）
  - Parallel Computing Toolbox（并行仿真）
  - Simulink（批量仿真、模型辅助）

## 📁 目录结构

```
matlab-toolkit/
├── +eplot/          # 出图美化模块 (10 个函数)
├── +ecalculator/    # 工程计算器模块 (15 类 80+ 函数)
│   ├── control.m    # 控制系统
│   ├── circuit.m    # 电路计算
│   ├── signal.m     # 信号处理
│   ├── motor.m      # 电机分析
│   ├── thermal.m    # 热力学
│   ├── fluid.m      # 流体力学
│   ├── material.m   # 材料力学
│   ├── communications.m # 通信工程
│   ├── power.m      # 电力电子
│   ├── statistics.m # 统计学
│   ├── ml.m         # 机器学习
│   ├── dsp.m        # 数字信号处理
│   ├── sysid.m      # 系统辨识
│   ├── vibration.m  # 振动分析
│   └── optimization.m # 优化决策
├── +ebatch/         # 批量仿真模块 (4 个函数)
├── +edata/          # 数据处理模块 (4 个函数)
├── +eutils/         # 实用工具模块 (11 个函数)
│   ├── units.m      # 单位换算
│   ├── constants.m  # 物理常数
│   ├── formulas.m   # 公式速查
│   ├── init_project.m # 项目初始化
│   ├── check_code.m # 代码检查
│   ├── optimize.m   # 性能优化
│   ├── benchmark.m  # 性能基准
│   ├── package_toolbox.m # 工具箱打包
│   └── generate_docs.m # 文档生成
├── +esimulink/      # Simulink 辅助模块 (4 个函数)
├── apps/            # App Designer GUI
├── examples/        # 示例脚本
├── tests/           # 单元测试
└── docs/            # 文档
```

## 🧪 运行测试

```matlab
% 运行所有测试
results = tests.run_tests();

% 或使用 MATLAB 测试框架
runtests('tests/');
```

## 🖥️ 启动 GUI

```matlab
MatForgeApp.run();
```

## 📚 文档

- [快速开始指南](docs/QUICKSTART.md)
- [API 参考手册](docs/API.md)
- [示例脚本](examples/)

## 💡 使用场景

### 学术论文
```matlab
eplot.style('ieee');
eplot.export('figure.pdf', 'dpi', 600, 'colorspace', 'cmyk');
```

### 课程设计
```matlab
ecalculator.control.bode_plot([1], [1 2 1]);
ecalculator.control.pid_tune([1], [1 10 0], 'ziegler-nichols');
```

### 毕业设计
```matlab
results = ebatch.sweep('my_model', 'Kp', linspace(0.1, 10, 50));
ebatch.plot_surface(results, 'Kp', 'Ki', 'overshoot');
ebatch.export_report(results, 'format', 'html');
```

### 实验数据处理
```matlab
data = edata.batch_read('experiments/*.csv');
data = edata.clean(data, 'remove_outliers', true);
edata.export(data, 'results.xlsx');
```

### 性能优化
```matlab
eutils.optimize('my_function');
results = eutils.benchmark('func1', 'func2', 'inputs', {args});
```

### 工具箱打包
```matlab
eutils.generate_docs('.', 'format', 'markdown');
eutils.package_toolbox('MyToolbox', 'version', '1.0.0');
```

## 📄 许可证

MIT License

---

**MatForge** — 让 MATLAB 工程开发更高效！
