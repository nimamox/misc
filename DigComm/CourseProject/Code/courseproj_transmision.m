%% OFDM-QAM over AWGN and Rayleigh channels
clc;
clear;
load inpsig;

M = 16;                 % Modulation alphabet
k = log2(M);           % Bits/symbol
numSC = 128;           % Number of OFDM subcarriers
cpLen = 32;            % OFDM cyclic prefix length

ofdmMod = comm.OFDMModulator('FFTLength', numSC, 'CyclicPrefixLength', cpLen);
ofdmDemod = comm.OFDMDemodulator('FFTLength', numSC, 'CyclicPrefixLength', cpLen);

ofdmDims = info(ofdmMod);
numDC = ofdmDims.DataInputSize(1);


rayleighChannel = comm.RayleighChannel;
rayleighChannel.PathGainsOutputPort = true;


awgnChannel = comm.AWGNChannel('NoiseMethod','Variance', 'VarianceSource','Input port');

EbNoVec = (0:10)';
snrVec = EbNoVec + 10*log10(k) + 10*log10(numDC/numSC);

BERqamOFDM = zeros(length(EbNoVec), 1);
BERqamOFDMfaded = zeros(length(EbNoVec), 1);

orig_msg_length = length(inpsig);
framesize = numDC*k;
nFrames = ceil(orig_msg_length / framesize);
paded_inpsig = inpsig;
paded_inpsig(end:nFrames * framesize) = 0;

rxBits = zeros([length(paded_inpsig), 1]);
rxBitsFaded = zeros([length(paded_inpsig), 1]);

fadings = zeros([(numSC + cpLen) * nFrames 1]);
ofdm_sig = zeros([(numSC + cpLen) * nFrames 1]);
qam_sig = zeros([(numDC) * nFrames 1]);

for m = 1:length(EbNoVec)
    for j=1:nFrames
        frame = paded_inpsig((j-1)*framesize+1:j*framesize);
        qamTx = qammod(frame, M, 'InputType', 'bit', 'UnitAveragePower', true);
        qamOfdmTx = ofdmMod(qamTx);
        
        [qamFadedSig pathGains] = rayleighChannel(qamOfdmTx);
        
        fadings((numSC + cpLen)*(j-1)+1:(numSC + cpLen)*j) = pathGains;
        qam_sig((numDC)*(j-1)+1:(numDC)*j) = qamTx;
        ofdm_sig((numSC + cpLen)*(j-1)+1:(numSC + cpLen)*j) = qamOfdmTx;
        
        powerDB = 10*log10(var(qamOfdmTx));
        noiseVar = 10.^(0.1*(powerDB-snrVec(m)));
        
        qamRxFadedNoisy = awgnChannel(qamFadedSig, noiseVar);
        qamRxNoisy = awgnChannel(qamOfdmTx, noiseVar);
        
        qamRxNoisyEq = qamRxFadedNoisy./sum(pathGains, 2);
        
        qamOfdmRxFaded = ofdmDemod(qamRxNoisyEq);
        qamOfdmRx = ofdmDemod(qamRxNoisy);
        
        qamRxFaded = qamdemod(qamOfdmRxFaded, M, 'OutputType', 'bit', 'UnitAveragePower', true);
        qamRx = qamdemod(qamOfdmRx, M, 'OutputType', 'bit', 'UnitAveragePower', true);
        
        rxBitsFaded((j-1)*framesize+1:j*framesize)  = qamRxFaded;
        rxBits((j-1)*framesize+1:j*framesize)  = qamRx;
    end
    [~, ratio] = biterr(inpsig, rxBitsFaded(1:length(inpsig)))
    BERqamOFDMfaded(m) = ratio;
    [~, ratio] = biterr(inpsig, rxBits(1:length(inpsig)))
    BERqamOFDM(m) = ratio;
end

%% Plot ESD
subplot(1, 2, 1);
EnergySpectralDensity(qam_sig, 65536, [0 33000 -70 0], 1);
title('16QAM');
subplot(1, 2, 2);
EnergySpectralDensity(ofdm_sig, 65536, [0 33000 -70 0], 1);
title('16QAM-OFDM');

