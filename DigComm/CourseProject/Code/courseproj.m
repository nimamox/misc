%% Calculate MSE and SNR of different Autoencs
orig_imgs = autoenc(12, 12, 'orig', 'test');
orgimg = cell(1, 10);
for i=1:10
    img = permute(reshape(orig_imgs(i,:,:,:), [3 32 32]), [2 3 1]);
    orgimg{i} = img;
end

kers_1 = [3 3 3 6 6 6 12 12 12];
kers_2 = [3 6 12 3 6 12 3 6 12];

recsimg = cell(9, 10);
MSEs = cell(1, 9);
SNRs = cell(1, 9);
for j=1:9
    comp_imgs = autoenc(kers_1(j), kers_2(j), 'comp', 'test');
    recons_imgs = autoenc(kers_1(j), kers_2(j), 'recons', comp_imgs);
    
    MSEs{j} = immse(orig_imgs, recons_imgs);
    SNRs{j} = snr(orig_imgs, orig_imgs-recons_imgs);
    for i=1:10
        img = permute(reshape(recons_imgs(i,:,:,:), [3 32 32]), [2 3 1]);
        recsimg{j, i} = img;
    end
end

%% Plot compressed and reconstructed images

img = zeros(128, 128, 3);
num_img = 8;
mont = cell(num_img*10);

mont{1} = insertText(img, [68 68], 'Orig', 'FontSize', 30, 'TextColor','white', 'AnchorPoint', 'Center');
for i=1:num_img
    mont{i+1} = orgimg{i};
end
for j=1:9
    mont{j*(num_img+1)+1} = insertText(img, [68 68],...
        ['(' int2str(kers_1(j)) ', ' int2str(kers_2(j)) ')'],...
        'FontSize',30, 'TextColor','white', 'AnchorPoint', 'Center');
    for i=1:num_img
        mont{j*(num_img+1)+i+1} = recsimg{j, i};
    end
end
montage(mont, 'Size', [10, num_img+1]);

%% Plot histogram of image
histogram(orig_imgs,'Normalization','probability');
xlabel('Pixel values')
ylabel('Probability')


%% Load compressed images from the selected Autoencoder (6, 12)
comp_imgs = autoenc(6, 12, 'comp', 'test');

%%
clc;
[sn, sx, sy, sz] = size(comp_imgs);
comp_flattened = reshape(comp_imgs, [sn*sx*sy*sz 1]);


recsimg = cell(8, 10);
MSEs = cell(1, 8);
SNRs = cell(1, 8);

for bits=1:8
    display(['******** ', int2str(bits)])
    comp_dig = Analog2Digital(double(comp_flattened), 65536, bits, 0);
    comp_anal = Digital2Analog(comp_dig, bits, 0);
    comp_anal_s = reshape(comp_anal, [sn sx sy sz]);
    recons_imgs = autoenc(6, 12, 'recons', comp_anal_s);
    
    MSEs{bits} = immse(orig_imgs, recons_imgs);
    SNRs{bits} = snr(orig_imgs, orig_imgs-recons_imgs);
    for i=1:10
        img = permute(reshape(recons_imgs(i,:,:,:), [3 32 32]), [2 3 1]);
        recsimg{bits, i} = img;
    end
end
%% Plot images for different quantization levels

img = zeros(128, 128, 3);
num_img = 8;
mont = cell(num_img*10);

mont{1} = insertText(img, [68 68], 'Orig', 'FontSize', 30, 'TextColor','white', 'AnchorPoint', 'Center');
for i=1:num_img
    mont{i+1} = orgimg{i};
end
for j=1:8
    mont{j*(num_img+1)+1} = insertText(img, [68 68],...
        [ int2str(j) '-bit'],...
        'FontSize',30, 'TextColor','white', 'AnchorPoint', 'Center');
    for i=1:num_img
        mont{j*(num_img+1)+i+1} = recsimg{j, i};
    end
end
montage(mont, 'Size', [9, num_img+1]);
%% Select autoencoder and quantization levels for the rest of the project
clear;
orig_imgs = autoenc(6, 12, 'orig', 'test_lim');
bits = 6;
comp_imgs = autoenc(6, 12, 'comp', 'test_lim');
[sn, sx, sy, sz] = size(comp_imgs);
comp_flattened = reshape(comp_imgs, [sn*sx*sy*sz 1]);
inpsig = Analog2Digital(double(comp_flattened), 65536, bits, 0);

outsig = Digital2Analog(inpsig, bits, 0);
outsig_orig_shape = reshape(outsig, [sn sx sy sz]);
recons_imgs = autoenc(6, 12, 'recons', outsig_orig_shape);
ref_MSEs = immse(orig_imgs, recons_imgs)
ref_SNRs = snr(orig_imgs, orig_imgs-recons_imgs)
save inpsig
