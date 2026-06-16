function fig = compare_bode(systems, varargin)
%EPLOT.COMPARE_BODE 多系统波特图对比
%
%   eplot.compare_bode({sys1, sys2, sys3})
%   eplot.compare_bode({sys1, sys2}, 'labels', {'Current', 'Proposed'})
%
%   See also eplot.compare_step, eplot.style

    opts = struct('labels', {[]}, 'style', '', 'w', [], 'title', 'Bode Plot Comparison');
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    n = numel(systems);

    if isempty(opts.labels)
        opts.labels = arrayfun(@(i) sprintf('System %d', i), 1:n, 'UniformOutput', false);
    end

    if isempty(opts.w)
        w = logspace(-2, 4, 1000);
    else
        w = opts.w;
    end

    colors = get_default_colors(n);

    fig = figure('Name', 'Bode Comparison');

    % 幅频特性
    subplot(2,1,1);
    hold on;
    for i = 1:n
        [mag, ~, wout] = bode(systems{i}, w);
        semilogx(wout, 20*log10(squeeze(mag)), 'Color', colors(i,:), ...
            'LineWidth', 1.5, 'DisplayName', opts.labels{i});
    end
    ylabel('Magnitude (dB)');
    title(opts.title);
    legend('Location', 'best');
    grid on;

    % 相频特性
    subplot(2,1,2);
    hold on;
    for i = 1:n
        [~, phase, wout] = bode(systems{i}, w);
        semilogx(wout, squeeze(phase), 'Color', colors(i,:), ...
            'LineWidth', 1.5, 'DisplayName', opts.labels{i});
    end
    yline(-180, 'k--', 'LineWidth', 0.5, 'HandleVisibility', 'off');
    xlabel('Frequency (rad/s)');
    ylabel('Phase (deg)');
    legend('Location', 'best');
    grid on;

    if ~isempty(opts.style)
        eplot.style(fig, opts.style);
    end
end