%% Plot Channel Amplitude
ll = numSC + cpLen;
ff = 140;
semilogy((1:ll*ff) * 117 / ll / 16384, sqrt(fadings(1:ll*ff).^2));
ylabel('Semilog Ch. Amp.');
xlabel('Time (s)');

%% Semilog SNR-BER plots
close all;
semilogy(EbNoVec, BERqamOFDMfaded, 'r*');
hold on;
semilogy(EbNoVec, BERqamOFDM, 'b*');
grid on;
hold on;
berTheoryQamFading = berfading(EbNoVec,'qam', M, 1);
semilogy(EbNoVec, berTheoryQamFading, 'r--');
hold on;
berTheoryQamAwgn = berawgn(EbNoVec,'qam', M);
semilogy(EbNoVec, berTheoryQamAwgn, 'b--');
legend('Fading OFDM-16QAM Simulation', 'AWGN OFDM-16QAM Simulation',...
    'Fading OFDM-16QAM Theory', 'AWGN OFDM-16QAM Theory', 'location', 'best')
xlabel('Eb/N0')
ylabel('BER')

%% Convolutional Encoder and Viterbi decoder
clc;
% clear;
load inpsig.mat;

M = 16;                 % Modulation alphabet
k = log2(M);           % Bits/symbol
numSC = 128;           % Number of OFDM subcarriers
cpLen = 32;            % OFDM cyclic prefix length


