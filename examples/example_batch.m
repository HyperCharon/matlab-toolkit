%% MatForge 批量仿真示例
% 本脚本演示 ebatch 模块的各种功能

clear; clc; close all;

%% 1. 创建示例 Simulink 模型
fprintf('=== 1. 创建示例 Simulink 模型 ===\n\n');

model_name = 'batch_demo';

% 创建新模型
new_system(model_name);
open_system(model_name);

% 添加模块
add_block('simulink/Sources/Step', [model_name '/Step']);
add_block('simulink/Continuous/Transfer Fcn', [model_name '/Plant']);
add_block('simulink/Sinks/Scope', [model_name '/Scope']);
add_block('simulink/Sinks/To Workspace', [model_name '/To Workspace']);

% 设置参数
set_param([model_name '/Plant'], 'Numerator', '[Kp]', 'Denominator', '[1 5 0]');
set_param([model_name '/To Workspace'], 'VariableName', 'y');

% 连接模块
add_line(model_name, 'Step/1', 'Plant/1');
add_line(model_name, 'Plant/1', 'Scope/1');
add_line(model_name, 'Plant/1', 'To Workspace/1');

% 保存模型
save_system(model_name);
fprintf('✅ Simulink 模型已创建: %s\n\n', model_name);

%% 2. 单参数扫描
fprintf('=== 2. 单参数扫描 ===\n\n');

% 扫描 Kp 参数
Kp_values = linspace(0.5, 10, 20);
results = ebatch.sweep(model_name, ...
    'Kp', Kp_values, ...
    'metrics', {'overshoot', 'settling_time', 'steady_state_error'}, ...
    'output', 'results_single');

fprintf('\n');

%% 3. 双参数扫描
fprintf('=== 3. 双参数扫描 ===\n\n');

% 修改模型以支持双参数
set_param([model_name '/Plant'], 'Numerator', '[Kp*Ki]', 'Denominator', '[1 5+Kp Ki]');

% 扫描 Kp 和 Ki 参数
Kp_values = linspace(0.5, 5, 10);
Ki_values = linspace(0.1, 2, 10);

results_2d = ebatch.sweep(model_name, ...
    'Kp', Kp_values, ...
    'Ki', Ki_values, ...
    'metrics', {'overshoot', 'settling_time'}, ...
    'output', 'results_double');

fprintf('\n');

%% 4. 可视化结果
fprintf('=== 4. 可视化结果 ===\n\n');

% 4.1 3D 曲面图
fprintf('--- 4.1 3D 曲面图 ---\n');
ebatch.plot_surface(results_2d, 'Kp', 'Ki', 'overshoot');

% 4.2 热力图
fprintf('\n--- 4.2 热力图 ---\n');
ebatch.plot_heatmap(results_2d, 'Kp', 'Ki', 'settling_time');

%% 5. 导出报告
fprintf('\n=== 5. 导出报告 ===\n\n');

% HTML 报告
ebatch.export_report(results_2d, 'format', 'html', 'filename', 'simulation_report');

% Markdown 报告
ebatch.export_report(results_2d, 'format', 'markdown', 'filename', 'simulation_report');

% LaTeX 报告
ebatch.export_report(results_2d, 'format', 'latex', 'filename', 'simulation_report');

%% 6. 高级功能：蒙特卡洛仿真
fprintf('\n=== 6. 蒙特卡洛仿真 ===\n\n');

% 定义参数不确定性
n_trials = 100;
Kp_nominal = 2;
Ki_nominal = 0.5;

% 随机参数
Kp_mc = Kp_nominal + 0.2*randn(n_trials, 1);
Ki_mc = Ki_nominal + 0.05*randn(n_trials, 1);

% 存储结果
overshoot_mc = zeros(n_trials, 1);
settling_mc = zeros(n_trials, 1);

fprintf('运行 %d 次蒙特卡洛仿真...\n', n_trials);

for i = 1:n_trials
    Kp = Kp_mc(i);
    Ki = Ki_mc(i);

    % 闭环系统
    C = pid(Kp, Ki, 0);
    plant = tf([1], [1 5 0]);
    sys_cl = feedback(C * plant, 1);

    % 计算性能指标
    info = stepinfo(sys_cl);
    overshoot_mc(i) = info.Overshoot;
    settling_mc(i) = info.SettlingTime;
end

fprintf('✅ 蒙特卡洛仿真完成\n\n');

% 统计分析
fprintf('📊 蒙特卡洛统计:\n');
fprintf('   超调量: %.2f%% ± %.2f%%\n', mean(overshoot_mc), std(overshoot_mc));
fprintf('   调节时间: %.4f ± %.4f s\n', mean(settling_mc), std(settling_mc));

% 绘制分布图
figure;
subplot(1,2,1);
histogram(overshoot_mc, 20);
xlabel('超调量 (%)');
ylabel('频次');
title('超调量分布');
grid on;

subplot(1,2,2);
histogram(settling_mc, 20);
xlabel('调节时间 (s)');
ylabel('频次');
title('调节时间分布');
grid on;

% 绘制参数空间
figure;
scatter(Kp_mc, Ki_mc, 50, overshoot_mc, 'filled');
colorbar;
xlabel('Kp');
ylabel('Ki');
title('参数空间 (颜色表示超调量)');
grid on;

%% 清理
close_system(model_name, 0);
delete([model_name '.slx']);

fprintf('\n🎉 所有批量仿真示例完成!\n');
fprintf('   结果目录: results_single/, results_double/\n');
