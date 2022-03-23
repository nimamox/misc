% Nima Mohammadi
% Design Project 3

clc
clear

%% Load dataset
load DesignProject1
duration = length(Original) / 65536;

%% Sampling and Quantization ~> bitstream
bits = 6;
fs = 8192;
inpsig = Analog2Digital(Original, fs, bits, 1, 255, 65536);
outsig = Digital2Analog(inpsig, bits, 1, 255);
% sound(outsig, fs);
sig_bpsk = PhaseMod(inpsig, 1, 0); %BPSK

% 1st Part) Pulse Shaping
%% Pulse Shaping
NS = 10;
N = 10;
roll_off = .25;

pulse_shapes = {'SQAR',... % Square Pulse
                'SINC',... % Sinc Pulse
                'RaCo',... % Raised Cosine
                'SRRC',... % Square Root Raised Cosine
                };
pulse_captions = {'Square Pulse',...
                  'Sinc Pulse',...
                  'Raised Cosine',...
                  'Square Root Raised Cosine'...
                  };
              
sigs_ps = cell(1, length(pulse_shapes));
pulse_ps = cell(1, length(pulse_shapes));
Es_ps = cell(1, length(pulse_shapes));

for i = 1:length(pulse_shapes)
    [sig_pulseshape, pulse, Es] = PulseShape(sig_bpsk, pulse_shapes{i},...
        NS, N, roll_off);
    sigs_ps{i} = sig_pulseshape;
    pulse_ps{i} = pulse;
    Es_ps{i} = Es;
end

%% Plot Signals

set(gcf,'PaperSize',[12 5]); 
set(gcf,'position',[0 0 1000 360]);

for i = 1:length(pulse_shapes)
    subplot(length(pulse_shapes), 1, i);
    if i == 1
        dd = N-1;
        ddd = 1;
    else
        dd = N * NS / 2;
        ddd = 5;
    end
    plot(1+dd:451+dd, sqrt(Es_ps{i})*sigs_ps{i}(1+dd:451+dd),'LineWidth',2);
    hold on;
    stem(1+dd+ddd:10:451+dd+ddd, sqrt(Es_ps{i})*sigs_ps{i}(1+dd:10:451+dd))
    title(pulse_captions{i})
    xlim([1+dd 451+dd])
end
saveas(gcf, 'plot1.pdf')

%% Plot ESDs and calculate first-null BW
clc;
set(gcf,'PaperSize',[9 10]); 
set(gcf,'position',[0 0 700 1000]);
for i = 1:length(pulse_shapes)
    subplot(length(pulse_shapes), 2, (i-1)*2+1);
    [Y, f] = EnergySpectralDensity([pulse_ps{i}, zeros(1,1000)], 8192);
    Y1 = abs(Y).^2;
    maximas = islocalmax(Y1);
    ylabel('Magnitude')
    title(pulse_captions{i})
    bw = CalculateBandwidth([pulse_ps{i}, zeros(1, 1000)], 8192, .99999);
    ind50dB_start = find(f > -bw, 1);
    ind50dB_end   = find(f > bw, 1);
    
    subplot(length(pulse_shapes), 2, (i-1)*2+2);
    EnergySpectralDensity([pulse_ps{i}, zeros(1,1000)], 8192, [-6000 6000 -100 20],1 );
    hold on;
    Y2 = 20*log10(abs(Y)/max(abs(Y)));
    
    maximas2 = Y2(maximas) < -5;
    ind1stLobe = find(maximas2(1:end-1) - maximas2(2:end) == -1)+1;
    tmp1 = find(maximas==1, ind1stLobe, 'first');
    ind1stLobe = tmp1(end);
    
    minimas = islocalmin(Y2);
    ind1stNull = find(minimas(1:ind1stLobe), 1, 'last');
    
    if i == 1
        plot(f(ind1stNull), Y2(ind1stNull+1), 'r*');
    else
        plot(f(ind1stNull), Y2(ind1stNull), 'r*');
    end
    plot(f(ind1stLobe), Y2(ind1stLobe), 'b*');
    ylabel('Magnitude dB')
    title(pulse_captions{i})
    
    fprintf("%s 50db-BW: %.2f \t null-bw:%.2f \t dB-down:%.2f\n",...
        pulse_shapes{i}, bw, f(ind1stNull), Y2(ind1stNull));