for framing_encoder=[1]
for ch_coding=[1 2]
    for interleaving=[0 1]

        ofdmMod = comm.OFDMModulator('FFTLength', numSC, 'CyclicPrefixLength', cpLen);
        ofdmDemod = comm.OFDMDemodulator('FFTLength', numSC, 'CyclicPrefixLength', cpLen);

        ofdmDims = info(ofdmMod);
        numDC = ofdmDims.DataInputSize(1);


        rayleighChannel = comm.RayleighChannel;
        rayleighChannel.PathGainsOutputPort =true;
        awgnChannel = comm.AWGNChannel('NoiseMethod','Variance', 'VarianceSource','Input port');


        trellis = {poly2trellis(7,[171 133]), poly2trellis(8, [367 323 275 271])};
        tbl = {32, 32};
        rate = {1/2, 1/4};


        if framing_encoder
            inpsig_msg = inpsig;
        else
            inpsig_pad = inpsig;
            inpsig_pad(length(inpsig):length(inpsig) + tbl{ch_coding}) = 0;
            inpsig_msg = convenc(inpsig_pad, trellis{ch_coding});

            if interleaving
                inpsig_msg = randintrlv(inpsig_msg, 123);
            end
        end


        orig_msg_length = length(inpsig_msg);
        if framing_encoder
            framesize = numDC*k*rate{ch_coding}-tbl{ch_coding};
        else
            framesize = numDC*k;
        end
        nFrames = ceil(orig_msg_length / framesize);
        paded_inpsig = inpsig_msg;
        paded_inpsig(end: nFrames * framesize) = 0;

        rxBitsFadedSoftEnc = zeros([length(paded_inpsig), 1]);
        rxBitsFadedHardEnc = zeros([length(paded_inpsig), 1]);
        rxBitsSoftEnc = zeros([length(paded_inpsig), 1]);
        rxBitsHardEnc = zeros([length(paded_inpsig), 1]);

        EbNoVec = (0:13)';
        snrdB = EbNoVec + 10*log10(k*rate{ch_coding}) + 10*log10(numDC/numSC);

        BERqamOfdmFadedEncodedSoft = zeros(length(EbNoVec), 1);
        BERqamOfdmFadedEncodedHard = zeros(length(EbNoVec), 1);
        BERqamOfdmEncodedSoft = zeros(length(EbNoVec), 1);
        BERqamOfdmEncodedHard = zeros(length(EbNoVec), 1);


        for m = 1:length(EbNoVec)
            for j=1:nFrames
                if framing_encoder
                    frame = paded_inpsig((j-1)*framesize+1:j*framesize);
                    frame_padded = frame;
                    frame_padded(framesize+1:framesize+tbl{ch_coding}) = 0;

                    dataEnc = convenc(frame_padded, trellis{ch_coding});
                    if interleaving
                        dataEnc = randintrlv(dataEnc, j);
                    end
                    qamTx = qammod(dataEnc, M, 'InputType', 'bit', 'UnitAveragePower',true);
                else
                    frame = paded_inpsig((j-1)*framesize+1:j*framesize);
                    qamTx = qammod(frame, M, 'InputType', 'bit', 'UnitAveragePower',true);
                end
                

                qamOfdmTx = ofdmMod(qamTx);

                powerDB = 10*log10(var(qamOfdmTx));               % Calculate Tx signal power
                noiseVar = 10.^(0.1*(powerDB-snrdB(m)));           % Calculate the noise variance

                % Faded Channel
                [fadedSig pathGains] = rayleighChannel(qamOfdmTx);
                qamOfdmRxFaded = awgnChannel(fadedSig, noiseVar);
                qamOfdmRxFaded_eq = qamOfdmRxFaded./sum(pathGains, 2);
                qamOfdmRxFaded = ofdmDemod(qamOfdmRxFaded_eq);
                % AWGN Channel
                qamOfdmRx =  awgnChannel(qamOfdmTx, noiseVar);
                qamOfdmRx = ofdmDemod(qamOfdmRx);

                % QAM Demod - Faded
                rxDataHardFaded = qamdemod(qamOfdmRxFaded, M, 'OutputType','bit','UnitAveragePower', true);
                rxDataSoftFaded = qamdemod(qamOfdmRxFaded, M, 'OutputType','approxllr', ...
                            'UnitAveragePower', true, 'NoiseVariance',noiseVar);

                % QAM Demod - AWGN
                rxDataHard = qamdemod(qamOfdmRx, M, 'OutputType','bit','UnitAveragePower', true);
                rxDataSoft = qamdemod(qamOfdmRx, M, 'OutputType','approxllr', ...
                            'UnitAveragePower', true, 'NoiseVariance',noiseVar);
                if framing_encoder
                    if interleaving
                        rxDataHardFaded = randdeintrlv(rxDataHardFaded, j);
                        rxDataSoftFaded = randdeintrlv(rxDataSoftFaded, j);
                        rxDataHard = randdeintrlv(rxDataHard, j);
                        rxDataSoft = randdeintrlv(rxDataSoft, j);
                    end
                    % Decode - Faded
                    dataHardFaded = vitdec(rxDataHardFaded, trellis{ch_coding}, tbl{ch_coding}, 'cont', 'hard');
                    dataSoftFaded = vitdec(rxDataSoftFaded, trellis{ch_coding}, tbl{ch_coding}, 'cont', 'unquant');

                    % Decode - AWGN
                    dataHard = vitdec(rxDataHard, trellis{ch_coding}, tbl{ch_coding}, 'cont', 'hard');
                    dataSoft = vitdec(rxDataSoft, trellis{ch_coding}, tbl{ch_coding}, 'cont', 'unquant');
                    
                    % Faded
                    rxBitsFadedHardEnc((j-1)*framesize+1:j*framesize)  = dataHardFaded(tbl{ch_coding}+1:end);
                    rxBitsFadedSoftEnc((j-1)*framesize+1:j*framesize)  = dataSoftFaded(tbl{ch_coding}+1:end);
                    % AWGN
                    rxBitsHardEnc((j-1)*framesize+1:j*framesize)  = dataHard(tbl{ch_coding}+1:end);
                    rxBitsSoftEnc((j-1)*framesize+1:j*framesize)  = dataSoft(tbl{ch_coding}+1:end);
                else
                    % Faded
                    rxBitsFadedHardEnc((j-1)*framesize+1:j*framesize)  = rxDataHardFaded;
                    rxBitsFadedSoftEnc((j-1)*framesize+1:j*framesize)  = rxDataSoftFaded;
                    % AWGN
                    rxBitsHardEnc((j-1)*framesize+1:j*framesize)  = rxDataHard;
                    rxBitsSoftEnc((j-1)*framesize+1:j*framesize)  = rxDataSoft;
                end

            end
            display('***************');
            fprintf('framing: %d\t coding_rate: %.2f\t interleaving: %d\t EbN0: %d \n', framing_encoder, rate{ch_coding}, interleaving, EbNoVec(m))
            if framing_encoder
                [~, ratio] = biterr(inpsig, rxBitsFadedHardEnc(1:length(inpsig)));
                BERqamOfdmFadedEncodedHard(m) = ratio;
                [~, ratio] = biterr(inpsig, rxBitsFadedSoftEnc(1:length(inpsig)));
                BERqamOfdmFadedEncodedSoft(m) = ratio;
                [~, ratio] = biterr(inpsig, rxBitsHardEnc(1:length(inpsig)));
                BERqamOfdmEncodedHard(m) = ratio;
                [~, ratio] = biterr(inpsig, rxBitsSoftEnc(1:length(inpsig)));
                BERqamOfdmEncodedSoft(m) = ratio;
            else
                if interleaving
                    rxBitsFadedHardEnc = randdeintrlv(rxBitsFadedHardEnc(1:orig_msg_length), 123);
                    rxBitsFadedSoftEnc = randdeintrlv(rxBitsFadedSoftEnc(1:orig_msg_length), 123);
                    rxBitsHardEnc = randdeintrlv(rxBitsHardEnc(1:orig_msg_length), 123);
                    rxBitsSoftEnc = randdeintrlv(rxBitsSoftEnc(1:orig_msg_length), 123);
                end

                inpsig_dec_FadedHardEnc = vitdec(rxBitsFadedHardEnc, trellis{ch_coding}, tbl{ch_coding}, 'cont', 'hard');
                inpsig_dec_FadedSoftEnc = vitdec(rxBitsFadedSoftEnc, trellis{ch_coding}, tbl{ch_coding}, 'cont', 'unquant');
                inpsig_dec_HardEnc = vitdec(rxBitsHardEnc, trellis{ch_coding}, tbl{ch_coding}, 'cont', 'hard');
                inpsig_dec_SoftEnc = vitdec(rxBitsSoftEnc, trellis{ch_coding}, tbl{ch_coding}, 'cont', 'unquant');

                [~, ratio] = biterr(inpsig, inpsig_dec_FadedHardEnc(tbl{ch_coding}+1:tbl{ch_coding}+length(inpsig)));
                BERqamOfdmFadedEncodedHard(m) = ratio;
                [~, ratio] = biterr(inpsig, inpsig_dec_FadedSoftEnc(tbl{ch_coding}+1:tbl{ch_coding}+length(inpsig)));
                BERqamOfdmFadedEncodedSoft(m) = ratio;
                [~, ratio] = biterr(inpsig, inpsig_dec_HardEnc(tbl{ch_coding}+1:tbl{ch_coding}+length(inpsig)));
                BERqamOfdmEncodedHard(m) = ratio;
                [~, ratio] = biterr(inpsig, inpsig_dec_SoftEnc(tbl{ch_coding}+1:tbl{ch_coding}+length(inpsig)));
                BERqamOfdmEncodedSoft(m) = ratio;
            end
            fprintf('\tFadedHard: %.5f\tFadedSoft: %.5f\tHard: %.5f\tSoft: %.5f \n', BERqamOfdmFadedEncodedHard(m),...
                BERqamOfdmFadedEncodedSoft(m), BERqamOfdmEncodedHard(m), BERqamOfdmEncodedSoft(m))
        end
        BERqamOfdmFadedEncodedHard_r{ch_coding, interleaving+1, framing_encoder+1} = BERqamOfdmFadedEncodedHard;
        BERqamOfdmFadedEncodedSoft_r{ch_coding, interleaving+1, framing_encoder+1} = BERqamOfdmFadedEncodedSoft;
        BERqamOfdmEncodedHard_r{ch_coding, interleaving+1, framing_encoder+1} = BERqamOfdmEncodedHard;
        BERqamOfdmEncodedSoft_r{ch_coding, interleaving+1, framing_encoder+1} = BERqamOfdmEncodedSoft;
    end
