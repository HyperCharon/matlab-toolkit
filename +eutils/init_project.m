function init_project(project_name, varargin)
%EUTILS.INIT_PROJECT 初始化新项目模板
%
%   eutils.init_project('my_project')
%   eutils.init_project('my_project', 'type', 'control')
%   eutils.init_project('my_project', 'type', 'signal', 'git', true)
%
%   项目类型:
%     'control'  - 控制系统项目 (默认)
%     'signal'   - 信号处理项目
%     'power'    - 电力电子项目
%     'general'  - 通用项目
%
%   可选参数:
%     'type'   - 项目类型 (默认 'control')
%     'git'    - 是否初始化 git (默认 true)
%     'README' - 是否生成 README (默认 true)
%
%   See also eutils.add_path, eutils.check_code

    opts = struct('type', 'control', 'git', true, 'README', true);
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    % 检查目录是否已存在
    if exist(project_name, 'dir')
        error('eutils:init_project:dirExists', '目录已存在: %s', project_name);
    end

    fprintf('🚀 初始化项目: %s (类型: %s)\n', project_name, opts.type);

    % 创建目录结构
    dirs = {'src', 'data', 'results', 'figures', 'docs', 'tests'};
    for i = 1:numel(dirs)
        mkdir(fullfile(project_name, dirs{i}));
    end

    % 创建主脚本
    create_main_script(project_name, opts.type);

    % 创建配置文件
    create_config(project_name, opts.type);

    % 创建 README
    if opts.README
        create_readme(project_name, opts.type);
    end

    % 创建 .gitignore
    if opts.git
        create_gitignore(project_name);
        try
            old_dir = pwd;
            cd(project_name);
            system('git init');
            cd(old_dir);
            fprintf('   ✅ Git 仓库已初始化\n');
        catch
            fprintf('   ⚠️  Git 初始化失败\n');
        end
    end

    fprintf('✅ 项目创建完成!\n');
    fprintf('   目录结构:\n');
    fprintf('   %s/\n', project_name);
    fprintf('   ├── src/          源代码\n');
    fprintf('   ├── data/         数据文件\n');
    fprintf('   ├── results/      仿真结果\n');
    fprintf('   ├── figures/      图表\n');
    fprintf('   ├── docs/         文档\n');
    fprintf('   ├── tests/        测试\n');
    fprintf('   ├── main.m        主脚本\n');
    fprintf('   ├── config.m      配置文件\n');
    fprintf('   └── README.md     说明文档\n');
end

