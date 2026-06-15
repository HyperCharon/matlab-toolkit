function add_path(varargin)
%EUTILS.ADD_PATH 智能路径管理
%
%   eutils.add_path()              添加当前目录及子目录
%   eutils.add_path('src', 'lib')  添加指定目录
%   eutils.add_path('save', true)  保存路径设置
%
%   See also eutils.init_project, eutils.check_code

    opts = struct('save', false);
    dirs = {};

    i = 1;
    while i <= numel(varargin)
        if isfield(opts, varargin{i})
            opts.(varargin{i}) = varargin{i+1};
            i = i + 2;
        else
            dirs{end+1} = varargin{i};
            i = i + 1;
        end
    end

    if isempty(dirs)
        dirs = {pwd};
    end

    for i = 1:numel(dirs)
        d = dirs{i};
        if exist(d, 'dir')
            addpath(genpath(d));
            fprintf('✅ 已添加路径: %s\n', d);
        else
            warning('eutils:add_path:dirNotFound', '目录不存在: %s', d);
        end
    end

    if opts.save
        savepath;
        fprintf('💾 路径已保存\n');
    end
end