end
end

save BERqamOfdmFadedEncodedHard_r
save BERqamOfdmFadedEncodedSoft_r
save BERqamOfdmEncodedHard_r
save BERqamOfdmEncodedSoft_r


%% Semilogy BERvsSNR plots for various channel coding configs
clc;
close all;
% clear;
% 
% load BERqamOfdmFadedEncodedHard_r
% load BERqamOfdmFadedEncodedSoft_r
% load BERqamOfdmEncodedHard_r
% load BERqamOfdmEncodedSoft_r
% 
% EbNoVec = (0:13)';

set(gcf,'PaperSize',[16 16]); 
set(gcf,'position',[0 0 1000 1000]);

framing = 1;
rates = {'1/2', '1/4'};
inter = {'No', 'Yes'};
for pp = 1:4
    subplot(2, 2, pp);
    for coding_rate = [1 2]
        for interleaving = [0 1]
            if pp == (coding_rate-1) * 2 + interleaving + 1
                % main plot
                lw = 1.7;
            else
                continue
                lw = 1.0;
                % other plots
            end
            semilogy(EbNoVec, BERqamOfdmFadedEncodedHard_r{coding_rate, interleaving+1, framing+1}, 'r-.', 'linewidth', lw);
            hold on;
            semilogy(EbNoVec, BERqamOfdmFadedEncodedSoft_r{coding_rate, interleaving+1, framing+1}, 'r--', 'linewidth', lw);
            hold on;
            semilogy(EbNoVec, BERqamOfdmEncodedHard_r{coding_rate, interleaving+1, framing+1}, 'b-.', 'linewidth', lw);
            hold on;
            semilogy(EbNoVec, BERqamOfdmEncodedSoft_r{coding_rate, interleaving+1, framing+1}, 'b--', 'linewidth', lw);
            legend('Faded Hard', 'Faded Soft', 'AWGN Hard', 'AWGN Soft', 'location', 'best')
            title(sprintf('Rate: %s, Interleaving: %s w framing', rates{coding_rate}, inter{interleaving+1}));
            grid on;
        end
    end
