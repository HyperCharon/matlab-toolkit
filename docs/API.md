# MatForge API 参考手册

## eplot — 出图美化模块

### eplot.style
一键应用论文级图表样式。

```matlab
eplot.style()             % 默认 IEEE 样式
eplot.style('ieee')       % IEEE 期刊样式
eplot.style('nature')     % Nature 期刊样式
eplot.style('springer')   % Springer 期刊样式
eplot.style('thesis')     % 学位论文样式
eplot.style('beamer')     % 演示文稿样式
eplot.style('dark')       % 暗色主题
eplot.style('custom', 'FontSize', 14, 'LineWidth', 2)  % 自定义
```

### eplot.colorscheme
应用配色方案。

```matlab
eplot.colorscheme('ieee')        % IEEE 推荐配色
eplot.colorscheme('nature')      % Nature 推荐配色
eplot.colorscheme('dark')        % 暗色主题配色
eplot.colorscheme('viridis')     % Viridis 配色
eplot.colorscheme(my_colors)     % 自定义颜色矩阵 (Nx3)
```

### eplot.export
导出图表为多种格式。

```matlab
eplot.export('figure.pdf')           % 导出为 PDF
eplot.export('figure.png', 'dpi', 600)  % 指定分辨率
eplot.export(fig, 'figure.eps')      % 导出指定 figure
```

支持格式: PDF, EPS, PNG, TIFF, SVG

### eplot.compare_step
多系统阶跃响应对比。

```matlab
fig = eplot.compare_step({sys1, sys2}, ...
    'labels', {'PID', 'LQR'}, ...
    'style', 'ieee');
```

### eplot.compare_bode
多系统波特图对比。

```matlab
fig = eplot.compare_bode({sys1, sys2}, ...
    'labels', {'Current', 'Proposed'});
```

### eplot.nyquist_styled
美化的 Nyquist 图。

```matlab
fig = eplot.nyquist_styled(sys, 'show_margin', true);
```

### eplot.waterfall
瀑布图（频响随参数变化）。

```matlab
fig = eplot.waterfall(frequencies, params, responses, ...
    'xlabel', 'Frequency (Hz)');
```

### eplot.export_tikz
导出为 LaTeX tikz 代码。

```matlab
eplot.export_tikz(gcf, 'figure.tex', 'width', '\textwidth');
```

### eplot.batch_style
批量应用样式。

```matlab
eplot.batch_style('figs/', 'ieee', 'export', true, 'format', 'pdf');
```

### eplot.batch_export
批量导出图表。

```matlab
eplot.batch_export('figs/', 'output/', {'pdf', 'png'}, 'style', 'ieee');
```

---

## ecalculator — 工程计算器模块

### ecalculator.control

#### bode_plot — 波特图分析
```matlab
info = ecalculator.control.bode_plot([1], [1 2 1]);
% info.Gm_dB, info.Pm, info.Wcg, info.Wcp, info.stable
```

#### step_response — 阶跃响应
```matlab
info = ecalculator.control.step_response([1], [1 2 1]);
% info.Overshoot, info.SettlingTime, info.RiseTime, info.PeakTime
```

#### pid_tune — PID 自动整定
```matlab
info = ecalculator.control.pid_tune([1], [1 10 0], 'ziegler-nichols');
% info.Kp, info.Ki, info.Kd
```

支持方法: 'ziegler-nichols', 'cohen-coon', 'imc', 'lambda'

#### stability — 稳定性分析
```matlab
info = ecalculator.control.stability([1], [1 3 3 1]);
% info.poles, info.stable, info.routh_table
```

#### root_locus — 根轨迹
```matlab
ecalculator.control.root_locus([1], [1 2 1]);
```

### ecalculator.circuit

#### voltage_divider — 分压计算
```matlab
info = ecalculator.circuit.voltage_divider(12, 10e3, 4.7e3);
% info.Vout, info.I, info.P_R1, info.P_R2, info.ratio
```

#### rc_filter — RC 滤波器
```matlab
info = ecalculator.circuit.rc_filter(10e3, 100e-9, 'lowpass');
% info.fc, info.tau, info.tf
```

#### rl_filter — RL 滤波器
```matlab
info = ecalculator.circuit.rl_filter(100, 10e-3, 'lowpass');
```

#### rlc_resonance — RLC 谐振
```matlab
info = ecalculator.circuit.rlc_resonance(10, 10e-3, 100e-9);
% info.f0, info.Q, info.BW, info.Z0
```

