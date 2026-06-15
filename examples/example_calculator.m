%% MatForge 工程计算器示例
% 本脚本演示 ecalculator 模块的各种功能

clear; clc; close all;

%% 1. 控制系统计算
fprintf('=== 1. 控制系统计算 ===\n\n');

% 1.1 波特图分析
fprintf('--- 1.1 波特图分析 ---\n');
num = [1];
den = [1 2 1];  % 二阶系统
info = ecalculator.control.bode_plot(num, den);

% 1.2 阶跃响应
fprintf('\n--- 1.2 阶跃响应 ---\n');
step_info = ecalculator.control.step_response(num, den);

% 1.3 PID 整定
fprintf('\n--- 1.3 PID 整定 ---\n');
plant_num = [1];
plant_den = [1 10 0];  % 双积分器
pid_info = ecalculator.control.pid_tune(plant_num, plant_den, 'ziegler-nichols');

% 1.4 稳定性分析
fprintf('\n--- 1.4 稳定性分析 ---\n');
ecalculator.control.stability([1], [1 3 3 1]);

%% 2. 电路计算
fprintf('\n\n=== 2. 电路计算 ===\n\n');

% 2.1 分压电路
fprintf('--- 2.1 分压电路 ---\n');
ecalculator.circuit.voltage_divider(12, 10e3, 4.7e3);

% 2.2 RC 滤波器
fprintf('\n--- 2.2 RC 低通滤波器 ---\n');
ecalculator.circuit.rc_filter(10e3, 100e-9, 'lowpass');

% 2.3 RLC 谐振
fprintf('\n--- 2.3 RLC 谐振电路 ---\n');
ecalculator.circuit.rlc_resonance(10, 10e-3, 100e-9);

% 2.4 运放增益
fprintf('\n--- 2.4 运放增益 ---\n');
ecalculator.circuit.opamp_gain(100e3, 10e3, 'inverting');
ecalculator.circuit.opamp_gain(100e3, 10e3, 'noninverting');

% 2.5 功率计算
fprintf('\n--- 2.5 功率计算 ---\n');
ecalculator.circuit.power(12, 0.5);

% 2.6 热计算
fprintf('\n--- 2.6 热计算 ---\n');
ecalculator.circuit.thermal(50, 2, 25);

%% 3. 信号处理计算
fprintf('\n\n=== 3. 信号处理计算 ===\n\n');

% 3.1 FFT 分析
fprintf('--- 3.1 FFT 分析 ---\n');
Fs = 1000;
t = 0:1/Fs:1;
x = sin(2*pi*50*t) + 0.5*sin(2*pi*120*t) + 0.2*randn(size(t));
ecalculator.signal.fft_analyze(x, Fs);

% 3.2 采样定理检查
fprintf('\n--- 3.2 采样定理检查 ---\n');
ecalculator.signal.sampling_check(1000, 8000);

% 3.3 信噪比计算
fprintf('\n--- 3.3 信噪比计算 ---\n');
signal = sin(2*pi*50*t);
noise = 0.1*randn(size(t));
ecalculator.signal.snr(signal, noise);

%% 4. 电机计算
fprintf('\n\n=== 4. 电机计算 ===\n\n');

% 4.1 直流电机分析
fprintf('--- 4.1 直流电机分析 ---\n');
ecalculator.motor.dc_motor(24, 0.5, 1e-3, 0.05, 0.05, 1e-4, 1e-5);

%% 5. 综合示例：设计一个控制系统
fprintf('\n\n=== 5. 综合示例：设计一个控制系统 ===\n\n');

fprintf('步骤 1: 分析被控对象\n');
plant = tf([1], [1 5 0]);
info = ecalculator.control.bode_plot([1], [5 0]);

fprintf('\n步骤 2: PID 整定\n');
pid_info = ecalculator.control.pid_tune([1], [1 5 0], 'ziegler-nichols');

fprintf('\n步骤 3: 闭环仿真\n');
C = pid(pid_info.Kp, pid_info.Ki, pid_info.Kd);
sys_closed = feedback(C * plant, 1);
step(sys_closed);
title('闭环阶跃响应');
grid on;

fprintf('\n步骤 4: 性能分析\n');
step_info = stepinfo(sys_closed);
fprintf('   超调量: %.2f%%\n', step_info.Overshoot);
fprintf('   调节时间: %.4f s\n', step_info.SettlingTime);

fprintf('\n🎉 所有计算器示例完成!\n');
