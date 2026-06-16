%% MatForge 数学建模常用功能示例
% 本脚本演示数学建模中常用的计算功能

clear; clc; close all;

%% 1. 统计分析
fprintf('=== 1. 统计分析 ===\n\n');

% 生成示例数据
rng(42);  % 固定随机种子
data = randn(100, 1) * 5 + 20;  % 均值20，标准差5

% 1.1 置信区间
fprintf('--- 1.1 置信区间 ---\n');
ci_info = ecalculator.statistics.confidence_interval(data, 0.05);
fprintf('   95%% 置信区间: [%.4f, %.4f]\n', ci_info.ci_lower, ci_info.ci_upper);

% 1.2 假设检验
fprintf('\n--- 1.2 假设检验 ---\n');
data1 = randn(50, 1) * 3 + 10;
data2 = randn(50, 1) * 3 + 12;
test_info = ecalculator.statistics.hypothesis_test(data1, data2, 'ttest2');
fprintf('   p 值: %.4f\n', test_info.p);

% 1.3 回归分析
fprintf('\n--- 1.3 回归分析 ---\n');
x = linspace(0, 10, 50)';
y = 2.5 * x + 5 + randn(50, 1) * 2;
reg_info = ecalculator.statistics.regression(x, y, 'linear');
fprintf('   R²: %.4f\n', reg_info.R2);

% 1.4 分布拟合
fprintf('\n--- 1.4 分布拟合 ---\n');
dist_info = ecalculator.statistics.distribution_fit(data, 'normal');
fprintf('   KS 检验 p 值: %.4f\n', dist_info.p_value);

%% 2. 机器学习
fprintf('\n\n=== 2. 机器学习 ===\n\n');

% 2.1 PCA 分析
fprintf('--- 2.1 PCA 分析 ---\n');
% 生成高维数据
X = randn(200, 5) * 2;
X(:,3) = X(:,1) * 1.5 + X(:,2) * 0.5 + randn(200, 1) * 0.1;  % 引入相关性
pca_info = ecalculator.ml.pca_analysis(X, 'n_components', 3);
fprintf('   前3个主成分解释方差: %.2f%%\n', sum(pca_info.explained(1:3)));

% 2.2 K-means 聚类
fprintf('\n--- 2.2 K-means 聚类 ---\n');
X_cluster = [randn(50,2)+2; randn(50,2)-2; randn(50,2)+[2,-2]];
km_info = ecalculator.ml.kmeans_analysis(X_cluster, 3);
fprintf('   平均轮廓系数: %.4f\n', km_info.mean_silhouette);

%% 3. 信号处理
fprintf('\n\n=== 3. 信号处理 ===\n\n');

% 3.1 FFT 分析
fprintf('--- 3.1 FFT 分析 ---\n');
Fs = 1000;
t = 0:1/Fs:1;
x = sin(2*pi*50*t) + 0.5*sin(2*pi*120*t) + 0.3*randn(size(t));
fft_info = ecalculator.signal.fft_analyze(x, Fs);

% 3.2 滤波器设计
fprintf('\n--- 3.2 FIR 滤波器设计 ---\n');
spec.type = 'lowpass';
spec.Fpass = 100;
spec.Fstop = 150;
spec.Fs = 1000;
spec.order = 50;
fir_info = ecalculator.dsp.fir_design(spec);

%% 4. 优化问题
fprintf('\n\n=== 4. 优化问题 ===\n\n');

% 4.1 线性规划
fprintf('--- 4.1 线性规划 ---\n');
% max z = 3x1 + 5x2
% s.t. x1 <= 4, x2 <= 6, 3x1 + 5x2 <= 40
f = [-3, -5];  % 最大化转最小化
A = [1 0; 0 1; 3 5];
b = [4; 6; 40];
[x_opt, fval] = linprog(f, A, b);
fprintf('   最优解: x1=%.2f, x2=%.2f\n', x_opt(1), x_opt(2));
fprintf('   最优值: %.2f\n', -fval);

% 4.2 非线性优化
fprintf('\n--- 4.2 非线性优化 ---\n');
% Rosenbrock 函数 min f(x,y) = (1-x)^2 + 100*(y-x^2)^2
rosenbrock = @(x) (1-x(1))^2 + 100*(x(2)-x(1)^2)^2;
x0 = [-1, 1];  % 初始点
[x_opt, fval] = fminsearch(rosenbrock, x0);
fprintf('   最优解: x=%.4f, y=%.4f\n', x_opt(1), x_opt(2));
fprintf('   最优值: %.6f\n', fval);

%% 5. 微分方程求解
fprintf('\n\n=== 5. 微分方程求解 ===\n\n');

% 5.1 常微分方程 (ODE)
fprintf('--- 5.1 常微分方程 ---\n');
% 求解 dy/dt = -2y + 1, y(0) = 0
ode_fun = @(t, y) -2*y + 1;
[t, y] = ode45(ode_fun, [0 5], 0);
fprintf('   t=5 时 y=%.4f (理论值: 0.5)\n', y(end));

% 绘图
figure('Name', 'ODE 求解');
plot(t, y, 'b-', 'LineWidth', 1.5);
xlabel('t');
ylabel('y');
title('ODE 求解: dy/dt = -2y + 1');
grid on;

%% 6. 蒙特卡洛模拟
fprintf('\n\n=== 6. 蒙特卡洛模拟 ===\n\n');

