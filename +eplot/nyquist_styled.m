function fig = nyquist_styled(sys, varargin)
%EPLOT.NYQUIST_STYLED 美化的 Nyquist 图
%
%   eplot.nyquist_styled(sys)
%   eplot.nyquist_styled(sys, 'style', 'ieee', 'w', logspace(-3,3,1000))
%
%   See also eplot.bode_styled, eplot.style

    opts = struct('style', '', 'w', [], 'title', 'Nyquist Plot', ...
                  'show_margin', true, 'show_critical', true);
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    if isempty(opts.w)
        w = logspace(-3, 3, 2000);
    else
        w = opts.w;
    end

    fig = figure('Name', 'Nyquist Plot');

    % 计算频率响应
    [re, im, wout] = nyquist(sys, w);
    re = squeeze(re);
    im = squeeze(im);

    % 绘制 Nyquist 曲线
    plot(re, im, 'b-', 'LineWidth', 1.5);
    hold on;
    plot(re, -im, 'b--', 'LineWidth', 1.0);  % 负频率部分

    % 标记临界点 (-1, 0)
    if opts.show_critical
        plot(-1, 0, 'r+', 'MarkerSize', 12, 'LineWidth', 2);
        text(-1.1, 0.1, '(-1, 0)', 'FontSize', 10, 'Color', 'r');
    end

    % 显示裕度
    if opts.show_margin
        [Gm, Pm, Wcg, Wcp] = margin(sys);
        if isfinite(Gm) && isfinite(Pm)
            % 增益裕度点
            re_gm = -1/Gm;
            plot(re_gm, 0, 'go', 'MarkerSize', 8, 'LineWidth', 2);
            text(re_gm, 0.1, sprintf('G_m = %.1f dB', 20*log10(Gm)), ...
                'FontSize', 9, 'Color', 'g');

            % 相位裕度点
            [re_pm, im_pm] = freqresp(sys, Wcp);
            plot(re_pm, im_pm, 'mo', 'MarkerSize', 8, 'LineWidth', 2);
        end
    end

    % 坐标轴设置
    xline(0, 'k-', 'LineWidth', 0.5);
    yline(0, 'k-', 'LineWidth', 0.5);
    xlabel('Real Axis');
    ylabel('Imaginary Axis');
    title(opts.title);
    axis equal;
    grid on;

    % 调整坐标范围
    xlim_val = xlim;
    ylim_val = ylim;
    max_range = max(abs([xlim_val ylim_val]));
    xlim([-max_range*1.1 max_range*1.1]);
    ylim([-max_range*1.1 max_range*1.1]);

    if ~isempty(opts.style)
        eplot.style(fig, opts.style);
    end
end
