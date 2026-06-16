function fig = bode_styled(sys, varargin)
%EPLOT.BODE_STYLED 美化的波特图
%
%   eplot.bode_styled(sys)
%   eplot.bode_styled(sys, 'style', 'ieee', 'w', logspace(-3,3,1000))
%   eplot.bode_styled(sys, 'show_margin', true, 'show_bandwidth', true)
%
%   可选参数:
%     'style'          - eplot 样式预设
%     'w'              - 频率范围 (rad/s)
%     'title'          - 图表标题
%     'show_margin'    - 显示裕度标注 (默认 true)
%     'show_bandwidth' - 显示带宽标注 (默认 false)
%     'show_crossover' - 显示穿越频率 (默认 true)
%
%   See also eplot.nyquist_styled, eplot.compare_bode, eplot.style

    opts = struct('style', '', 'w', [], 'title', 'Bode Plot', ...
                  'show_margin', true, 'show_bandwidth', false, ...
                  'show_crossover', true);
    for i = 1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end

    if isempty(opts.w)
        w = logspace(-3, 4, 2000);
    else
        w = opts.w;
    end

    % 计算频率响应
    [mag, phase, wout] = bode(sys, w);
    mag = squeeze(mag);
    phase = squeeze(phase);
    mag_dB = 20*log10(mag);

    % 计算关键指标
    [Gm, Pm, Wcg, Wcp] = margin(sys);

    % 绘图
    fig = figure('Name', 'Bode Plot');

    % 幅频特性
    subplot(2,1,1);
    semilogx(wout, mag_dB, 'b-', 'LineWidth', 1.5);
    hold on;

    % 标注增益裕度
    if opts.show_margin && isfinite(Gm)
        % 在增益裕度点标注
        [mag_at_wcg, ~] = bode(sys, Wcg);
        mag_at_wcg_dB = 20*log10(squeeze(mag_at_wcg));
        semilogx(Wcg, mag_at_wcg_dB, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
        text(Wcg, mag_at_wcg_dB + 3, sprintf('G_m = %.1f dB', 20*log10(Gm)), ...
            'FontSize', 9, 'Color', 'r', 'HorizontalAlignment', 'center');

        % 画增益裕度线
        semilogx([Wcg Wcg], [0 mag_at_wcg_dB], 'r--', 'LineWidth', 1);
    end

    % 标注带宽
    if opts.show_bandwidth
        % 找到 -3dB 带宽 (相对于峰值)
        peak_dB = max(mag_dB);
        idx_bw = find(mag_dB <= peak_dB - 3, 1);
        if ~isempty(idx_bw)
            Wbw = wout(idx_bw);
            semilogx(Wbw, mag_dB(idx_bw), 'gs', 'MarkerSize', 8, 'LineWidth', 2);
            text(Wbw, mag_dB(idx_bw) - 3, sprintf('BW = %.2f rad/s', Wbw), ...
                'FontSize', 9, 'Color', 'g', 'HorizontalAlignment', 'center');
        end
    end

    yline(0, 'k--', 'LineWidth', 0.5);
    ylabel('Magnitude (dB)');
    title(opts.title);
    grid on;
    xlim([w(1) w(end)]);

    % 相频特性
    subplot(2,1,2);
    semilogx(wout, phase, 'b-', 'LineWidth', 1.5);
    hold on;

    % 标注相位裕度
    if opts.show_margin && isfinite(Pm)
        [mag_at_wcp, phase_at_wcp] = bode(sys, Wcp);
        phase_at_wcp = squeeze(phase_at_wcp);
        semilogx(Wcp, phase_at_wcp, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
        text(Wcp, phase_at_wcp + 5, sprintf('P_m = %.1f°', Pm), ...
            'FontSize', 9, 'Color', 'r', 'HorizontalAlignment', 'center');

        % 画相位裕度线
        semilogx([Wcp Wcp], [-180 phase_at_wcp], 'r--', 'LineWidth', 1);
    end

    yline(-180, 'k--', 'LineWidth', 0.5);
    xlabel('Frequency (rad/s)');
    ylabel('Phase (deg)');
    grid on;
    xlim([w(1) w(end)]);

    % 打印关键指标
    fprintf('📊 Bode Plot 分析结果:\n');
    if isfinite(Gm)
        fprintf('   增益裕度: %.2f dB (at %.2f rad/s)\n', 20*log10(Gm), Wcg);
    else
        fprintf('   增益裕度: Inf\n');
    end
    if isfinite(Pm)
        fprintf('   相位裕度: %.2f° (at %.2f rad/s)\n', Pm, Wcp);
    else
        fprintf('   相位裕度: Inf\n');
    end

    if isfinite(Gm) && Gm > 1 && isfinite(Pm) && Pm > 30
        fprintf('   ✅ 系统稳定\n');
    elseif isfinite(Gm) && isfinite(Pm)
        fprintf('   ⚠️  裕度不足，建议调整参数\n');
    else
        fprintf('   ❌ 系统不稳定\n');
    end

    % 应用样式
    if ~isempty(opts.style)
        eplot.style(fig, opts.style);
    end
end
