classdef formulas
%EUTILS.FORMULAS 工程公式速查手册
%
%   eutils.formulas.control()      控制系统公式
%   eutils.formulas.circuit()      电路公式
%   eutils.formulas.signal()       信号处理公式
%   eutils.formulas.mechanical()   机械/材料公式
%   eutils.formulas.thermal()      热力学公式
%   eutils.formulas.fluid()        流体力学公式
%   eutils.formulas.electromagnetics()  电磁学公式
%
%   See also ecalculator, eutils.constants

    methods (Static)
        function control()
        %CONTROL 控制系统常用公式
            fprintf('📖 控制系统公式速查\n');
            fprintf('═══════════════════════════════════════════\n\n');

            fprintf('【传递函数】\n');
            fprintf('  G(s) = K / (τs + 1)           一阶系统\n');
            fprintf('  G(s) = K·ωn² / (s² + 2ζωn·s + ωn²)  二阶系统\n\n');

            fprintf('【二阶系统性能】\n');
            fprintf('  超调量:   OS%% = exp(-ζπ/√(1-ζ²)) × 100\n');
            fprintf('  峰值时间: tp = π / (ωn·√(1-ζ²))\n');
            fprintf('  调节时间: ts ≈ 4/(ζωn) (2%%准则)\n');
            fprintf('  上升时间: tr ≈ 1.8/ωn (ζ=0.5时)\n\n');

            fprintf('【稳定性判据】\n');
            fprintf('  Routh: 首列全为正 → 稳定\n');
            fprintf('  Nyquist: 不包围(-1,j0) → 稳定\n');
            fprintf('  Bode: Gm>0dB 且 Pm>0° → 稳定\n\n');

            fprintf('【PID 控制器】\n');
            fprintf('  u(t) = Kp·e(t) + Ki·∫e(t)dt + Kd·de(t)/dt\n');
            fprintf('  C(s) = Kp + Ki/s + Kd·s\n');
            fprintf('  C(s) = Kp(1 + 1/(Ti·s) + Td·s)  (ISA形式)\n\n');

            fprintf('【Ziegler-Nichols 整定】\n');
            fprintf('  P:  Kp = 0.5·Ku\n');
            fprintf('  PI: Kp = 0.45·Ku, Ti = Tu/1.2\n');
            fprintf('  PID: Kp = 0.6·Ku, Ti = Tu/2, Td = Tu/8\n\n');

            fprintf('【状态空间】\n');
            fprintf('  ẋ = Ax + Bu\n');
            fprintf('  y = Cx + Du\n');
            fprintf('  传递函数: G(s) = C(sI-A)⁻¹B + D\n');
        end

        function circuit()
        %CIRCUIT 电路常用公式
            fprintf('📖 电路公式速查\n');
            fprintf('═══════════════════════════════════════════\n\n');

            fprintf('【基本定律】\n');
            fprintf('  欧姆定律: V = I·R\n');
            fprintf('  KVL: ΣV = 0 (回路)\n');
            fprintf('  KCL: ΣI = 0 (节点)\n\n');

            fprintf('【功率】\n');
            fprintf('  P = V·I = I²·R = V²/R\n');
            fprintf('  交流: P = V·I·cos(φ) (有功)\n');
            fprintf('        Q = V·I·sin(φ) (无功)\n');
            fprintf('        S = V·I (视在)\n\n');

            fprintf('【RC 电路】\n');
            fprintf('  时间常数: τ = R·C\n');
            fprintf('  低通截止: fc = 1/(2πRC)\n');
            fprintf('  充电: V(t) = V0·(1 - e^(-t/τ))\n');
            fprintf('  放电: V(t) = V0·e^(-t/τ)\n\n');

            fprintf('【RL 电路】\n');
            fprintf('  时间常数: τ = L/R\n');
            fprintf('  截止频率: fc = R/(2πL)\n\n');

            fprintf('【RLC 谐振】\n');
            fprintf('  谐振频率: f0 = 1/(2π√(LC))\n');
            fprintf('  品质因数: Q = ω0·L/R = 1/(ω0·C·R)\n');
            fprintf('  带宽: BW = f0/Q\n\n');

            fprintf('【运放】\n');
            fprintf('  反相: Vout = -(Rf/Rin)·Vin\n');
            fprintf('  同相: Vout = (1 + Rf/Rin)·Vin\n');
            fprintf('  积分: Vout = -1/(RC)·∫Vin·dt\n');
            fprintf('  微分: Vout = -RC·dVin/dt\n');
        end

        function signal()
        %SIGNAL 信号处理常用公式
            fprintf('📖 信号处理公式速查\n');
            fprintf('═══════════════════════════════════════════\n\n');

            fprintf('【傅里叶变换】\n');
            fprintf('  X(f) = ∫x(t)·e^(-j2πft)dt\n');
            fprintf('  x(t) = ∫X(f)·e^(j2πft)df\n');
            fprintf('  DFT: X[k] = Σ x[n]·e^(-j2πkn/N)\n\n');

            fprintf('【采样定理】\n');
            fprintf('  Nyquist: Fs ≥ 2·fmax\n');
            fprintf('  实际建议: Fs ≥ 5~10·fmax\n');
            fprintf('  抗混叠: fc < Fs/2\n\n');

            fprintf('【窗函数】\n');
            fprintf('  矩形: w[n] = 1\n');
            fprintf('  汉宁: w[n] = 0.5(1-cos(2πn/N))\n');
            fprintf('  汉明: w[n] = 0.54-0.46cos(2πn/N)\n');
            fprintf('  布莱克曼: w[n] = 0.42-0.5cos(2πn/N)+0.08cos(4πn/N)\n\n');

            fprintf('【滤波器设计】\n');
            fprintf('  Butterworth: 最大平坦\n');
            fprintf('  Chebyshev I: 通带纹波\n');
            fprintf('  Chebyshev II: 阻带纹波\n');
            fprintf('  Elliptic: 通带+阻带纹波，最陡峭\n\n');

            fprintf('【频谱分析】\n');
            fprintf('  频率分辨率: Δf = Fs/N\n');
            fprintf('  频谱泄漏: 加窗减少\n');
            fprintf('  THD = √(A2²+A3²+...+An²) / A1\n');
        end

        function mechanical()
        %MECHANICAL 机械/材料力学公式
            fprintf('📖 机械/材料力学公式速查\n');
            fprintf('═══════════════════════════════════════════\n\n');

            fprintf('【应力应变】\n');
            fprintf('  正应力: σ = F/A\n');
            fprintf('  正应变: ε = ΔL/L\n');
            fprintf('  胡克定律: σ = E·ε\n');
            fprintf('  剪应力: τ = V/A\n');
            fprintf('  剪应变: γ = τ/G\n\n');

            fprintf('【弹性模量】\n');
            fprintf('  钢: E = 200 GPa, G = 80 GPa\n');
            fprintf('  铝: E = 69 GPa, G = 26 GPa\n');
            fprintf('  铜: E = 117 GPa, G = 44 GPa\n');
            fprintf('  泊松比: ν = E/(2G) - 1\n\n');

            fprintf('【梁挠度】\n');
            fprintf('  悬臂梁(端部力): δ = PL³/(3EI)\n');
            fprintf('  简支梁(中点力): δ = PL³/(48EI)\n');
            fprintf('  悬臂梁(均布): δ = wL⁴/(8EI)\n');
            fprintf('  简支梁(均布): δ = 5wL⁴/(384EI)\n\n');

            fprintf('【扭转】\n');
            fprintf('  圆轴: τ = T·r/J\n');
            fprintf('  扭转角: θ = TL/(GJ)\n');
            fprintf('  极惯性矩(实心): J = πd⁴/32\n');
            fprintf('  极惯性矩(空心): J = π(D⁴-d⁴)/32\n\n');

            fprintf('【压力容器】\n');
            fprintf('  薄壁环向: σθ = Pr/t\n');
            fprintf('  薄壁轴向: σz = Pr/(2t)\n');
            fprintf('  厚壁(Lame): σθ = P(ri²)/(ro²-ri²)·(1+ro²/r²)\n\n');

            fprintf('【疲劳】\n');
            fprintf('  S-N曲线: S = a·N^b\n');
            fprintf('  Goodman: Sa/Se + Sm/Sut = 1\n');
            fprintf('  安全系数: nf = Se/Sa (平均应力为0时)\n');
        end

        function thermal()
        %THERMAL 热力学公式
            fprintf('📖 热力学公式速查\n');
            fprintf('═══════════════════════════════════════════\n\n');

            fprintf('【热传导】\n');
            fprintf('  傅里叶定律: Q = -kA(dT/dx)\n');
            fprintf('  平壁: Q = kA·ΔT/L\n');
            fprintf('  圆筒: Q = 2πkL·ΔT/ln(ro/ri)\n');
            fprintf('  热阻(平壁): R = L/(kA)\n\n');

            fprintf('【对流换热】\n');
            fprintf('  牛顿冷却: Q = hA·ΔT\n');
            fprintf('  自然对流: h ≈ 5-25 W/(m²·K)\n');
            fprintf('  强制对流: h ≈ 25-250 W/(m²·K)\n\n');

            fprintf('【辐射换热】\n');
            fprintf('  Stefan-Boltzmann: Q = εσA(T1⁴-T2⁴)\n');
            fprintf('  σ = 5.67×10⁻⁸ W/(m²·K⁴)\n');
            fprintf('  黑体: ε = 1, 实际: ε < 1\n\n');

            fprintf('【散热器】\n');
            fprintf('  总热阻: Rja = Rjc + Rcs + Rsa\n');
            fprintf('  结温: Tj = Ta + P·Rja\n');
            fprintf('  最大热阻: Rsa_max = (Tj_max-Ta)/P - Rjc - Rcs\n');
        end

        function fluid()
        %FLUID 流体力学公式
            fprintf('📖 流体力学公式速查\n');
            fprintf('═══════════════════════════════════════════\n\n');

            fprintf('【雷诺数】\n');
            fprintf('  Re = ρvD/μ\n');
            fprintf('  层流: Re < 2300\n');
            fprintf('  湍流: Re > 4000\n\n');

            fprintf('【伯努利方程】\n');
            fprintf('  P/(ρg) + v²/(2g) + z = 常数\n');
            fprintf('  P1 + ½ρv1² + ρgz1 = P2 + ½ρv2² + ρgz2\n\n');

            fprintf('【管道流动】\n');
            fprintf('  达西公式: hf = f·(L/D)·v²/(2g)\n');
            fprintf('  层流摩擦: f = 64/Re\n');
            fprintf('  湍流摩擦(Colebrook): 1/√f = -2log(ε/(3.7D) + 2.51/(Re√f))\n\n');

            fprintf('【皮托管】\n');
            fprintf('  v = √(2ΔP/ρ)\n\n');

            fprintf('【喷管】\n');
            fprintf('  临界压力比: Pr = (2/(γ+1))^(γ/(γ-1))\n');
            fprintf('  出口速度: v = √(2γRT₁/(γ-1)·(1-(P₂/P₁)^((γ-1)/γ)))\n');
        end

        function electromagnetics()
        %ELECTROMAGNETICS 电磁学公式
            fprintf('📖 电磁学公式速查\n');
            fprintf('═══════════════════════════════════════════\n\n');

            fprintf('【库仑定律】\n');
            fprintf('  F = kq₁q₂/r²\n');
            fprintf('  k = 1/(4πε₀) = 8.99×10⁹ N·m²/C²\n\n');

            fprintf('【电场】\n');
            fprintf('  E = F/q = kQ/r²\n');
            fprintf('  电势: V = kQ/r\n\n');

            fprintf('【磁场】\n');
            fprintf('  Biot-Savart: dB = (μ₀/4π)·Idl×r̂/r²\n');
            fprintf('  长直导线: B = μ₀I/(2πr)\n');
            fprintf('  螺线管: B = μ₀nI\n\n');

            fprintf('【电磁感应】\n');
            fprintf('  法拉第: ε = -dΦ/dt\n');
            fprintf('  电感: L = NΦ/I\n');
            fprintf('  能量: W = ½LI²\n\n');

            fprintf('【电容/电感】\n');
            fprintf('  平板电容: C = εA/d\n');
            fprintf('  电感储能: W = ½LI²\n');
            fprintf('  电容储能: W = ½CV²\n');
            fprintf('  谐振: f = 1/(2π√(LC))\n');
        end

        function list()
        %LIST 列出所有公式类别
            fprintf('📋 公式速查类别:\n');
            fprintf('   eutils.formulas.control()           控制系统\n');
            fprintf('   eutils.formulas.circuit()           电路\n');
            fprintf('   eutils.formulas.signal()            信号处理\n');
            fprintf('   eutils.formulas.mechanical()        机械/材料\n');
            fprintf('   eutils.formulas.thermal()           热力学\n');
            fprintf('   eutils.formulas.fluid()             流体力学\n');
            fprintf('   eutils.formulas.electromagnetics()  电磁学\n');
        end
    end
end
