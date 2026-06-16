classdef signal
%ECALCULATOR.SIGNAL 信号处理工程计算器
%
%   ecalculator.signal.fft_analyze(x, Fs)           FFT 频谱分析
%   ecalculator.signal.filter_design(type, spec)    滤波器设计
%   ecalculator.signal.sampling_check(fmax, Fs)     采样定理检查
%   ecalculator.signal.snr(signal, noise)           信噪比计算
%   ecalculator.signal.thd(signal, Fs)              总谐波失真
%
%   See also ecalculator.control, ecalculator.circuit

    methods(Static)
        function info = fft_analyze(x, Fs, varargin)
        %FFT_ANALYZE FFT 频谱分析
        %
        %   ecalculator.signal.fft_analyze(x, 1000)
        %   ecalculator.signal.fft_analyze(x, 1000, 'nfft', 4096, 'window', 'hanning')

            opts = struct('nfft', [], 'window', 'rectangular', 'plot', true);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            N = numel(x);

            % 窗函数
            switch lower(opts.window)
                case 'hanning'
                    w = hanning(N);
                case 'hamming'
                    w = hamming(N);
                case 'blackman'
                    w = blackman(N);
                case 'kaiser'
                    w = kaiser(N, 5);
                otherwise
                    w = ones(N, 1);
            end

            x_win = x(:) .* w;

            % FFT
            if isempty(opts.nfft)
                nfft = 2^nextpow2(N);
            else
                nfft = opts.nfft;
            end

            X = fft(x_win, nfft);
            X = X(1:nfft/2+1);
            f = Fs * (0:nfft/2) / nfft;
            magnitude = 2 * abs(X) / N;
            magnitude(1) = magnitude(1) / 2;  % DC 分量
            phase = angle(X) * 180 / pi;
            power_dB = 20*log10(magnitude + eps);

            % 找到主要频率分量
            [~, peak_idx] = max(magnitude(2:end));
            peak_freq = f(peak_idx + 1);
            peak_amp = magnitude(peak_idx + 1);

            % THD 计算
            thd_val = calculate_thd(magnitude, f, peak_freq);

            fprintf('📊 FFT 分析结果:\n');
            fprintf('   采样率:     %s\n', eutils.formatters.frequency(Fs));
            fprintf('   采样点数:   %d\n', N);
            fprintf('   频率分辨率: %s\n', eutils.formatters.frequency(Fs/nfft));
            fprintf('   主频率:     %s\n', eutils.formatters.frequency(peak_freq));
            fprintf('   主幅值:     %.6f\n', peak_amp);
            fprintf('   THD:        %.2f%%\n', thd_val * 100);

            if opts.plot
                fig = figure('Name', 'FFT Analysis');
                subplot(2,1,1);
                plot(f, magnitude, 'b-', 'LineWidth', 1);
                xlabel('Frequency (Hz)');
                ylabel('Magnitude');
                title('FFT Spectrum');
                grid on;
                xlim([0 Fs/2]);

                subplot(2,1,2);
                plot(f, phase, 'r-', 'LineWidth', 1);
                xlabel('Frequency (Hz)');
                ylabel('Phase (deg)');
                title('Phase Spectrum');
                grid on;
                xlim([0 Fs/2]);
            end

            info.f = f;
            info.magnitude = magnitude;
            info.phase = phase;
            info.peak_freq = peak_freq;
            info.peak_amp = peak_amp;
            info.thd = thd_val;
            info.power_dB = power_dB;
        end

        function info = filter_design(type, spec)
        %FILTER_DESIGN 滤波器设计
        %
        %   spec.type = 'lowpass';
        %   spec.Fpass = 1000;    % 通带频率
        %   spec.Fstop = 1500;    % 阻带频率
        %   spec.Apass = 1;       % 通带纹波 (dB)
        %   spec.Astop = 60;      % 阻带衰减 (dB)
        %   spec.Fs = 8000;       % 采样率
        %   ecalculator.signal.filter_design('butterworth', spec)

            if nargin < 2
                % 默认设计一个低通滤波器
                spec.type = 'lowpass';
                spec.Fpass = 1000;
                spec.Fstop = 1500;
                spec.Apass = 1;
                spec.Astop = 60;
                spec.Fs = 8000;
            end

            switch lower(type)
                case 'butterworth'
                    [N, Wn] = buttord(spec.Fpass/(spec.Fs/2), spec.Fstop/(spec.Fs/2), spec.Apass, spec.Astop);
                    [b, a] = butter(N, Wn);
                    filter_type = 'Butterworth';

                case 'chebyshev1'
                    [N, Wn] = cheb1ord(spec.Fpass/(spec.Fs/2), spec.Fstop/(spec.Fs/2), spec.Apass, spec.Astop);
                    [b, a] = cheby1(N, spec.Apass, Wn);
                    filter_type = 'Chebyshev Type I';

                case 'chebyshev2'
                    [N, Wn] = cheb2ord(spec.Fpass/(spec.Fs/2), spec.Fstop/(spec.Fs/2), spec.Apass, spec.Astop);
                    [b, a] = cheby2(N, spec.Astop, Wn);
                    filter_type = 'Chebyshev Type II';

                case 'elliptic'
                    [N, Wn] = ellipord(spec.Fpass/(spec.Fs/2), spec.Fstop/(spec.Fs/2), spec.Apass, spec.Astop);
                    [b, a] = ellip(N, spec.Apass, spec.Astop, Wn);
                    filter_type = 'Elliptic';

                otherwise
                    error('ecalculator:signal:unknownFilter', '未知滤波器类型: %s', type);
            end

            sys = tf(b, a, 1/spec.Fs);

            fprintf('🎛️  %s 滤波器设计:\n', filter_type);
            fprintf('   阶数:       %d\n', N);
            fprintf('   类型:       %s\n', spec.type);
            fprintf('   通带频率:   %s\n', eutils.formatters.frequency(spec.Fpass));
            fprintf('   阻带频率:   %s\n', eutils.formatters.frequency(spec.Fstop));
            fprintf('   通带纹波:   %.2f dB\n', spec.Apass);
            fprintf('   阻带衰减:   %.2f dB\n', spec.Astop);

            % 绘制频率响应
            figure('Name', sprintf('%s Filter', filter_type));
            freqz(b, a, 1024, spec.Fs);
            title(sprintf('%s Filter (Order = %d)', filter_type, N));

            info.b = b;
            info.a = a;
            info.N = N;
            info.tf = sys;
            info.type = filter_type;
        end

        function info = sampling_check(fmax, Fs)
        %SAMPLING_CHECK 采样定理检查
        %
        %   ecalculator.signal.sampling_check(1000, 8000)

            nyquist = 2 * fmax;
            ratio = Fs / fmax;

            fprintf('📐 采样定理检查:\n');
            fprintf('   信号最高频率: %s\n', eutils.formatters.frequency(fmax));
            fprintf('   采样率:       %s\n', eutils.formatters.frequency(Fs));
            fprintf('   奈奎斯特频率: %s\n', eutils.formatters.frequency(nyquist));
            fprintf('   采样率/信号频率: %.1f\n', ratio);

            if Fs >= nyquist
                fprintf('   ✅ 满足采样定理 (Fs ≥ 2*fmax)\n');
                fprintf('   建议: 采样率 %.1f 倍于信号频率，', ratio);
                if ratio >= 10
                    fprintf('非常充裕\n');
                elseif ratio >= 4
                    fprintf('比较充裕\n');
                else
                    fprintf('略显紧张，建议提高采样率\n');
                end
            else
                fprintf('   ❌ 不满足采样定理! 将发生混叠\n');
                fprintf('   最低采样率: %s\n', eutils.formatters.frequency(nyquist));
                fprintf('   需要提高:   %s\n', eutils.formatters.frequency(nyquist - Fs));
            end

            % 计算抗混叠滤波器参数
            f_alias = Fs - fmax;
            fprintf('\n   抗混叠滤波器建议:\n');
            fprintf('   通带截止:   %s\n', eutils.formatters.frequency(fmax));
            fprintf('   阻带起始:   %s\n', eutils.formatters.frequency(f_alias));

            info.valid = Fs >= nyquist;
            info.ratio = ratio;
            info.nyquist = nyquist;
            info.f_alias = f_alias;
        end

        function info = snr(signal, noise)
        %SNR 信噪比计算
        %
        %   info = ecalculator.signal.snr(signal_data, noise_data)

            P_signal = rms(signal)^2;
            P_noise = rms(noise)^2;
            snr_dB = 10*log10(P_signal / P_noise);

            fprintf('📡 信噪比:\n');
            fprintf('   信号功率: %.6f\n', P_signal);
            fprintf('   噪声功率: %.6f\n', P_noise);
            fprintf('   SNR:      %.2f dB\n', snr_dB);

            info.P_signal = P_signal;
            info.P_noise = P_noise;
            info.snr_dB = snr_dB;
        end

        function info = thd(x, Fs, f0)
        %THD 总谐波失真
        %
        %   info = ecalculator.signal.thd(x, 44100, 1000)

            N = numel(x);
            X = abs(fft(x)) / N;
            f = Fs * (0:N-1) / N;

            % 找基波
            [~, idx0] = min(abs(f - f0));
            A0 = X(idx0);

            % 计算谐波
            harmonics = 0;
            harmonic_amps = zeros(9, 1);
            for k = 2:10
                [~, idx] = min(abs(f - k*f0));
                harmonic_amps(k-1) = X(idx);
                harmonics = harmonics + X(idx)^2;
            end

            thd_val = sqrt(harmonics) / A0;

            fprintf('🔊 总谐波失真:\n');
            fprintf('   基波频率: %s\n', eutils.formatters.frequency(f0));
            fprintf('   THD:      %.4f%%\n', thd_val * 100);

            info.f0 = f0;
            info.A0 = A0;
            info.harmonic_amps = harmonic_amps;
            info.thd = thd_val;
            info.thd_percent = thd_val * 100;
        end
    end
end


function val = calculate_thd(magnitude, f, f0)
    if f0 == 0
        val = 0;
        return;
    end
    [~, idx0] = min(abs(f - f0));
    A0 = magnitude(idx0);
    harmonics = 0;
    for k = 2:10
        [~, idx] = min(abs(f - k*f0));
        if idx <= numel(magnitude)
            harmonics = harmonics + magnitude(idx)^2;
        end
    end
    val = sqrt(harmonics) / A0;
end
