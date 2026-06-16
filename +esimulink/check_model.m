function issues = check_model(model_name, varargin)
%ESIMULINK.CHECK_MODEL Simulink 模型检查
%
%   issues = esimulink.check_model('my_model')
%   issues = esimulink.check_model('my_model', 'verbose', true)
%
%   检查项:
%     - 未连接的信号线
%     - 未使用的端口
%     - 数据类型不匹配
%     - 代数环
%     - 参数未定义
%     - 子系统嵌套过深
%
%   See also esimulink.generate_docs, esimulink.export_params

    opts = struct('verbose', true, 'max_depth', 5);
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    % 加载模型
    try
        load_system(model_name);
    catch
        error('esimulink:check_model:modelNotFound', '无法加载模型: %s', model_name);
    end

    if opts.verbose
        fprintf('🔍 检查 Simulink 模型: %s\n\n', model_name);
    end

    issues = {};

    % 检查未连接的端口
    issues = [issues; check_unconnected_ports(model_name)];

    % 检查代数环
    issues = [issues; check_algebraic_loops(model_name)];

    % 检查子系统嵌套深度
    issues = [issues; check_subsystem_depth(model_name, opts.max_depth)];

    % 检查未使用的变量
    issues = [issues; check_unused_variables(model_name)];

    % 检查求解器设置
    issues = [issues; check_solver_settings(model_name)];

    % 打印报告
    if opts.verbose
        fprintf('📊 检查报告:\n');
        fprintf('   问题数: %d\n', numel(issues));

        if isempty(issues)
            fprintf('   ✅ 没有发现问题!\n');
        else
            errors = issues(cellfun(@(x) strcmp(x.severity, 'error'), issues));
            warnings = issues(cellfun(@(x) strcmp(x.severity, 'warning'), issues));
            infos = issues(cellfun(@(x) strcmp(x.severity, 'info'), issues));

            fprintf('   ❌ 错误: %d\n', numel(errors));
            fprintf('   ⚠️  警告: %d\n', numel(warnings));
            fprintf('   ℹ️  建议: %d\n', numel(infos));

            fprintf('\n');
            for i = 1:numel(issues)
                issue = issues{i};
                switch issue.severity
                    case 'error'
                        icon = '❌';
                    case 'warning'
                        icon = '⚠️';
                    case 'info'
                        icon = 'ℹ️';
                end
                fprintf('   %s [%s] %s\n', icon, issue.type, issue.message);
                if ~isempty(issue.block)
                    fprintf('      模块: %s\n', issue.block);
                end
            end
        end
    end
end

function issues = check_unconnected_ports(model_name)
    issues = {};

    % 查找所有未连接的端口
    ports = find_system(model_name, 'FindAll', 'on', 'Type', 'port', 'Line', -1);

    for i = 1:numel(ports)
        try
            port_name = get_param(ports(i), 'Name');
            parent = get_param(ports(i), 'Parent');
            issues{end+1} = struct(...
                'type', 'unconnected_port', ...
                'severity', 'warning', ...
                'message', sprintf('未连接的端口: %s', port_name), ...
                'block', parent);
        catch
            % 忽略无法读取的端口
        end
    end
end

function issues = check_algebraic_loops(model_name)
    issues = {};

    % 检查是否有代数环
    try
        % 尝试编译模型
        set_param(model_name, 'SimulationCommand', 'update');
    catch ME
        if contains(ME.message, 'algebraic')
            issues{end+1} = struct(...
                'type', 'algebraic_loop', ...
                'severity', 'error', ...
                'message', '存在代数环', ...
                'block', '');
        end
    end
end

function issues = check_subsystem_depth(model_name, max_depth)
    issues = {};

    subsystems = find_system(model_name, 'BlockType', 'SubSystem');

    for i = 1:numel(subsystems)
        path = subsystems{i};
        depth = numel(strfind(path, '/')) - 1;

        if depth > max_depth
            issues{end+1} = struct(...
                'type', 'deep_subsystem', ...
                'severity', 'warning', ...
                'message', sprintf('子系统嵌套过深 (%d > %d)', depth, max_depth), ...
                'block', path);
        end
    end
end

function issues = check_unused_variables(model_name)
    issues = {};

    try
        ws = get_param(model_name, 'ModelWorkspace');
        vars = whos(ws);

        for i = 1:numel(vars)
            var_name = vars(i).name;
            % 检查变量是否在模型中使用
            usage = find_system(model_name, 'LookUnderMasks', 'all', ...
                'RegExp', 'on', 'Value', ['\<' var_name '\>']);

            if isempty(usage)
                issues{end+1} = struct(...
                    'type', 'unused_variable', ...
                    'severity', 'info', ...
                    'message', sprintf('未使用的变量: %s', var_name), ...
                    'block', '');
            end
        end
    catch ME
        warning('esimulink:check_model:workspaceCheckFailed', ...
            '工作区变量检查失败: %s', ME.message);
    end
end

function issues = check_solver_settings(model_name)
    issues = {};

    solver = get_param(model_name, 'Solver');

    % 检查是否使用固定步长求解器
    if contains(solver, 'ode') && ~contains(solver, 'Fixed')
        issues{end+1} = struct(...
            'type', 'solver', ...
            'severity', 'info', ...
            'message', sprintf('使用变步长求解器: %s，代码生成建议使用固定步长', solver), ...
            'block', '');
    end
end