#### opamp_gain — 运放增益
```matlab
info = ecalculator.circuit.opamp_gain(100e3, 10e3, 'inverting');
info = ecalculator.circuit.opamp_gain(100e3, 10e3, 'noninverting');
```

#### power — 功率计算
```matlab
info = ecalculator.circuit.power(12, 0.5);
% info.P, info.R
```

#### thermal — 热计算
```matlab
info = ecalculator.circuit.thermal(50, 2, 25);
% info.Tj, info.margin
```

### ecalculator.signal

#### fft_analyze — FFT 频谱分析
```matlab
info = ecalculator.signal.fft_analyze(x, 1000);
% info.f, info.magnitude, info.phase, info.peak_freq, info.thd
```

#### filter_design — 滤波器设计
```matlab
spec.Fpass = 1000; spec.Fstop = 1500; spec.Fs = 8000;
info = ecalculator.signal.filter_design('butterworth', spec);
```

支持类型: 'butterworth', 'chebyshev1', 'chebyshev2', 'elliptic'

#### sampling_check — 采样定理检查
```matlab
info = ecalculator.signal.sampling_check(1000, 8000);
% info.valid, info.ratio, info.nyquist
```

#### snr — 信噪比
```matlab
val = ecalculator.signal.snr(signal, noise);
```

#### thd — 总谐波失真
```matlab
val = ecalculator.signal.thd(x, 44100, 1000);
```

### ecalculator.motor

#### dc_motor — 直流电机分析
```matlab
info = ecalculator.motor.dc_motor(24, 0.5, 1e-3, 0.05, 0.05, 1e-4, 1e-5);
% info.I_stall, info.T_stall, info.RPM_no_load, info.P_max_power
```

#### foc_calc — FOC 控制参数
```matlab
params.Vdc = 48; params.Rs = 0.5; params.Ld = 1e-3;
info = ecalculator.motor.foc_calc(3000, 10, params);
% info.Kp_d, info.Ki_d, info.Kp_q, info.Ki_q
```

### ecalculator.thermal

#### conduction — 热传导
```matlab
info = ecalculator.thermal.conduction(385, 0.01, 50, 0.1);
% info.Q, info.R
```

#### convection — 对流换热
```matlab
info = ecalculator.thermal.convection(50, 0.01, 50);
```

#### radiation — 辐射换热
```matlab
info = ecalculator.thermal.radiation(0.9, 0.01, 373, 293);
```

#### heatsink — 散热器选型
```matlab
info = ecalculator.thermal.heatsink(150, 40, 10, 1.5, 0.5);
% info.Rth_sa_max
```

### ecalculator.fluid

#### reynolds — 雷诺数
```matlab
info = ecalculator.fluid.reynolds(1000, 1, 0.01, 1e-3);
% info.Re, info.regime
```

#### pipe_flow — 管道流动
```matlab
info = ecalculator.fluid.pipe_flow(1000, 1e-3, 0.01, 10, 1, 0.001);
% info.f, info.Q, info.dP
```

#### nozzle — 喷管流动
```matlab
info = ecalculator.fluid.nozzle(101325, 300, 50000, 1.4, 287);
```

#### pitot — 皮托管测速
```matlab
v = ecalculator.fluid.pitot(1.225, 100);
```

#### bernoulli — 伯努利方程
```matlab
info = ecalculator.fluid.bernoulli(101325, 1, 0, 0, 0, 1, 1000);
```

### ecalculator.material

#### stress — 应力计算
```matlab
info = ecalculator.material.stress(1000, 0.001);
% info.sigma
```

#### strain — 应变计算
```matlab
info = ecalculator.material.strain(0.001, 1);
% info.epsilon
```

#### beam_deflection — 梁挠度
```matlab
info = ecalculator.material.beam_deflection(1000, 1, 200e9, 1e-6, 'cantilever');
% info.delta_max, info.theta_max
```

支持类型: 'cantilever', 'simply', 'distributed'

#### pressure_vessel — 压力容器
```matlab
info = ecalculator.material.pressure_vessel(1e6, 0.1, 0.005, 'thin');
% info.sigma_hoop, info.sigma_axial
```

#### fatigue — 疲劳分析
```matlab
info = ecalculator.material.fatigue(200, 150, 500);
% info.safety_factor, info.N_f
```

#### torsion — 扭转变形
```matlab
info = ecalculator.material.torsion(100, 0.01, 1.57e-8, 0.5, 80e9);
% info.tau_max, info.theta
```

