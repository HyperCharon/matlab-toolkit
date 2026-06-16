classdef communications
%ECALCULATOR.COMMUNICATIONS 通信工程计算器
%
%   ecalculator.communications.snr_db(S, N)                信噪比 (dB)
%   ecalculator.communications.ebno_to_snr(EbN0, M, rate)  Eb/N0 转 SNR
%   ecalculator.communications.ber_bpsk(EbN0)              BPSK BER
%   ecalculator.communications.ber_qam(EbN0, M)            M-QAM BER
%   ecalculator.communications.link_budget(Pt, Gt, Gr, L, d, f)  链路预算
%   ecalculator.communications.channel_capacity(SNR, BW)   信道容量
%   ecalculator.communications.fresnel_zone(d1, d2, f, n)  菲涅尔区
%   ecalculator.communications.doppler_shift(v, f, theta)  多普勒频移
%
%   See also ecalculator.signal, ecalculator.circuit

    methods(Static)
        function val = snr_db(S, N)
        %SNR_DB 信噪比 (dB)
        %
        %   ecalculator.communications.snr_db(100, 1)

            val = 10*log10(S/N);
            fprintf('📡 信噪比:\n');
            fprintf('   信号功率: %.4f\n', S);
            fprintf('   噪声功率: %.4f\n', N);
            fprintf('   SNR:      %.2f dB\n', val);
        end

        function val = ebno_to_snr(EbN0_dB, M, code_rate)
        %EBNO_TO_SNR Eb/N0 转 SNR
        %
        %   ecalculator.communications.ebno_to_snr(10, 4, 0.5)

            if nargin < 3, code_rate = 1; end
            if nargin < 2, M = 2; end

            k = log2(M);
            val = EbN0_dB + 10*log10(k * code_rate);

            fprintf('📊 Eb/N0 → SNR 转换:\n');
            fprintf('   Eb/N0:      %.2f dB\n', EbN0_dB);
            fprintf('   调制阶数:   %d (%s)\n', M, get_mod_order(M));
            fprintf('   编码率:     %.2f\n', code_rate);
            fprintf('   SNR:        %.2f dB\n', val);
        end

        function val = ber_bpsk(EbN0_dB)
        %BER_BPSK BPSK 误码率
        %
        %   ecalculator.communications.ber_bpsk(10)

            EbN0 = 10.^(EbN0_dB/10);
            val = 0.5 * erfc(sqrt(EbN0));

            fprintf('📊 BPSK 误码率:\n');
            fprintf('   Eb/N0: %.2f dB\n', EbN0_dB);
            fprintf('   BER:   %.2e\n', val);
        end

        function val = ber_qam(EbN0_dB, M)
        %BER_QAM M-QAM 误码率
        %
        %   ecalculator.communications.ber_qam(10, 16)

            if nargin < 2, M = 16; end

            k = log2(M);
            EbN0 = 10.^(EbN0_dB/10);
            SNR = EbN0 * k;

            % 近似公式
            val = (4/k) * (1 - 1/sqrt(M)) * erfc(sqrt(3*SNR/(2*(M-1))));

            fprintf('📊 %d-QAM 误码率:\n', M);
            fprintf('   Eb/N0:   %.2f dB\n', EbN0_dB);
            fprintf('   SNR:     %.2f dB\n', 10*log10(SNR));
            fprintf('   BER:     %.2e\n', val);
        end

        function val = link_budget(Pt_dBm, Gt_dBi, Gr_dBi, L_dB, d_m, f_Hz)
        %LINK_BUDGET 链路预算
        %
        %   ecalculator.communications.link_budget(20, 10, 10, 3, 1000, 2.4e9)

            c = 3e8;
            lambda = c / f_Hz;

            % 自由空间损耗
            Lfs = 20*log10(4*pi*d_m/lambda);

            % 接收功率
            Pr_dBm = Pt_dBm + Gt_dBi + Gr_dBi - Lfs - L_dB;

            fprintf('📡 链路预算:\n');
            fprintf('   发射功率:   %.2f dBm\n', Pt_dBm);
            fprintf('   发射增益:   %.2f dBi\n', Gt_dBi);
            fprintf('   接收增益:   %.2f dBi\n', Gr_dBi);
            fprintf('   附加损耗:   %.2f dB\n', L_dB);
            fprintf('   距离:       %.2f m\n', d_m);
            fprintf('   频率:       %.2f MHz\n', f_Hz/1e6);
            fprintf('   波长:       %.4f m\n', lambda);
            fprintf('   自由空间损耗: %.2f dB\n', Lfs);
            fprintf('   接收功率:   %.2f dBm\n', Pr_dBm);

            val = Pr_dBm;
        end

        function val = channel_capacity(SNR_dB, BW_Hz)
        %CHANNEL_CAPACITY 信道容量 (Shannon)
        %
        %   ecalculator.communications.channel_capacity(20, 10e6)

            SNR = 10^(SNR_dB/10);
            val = BW_Hz * log2(1 + SNR);

            fprintf('📊 Shannon 信道容量:\n');
            fprintf('   带宽:   %.2f MHz\n', BW_Hz/1e6);
            fprintf('   SNR:    %.2f dB\n', SNR_dB);
            fprintf('   容量:   %.2f Mbps\n', val/1e6);
        end

        function val = fresnel_zone(d1_m, d2_m, f_Hz, n)
        %FRESNEL_ZONE 菲涅尔区半径
        %
        %   ecalculator.communications.fresnel_zone(1000, 1000, 2.4e9, 1)

            if nargin < 4, n = 1; end

            c = 3e8;
            lambda = c / f_Hz;
            d = d1_m + d2_m;

            val = sqrt(n * lambda * d1_m * d2_m / d);

            fprintf('📡 菲涅尔区:\n');
            fprintf('   频率:     %.2f MHz\n', f_Hz/1e6);
            fprintf('   距离 1:   %.2f m\n', d1_m);
            fprintf('   距离 2:   %.2f m\n', d2_m);
            fprintf('   第 %d 菲涅尔区半径: %.2f m\n', n, val);
        end

        function val = doppler_shift(v_ms, f_Hz, theta)
        %DOPPLER_SHIFT 多普勒频移
        %
        %   ecalculator.communications.doppler_shift(30, 2.4e9, 0)

            if nargin < 3, theta = 0; end

            c = 3e8;
            val = v_ms * f_Hz * cos(theta) / c;

            fprintf('📡 多普勒频移:\n');
            fprintf('   速度:   %.2f m/s (%.2f km/h)\n', v_ms, v_ms*3.6);
            fprintf('   频率:   %.2f MHz\n', f_Hz/1e6);
            fprintf('   角度:   %.2f°\n', theta*180/pi);
            fprintf('   频移:   %.2f Hz\n', val);
        end
    end
end

function name = get_mod_order(M)
    switch M
        case 2, name = 'BPSK';
        case 4, name = 'QPSK';
        case 8, name = '8-PSK';
        case 16, name = '16-QAM';
        case 64, name = '64-QAM';
        case 256, name = '256-QAM';
        otherwise, name = sprintf('%d-QAM', M);
    end
end