function create_main_script(project_name, type)
    fid = fopen(fullfile(project_name, 'main.m'), 'w');

    fprintf(fid, '%%%% %s - 主脚本\n', project_name);
    fprintf(fid, '%% 项目类型: %s\n', type);
    fprintf(fid, '%% 生成时间: %s\n\n', datestr(now));

    fprintf(fid, '%% 添加路径\n');
    fprintf(fid, 'addpath(genpath(\"src\"));\n');
    fprintf(fid, 'addpath(genpath(\"data\"));\n\n');

    fprintf(fid, '%% 加载配置\n');
    fprintf(fid, 'cfg = config();\n\n');

    switch type
        case 'control'
            fprintf(fid, '%% 控制系统设计\n');
            fprintf(fid, '%% 1. 定义被控对象\n');
            fprintf(fid, 'plant = tf(cfg.plant.num, cfg.plant.den);\n\n');
            fprintf(fid, '%% 2. 设计控制器\n');
            fprintf(fid, 'C = pid(cfg.pid.Kp, cfg.pid.Ki, cfg.pid.Kd);\n\n');
            fprintf(fid, '%% 3. 闭环仿真\n');
            fprintf(fid, 'sys_closed = feedback(C * plant, 1);\n');
            fprintf(fid, 'step(sys_closed);\n');
            fprintf(fid, 'title(\"阶跃响应\");\n\n');
            fprintf(fid, '%% 4. 性能分析\n');
            fprintf(fid, 'info = stepinfo(sys_closed);\n');
            fprintf(fid, 'fprintf(\"超调量: %%.2f%%\\n\", info.Overshoot);\n');
            fprintf(fid, 'fprintf(\"调节时间: %%.4f s\\n\", info.SettlingTime);\n');

        case 'signal'
            fprintf(fid, '%% 信号处理\n');
            fprintf(fid, '%% 1. 生成测试信号\n');
            fprintf(fid, 'Fs = cfg.signal.Fs;\n');
            fprintf(fid, 't = 0:1/Fs:cfg.signal.duration;\n');
            fprintf(fid, 'x = sin(2*pi*cfg.signal.f1*t) + 0.5*sin(2*pi*cfg.signal.f2*t);\n\n');
            fprintf(fid, '%% 2. FFT 分析\n');
            fprintf(fid, 'ecalculator.signal.fft_analyze(x, Fs);\n\n');
            fprintf(fid, '%% 3. 滤波\n');
            fprintf(fid, 'spec.Fpass = cfg.filter.Fpass;\n');
            fprintf(fid, 'spec.Fstop = cfg.filter.Fstop;\n');
            fprintf(fid, 'spec.Fs = Fs;\n');
            fprintf(fid, 'filt = ecalculator.signal.filter_design(\"butterworth\", spec);\n');

        case 'power'
            fprintf(fid, '%% 电力电子仿真\n');
            fprintf(fid, '%% 1. 电路参数\n');
            fprintf(fid, 'Vdc = cfg.power.Vdc;\n');
            fprintf(fid, 'L = cfg.power.L;\n');
            fprintf(fid, 'C = cfg.power.C;\n');
            fprintf(fid, 'R = cfg.power.R;\n\n');
            fprintf(fid, '%% 2. 传递函数\n');
            fprintf(fid, 'num = [1];\n');
            fprintf(fid, 'den = [L*C, L/R, 1];\n');
            fprintf(fid, 'sys = tf(num, den);\n\n');
            fprintf(fid, '%% 3. 频率响应\n');
            fprintf(fid, 'figure;\n');
            fprintf(fid, 'bode(sys);\n');
            fprintf(fid, 'title(\"Bode Plot\");\n');

        case 'general'
            fprintf(fid, '%% 通用项目主脚本\n\n');
            fprintf(fid, '%% 1. 加载数据\n');
            fprintf(fid, '%% data = edata.read(\"data/my_data.csv\");\n\n');
            fprintf(fid, '%% 2. 数据处理\n');
            fprintf(fid, '%% data = edata.clean(data);\n\n');
            fprintf(fid, '%% 3. 分析\n');
            fprintf(fid, '%% info = edata.analyze(data, \"plot\", true);\n\n');
            fprintf(fid, '%% 4. 导出结果\n');
            fprintf(fid, '%% edata.export(data, \"results/output.csv\");\n');
    end

    fclose(fid);
end