end
saveas(gcf, 'plot2.pdf')

%% Raised Cosine - Impact of N and r
NS = 10;
ps_raco = {'SINC', 'RaCo', 'RaCo', 'SINC', 'RaCo', 'RaCo'};
sigs_raco_N = [5, 5, 5, 10, 10, 10];
sigs_raco_r = [0 .25, .75, 0 .25, .75];

sigs_raco = cell(1, length(ps_raco));
pulse_raco = cell(1, length(ps_raco));
Es_raco = cell(1, length(ps_raco));
pulse_raco_cap = cell(1, length(ps_raco));

for i = 1:length(ps_raco)
    [sig_pulseshape, pulse, Es] = PulseShape(sig_bpsk, ps_raco{i},...
        NS, sigs_raco_N(i), sigs_raco_r(i));
    sigs_raco{i} = sig_pulseshape;
    pulse_raco{i} = pulse;
    Es_raco{i} = Es;
end

%% Calculate first-null BW and 50dB BW for SINC and RaCo w/ different N &r
clc;
set(gcf,'PaperSize',[9 10]); 
set(gcf,'position',[0 0 700 1000]);
for i=1:length(ps_raco)
    if ps_raco{i}=='SINC'
        caption = sprintf('%s N=%d', ps_raco{i}, sigs_raco_N(i));
    else
        caption = sprintf('%s N=%d, r=%.2f', ps_raco{i}, sigs_raco_N(i), sigs_raco_r(i));
    end
    subplot(length(ps_raco), 3, (i-1)*3+1);
    plot(1:length(pulse_raco{i}), pulse_raco{i});
    title(caption);
    
    subplot(length(ps_raco), 3, (i-1)*3+2);
    [Y, f] = EnergySpectralDensity([pulse_raco{i}, zeros(1,1000)], 8192);
    Y1 = abs(Y).^2;
    maximas = islocalmax(Y1);
    ylabel('Magnitude')
    title(pulse_raco_cap{i})
    bw = CalculateBandwidth([pulse_raco{i}, zeros(1, 1000)], 8192, .99999);
    ind50dB_start = find(f > -bw, 1);
    ind50dB_end   = find(f > bw, 1);
    title(caption);
    
    subplot(length(ps_raco), 3, (i-1)*3+3);
    EnergySpectralDensity([pulse_raco{i}, zeros(1,1000)], 8192, [-4000 4000 -100 20],1 );
    hold on;
    Y2 = 20*log10(abs(Y)/max(abs(Y)));
    
    maximas2 = Y2(maximas) < -5;
    ind1stLobe = find(maximas2(1:end-1) - maximas2(2:end) == -1)+1;
    tmp1 = find(maximas==1, ind1stLobe, 'first');
    ind1stLobe = tmp1(end);
    
    minimas = islocalmin(Y2);
    ind1stNull = find(minimas(1:ind1stLobe), 1, 'last');
    
    plot(f(ind1stNull), Y2(ind1stNull), 'r*');
    plot(f(ind1stLobe), Y2(ind1stLobe), 'b*');
    
    ylabel('Magnitude dB')
    title(caption);
    
    fprintf("%s 50db-BW: %.2f \t null-bw:%.2f \t dB-down:%.2f\n",...
        ps_raco{i}, bw, f(ind1stNull), Y2(ind1stLobe));
end
saveas(gcf, 'plot3.pdf')

% 2nd Part) Matched Filtering
%% Adding noise - Matched Filtering