% 6.1 估算 π
fprintf('--- 6.1 蒙特卡洛估算 π ---\n');
N = 100000;
x_mc = rand(N, 1);
y_mc = rand(N, 1);
inside = sum(x_mc.^2 + y_mc.^2 <= 1);
pi_est = 4 * inside / N;
fprintf('   模拟次数: %d\n', N);
fprintf('   π 估计值: %.6f\n', pi_est);
fprintf('   真实值:   %.6f\n', pi);
fprintf('   误差:     %.6f\n', abs(pi_est - pi));

%% 7. 曲线拟合
fprintf('\n\n=== 7. 曲线拟合 ===\n\n');

% 7.1 多项式拟合
fprintf('--- 7.1 多项式拟合 ---\n');
x_fit = linspace(0, 2*pi, 50)';
y_fit = sin(x_fit) + 0.1*randn(50, 1);

% 3 阶多项式
p = polyfit(x_fit, y_fit, 3);
y_pred = polyval(p, x_fit);
SS_res = sum((y_fit - y_pred).^2);
SS_tot = sum((y_fit - mean(y_fit)).^2);
R2 = 1 - SS_res / SS_tot;
fprintf('   3阶多项式 R²: %.4f\n', R2);

% 绘图
figure('Name', '曲线拟合');
scatter(x_fit, y_fit, 30, 'b', 'filled', 'DisplayName', '数据');
hold on;
x_plot = linspace(0, 2*pi, 200)';
y_plot = polyval(p, x_plot);
plot(x_plot, y_plot, 'r-', 'LineWidth', 2, 'DisplayName', '拟合');
xlabel('x');
ylabel('y');
title('多项式拟合');
legend('Location', 'best');
grid on;

%% 8. 灰色预测 GM(1,1)
fprintf('\n\n=== 8. 灰色预测 GM(1,1) ===\n\n');

% 原始数据
X0 = [2.874, 3.278, 3.337, 3.390, 3.679];
fprintf('   原始数据: %s\n', mat2str(X0, 4));

% GM(1,1) 建模
n = numel(X0);
X1 = cumsum(X0);  % 累加生成
Z1 = 0.5 * (X1(1:end-1) + X1(2:end));  % 紧邻均值

% 最小二乘求参数
B = [-Z1', ones(n-1, 1)];
Y = X0(2:end)';
u = B \ Y;
a = u(1);
b = u(2);

% 预测
X1_hat = zeros(n+3, 1);  % 预测未来3期
X1_hat(1) = X1(1);
for k = 2:n+3
    X1_hat(k) = (X0(1) - b/a) * exp(-a*(k-1)) + b/a;
end

X0_hat = diff([0; X1_hat]);
X0_hat = X0_hat(2:end);

fprintf('   参数 a=%.4f, b=%.4f\n', a, b);
fprintf('   预测值: %s\n', mat2str(X0_hat', 4));

%% 9. TOPSIS 综合评价
fprintf('\n\n=== 9. TOPSIS 综合评价 ===\n\n');

% 决策矩阵 (方案 x 指标)
A = [80 90 85 70;
     70 80 90 80;
     90 85 80 75;
     85 75 70 90];
[m, n] = size(A);

% 指标权重
W = [0.3, 0.25, 0.25, 0.2];

% 指标类型 (1=效益型, 2=成本型)
type = [1, 1, 1, 1];

% 归一化
A_norm = A ./ sqrt(sum(A.^2));

% 加权归一化
V = A_norm .* W;

% 确定正负理想解
V_plus = zeros(1, n);
V_minus = zeros(1, n);
for j = 1:n
    if type(j) == 1  % 效益型
        V_plus(j) = max(V(:, j));
        V_minus(j) = min(V(:, j));
    else  % 成本型
        V_plus(j) = min(V(:, j));
        V_minus(j) = max(V(:, j));
    end
end

% 计算距离
D_plus = sqrt(sum((V - V_plus).^2, 2));
D_minus = sqrt(sum((V - V_minus).^2, 2));

% 相对接近度
C = D_minus ./ (D_plus + D_minus);

% 排序
[C_sorted, idx] = sort(C, 'descend');

fprintf('   方案排名:\n');
for i = 1:m
    fprintf('   第 %d 名: 方案 %d (C=%.4f)\n', i, idx(i), C_sorted(i));
end

%% 10. 层次分析法 (AHP)
fprintf('\n\n=== 10. 层次分析法 (AHP) ===\n\n');

% 判断矩阵 (3x3)
A_ahp = [1   1/3  1/5;
         3   1    1/2;
         5   2    1];

% 计算特征值和特征向量
[V_ahp, D_ahp] = eig(A_ahp);
[lambda_max, idx] = max(diag(D_ahp));
w = V_ahp(:, idx);
w = w / sum(w);  % 归一化

% 一致性检验
n_ahp = size(A_ahp, 1);
CI = (lambda_max - n_ahp) / (n_ahp - 1);
RI = [0 0 0.58 0.90 1.12 1.24 1.32 1.41 1.45];  % 随机一致性指标
CR = CI / RI(n_ahp);

fprintf('   权重向量: %s\n', mat2str(w', 4));
fprintf('   最大特征值: %.4f\n', lambda_max);
fprintf('   一致性指标 CI: %.4f\n', CI);
fprintf('   一致性比率 CR: %.4f\n', CR);

if CR < 0.1
    fprintf('   ✅ 通过一致性检验\n');
else
    fprintf('   ❌ 未通过一致性检验，需要调整判断矩阵\n');
end

fprintf('\n🎉 所有数学建模示例完成!\n');
