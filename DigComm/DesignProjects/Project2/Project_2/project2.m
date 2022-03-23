% Nima Mohammadi
% Design Project 2

% As mentioned in the accompanied report, I have modified PhaseMod.m and
% PhaseDemod.m files to fix a bug in these files

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

%% Constellation plots w/ and w/o noise
mods = {'BPSK', 'BPSK(GRAY)', 'QPSK', 'QPSK(GRAY)', '8PSK', '8PSK(GRAY)',...
    '16PSK', '16PSK(GRAY)', '16QAM'};
bps_mods = {1, 1, 2, 2, 3, 3, 4, 4, 4};
tx_sigs = cell(1, 9);
rx_sigs = cell(1, 9);

set(gcf,'PaperSize',[14 15]); 
set(gcf,'position',[0 0 550 1000]);

for i = 1:length(mods)
    wo_noise = reshape(de2bi(0:63, 'left-msb')', [], 1);
    labels = string(bi2de(reshape(wo_noise, bps_mods{i}, [])', 'left-msb'));
    if i < 9 % Phase modulations
        % Transmitter modulation
        tx_sigs{i} = PhaseMod(inpsig, bps_mods{i}, mod(i+1, 2));
        wo_noise_mod = PhaseMod(wo_noise, bps_mods{i}, mod(i+1, 2));
        
    else % 16QAM
        % Transmitter modulation
        tx_sigs{i} = QAM16_mod(inpsig);
        wo_noise_mod = QAM16_mod(wo_noise);
    end
    % Passing through AWGN channel with SNR per bit of 7.5dB
    rng(1,'philox');
    rx_sigs{i} = AddNoise(tx_sigs{i}, 5.62, bps_mods{i});

    subplot(5, 2, i);
    scatter(real(rx_sigs{i}), imag(rx_sigs{i}), 'b.',...
        'MarkerFaceAlpha', .1,'MarkerEdgeAlpha', .1)
    hold on;
    plot(real(tx_sigs{i}), imag(tx_sigs{i}),'r.',...
        'markers', 40, 'LineWidth', 3)

    plot(real(wo_noise_mod), imag(wo_noise_mod),...
        'r.', 'markers', 45, 'LineWidth', 3)
    if i < 9
        text(real(wo_noise_mod)-.06, imag(wo_noise_mod), labels);
    end

    ylim([-1.75 1.75]);
    xlim([-1.75 1.75]);
    hold off;
    title(mods{i});
end
saveas(gcf, 'plot1_constellations.pdf')

%% Demodulation
demod_sigs = cell(1, 9);
demod_sigs_analog = cell(1, 9);

for i = 1:length(mods)
    if i < 9 %Phase modulations
        demod_sigs{i} = PhaseDemod(rx_sigs{i}, bps_mods{i}, mod(i+1, 2));
        demod_sigs_analog{i} = Digital2Analog(demod_sigs{i}, bits, 1, 255);
    else % 16QAM
        demod_sigs{i} = QAM16_demod(rx_sigs{i})';
        demod_sigs_analog{i} = Digital2Analog(demod_sigs{i}, bits, 1, 255);
    end
end

%% Calculate SNRs
mod_SNR = cell(1, 9);
fprintf('%15s \t%s\n', 'Mod', 'SNR');
for i = 1:length(mods)
    mod_SNR{i} = snr(Original',...
        Original'-interp(demod_sigs_analog{i}, 65536/fs));
    fprintf('%15s \t%f\n', mods{i}, mod_SNR{i});
end
fprintf('----------\n');

%% Calculate MSEs
mod_MSE = cell(1, 9);
fprintf('%15s \t%s\n', 'Mod', 'MSE');
for i = 1:length(mods)
    mod_MSE{i} = immse(Original', interp(demod_sigs_analog{i}, 65536/fs));
    fprintf('%15s \t%f\n', mods{i}, mod_MSE{i});
end
fprintf('----------\n');

%% Calculate BERs
mod_BER = cell(1, 9);

fprintf('%15s \t%s\n', 'Mod', 'BER');
for i = 1:length(mods)
    [num, ratio] = biterr(inpsig, demod_sigs{i});
    mod_BER{i} = ratio;
    fprintf('%15s \t%f\n', mods{i}, mod_BER{i});
end
fprintf('----------\n');

%% Listening to received signals
i = 1; % change i from 1 to 9
sound(demod_sigs_analog{6}, fs)
% sound(outsig, fs);

%% Constellation plots for misidentified points

set(gcf,'PaperSize',[14 15]); 
set(gcf,'position',[0 0 550 1000]);
for i = 1:length(mods)
    subplot(5, 2, i);
    errs = bi2de(reshape(demod_sigs{i},...
        bps_mods{i}, [])') ~= bi2de(reshape(inpsig, bps_mods{i}, [])');
    scatter(real(rx_sigs{i}), imag(rx_sigs{i}), 'b.',...
        'MarkerFaceAlpha', .2,'MarkerEdgeAlpha', .2)
    hold on;
    scatter(real(rx_sigs{i}(errs)), imag(rx_sigs{i}(errs)),...
        'r.', 'MarkerFaceAlpha', .3,'MarkerEdgeAlpha', .3)
    title(sprintf("%s BER=%.5f, #Errs= %d", mods{i}, mod_BER{i}, sum(errs)))
    ylim([-1.75 1.75]);
    xlim([-1.75 1.75]);
    hold off;
end
saveas(gcf,'plot2_constellations-misclassified.pdf')

%% Calculate theoretical BW requirements
bw_theoretical_mods = cell(1, 9);
r = .25;
fprintf('%15s \t%s\n', 'Mod', 'Theoretical BW');
for i = 1:2:length(mods)
    bw_theoretical_mods{i} = (1+r) * bits * fs / bps_mods{i};
    fprintf('%15s \t%d\n', mods{i}, bw_theoretical_mods{i});
end
fprintf('----------\n');

%% Plot time waves and ESD
dd = 16;

begin_orig = 65536*2;
end_orig = begin_orig + 65536/dd-1;

begin_sigs = fs*2;
end_sigs = begin_sigs + fs/dd-1;

begin_orig_t = 2;
end_orig_t = begin_orig_t + (end_orig - begin_orig) / 65536;

slice_orig = Original(begin_orig: end_orig);

t_orig = linspace(begin_orig_t, end_orig_t, 65536/dd);
t_sig = linspace(begin_orig_t, end_orig_t, fs/dd);


set(gcf,'PaperSize',[20 12]); 
set(gcf,'position',[0,0,730,1000])

jj = 1;
for i = 1:2:length(mods)
    subplot(5, 4, [jj jj+1]);
    slice_sig = demod_sigs_analog{i}(begin_sigs: end_sigs);
    lh1 = plot(t_orig, slice_orig, 'b', 'LineWidth', 4);
    lh1.Color = [0,0,1,0.9];
    hold on
    lh2 = plot(t_sig, slice_sig, 'r', 'LineWidth', 2);
    lh2.Color = [1,0,0,0.9];
    xlim([begin_orig_t, end_orig_t])
    ylim([-.6 .5])
    title(mods{i});
    lgd = legend('orig', 'received');
    lgd.FontSize = 6;
    
    subplot(5, 4, jj+2);
    EnergySpectralDensity(tx_sigs{i}(1:10000),...
        bw_theoretical_mods{i}, [0 30000 0 100000], 0);
    ylabel('Mag Spec');
    
    subplot(5, 4, jj+3);
    EnergySpectralDensity(tx_sigs{i}(1:10000),...
        2*bw_theoretical_mods{i}, [0 bw_theoretical_mods{i} -60 0], 1);
    ylabel('Mag Spec');
    jj = jj + 4;
end
saveas(gcf,'plot3_esd.pdf')