clc;
set(gcf,'PaperSize',[18 12]); 
set(gcf,'position',[0 0 1300 900]);

% sigs_MF = cell(1, length(pulse_shapes));
sig_bpsk_noisy = AddNoise(sig_bpsk, 5.62, 1);
sig_bpsk_demod_noisy = PhaseDemod(sig_bpsk_noisy, 1, 0);
[~, berr] = biterr(inpsig, sig_bpsk_demod_noisy);
noisy_analog_sig = cell(1, length(pulse_shapes));
noisy_analog_sig_wo_mf = cell(1, length(pulse_shapes));

for i = 1:length(pulse_shapes)
    if i == 1
        dd = N-1;
    else
        dd = N * NS / 2;
    end

    [sig_pulseshape, pulse, Es] = PulseShape(sig_bpsk, pulse_shapes{i},...
        NS, N, roll_off);
    orig_sig = sig_pulseshape;
    noisy_sig = AddNoise(sig_pulseshape, 5.62, 1);
    
    orig_mf = conv(orig_sig, pulse);
    noisy_mf = conv(noisy_sig, pulse);
    
    % Orig signal
    subplot(length(pulse_shapes), 2, (i-1)*2+1);
    h1 = plot(1:350, orig_mf(1:350), 'DisplayName', 'Befor Conv',...
        'LineWidth', 1.1);
    hold on;
    h2 = plot(1+dd:350+dd, orig_mf(1+dd:350+dd), '--', 'DisplayName', 'After Conv',...
        'LineWidth', 1.6);
    
    hold on;
    demod_mf = PhaseDemod(orig_mf(1+dd:10:end), 1, 0);
    if i > 1
        demod_mf = demod_mf(6:length(inpsig)+6);
    end
    [~, berr] = biterr(inpsig, demod_mf(1:length(inpsig)));
    title(sprintf('%s w/o noise BER:%.5f', pulse_shapes{i}, berr));
    
    h3 = stem((1+dd+5:10:355+dd), demod_mf(1:35), 'k', 'DisplayName', 'Rx Bitstream');
    h4 = patch([0 dd dd 0], [-5 -5 5 5], [17 17 17]/255);
    alpha(.2);
    legend([h1 h2 h3]);
    ylim([-1.6 2.5])
    
    % Noisy signal
    subplot(length(pulse_shapes), 2, (i-1)*2+2);
    h1 = plot(1:350, noisy_sig(1:350), 'DisplayName', 'Befor Conv',...
        'LineWidth', 1.1);
    hold on;
    h2 = plot(1+dd:350+dd, noisy_mf(1+dd:350+dd), '--', 'DisplayName', 'After Conv',...
        'LineWidth', 1.6);
    hold on;
    
    % Optimal Sampling
    demod_mf = PhaseDemod(noisy_mf(1+dd:10:end), 1, 0);
    if i > 1
        demod_mf = demod_mf(6:end);
    end
    demod_mf = demod_mf(1:length(inpsig));
    [~, berr] = biterr(inpsig, demod_mf);
    noisy_analog_sig{i} = Digital2Analog(demod_mf, bits, 1, 255);
    analog_snr = snr(Original', Original'-interp(noisy_analog_sig{i}, 65536/fs));
    
    title(sprintf('%s w/ noise BER:%.5f SNR:%.3f', pulse_shapes{i}, berr, analog_snr));
    h3 = stem((1+dd+5:10:355+dd), demod_mf(1:35), 'k', 'DisplayName', 'Rx Bitstream');
    h4 = patch([0 dd dd 0], [-5 -5 5 5], [17 17 17]/255);
    alpha(.2);
    legend([h1 h2 h3]);
    ylim([-1.6 2.5])
    
    fprintf('%s (opt) w/ noise\t BER:%.5f SNR:%.3f \n', pulse_shapes{i}, berr, analog_snr);
    
    % Without matched filtering
    demod_wo_mf = PhaseDemod(noisy_sig(1+dd:10:end), 1, 0);
    demod_wo_mf = demod_wo_mf(1:length(inpsig));
    [~, berr] = biterr(inpsig, demod_wo_mf);
    noisy_analog_sig_wo_mf{i} = Digital2Analog(demod_wo_mf, bits, 1, 255);
    analog_snr = snr(Original', Original'-interp(noisy_analog_sig_wo_mf{i}, 65536/fs));
    
    fprintf('%s (opt) w/o MF\t BER:%.5f SNR:%.3f \n', pulse_shapes{i}, berr, analog_snr);
    
    % Nonoptimal sampling
    demod_mf = PhaseDemod(noisy_mf(1+dd-1:10:end-1), 1, 0);
    if i > 1
        demod_mf = demod_mf(6:end);
    end
    demod_mf = demod_mf(1:length(inpsig));
    [~, berr] = biterr(inpsig, demod_mf);
    noisy_analog_nonopt = Digital2Analog(demod_mf, bits, 1, 255);
    analog_snr = snr(Original', Original'-interp(noisy_analog_nonopt, 65536/fs));
    
    fprintf('%s (nonopt) w/ noise\t BER:%.5f SNR:%.3f \n', pulse_shapes{i}, berr, analog_snr);
    