end

%% Convolutional Encoder and Viterbi decoder
clc;
clear;
load inpsig.mat;

M = 16;                 % Modulation alphabet
k = log2(M);           % Bits/symbol
numSC = 128;           % Number of OFDM subcarriers
cpLen = 32;            % OFDM cyclic prefix length


framing_encoder = 0;
ch_coding = 2;
interleaving = 1;

ofdmMod = comm.OFDMModulator('FFTLength', numSC, 'CyclicPrefixLength', cpLen);
ofdmDemod = comm.OFDMDemodulator('FFTLength', numSC, 'CyclicPrefixLength', cpLen);

ofdmDims = info(ofdmMod);
numDC = ofdmDims.DataInputSize(1);


rayleighChannel = comm.RayleighChannel;
rayleighChannel.PathGainsOutputPort =true;
awgnChannel = comm.AWGNChannel('NoiseMethod','Variance', 'VarianceSource','Input port');


trellis = {poly2trellis(7,[171 133]), poly2trellis(8, [367 323 275 271])};
tbl = {32, 32};
rate = {1/2, 1/4};


if framing_encoder
    inpsig_msg = inpsig;
else
    inpsig_pad = inpsig;
    inpsig_pad(length(inpsig):length(inpsig) + tbl{ch_coding}) = 0;
    inpsig_msg = convenc(inpsig_pad, trellis{ch_coding});

    if interleaving
        inpsig_msg = randintrlv(inpsig_msg, 123);
    end
end


orig_msg_length = length(inpsig_msg);
if framing_encoder
    framesize = numDC*k*rate{ch_coding}-tbl{ch_coding};
