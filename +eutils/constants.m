classdef constants
%EUTILS.CONSTANTS 物理常数库
%
%   eutils.constants.c           光速
%   eutils.constants.g           重力加速度
%   eutils.constants.kB          玻尔兹曼常数
%   eutils.constants.h           普朗克常数
%   eutils.constants.sigma       斯蒂芬-玻尔兹曼常数
%   eutils.constants.epsilon0    真空介电常数
%   eutils.constants.mu0         真空磁导率
%
%   使用方法:
%     c = eutils.constants.c;        % 获取值
%     eutils.constants.list('all');  % 列出所有常数
%     eutils.constants.info('g');    % 查看详细信息
%
%   See also eutils.units

    properties (Constant)
        % 基本物理常数
        c = 299792458;                     % 光速 (m/s)
        g = 9.80665;                       % 标准重力加速度 (m/s²)
        G = 6.67430e-11;                   % 万有引力常数 (m³/(kg·s²))
        h = 6.62607015e-34;                % 普朗克常数 (J·s)
        hbar = 1.054571817e-34;            % 约化普朗克常数 (J·s)
        kB = 1.380649e-23;                 % 玻尔兹曼常数 (J/K)
        NA = 6.02214076e23;                % 阿伏伽德罗常数 (1/mol)
        R = 8.314462618;                   % 理想气体常数 (J/(mol·K))
        sigma = 5.670374419e-8;            % 斯蒂芬-玻尔兹曼常数 (W/(m²·K⁴))
        eV = 1.602176634e-19;              % 电子伏特 (J)

        % 电磁常数
        e = 1.602176634e-19;               % 基本电荷 (C)
        epsilon0 = 8.8541878128e-12;       % 真空介电常数 (F/m)
        mu0 = 1.25663706212e-6;            % 真空磁导率 (H/m)
        Z0 = 376.730313668;                % 真空阻抗 (Ω)

        % 材料常用参数
        rho_water = 997;                   % 水密度 @ 25°C (kg/m³)
        rho_air = 1.225;                   % 空气密度 @ 15°C, 1atm (kg/m³)
        cp_water = 4186;                   % 水比热容 (J/(kg·K))
        cp_air = 1005;                     % 空气比热容 (J/(kg·K))
        mu_water = 8.9e-4;                 % 水动力粘度 @ 25°C (Pa·s)
        mu_air = 1.81e-5;                  % 空气动力粘度 @ 15°C (Pa·s)
        k_water = 0.606;                   % 水导热系数 @ 25°C (W/(m·K))
        k_air = 0.0257;                    % 空气导热系数 @ 15°C (W/(m·K))

        % 材料弹性模量 (Pa)
        E_steel = 200e9;                   % 钢
        E_aluminum = 69e9;                 % 铝
        E_copper = 117e9;                  % 铜
        E_titanium = 114e9;                % 钛
        E_concrete = 30e9;                 % 混凝土

        % 圆周率
        pi = 3.14159265358979323846;
        e_num = 2.71828182845904523536;    % 自然常数
    end

    methods (Static)
        function val = get(name)
        %GET 获取常数值
        %
        %   val = eutils.constants.get('c')

            try
                val = eutils.constants.(name);
            catch
                error('eutils:constants:unknown', '未知常数: %s', name);
            end
        end

        function info(name)
        %INFO 显示常数详细信息
        %
        %   eutils.constants.info('g')

            switch lower(name)
                case {'c', 'speed_of_light'}
                    fprintf('光速:\n');
                    fprintf('   符号: c\n');
                    fprintf('   值:   299,792,458 m/s\n');
                    fprintf('   说明: 真空中的光速，精确值\n');

                case {'g', 'gravity'}
                    fprintf('标准重力加速度:\n');
                    fprintf('   符号: g\n');
                    fprintf('   值:   9.80665 m/s²\n');
                    fprintf('   说明: 海平面标准重力加速度\n');

                case {'kb', 'boltzmann'}
                    fprintf('玻尔兹曼常数:\n');
                    fprintf('   符号: kB\n');
                    fprintf('   值:   1.380649 × 10⁻²³ J/K\n');
                    fprintf('   说明: 关系温度与能量的基本常数\n');

                case {'h', 'planck'}
                    fprintf('普朗克常数:\n');
                    fprintf('   符号: h\n');
                    fprintf('   值:   6.62607015 × 10⁻³⁴ J·s\n');
                    fprintf('   说明: 量子力学基本常数\n');

                case {'sigma', 'stefan_boltzmann'}
                    fprintf('斯蒂芬-玻尔兹曼常数:\n');
                    fprintf('   符号: σ\n');
                    fprintf('   值:   5.670374419 × 10⁻⁸ W/(m²·K⁴)\n');
                    fprintf('   说明: 黑体辐射定律常数\n');

                case {'e', 'elementary_charge'}
                    fprintf('基本电荷:\n');
                    fprintf('   符号: e\n');
                    fprintf('   值:   1.602176634 × 10⁻¹⁹ C\n');
                    fprintf('   说明: 电子电荷量，精确值\n');

                otherwise
                    fprintf('未知常数: %s\n', name);
                    fprintf('使用 eutils.constants.list 查看所有常数\n');
            end
        end

        function list(category)
        %LIST 列出常数
        %
        %   eutils.constants.list('all')
        %   eutils.constants.list('physics')

            if nargin < 1, category = 'all'; end

            switch lower(category)
                case 'all'
                    fprintf('📋 物理常数:\n');
                    fprintf('   c        = %e m/s     (光速)\n', eutils.constants.c);
                    fprintf('   g        = %f m/s²    (重力加速度)\n', eutils.constants.g);
                    fprintf('   G        = %e m³/(kg·s²) (引力常数)\n', eutils.constants.G);
                    fprintf('   h        = %e J·s     (普朗克常数)\n', eutils.constants.h);
                    fprintf('   hbar     = %e J·s     (约化普朗克常数)\n', eutils.constants.hbar);
                    fprintf('   kB       = %e J/K     (玻尔兹曼常数)\n', eutils.constants.kB);
                    fprintf('   NA       = %e 1/mol   (阿伏伽德罗常数)\n', eutils.constants.NA);
                    fprintf('   R        = %f J/(mol·K) (气体常数)\n', eutils.constants.R);
                    fprintf('   sigma    = %e W/(m²·K⁴) (斯蒂芬-玻尔兹曼常数)\n', eutils.constants.sigma);
                    fprintf('   eV       = %e J       (电子伏特)\n', eutils.constants.eV);
                    fprintf('\n   电磁常数:\n');
                    fprintf('   e        = %e C       (基本电荷)\n', eutils.constants.e);
                    fprintf('   epsilon0 = %e F/m     (真空介电常数)\n', eutils.constants.epsilon0);
                    fprintf('   mu0      = %e H/m     (真空磁导率)\n', eutils.constants.mu0);
                    fprintf('   Z0       = %f Ω       (真空阻抗)\n', eutils.constants.Z0);
                    fprintf('\n   材料参数 (常温):\n');
                    fprintf('   rho_water  = %d kg/m³\n', eutils.constants.rho_water);
                    fprintf('   rho_air    = %.3f kg/m³\n', eutils.constants.rho_air);
                    fprintf('   cp_water   = %d J/(kg·K)\n', eutils.constants.cp_water);
                    fprintf('   E_steel    = %d GPa\n', eutils.constants.E_steel/1e9);
                    fprintf('   E_aluminum = %d GPa\n', eutils.constants.E_aluminum/1e9);

                case 'physics'
                    eutils.constants.list('all');

                case 'material'
                    fprintf('📋 材料参数:\n');
                    fprintf('   密度 (kg/m³):\n');
                    fprintf('     水:   %d\n', eutils.constants.rho_water);
                    fprintf('     空气: %.3f\n', eutils.constants.rho_air);
                    fprintf('   比热容 (J/(kg·K)):\n');
                    fprintf('     水:   %d\n', eutils.constants.cp_water);
                    fprintf('     空气: %d\n', eutils.constants.cp_air);
                    fprintf('   弹性模量 (GPa):\n');
                    fprintf('     钢:   %d\n', eutils.constants.E_steel/1e9);
                    fprintf('     铝:   %d\n', eutils.constants.E_aluminum/1e9);
                    fprintf('     铜:   %d\n', eutils.constants.E_copper/1e9);
                    fprintf('     钛:   %d\n', eutils.constants.E_titanium/1e9);
            end
        end
    end
end