end
saveas(gcf, 'plot4.pdf')

%% Listen to received analog signals
sound(noisy_analog_sig{4}, fs);
% sound(noisy_analog_sig_wo_mf{1}, fs);


% 3rd Part) Fading
%% Without Fading
sig_bpsk_noisy = AddNoise(sig_bpsk, 5.62, 1);
b_hat_bpsk_noisy = PhaseDemod(sig_bpsk_noisy, 1);
[~, berr] = biterr(inpsig, b_hat_bpsk_noisy);
analog_bpsk_noisy = Digital2Analog(b_hat_bpsk_noisy, bits, 1, 255);
analog_snr_bpsk = snr(Original', Original'-interp(analog_bpsk_noisy, 65536/fs));
sound(analog_bpsk_noisy, fs);

%% With fading
clc;
fading_types = {'RAYL', 'RAYL', 'RICE', 'RICE', 'RICE'};
analog_faded = cell(1, length(fading_types));
dopper_shifts = [200 10 200 200 200];
k_factors = [0 0 1 10 100];
for i=1:length(fading_types)
    doppler_rate = dopper_shifts(i)/fs;
    [faded_sig, channel] = FadingChannel(sig_bpsk, fading_types{i},...
        doppler_rate, k_factors(i));
    rx_sig = AddNoise(faded_sig, 5.62, 1);
    z = conj(channel) .* rx_sig;
    b_hat_faded = PhaseDemod(z, 1);
    [~, berr] = biterr(inpsig, b_hat_faded);
    analog_faded{i} = Digital2Analog(b_hat_faded, bits, 1, 255);
    analog_snr_faded = snr(Original', Original'-interp(analog_faded{i}, 65536/fs));
    
    subplot(length(fading_types), 1, i);
    semilogy(1:fs, sqrt(channel(1:fs).^2));
    ylabel('Semilog Ch. Amp.');
    xlabel('Time');
    xlim([1 fs]);
    
    if fading_types{i} == 'RAYL'
        fprintf('%s DopplerShift=%d    \tBER: %.4f, SNR: %.4f\n',...
            'Rayleigh', dopper_shifts(i), berr, analog_snr_faded);
        title(sprintf('%s DopplerShift=%d',...
            'Rayleigh', dopper_shifts(i)));
    else
        fprintf('%s DopplerShift=%d, K=%d\tBER: %.4f, SNR: %.4f\n',...
            'Ricean', dopper_shifts(i), k_factors(i), berr, analog_snr_faded);
        title(sprintf('%s DopplerShift=%d, K=%d',...
            'Ricean', dopper_shifts(i), k_factors(i)));
    end
end

%% Listen to received signals
sound(analog_faded{1}, fs);