else
    framesize = numDC*k;
end
nFrames = ceil(orig_msg_length / framesize);
paded_inpsig = inpsig_msg;
paded_inpsig(end: nFrames * framesize) = 0;

rxBitsFadedSoftEnc = zeros([length(paded_inpsig), 1]);
rxBitsFadedHardEnc = zeros([length(paded_inpsig), 1]);
rxBitsSoftEnc = zeros([length(paded_inpsig), 1]);
rxBitsHardEnc = zeros([length(paded_inpsig), 1]);

EbNoVec = [8.5];
snrdB = EbNoVec + 10*log10(k*rate{ch_coding}) + 10*log10(numDC/numSC);

BERqamOfdmFadedEncodedSoft = zeros(length(EbNoVec), 1);
BERqamOfdmFadedEncodedHard = zeros(length(EbNoVec), 1);
BERqamOfdmEncodedSoft = zeros(length(EbNoVec), 1);
BERqamOfdmEncodedHard = zeros(length(EbNoVec), 1);


for m = 1:length(EbNoVec)
    for j=1:nFrames
        if framing_encoder
            frame = paded_inpsig((j-1)*framesize+1:j*framesize);
            frame_padded = frame;
            frame_padded(framesize+1:framesize+tbl{ch_coding}) = 0;

            dataEnc = convenc(frame_padded, trellis{ch_coding});
            if interleaving
                dataEnc = randintrlv(dataEnc, j);
            end
            qamTx = qammod(dataEnc, M, 'InputType', 'bit', 'UnitAveragePower',true);
        else
            frame = paded_inpsig((j-1)*framesize+1:j*framesize);
            qamTx = qammod(frame, M, 'InputType', 'bit', 'UnitAveragePower',true);
        end


        qamOfdmTx = ofdmMod(qamTx);

        powerDB = 10*log10(var(qamOfdmTx));               % Calculate Tx signal power
        noiseVar = 10.^(0.1*(powerDB-snrdB(m)));           % Calculate the noise variance

        % Faded Channel
        [fadedSig pathGains] = rayleighChannel(qamOfdmTx);
        qamOfdmRxFaded = awgnChannel(fadedSig, noiseVar);
        qamOfdmRxFaded_eq = qamOfdmRxFaded./sum(pathGains, 2);
        qamOfdmRxFaded = ofdmDemod(qamOfdmRxFaded_eq);
        % AWGN Channel
        qamOfdmRx =  awgnChannel(qamOfdmTx, noiseVar);
        qamOfdmRx = ofdmDemod(qamOfdmRx);

        % QAM Demod - Faded
        rxDataHardFaded = qamdemod(qamOfdmRxFaded, M, 'OutputType','bit','UnitAveragePower', true);
        rxDataSoftFaded = qamdemod(qamOfdmRxFaded, M, 'OutputType','approxllr', ...
                    'UnitAveragePower', true, 'NoiseVariance',noiseVar);

        % QAM Demod - AWGN
        rxDataHard = qamdemod(qamOfdmRx, M, 'OutputType','bit','UnitAveragePower', true);
        rxDataSoft = qamdemod(qamOfdmRx, M, 'OutputType','approxllr', ...
                    'UnitAveragePower', true, 'NoiseVariance',noiseVar);
        if framing_encoder
            if interleaving
                rxDataHardFaded = randdeintrlv(rxDataHardFaded, j);
                rxDataSoftFaded = randdeintrlv(rxDataSoftFaded, j);
                rxDataHard = randdeintrlv(rxDataHard, j);
                rxDataSoft = randdeintrlv(rxDataSoft, j);
            end
            % Decode - Faded
            dataHardFaded = vitdec(rxDataHardFaded, trellis{ch_coding}, tbl{ch_coding}, 'cont', 'hard');
            dataSoftFaded = vitdec(rxDataSoftFaded, trellis{ch_coding}, tbl{ch_coding}, 'cont', 'unquant');

            % Decode - AWGN
            dataHard = vitdec(rxDataHard, trellis{ch_coding}, tbl{ch_coding}, 'cont', 'hard');
            dataSoft = vitdec(rxDataSoft, trellis{ch_coding}, tbl{ch_coding}, 'cont', 'unquant');

            % Faded
            rxBitsFadedHardEnc((j-1)*framesize+1:j*framesize)  = dataHardFaded(tbl{ch_coding}+1:end);
            rxBitsFadedSoftEnc((j-1)*framesize+1:j*framesize)  = dataSoftFaded(tbl{ch_coding}+1:end);
            % AWGN
            rxBitsHardEnc((j-1)*framesize+1:j*framesize)  = dataHard(tbl{ch_coding}+1:end);
            rxBitsSoftEnc((j-1)*framesize+1:j*framesize)  = dataSoft(tbl{ch_coding}+1:end);
        else
            % Faded
            rxBitsFadedHardEnc((j-1)*framesize+1:j*framesize)  = rxDataHardFaded;
            rxBitsFadedSoftEnc((j-1)*framesize+1:j*framesize)  = rxDataSoftFaded;
            % AWGN
            rxBitsHardEnc((j-1)*framesize+1:j*framesize)  = rxDataHard;
            rxBitsSoftEnc((j-1)*framesize+1:j*framesize)  = rxDataSoft;
        end

    end
    display('***************');
    fprintf('framing: %d\t coding_rate: %.2f\t interleaving: %d\t EbN0: %d \n', framing_encoder, rate{ch_coding}, interleaving, EbNoVec(m))
    if framing_encoder
        [~, ratio] = biterr(inpsig, rxBitsFadedHardEnc(1:length(inpsig)));
        BERqamOfdmFadedEncodedHard(m) = ratio;
        [~, ratio] = biterr(inpsig, rxBitsFadedSoftEnc(1:length(inpsig)));
        BERqamOfdmFadedEncodedSoft(m) = ratio;
        [~, ratio] = biterr(inpsig, rxBitsHardEnc(1:length(inpsig)));
        BERqamOfdmEncodedHard(m) = ratio;
        [~, ratio] = biterr(inpsig, rxBitsSoftEnc(1:length(inpsig)));
        BERqamOfdmEncodedSoft(m) = ratio;
    else
        if interleaving
            rxBitsFadedHardEnc = randdeintrlv(rxBitsFadedHardEnc(1:orig_msg_length), 123);
            rxBitsFadedSoftEnc = randdeintrlv(rxBitsFadedSoftEnc(1:orig_msg_length), 123);
            rxBitsHardEnc = randdeintrlv(rxBitsHardEnc(1:orig_msg_length), 123);
            rxBitsSoftEnc = randdeintrlv(rxBitsSoftEnc(1:orig_msg_length), 123);
        end

        inpsig_dec_FadedHardEnc = vitdec(rxBitsFadedHardEnc, trellis{ch_coding}, tbl{ch_coding}, 'cont', 'hard');
        inpsig_dec_FadedSoftEnc = vitdec(rxBitsFadedSoftEnc, trellis{ch_coding}, tbl{ch_coding}, 'cont', 'unquant');
        inpsig_dec_HardEnc = vitdec(rxBitsHardEnc, trellis{ch_coding}, tbl{ch_coding}, 'cont', 'hard');
        inpsig_dec_SoftEnc = vitdec(rxBitsSoftEnc, trellis{ch_coding}, tbl{ch_coding}, 'cont', 'unquant');

        [~, ratio] = biterr(inpsig, inpsig_dec_FadedHardEnc(tbl{ch_coding}+1:tbl{ch_coding}+length(inpsig)));
        BERqamOfdmFadedEncodedHard(m) = ratio;
        [~, ratio] = biterr(inpsig, inpsig_dec_FadedSoftEnc(tbl{ch_coding}+1:tbl{ch_coding}+length(inpsig)));
        BERqamOfdmFadedEncodedSoft(m) = ratio;
        [~, ratio] = biterr(inpsig, inpsig_dec_HardEnc(tbl{ch_coding}+1:tbl{ch_coding}+length(inpsig)));
        BERqamOfdmEncodedHard(m) = ratio;
        [~, ratio] = biterr(inpsig, inpsig_dec_SoftEnc(tbl{ch_coding}+1:tbl{ch_coding}+length(inpsig)));
        BERqamOfdmEncodedSoft(m) = ratio;
    end
    fprintf('\tFadedHard: %.5f\tFadedSoft: %.5f\tHard: %.5f\tSoft: %.5f \n', BERqamOfdmFadedEncodedHard(m),...
        BERqamOfdmFadedEncodedSoft(m), BERqamOfdmEncodedHard(m), BERqamOfdmEncodedSoft(m))
