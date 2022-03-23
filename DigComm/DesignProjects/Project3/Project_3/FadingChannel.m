function [y, channel] = FadingChannel(x, FadingType, DopplerRate, K_factor)
% function y = FadingChannel(x, FadingType, DopplerRate, K_factor)
%
% This function simulates the effect of a flat fading channel at complex
% baseband.  FadingType is either 'RAYL' for Rayleigh fading or 'RICE' for
% Ricean fading.  Note that if Ricean fading is examined, you must define
% the K_factor (ratio of direct to diffuse components).  DopplerRate is the
% maximum Doppler rate *in terms of the sample rate*.

if FadingType ~= 'RAYL'
    if FadingType ~= 'RICE'
        error('FadingType not understood!  Please use RAYL or RICE')
    end
    if nargin < 4
        error('K_factor not defined!')
    end
end

L = length(x);
t = 1:L;

N = 50;   % number of multipath components;
DopplerFreq = DopplerRate*rand(1,N);

tmp = zeros(N,L);

for i=1:N
    tmp(i,:) = exp(j*2*pi*DopplerFreq(i)*t + j*rand*2*pi);
end

channel = sum(tmp)/sqrt(N);

if FadingType == 'RICE'
    channel = 1/sqrt(K_factor+1)*channel + sqrt(K_factor/(1+K_factor));
end

if size(x,1) ~= size(channel,1)
    x = x.';
end

y = channel.*x;



