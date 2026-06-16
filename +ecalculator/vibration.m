classdef vibration
%ECALCULATOR.VIBRATION 振动分析工程计算器
%
%   ecalculator.vibration.fft_guided(x, Fs)              引导式 FFT 分析
%   ecalculator.vibration.signal_check(x, Fs)            信号质量检查
%   ecalculator.vibration.transfer_function(x, y, Fs)    实验传递函数估计
%   ecalculator.vibration.modal_analysis(frfs, freqs)     模态分析
%   ecalculator.vibration.psd(x, Fs)                     功率谱密度
%
%   See also ecalculator.signal, ecalculator.dsp

    methods(Static)
        function info = fft_guided(x, Fs, varargin)
        %FFT_GUIDED 引导式 FFT 分析（自动处理常见错误）
        %
        %   ecalculator.vibration.fft_guided(x, 10000)
        %   ecalculator.vibration.fft_guided(x, 10000, 'window', 'hanning')
        %
        %   自动完成:
        %   1. 信号质量检查（直流偏移、混叠、削波）
        %   2. 加窗处理
        %   3. 正确的幅值归一化
        %   4. 频率轴构建
        %   5. 主频识别与标注

            opts = struct('window', 'hanning', 'nfft', [], 'plot', true, ...
                          'harmonics', 5, 'dc_remove', true);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            N = numel(x);
            x = x(:);  % 确保列向量

            %% Step 1: 信号质量检查
            warnings = {};

            % 检查直流偏移
            dc_offset = mean(x);
            if abs(dc_offset) > 0.1 * std(x)
                warnings{end+1} = sprintf('检测到直流偏移: %.4f（已自动去除）', dc_offset);
                if opts.dc_remove
                    x = x - dc_offset;
                end
            end

            % 检查削波
            x_range = max(x) - min(x);
            n_clip_high = sum(abs(x - max(x)) < 0.001 * x_range);
            n_clip_low = sum(abs(x - min(x)) < 0.001 * x_range);
            if n_clip_high > N * 0.01 || n_clip_low > N * 0.01
                warnings{end+1} = sprintf('可能存在削波（顶部 %d 点，底部 %d 点）', n_clip_high, n_clip_low);
            end

            % 检查数据长度
            if N < 100
                warnings{end+1} = sprintf('数据长度过短（%d 点），频谱分辨率可能不足', N);
            end

            %% Step 2: 加窗
            switch lower(opts.window)
                case 'hanning'
                    win = hanning(N);
                case 'hamming'
                    win = hamming(N);
                case 'blackman'
                    win = blackman(N);
                case 'kaiser'
                    win = kaiser(N, 5);
                case 'flat top'
                    win = flattopwin(N);
                case 'rectangular'
                    win = ones(N, 1);
                otherwise
                    win = hanning(N);
            end

            x_win = x .* win;

            % 窗函数相干功率修正
            coherent_gain = sum(win) / N;
            noise_gain = sqrt(sum(win.^2) / N);
            enbw = Fs * noise_gain^2 / (coherent_gain^2);  % 等效噪声带宽

            %% Step 3: FFT 计算
            if isempty(opts.nfft)
                nfft = 2^nextpow2(N);
            else
                nfft = opts.nfft;
            end

            X = fft(x_win, nfft);

            % 单边谱
            X_single = X(1:nfft/2+1);
            f = Fs * (0:nfft/2) / nfft;

            % 幅值归一化（考虑窗函数和单边谱）
            magnitude = 2 * abs(X_single) / (N * coherent_gain);
            magnitude(1) = magnitude(1) / 2;  % DC 分量不乘 2

            % 相位
            phase = angle(X_single) * 180 / pi;

            % 功率谱密度
            psd = (magnitude.^2) / (2 * enbw);

            %% Step 4: 主频识别
            [~, peak_idx] = max(magnitude(2:end));
            peak_idx = peak_idx + 1;
            peak_freq = f(peak_idx);
            peak_amp = magnitude(peak_idx);

            % 识别谐波
            harmonics = zeros(opts.harmonics, 1);
            harmonics(1) = peak_freq;
            for k = 2:opts.harmonics
                harm_freq = k * peak_freq;
                [~, harm_idx] = min(abs(f - harm_freq));
                harmonics(k) = f(harm_idx);
            end

            %% Step 5: 输出结果
            fprintf('📊 FFT 分析结果:\n');
            fprintf('   采样率:     %d Hz\n', Fs);
            fprintf('   数据长度:   %d 点\n', N);
            fprintf('   频率分辨率: %.4f Hz\n', Fs/nfft);
            fprintf('   主频率:     %.4f Hz\n', peak_freq);
            fprintf('   主幅值:     %.6f\n', peak_amp);

            if ~isempty(warnings)
                fprintf('\n   ⚠️  警告:\n');
                for w = 1:numel(warnings)
                    fprintf('      - %s\n', warnings{w});
                end
            end

            %% Step 6: 绘图
            if opts.plot
                fig = figure('Name', 'FFT Analysis');

                % 幅值谱
                subplot(3,1,1);
                plot(f, magnitude, 'b-', 'LineWidth', 1);
                hold on;
                plot(peak_freq, peak_amp, 'rv', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
                text(peak_freq, peak_amp*1.1, sprintf('%.2f Hz', peak_freq), ...
                    'HorizontalAlignment', 'center', 'FontSize', 9);
                xlabel('Frequency (Hz)');
                ylabel('Amplitude');
                title('Amplitude Spectrum');
                grid on;
                xlim([0 Fs/2]);

                % 功率谱密度
                subplot(3,1,2);
                semilogy(f, psd, 'r-', 'LineWidth', 1);
                xlabel('Frequency (Hz)');
                ylabel('PSD (unit²/Hz)');
                title('Power Spectral Density');
                grid on;
                xlim([0 Fs/2]);

                % 相位谱
                subplot(3,1,3);
                plot(f, phase, 'g-', 'LineWidth', 1);
                xlabel('Frequency (Hz)');
                ylabel('Phase (deg)');
                title('Phase Spectrum');
                grid on;
                xlim([0 Fs/2]);
            end

            %% 返回结果
            info.f = f;
            info.magnitude = magnitude;
            info.phase = phase;
            info.psd = psd;
            info.peak_freq = peak_freq;
            info.peak_amp = peak_amp;
            info.harmonics = harmonics;
            info.warnings = warnings;
            info.window = opts.window;
            info.enbw = enbw;
        end

        function info = signal_check(x, Fs)
        %SIGNAL_CHECK 信号质量自动检查
        %
        %   ecalculator.vibration.signal_check(x, 10000)

            N = numel(x);
            x = x(:);

            fprintf('🔍 信号质量检查:\n');
            fprintf('   数据长度: %d 点 (%.3f s)\n', N, N/Fs);
            fprintf('   采样率:   %d Hz\n', Fs);

            issues = {};

            % 1. 直流偏移
            dc = mean(x);
            dc_ratio = abs(dc) / std(x);
            if dc_ratio > 0.1
                issues{end+1} = struct('type', 'dc_offset', 'severity', 'warning', ...
                    'message', sprintf('直流偏移 %.4f（占信号标准差 %.1f%%）', dc, dc_ratio*100));
            end

            % 2. 削波检测
            x_range = max(x) - min(x);
            n_top = sum(abs(x - max(x)) < 0.001 * x_range);
            n_bot = sum(abs(x - min(x)) < 0.001 * x_range);
            if n_top > N * 0.01 || n_bot > N * 0.01
                issues{end+1} = struct('type', 'clipping', 'severity', 'error', ...
                    'message', sprintf('削波检测：顶部 %d 点，底部 %d 点', n_top, n_bot));
            end

            % 3. NaN/Inf 检测
            n_nan = sum(isnan(x));
            n_inf = sum(isinf(x));
            if n_nan > 0 || n_inf > 0
                issues{end+1} = struct('type', 'invalid', 'severity', 'error', ...
                    'message', sprintf('无效数据：NaN %d 个，Inf %d 个', n_nan, n_inf));
            end

            % 4. 混叠风险评估
            % 粗略估计信号最高频率
            X = abs(fft(x - mean(x)));
            X = X(1:floor(N/2));
            f_axis = Fs * (0:floor(N/2)-1) / N;
            [~, idx_95] = min(abs(cumsum(X)/sum(X) - 0.95));
            f_95 = f_axis(idx_95);

            if f_95 > Fs * 0.4
                issues{end+1} = struct('type', 'aliasing', 'severity', 'warning', ...
                    'message', sprintf('混叠风险：信号能量集中在 %.1f Hz（采样率的 %.0f%%）', f_95, f_95/Fs*100));
            end

            % 5. 数据长度评估
            min_cycles = 10;  % 最低 10 个周期
            if f_95 > 0
                min_samples = min_cycles * Fs / f_95;
                if N < min_samples
                    issues{end+1} = struct('type', 'short_data', 'severity', 'warning', ...
                        'message', sprintf('数据可能过短：需要 %.0f 点（10个周期），实际 %d 点', min_samples, N));
                end
            end

            % 6. 噪声水平评估
            % 用高频段估计噪声
            noise_idx = round(N*0.8):floor(N/2);
            if numel(noise_idx) > 10
                noise_level = mean(X(noise_idx));
                signal_level = max(X);
                snr_est = 20*log10(signal_level / noise_level);
                fprintf('   估计信噪比: %.1f dB\n', snr_est);
                if snr_est < 20
                    issues{end+1} = struct('type', 'low_snr', 'severity', 'warning', ...
                        'message', sprintf('信噪比较低：约 %.1f dB', snr_est));
                end
            end

            % 打印结果
            if isempty(issues)
                fprintf('   ✅ 信号质量良好\n');
            else
                for i = 1:numel(issues)
                    issue = issues{i};
                    switch issue.severity
                        case 'error'
                            icon = '❌';
                        case 'warning'
                            icon = '⚠️';
                        otherwise
                            icon = 'ℹ️';
                    end
                    fprintf('   %s [%s] %s\n', icon, issue.type, issue.message);
                end
            end

            info.issues = issues;
            info.dc_offset = dc;
            info.f_95 = f_95;
            info.n_nan = n_nan;
        end

        function info = transfer_function(input_sig, output_sig, Fs, varargin)
        %TRANSFER_FUNCTION 实验传递函数估计
        %
        %   info = ecalculator.vibration.transfer_function(u, y, 10000)
        %   info = ecalculator.vibration.transfer_function(u, y, 10000, 'nfft', 1024)
        %
        %   使用 Welch 方法估计频率响应函数 (FRF)
        %   同时计算相干函数作为可靠性指标

            opts = struct('nfft', [], 'window', 'hanning', 'noverlap', [], 'plot', true);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            input_sig = input_sig(:);
            output_sig = output_sig(:);

            % 确保长度一致
            N = min(numel(input_sig), numel(output_sig));
            input_sig = input_sig(1:N);
            output_sig = output_sig(1:N);

            if isempty(opts.nfft)
                opts.nfft = 2^nextpow2(N/4);
            end
            if isempty(opts.noverlap)
                opts.noverlap = opts.nfft / 2;
            end

            % 估计传递函数
            [H, f] = tfestimate(input_sig, output_sig, ...
                feval(opts.window, opts.nfft), opts.noverlap, opts.nfft, Fs);

            % 估计相干函数
            [Cxy, ~] = mscohere(input_sig, output_sig, ...
                feval(opts.window, opts.nfft), opts.noverlap, opts.nfft, Fs);

            % 幅值和相位
            mag_dB = 20*log10(abs(H));
            phase_deg = angle(H) * 180 / pi;

            fprintf('📊 传递函数估计:\n');
            fprintf('   数据长度: %d 点\n', N);
            fprintf('   FFT 点数: %d\n', opts.nfft);
            fprintf('   频率分辨率: %.4f Hz\n', Fs/opts.nfft);
            fprintf('   平均相干: %.4f\n', mean(Cxy));

            % 找到相干较好的频率范围
            good_coh = find(Cxy > 0.8);
            if ~isempty(good_coh)
                fprintf('   有效频率范围: %.2f - %.2f Hz\n', ...
                    f(good_coh(1)), f(good_coh(end)));
            end

            % 绘图
            if opts.plot
                fig = figure('Name', 'Transfer Function Estimation');

                % 幅频特性
                subplot(3,1,1);
                plot(f, mag_dB, 'b-', 'LineWidth', 1.5);
                xlabel('Frequency (Hz)');
                ylabel('Magnitude (dB)');
                title('Frequency Response Function');
                grid on;

                % 相频特性
                subplot(3,1,2);
                plot(f, phase_deg, 'r-', 'LineWidth', 1.5);
                xlabel('Frequency (Hz)');
                ylabel('Phase (deg)');
                title('Phase Response');
                grid on;

                % 相干函数
                subplot(3,1,3);
                plot(f, Cxy, 'g-', 'LineWidth', 1.5);
                hold on;
                yline(0.8, 'k--', 'LineWidth', 1);
                xlabel('Frequency (Hz)');
                ylabel('Coherence');
                title('Coherence Function');
                ylim([0 1.1]);
                grid on;
            end

            info.H = H;
            info.f = f;
            info.magnitude = abs(H);
            info.magnitude_dB = mag_dB;
            info.phase = phase_deg;
            info.coherence = Cxy;
            info.nfft = opts.nfft;
        end

        function info = psd(x, Fs, varargin)
        %PSD 功率谱密度估计
        %
        %   ecalculator.vibration.psd(x, 10000)
        %   ecalculator.vibration.psd(x, 10000, 'method', 'welch')

            opts = struct('method', 'welch', 'nfft', [], 'window', 'hanning', 'noverlap', [], 'plot', true);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            x = x(:);

            if isempty(opts.nfft)
                opts.nfft = 2^nextpow2(numel(x)/4);
            end
            if isempty(opts.noverlap)
                opts.noverlap = opts.nfft / 2;
            end

            switch lower(opts.method)
                case 'welch'
                    [Pxx, f] = pwelch(x, feval(opts.window, opts.nfft), ...
                        opts.noverlap, opts.nfft, Fs);
                case 'periodogram'
                    [Pxx, f] = periodogram(x, feval(opts.window, numel(x)), ...
                        2^nextpow2(numel(x)), Fs);
                otherwise
                    error('ecalculator:vibration:unknownMethod', '未知方法: %s', opts.method);
            end

            fprintf('📊 功率谱密度估计:\n');
            fprintf('   方法: %s\n', opts.method);
            fprintf('   频率分辨率: %.4f Hz\n', f(2)-f(1));
            fprintf('   峰值频率: %.4f Hz\n', f(Pxx == max(Pxx)));

            if opts.plot
                figure('Name', 'Power Spectral Density');
                semilogy(f, Pxx, 'b-', 'LineWidth', 1.5);
                xlabel('Frequency (Hz)');
                ylabel('PSD (unit²/Hz)');
                title('Power Spectral Density');
                grid on;
            end

            info.Pxx = Pxx;
            info.f = f;
            info.peak_freq = f(Pxx == max(Pxx));
        end

        function info = rms_envelope(x, Fs, window_size)
        %RMS_ENVELOPE RMS 包络分析
        %
        %   ecalculator.vibration.rms_envelope(x, 10000, 100)

            if nargin < 3, window_size = 100; end

            x = x(:);
            N = numel(x);

            % 计算 RMS 包络
            n_windows = floor(N / window_size);
            rms_env = zeros(n_windows, 1);
            t_env = zeros(n_windows, 1);

            for i = 1:n_windows
                idx_start = (i-1) * window_size + 1;
                idx_end = i * window_size;
                rms_env(i) = rms(x(idx_start:idx_end));
                t_env(i) = (idx_start + idx_end) / 2 / Fs;
            end

            fprintf('📊 RMS 包络分析:\n');
            fprintf('   窗口大小: %d 点 (%.4f s)\n', window_size, window_size/Fs);
            fprintf('   包络均值: %.6f\n', mean(rms_env));
            fprintf('   包络最大: %.6f\n', max(rms_env));
            fprintf('   包络最小: %.6f\n', min(rms_env));

            figure('Name', 'RMS Envelope');
            subplot(2,1,1);
            plot((1:N)/Fs, x, 'b-', 'LineWidth', 0.5);
            xlabel('Time (s)');
            ylabel('Amplitude');
            title('Raw Signal');
            grid on;

            subplot(2,1,2);
            plot(t_env, rms_env, 'r-', 'LineWidth', 1.5);
            xlabel('Time (s)');
            ylabel('RMS');
            title('RMS Envelope');
            grid on;

            info.rms_envelope = rms_env;
            info.time = t_env;
            info.window_size = window_size;
        end

        function info = modal_analysis(frfs, freqs, varargin)
        %MODAL_ANALYSIS 模态分析
        %
        %   info = ecalculator.vibration.modal_analysis(frfs, freqs)
        %
        %   从 FRF 数据识别模态参数（固有频率、阻尼比、振型）
        %
        %   输入:
        %     frfs  - FRF 矩阵 (n_freqs x n_points)
        %     freqs - 频率向量 (Hz)

            opts = struct('n_modes', 3, 'plot', true);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            n_freqs = numel(freqs);
            n_points = size(frfs, 2);

            % 使用峰值拾取法识别模态
            natural_freqs = zeros(opts.n_modes, 1);
            damping_ratios = zeros(opts.n_modes, 1);
            mode_shapes = zeros(n_points, opts.n_modes);

            % 对每个 FRF 找峰值
            all_peaks = [];
            for p = 1:n_points
                frf_mag = abs(frfs(:, p));
                [pks, locs] = findpeaks(frf_mag, 'SortStr', 'descend', ...
                    'NPeaks', opts.n_modes * 2);
                all_peaks = [all_peaks; locs(:)];
            end

            % 聚类峰值位置
            if numel(all_peaks) >= opts.n_modes
                [cluster_idx, cluster_centers] = kmeans(all_peaks, opts.n_modes, ...
                    'Replicates', 5);

                for m = 1:opts.n_modes
                    % 固有频率
                    peak_idx = round(cluster_centers(m));
                    peak_idx = max(1, min(n_freqs, peak_idx));
                    natural_freqs(m) = freqs(peak_idx);

                    % 半功率带宽法估算阻尼比
                    for p = 1:n_points
                        frf_mag = abs(frfs(:, p));
                        peak_val = frf_mag(peak_idx);
                        half_power = peak_val / sqrt(2);

                        % 找半功率点
                        below = find(frf_mag(1:peak_idx) < half_power, 1, 'last');
                        above = find(frf_mag(peak_idx:end) < half_power, 1) + peak_idx - 1;

                        if ~isempty(below) && ~isempty(above)
                            f1 = freqs(below);
                            f2 = freqs(above);
                            damping_ratios(m) = (f2 - f1) / (2 * natural_freqs(m));
                        end
                    end

                    % 振型
                    for p = 1:n_points
                        frf_mag = abs(frfs(:, p));
                        mode_shapes(p, m) = frf_mag(peak_idx);
                    end

                    % 归一化振型
                    mode_shapes(:, m) = mode_shapes(:, m) / max(abs(mode_shapes(:, m)));
                end
            end

            fprintf('📊 模态分析结果:\n');
            fprintf('   识别模态数: %d\n', opts.n_modes);
            fprintf('   测点数:     %d\n', n_points);
            for m = 1:opts.n_modes
                fprintf('   ───── 模态 %d ─────\n', m);
                fprintf('   固有频率:   %.2f Hz\n', natural_freqs(m));
                fprintf('   阻尼比:     %.4f (%.2f%%)\n', ...
                    damping_ratios(m), damping_ratios(m)*100);
            end

            % 绘图
            if opts.plot
                figure('Name', 'Modal Analysis');

                % FRF 叠加图
                subplot(2,1,1);
                hold on;
                for p = 1:n_points
                    plot(freqs, 20*log10(abs(frfs(:, p))), 'LineWidth', 0.5);
                end
                for m = 1:opts.n_modes
                    xline(natural_freqs(m), 'r--', sprintf('Mode %d', m), ...
                        'LineWidth', 1.5, 'LabelVerticalAlignment', 'bottom');
                end
                xlabel('Frequency (Hz)');
                ylabel('Magnitude (dB)');
                title('FRF Overlay with Identified Modes');
                grid on;

                % 振型图
                subplot(2,1,2);
                bar(mode_shapes, 'grouped');
                xlabel('Measurement Point');
                ylabel('Normalized Amplitude');
                title('Mode Shapes');
                legend(arrayfun(@(m) sprintf('Mode %d', m), 1:opts.n_modes, ...
                    'UniformOutput', false), 'Location', 'best');
                grid on;
            end

            info.natural_freqs = natural_freqs;
            info.damping_ratios = damping_ratios;
            info.mode_shapes = mode_shapes;
        end
    end
end