end
BERqamOfdmFadedEncodedHard_r{ch_coding, interleaving+1, framing_encoder+1} = BERqamOfdmFadedEncodedHard;
BERqamOfdmFadedEncodedSoft_r{ch_coding, interleaving+1, framing_encoder+1} = BERqamOfdmFadedEncodedSoft;
BERqamOfdmEncodedHard_r{ch_coding, interleaving+1, framing_encoder+1} = BERqamOfdmEncodedHard;
BERqamOfdmEncodedSoft_r{ch_coding, interleaving+1, framing_encoder+1} = BERqamOfdmEncodedSoft;

%% Use the Autoencoder on received signals
orig_imgs = autoenc(6, 12, 'orig', 'test_lim');
bits = 6;
comp_imgs = autoenc(6, 12, 'comp', 'test_lim');
[sn, sx, sy, sz] = size(comp_imgs);

outsigs = {Digital2Analog(inpsig_dec_FadedHardEnc(tbl{ch_coding}+1:tbl{ch_coding}+length(inpsig)), bits, 0),...
    Digital2Analog(inpsig_dec_FadedSoftEnc(tbl{ch_coding}+1:tbl{ch_coding}+length(inpsig)), bits, 0),...
    Digital2Analog(inpsig_dec_HardEnc(tbl{ch_coding}+1:tbl{ch_coding}+length(inpsig)), bits, 0),...
    Digital2Analog(inpsig_dec_SoftEnc(tbl{ch_coding}+1:tbl{ch_coding}+length(inpsig)), bits, 0)};