function create_config(project_name, type)
    fid = fopen(fullfile(project_name, 'config.m'), 'w');

    fprintf(fid, 'function cfg = config()\n');
    fprintf(fid, '%%CONFIG 项目配置文件\n\n');

    switch type
        case 'control'
            fprintf(fid, '%% 被控对象参数\n');
            fprintf(fid, 'cfg.plant.num = [1];\n');
            fprintf(fid, 'cfg.plant.den = [1, 10, 0];\n\n');
            fprintf(fid, '%% PID 参数\n');
            fprintf(fid, 'cfg.pid.Kp = 1;\n');
            fprintf(fid, 'cfg.pid.Ki = 0.5;\n');
            fprintf(fid, 'cfg.pid.Kd = 0.1;\n\n');
            fprintf(fid, '%% 仿真参数\n');
            fprintf(fid, 'cfg.sim.Ts = 0.001;\n');
            fprintf(fid, 'cfg.sim.Tend = 5;\n');

        case 'signal'
            fprintf(fid, '%% 信号参数\n');
            fprintf(fid, 'cfg.signal.Fs = 1000;\n');
            fprintf(fid, 'cfg.signal.duration = 1;\n');
            fprintf(fid, 'cfg.signal.f1 = 50;\n');
            fprintf(fid, 'cfg.signal.f2 = 200;\n\n');
            fprintf(fid, '%% 滤波器参数\n');
            fprintf(fid, 'cfg.filter.Fpass = 100;\n');
            fprintf(fid, 'cfg.filter.Fstop = 150;\n');

        case 'power'
            fprintf(fid, '%% 电源参数\n');
            fprintf(fid, 'cfg.power.Vdc = 48;\n');
            fprintf(fid, 'cfg.power.L = 1e-3;\n');
            fprintf(fid, 'cfg.power.C = 100e-6;\n');
            fprintf(fid, 'cfg.power.R = 10;\n');

        case 'general'
            fprintf(fid, '%% 通用配置\n');
            fprintf(fid, 'cfg.data.input_dir = \"data\";\n');
            fprintf(fid, 'cfg.data.output_dir = \"results\";\n');
    end

    fprintf(fid, 'end\n');
    fclose(fid);
end

function create_readme(project_name, type)
    fid = fopen(fullfile(project_name, 'README.md'), 'w');

    fprintf(fid, '# %s\n\n', project_name);
    fprintf(fid, '## 项目说明\n\n');
    fprintf(fid, '- **类型:** %s\n', type);
    fprintf(fid, '- **创建时间:** %s\n\n', datestr(now));

    fprintf(fid, '## 目录结构\n\n');
    fprintf(fid, '```\n');
    fprintf(fid, '%s/\n', project_name);
    fprintf(fid, '├── src/          源代码\n');
    fprintf(fid, '├── data/         数据文件\n');
    fprintf(fid, '├── results/      仿真结果\n');
    fprintf(fid, '├── figures/      图表\n');
    fprintf(fid, '├── docs/         文档\n');
    fprintf(fid, '├── tests/        测试\n');
    fprintf(fid, '├── main.m        主脚本\n');
    fprintf(fid, '├── config.m      配置文件\n');
    fprintf(fid, '└── README.md     说明文档\n');
    fprintf(fid, '```\n\n');

    fprintf(fid, '## 快速开始\n\n');
    fprintf(fid, '```matlab\n');
    fprintf(fid, '%% 运行主脚本\n');
    fprintf(fid, 'main\n');
    fprintf(fid, '```\n\n');

    fclose(fid);
end

function create_gitignore(project_name)
    fid = fopen(fullfile(project_name, '.gitignore'), 'w');

    fprintf(fid, '# MATLAB\n');
    fprintf(fid, '*.asv\n');
    fprintf(fid, '*.m~\n');
    fprintf(fid, 'slprj/\n');
    fprintf(fid, '*.slxc\n');
    fprintf(fid, '*.autosave\n');
    fprintf(fid, 'codegen/\n');
    fprintf(fid, '*.mex*\n\n');

    fprintf(fid, '# Simulink\n');
    fprintf(fid, '*.slxc\n');
    fprintf(fid, 'slprj/\n\n');

    fprintf(fid, '# 数据文件\n');
    fprintf(fid, '*.mat\n');
    fprintf(fid, '*.h5\n');
    fprintf(fid, '*.hdf5\n\n');

    fprintf(fid, '# 结果文件\n');
    fprintf(fid, 'results/\n');
    fprintf(fid, 'figures/\n\n');

    fprintf(fid, '# 系统文件\n');
    fprintf(fid, '.DS_Store\n');
    fprintf(fid, 'Thumbs.db\n');
    fprintf(fid, 'desktop.ini\n');

    fclose(fid);
end
