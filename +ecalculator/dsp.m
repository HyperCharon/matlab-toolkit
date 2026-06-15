classdef dsp
%ECALCULATOR.DSP 数字信号处理工程计算器
%
%   ecalculator.dsp.fir_design(spec)           FIR 滤波器设计
%   ecalculator.dsp.iir_design(spec)           IIR 滤波器设计
%   ecalculator.dsp.resample(x, p, q, Fs)      采样率转换
%   ecalculator.dsp.window_analysis(win)       窗函数分析
%   ecalculator.dsp.spectrogram_analysis(x, Fs) 时频分析
%
%   See also ecalculator.signal, ecalculator.control

    methods(Static)
        function info = fir_design(spec)
        %FIR_DESIGN FIR 滤波器设计
        %
        %   spec.type = 'lowpass';
        %   spec.Fpass = 1000;
        %   spec.Fstop = 1500;
        %   spec.Fs = 8000;
        %   spec.order = 50;
        %   ecalculator.dsp.fir_design(spec)

            if nargin < 1
                spec.type = 'lowpass';
                spec.Fpass = 1000;
                spec.Fstop = 1500;
                spec.Fs = 8000;
                spec.order = 50;
            end

            % 设计 FIR 滤波器
            switch lower(spec.type)
                case 'lowpass'
                    b = fir1(spec.order, spec.Fpass/(spec.Fs/2));
                case 'highpass'
                    b = fir1(spec.order, spec.Fpass/(spec.Fs/2), 'high');
                case 'bandpass'
                    b = fir1(spec.order, [spec.Fpass1 spec.Fpass2]/(spec.Fs/2));
                case 'bandstop'
                    b = fir1(spec.order, [spec.Fstop1 spec.Fstop2]/(spec.Fs/2), 'stop');
                otherwise
                    error('ecalculator:dsp:unknownType', '未知滤波器类型: %s', spec.type);
            end

            a = 1;

            % 频率响应
            [H, f] = freqz(b, a, 1024, spec.Fs);

            fprintf('🎛️  FIR 滤波器设计:\n');
            fprintf('   类型:       %s\n', spec.type);
            fprintf('   阶数:       %d\n', spec.order);
            fprintf('   通带频率:   %.2f Hz\n', spec.Fpass);
            fprintf('   采样率:     %.2f Hz\n', spec.Fs);

            % 绘制频率响应
            figure('Name', 'FIR Filter Response');
            subplot(2,1,1);
            plot(f, 20*log10(abs(H)), 'b-', 'LineWidth', 1.5);
            xlabel('Frequency (Hz)');
            ylabel('Magnitude (dB)');
            title('FIR Filter Frequency Response');
            grid on;
            ylim([-80 5]);

            subplot(2,1,2);
            plot(f, angle(H)*180/pi, 'r-', 'LineWidth', 1.5);
            xlabel('Frequency (Hz)');
            ylabel('Phase (deg)');
            title('Phase Response');
            grid on;

            info.b = b;
            info.a = a;
            info.order = spec.order;
            info.H = H;
            info.f = f;
        end

        function info = iir_design(spec)
        %IIR_DESIGN IIR 滤波器设计
        %
        %   spec.type = 'lowpass';
        %   spec.Fpass = 1000;
        %   spec.Fstop = 1500;
        %   spec.Fs = 8000;
        %   spec.ripple = 1;
        %   spec.attenuation = 60;
        %   ecalculator.dsp.iir_design(spec)

            if nargin < 1
                spec.type = 'lowpass';
                spec.Fpass = 1000;
                spec.Fstop = 1500;
                spec.Fs = 8000;
                spec.ripple = 1;
                spec.attenuation = 60;
            end

            % 设计 IIR 滤波器 (椭圆滤波器)
            [N, Wn] = ellipord(spec.Fpass/(spec.Fs/2), spec.Fstop/(spec.Fs/2), ...
                spec.ripple, spec.attenuation);

            switch lower(spec.type)
                case 'lowpass'
                    [b, a] = ellip(N, spec.ripple, spec.attenuation, Wn);
                case 'highpass'
                    [b, a] = ellip(N, spec.ripple, spec.attenuation, Wn, 'high');
                case 'bandpass'
                    [b, a] = ellip(N, spec.ripple, spec.attenuation, Wn);
                otherwise
                    error('ecalculator:dsp:unknownType', '未知滤波器类型: %s', spec.type);
            end

            % 频率响应
            [H, f] = freqz(b, a, 1024, spec.Fs);

            fprintf('🎛️  IIR 滤波器设计:\n');
            fprintf('   类型:       %s\n', spec.type);
            fprintf('   阶数:       %d\n', N);
            fprintf('   通带频率:   %.2f Hz\n', spec.Fpass);
            fprintf('   通带纹波:   %.2f dB\n', spec.ripple);
            fprintf('   阻带衰减:   %.2f dB\n', spec.attenuation);

            % 绘制频率响应
            figure('Name', 'IIR Filter Response');
            subplot(2,1,1);
            plot(f, 20*log10(abs(H)), 'b-', 'LineWidth', 1.5);
            xlabel('Frequency (Hz)');
            ylabel('Magnitude (dB)');
            title('IIR Filter Frequency Response');
            grid on;

            subplot(2,1,2);
            plot(f, angle(H)*180/pi, 'r-', 'LineWidth', 1.5);
            xlabel('Frequency (Hz)');
            ylabel('Phase (deg)');
            title('Phase Response');
            grid on;

            info.b = b;
            info.a = a;
            info.order = N;
            info.H = H;
            info.f = f;
        end

        function [y, Fs_new] = resample(x, p, q, Fs)
        %RESAMPLE 采样率转换
        %
        %   [y, Fs_new] = ecalculator.dsp.resample(x, 3, 2, 8000)

            y = resample(x, p, q);
            Fs_new = Fs * p / q;

            fprintf('🔄 采样率转换:\n');
            fprintf('   原始采样率: %.2f Hz\n', Fs);
            fprintf('   转换因子:   %d/%d\n', p, q);
            fprintf('   新采样率:   %.2f Hz\n', Fs_new);
            fprintf('   原始长度:   %d\n', length(x));
            fprintf('   新长度:     %d\n', length(y));
        end

        function info = window_analysis(win_type, N)
        %WINDOW_ANALYSIS 窗函数分析
        %
        %   ecalculator.dsp.window_analysis('hanning', 100)

            if nargin < 2, N = 100; end

            % 生成窗函数
            switch lower(win_type)
                case 'rectangular'
                    win = ones(N, 1);
                case 'hanning'
                    win = hanning(N);
                case 'hamming'
                    win = hamming(N);
                case 'blackman'
                    win = blackman(N);
                case 'kaiser'
                    win = kaiser(N, 5);
                case 'bartlett'
                    win = bartlett(N);
                otherwise
                    error('ecalculator:dsp:unknownWindow', '未知窗函数: %s', win_type);
            end

            % 频谱分析
            N_fft = 1024;
            W = fft(win, N_fft);
            W = W(1:N_fft/2+1);
            f = (0:N_fft/2) / N_fft;
            W_dB = 20*log10(abs(W) / max(abs(W)) + eps);

            % 计算参数
            main_lobe_width = 4/N;  % 主瓣宽度 (近似)
            sidelobe_level = max(W_dB(N_fft/4:end));  % 最大旁瓣电平

            fprintf('📊 窗函数分析 (%s):\n', win_type);
            fprintf('   长度:         %d\n', N);
            fprintf('   主瓣宽度:     %.4f (归一化)\n', main_lobe_width);
            fprintf('   最大旁瓣:     %.2f dB\n', sidelobe_level);

            % 绘图
            figure('Name', sprintf('Window Analysis: %s', win_type));

            subplot(2,1,1);
            plot(win, 'b-', 'LineWidth', 1.5);
            xlabel('Sample');
            ylabel('Amplitude');
            title(sprintf('%s Window (N=%d)', win_type, N));
            grid on;

            subplot(2,1,2);
            plot(f, W_dB, 'b-', 'LineWidth', 1.5);
            xlabel('Normalized Frequency');
            ylabel('Magnitude (dB)');
            title('Frequency Response');
            grid on;
            ylim([-100 5]);

            info.win = win;
            info.main_lobe_width = main_lobe_width;
            info.sidelobe_level = sidelobe_level;
        end

        function info = spectrogram_analysis(x, Fs, varargin)
        %SPECTROGRAM_ANALYSIS 时频分析
        %
        %   ecalculator.dsp.spectrogram_analysis(x, 1000)
        %   ecalculator.dsp.spectrogram_analysis(x, 1000, 'window', 256)

            opts = struct('window', 256, 'overlap', 128, 'nfft', 512);
            for i = 1:2:numel(varargin)
                opts.(varargin{i}) = varargin{i+1};
            end

            % 计算 spectrogram
            [S, F, T] = spectrogram(x, opts.window, opts.overlap, opts.nfft, Fs);

            % 绘图
            figure('Name', 'Spectrogram Analysis');
            imagesc(T, F, 20*log10(abs(S) + eps));
            axis xy;
            xlabel('Time (s)');
            ylabel('Frequency (Hz)');
            title('Spectrogram');
            colorbar;
            colormap('jet');

            info.S = S;
            info.F = F;
            info.T = T;
        end
    end
end