recons_imgs = cell([4 1]);
for i=1:4
    outsigs{i} = reshape(outsigs{i}, [sn sx sy sz]);
    recons_imgs{i} = autoenc(6, 12, 'recons', outsigs{i});
end

%% Calculate MSE and SNR of received signals
MSEs = cell([4 1]);
SNRs = cell([4 1]);
for i=1:4
    MSEs{i} = immse(orig_imgs, recons_imgs{i});
    SNRs{i} = snr(orig_imgs, orig_imgs-recons_imgs{i});
end
MSEs
SNRs

%% Montage reconstructed images
orgimg = cell(1, 10);
for i=1:10
    img = permute(reshape(orig_imgs(i,:,:,:), [3 32 32]), [2 3 1]);
    orgimg{i} = img;
end

for j=1:4
    for i=1:10
        img = permute(reshape(recons_imgs{j}(i,:,:,:), [3 32 32]), [2 3 1]);
        recsimg{j, i} = img;
    end
end

img = zeros(128, 128, 3);
num_img = 8;
mont = cell(num_img*5, 1);

mont{1} = insertText(img, [68 68], 'Orig', 'FontSize', 30, 'TextColor','white', 'AnchorPoint', 'Center');
for i=1:num_img
    mont{i+1} = orgimg{i};
end
labels = {'Fading_Hard', 'Fading_Soft', 'AWGN_Hard', 'AWGN_Soft'};
for j=1:4
    mont{j*(num_img+1)+1} = insertText(img, [68 68],...
        labels{j},...
        'FontSize',20, 'TextColor','white', 'AnchorPoint', 'Center');
    for i=1:num_img
        mont{j*(num_img+1)+i+1} = recsimg{j, i};
    end
end
montage(mont, 'Size', [5, num_img+1]);