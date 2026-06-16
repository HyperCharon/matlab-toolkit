function animate(fig, filename, varargin)
%EPLOT.ANIMATE 将 figure 动画导出为 GIF 或视频
%
%   eplot.animate(fig, 'animation.gif')
%   eplot.animate(fig, 'animation.gif', 'fps', 20, 'loop', true)
%   eplot.animate(fig, 'animation.mp4', 'fps', 30)
%
%   使用方法:
%   1. 先创建动画循环，在循环中更新 figure 内容
%   2. 每帧调用 eplot.animate(fig, filename, 'frame') 保存帧
%   3. 循环结束后调用 eplot.animate(fig, filename, 'finish') 完成
%
%   或使用便捷函数:
%   eplot.animate_step(sys, 'step_response.gif')
%   eplot.animate_root_locus(num, den, 'root_locus.gif')
%
%   See also eplot.export, eplot.style

    opts = struct('fps', 15, 'loop', true, 'quality', 95);
    args = {};
    i = 1;
    while i <= numel(varargin)
        if isfield(opts, varargin{i})
            opts.(varargin{i}) = varargin{i+1};
            i = i + 2;
        else
            args{end+1} = varargin{i};
            i = i + 1;
        end
    end

    if isempty(args)
        mode = 'single';
    else
        mode = args{1};
    end

    % 持久化存储帧
    persistent anim_frames anim_counter anim_filename

    switch mode
        case 'frame'
            % 保存当前帧
            frame = getframe(fig);
            if isempty(anim_frames)
                anim_frames = {frame};
                anim_counter = 1;
                anim_filename = filename;
            else
                anim_frames{end+1} = frame;
                anim_counter = anim_counter + 1;
            end

        case 'finish'
            % 完成动画，写入文件
            if isempty(anim_frames)
                warning('eplot:animate:noFrames', '没有帧数据');
                return;
            end

            [~, ~, ext] = fileparts(anim_filename);

            switch lower(ext)
                case '.gif'
                    % 写入 GIF
                    for i = 1:numel(anim_frames)
                        [A, map] = rgb2ind(frame2im(anim_frames{i}), 256);
                        if i == 1
                            if opts.loop
                                loop_count = Inf;
                            else
                                loop_count = 0;
                            end
                            imwrite(A, map, anim_filename, 'gif', ...
                                'LoopCount', loop_count, ...
                                'DelayTime', 1/opts.fps);
                        else
                            imwrite(A, map, anim_filename, 'gif', ...
                                'WriteMode', 'append', ...
                                'DelayTime', 1/opts.fps);
                        end
                    end

                case {'.mp4', '.avi'}
                    % 写入视频
                    v = VideoWriter(anim_filename);
                    v.FrameRate = opts.fps;
                    v.Quality = opts.quality;
                    open(v);
                    for i = 1:numel(anim_frames)
                        writeVideo(v, anim_frames{i});
                    end
                    close(v);

                otherwise
                    error('eplot:animate:unsupportedFormat', '不支持的格式: %s', ext);
            end

            fprintf('✅ 动画已导出: %s (%d 帧, %.1f s)\n', ...
                anim_filename, numel(anim_frames), numel(anim_frames)/opts.fps);

            % 清理
            anim_frames = [];
            anim_counter = 0;
            anim_filename = '';

        case 'single'
            % 单次捕获（用于简单动画）
            frame = getframe(fig);
            [A, map] = rgb2ind(frame2im(frame), 256);
            [~, ~, ext] = fileparts(filename);

            if strcmpi(ext, '.gif')
                if exist(filename, 'file')
                    imwrite(A, map, filename, 'gif', 'WriteMode', 'append', ...
                        'DelayTime', 1/opts.fps);
                else
                    if opts.loop
                        loop_count = Inf;
                    else
                        loop_count = 0;
                    end
                    imwrite(A, map, filename, 'gif', ...
                        'LoopCount', loop_count, ...
                        'DelayTime', 1/opts.fps);
                end
            end
    end
end
