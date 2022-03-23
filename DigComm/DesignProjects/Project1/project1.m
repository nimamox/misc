% Nima Mohammadi
% Design Project 1

% Note: You need to comment out command the 'figure'
% command inside `EnergySpectralDensity.m` function

%% Load dataset
load DesignProject1
duration = length(Original) / 65536;
%% Plot of original quantization
plot(sort(Original));
title('Approximation of original quantization scheme');
xlabel('Input');
ylabel('Output');

%% Plot time wave
plot(time, Original);
title('Original Signal');
xlabel('Time');
ylabel('Amplitude');

%% Plot ESD (Energy Spectral Density)
EnergySpectralDensity(Original, 65536, [-6000 6000 0 2000000], 0);
figure;
EnergySpectralDensity(Original, 65536, [-6000 6000 -60 1], 1);
ylabel('Magnitude Spectrum (log)')

%% Calculate bandwidth of the original signal
bw_orig = CalculateBandwidth(Original, 65536, 0.999)

%% Plots for each sampling rate
sampling_freq = {2048, 4096, 8192, 16384};
sampled_signals = cell(1, 4);
sampled_bw = cell(1, 4);
plot_sig_orig = Original(65536*2: 65536*2+65536/64-1);
plot_t_orig = linspace(2, 2 + length(plot_sig_orig)/65536, length(plot_sig_orig));

figure;
set(gcf,'position',[0,0,500,1000])
for i = 1:length(sampling_freq)
    sampled_signals{i} = MyResample(Original, sampling_freq{i}, 65536);
    sampled_bw{i} = CalculateBandwidth(sampled_signals{i}, sampling_freq{i}, 0.999);
    subplot(length(sampling_freq), 3, 3*i-2);
    plot_sig = sampled_signals{i}(sampling_freq{i}*2: sampling_freq{i}*2+sampling_freq{i}/64-1);
%     length(plot_sig)
    plot_t = linspace(2, 2 + length(plot_sig)/sampling_freq{i}, length(plot_sig));
    plot(plot_t, plot_sig);
    hold on
    plot(plot_t_orig, plot_sig_orig);
    legend('x(t)', 'x_s(t)');
    xlim([2 plot_t(end)]);
    title(sprintf('f_s=%d', sampling_freq{i}));
    xlabel('Time');
    ylabel('Amplitude');
    
    subplot(length(sampling_freq), 3, 3*i-1);
    EnergySpectralDensity(sampled_signals{i}, sampling_freq{i}, [0 bw_orig -60 1], 1);
    ylabel('Mag Spec')
    title(sprintf('f_s=%d, BW=%.3fHz', sampling_freq{i}, sampled_bw{i}));
    
    subplot(length(sampling_freq), 3, 3*i);
    [Y_tmp, f_tmp] = EnergySpectralDensity(sampled_signals{i}, sampling_freq{i});
    ylabel('Mag Spec')
    title(sprintf('f_s=%d, BW=%.3fHz', sampling_freq{i}, sampled_bw{i}));
    ylim([0 max(abs(abs(Y_tmp).^2))]);
    tmp = xlim;
    xlim([0 tmp(2)]);
end

%% Listening to sampled signals
i = 3; % change i from 1 to 4 to hear different SRs
sound(sampled_signals{i}, sampling_freq{i})
% sound(Original, 65536);

%% Calculate SNR for sampled signals
sampled_snr = cell(1, 4);
for i = 1:length(sampling_freq)
    sampled_snr{i} = snr(Original, Original-interp(sampled_signals{i}, 65536/sampling_freq{i}));
end
sampled_snr

%% Plots different uniform quantizations
quant_levels = {2, 8, 32, 128, 512, 1024};
x = -1:.0001:1;
figure;
for i = 1:length(quant_levels)
    subplot(length(quant_levels)/3, 3, i)
    plot(x, uniformquantize(x, quant_levels{i}));
    title(sprintf('Uniform Quant levels=%.0f', quant_levels{i}))
end

%% Quantization 
quant_signals = cell(1, 6);
figure;
for i = 1:length(quant_levels)
    subplot(length(quant_levels)/3, 3, i)
    quant_signals{i} = uniformquantize(Original, quant_levels{i});
    plot(time, quant_signals{i});
    title(sprintf('Uniform Quant levels=%.0f', quant_levels{i}))
    xlabel('Time');
    ylabel('Amplitude');
end

%% Listening to quantized signals
i = 6; % change i from 1 to 6 to hear different quantizations
sound(quant_signals{i}, 65536)
% sound(Original, 65536);

%% Calculate SNR for quantized signals
quants_snr = cell(1, 6);
theoretical_snr = cell(1, 6);
for i = 1:length(quant_levels)
    quants_snr{i} = snr(Original, Original-quant_signals{i});
    bits = log(quant_levels{i}) / log(2);
    theoretical_snr{i} = 1.8 + 6 * bits;
end
quants_snr
theoretical_snr

%% Plotting Quantization Errors
quant_signals_noise = cell(1, 6);
figure;
for i = 1:length(quant_levels)
    subplot(length(quant_levels)/3, 3, i)
    quant_signals_noise{i} = Original - quant_signals{i};
    plot(time(65536:65536*1.01), quant_signals_noise{i}(65536:65536*1.01));
    ylim([-.5 .5]);
    title(sprintf('Uniform Quant levels=%.0f', quant_levels{i}))
    xlabel('Time');
    ylabel('Error Amplitude');
end

%% Uniform Quantization with Amplifier Gain Control
figure;
x = MyResample(Original, 8192);
% sound(x, 8192);
y = uniformquantize(x, 16);
y_err = Original-interp(y, 65536/8192);
snr(Original, y_err)
subplot(3, 1, 1);
plot(time(65536:65536*1.01), y_err(65536:65536*1.01))
title('Q(x, 4)');
ylim([-.2 .2])
% sound(y, 8192);
z = 2*uniformquantize(.5*x, 16);
z_err = Original-interp(z, 65536/8192);
snr(Original, z_err)
subplot(3, 1, 2);
plot(time(65536:65536*1.01), z_err(65536:65536*1.01))
title('2Q(.5x, 4)');
ylim([-.2 .2])
% sound(z, 8192);
w = .2*uniformquantize(5*x, 16);
w_err = Original-interp(w, 65536/8192);
snr(Original, w_err)
subplot(3, 1, 3);
plot(time(65536:65536*1.01), w_err(65536:65536*1.01))
title('.2Q(5x, 4)');
ylim([-.2 .2])
% sound(w, 8192);

%% Plotting mu-law Nonuniform Quantization
figure;
plot(-1:.0001:1, expand(uniformquantize(compress(-1:.0001:1, 255), 16), 255));
xlabel('Input');
ylabel('Output');
title('Nonlinear Quantization w/ \mu=255');

%% Nonuniform quantization of signal using mu-law
figure;
x = MyResample(Original, 8192);
y = compress(x, 255);
x_q = uniformquantize(x, 16);
y_q = uniformquantize(y, 16);
z = expand(y_q, 255);
% sound(x_q, 8192);
% sound(z, 8192);

x_err = Original-interp(x_q, 65536/8192);
snr(Original, x_err)
subplot(2, 1, 1);
plot(time(65536:65536*1.01), x_err(65536:65536*1.01))
title('UQ(x, 4)');
ylim([-.11 .11])

z_err = Original-interp(z, 65536/8192);
snr(Original, z_err)
subplot(2, 1, 2);
plot(time(65536:65536*1.01), z_err(65536:65536*1.01))
title('NUQ(x, 4, 255)');
ylim([-.11 .11])