---

## ebatch — 批量仿真模块

### ebatch.sweep
参数扫描仿真。

```matlab
results = ebatch.sweep('my_model', ...
    'Kp', linspace(0.1, 10, 20), ...
    'Ki', linspace(0.01, 5, 20), ...
    'parallel', true, ...
    'metrics', {'overshoot', 'settling_time'});
```

### ebatch.plot_surface
绘制 3D 响应曲面。

```matlab
ebatch.plot_surface(results, 'Kp', 'Ki', 'overshoot');
ebatch.plot_surface(results, 'Kp', 'Ki', 'overshoot', 'contour', true);
```

### ebatch.plot_heatmap
绘制热力图。

```matlab
ebatch.plot_heatmap(results, 'Kp', 'Ki', 'settling_time');
```

### ebatch.export_report
导出仿真报告。

```matlab
ebatch.export_report(results, 'format', 'html');
ebatch.export_report(results, 'format', 'markdown');
ebatch.export_report(results, 'format', 'latex');
```

---

## edata — 数据处理模块

### edata.read
智能数据读取。

```matlab
data = edata.read('data.csv');
data = edata.read('data.xlsx', 'Sheet', 'Sheet1');
data = edata.read('data.json');
data = edata.read('data.mat');
```

### edata.clean
数据清洗。

```matlab
data = edata.clean(data, ...
    'remove_nan', true, ...
    'remove_outliers', true, ...
    'outlier_method', 'iqr', ...
    'smooth', 5, ...
    'normalize', 'zscore');
```

### edata.analyze
统计分析。

```matlab
info = edata.analyze(data, 'plot', true);
% info.columns.col_name.mean, .std, .median, .iqr, ...
```

### edata.export
数据导出。

```matlab
edata.export(data, 'output.csv');
edata.export(data, 'output.xlsx', 'Sheet', 'Results');
edata.export(data, 'output.json');
```

### edata.batch_read
批量读取。

```matlab
data = edata.batch_read('data/*.csv', 'combine', true);
```

---

## eutils — 实用工具模块

### eutils.init_project
初始化新项目。

```matlab
eutils.init_project('my_project', 'type', 'control');
eutils.init_project('my_project', 'type', 'signal', 'git', true);
```

类型: 'control', 'signal', 'power', 'general'

### eutils.add_path
路径管理。

```matlab
eutils.add_path('src', 'lib', 'save', true);
```

### eutils.check_code
代码质量检查。

```matlab
issues = eutils.check_code('src/', 'verbose', true);
```

### eutils.units
单位换算。

```matlab
eutils.units.convert(100, 'mph', 'kmh')
eutils.units.convert(1, 'atm', 'Pa')
eutils.units.convert(72, 'fahrenheit', 'celsius')
eutils.units.convert(100, 'W', 'hp')
```

### eutils.constants
物理常数。

```matlab
c = eutils.constants.c;            % 光速
eutils.constants.list('all');      % 列出所有常数
eutils.constants.info('g');        % 查看详细信息
```

### eutils.formulas
公式速查。

```matlab
eutils.formulas.control()           % 控制系统公式
eutils.formulas.circuit()           % 电路公式
eutils.formulas.signal()            % 信号处理公式
eutils.formulas.mechanical()        % 机械/材料公式
eutils.formulas.thermal()           % 热力学公式
eutils.formulas.fluid()             % 流体力学公式
eutils.formulas.electromagnetics()  % 电磁学公式
```

---

## esimulink — Simulink 辅助模块

### esimulink.generate_docs
生成模型文档。

```matlab
esimulink.generate_docs('my_model', 'format', 'html');
esimulink.generate_docs('my_model', 'format', 'markdown');
```

### esimulink.check_model
模型检查。

```matlab
issues = esimulink.check_model('my_model');
```

### esimulink.export_params
导出模型参数。

```matlab
esimulink.export_params('my_model', 'format', 'csv');
```

### esimulink.sensitivity
参数灵敏度分析。

```matlab
results = esimulink.sensitivity('my_model', 'Kp', ...
    [0.5 0.8 1.0 1.2 1.5], 'overshoot', 'nominal', 1.0);
```

---

## 运行测试

```matlab
% 运行所有测试
results = tests.run_tests();

% 或使用 MATLAB 测试框架
runtests('tests/');
```

## 启动 GUI

```matlab
MatForgeApp.run();
```
