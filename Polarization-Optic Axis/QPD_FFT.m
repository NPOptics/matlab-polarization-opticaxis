% Perform FFT on QPD data.
% Written 7/2017 L. Tracy

% Find and select file to be uploaded
[fname, pname] = uigetfile('*.*','testUpload');
% Change path to file path
cd(pname)

data = importdata(fname);

tt = transpose(data(:,1)); %Time data
s = size(tt);              %Number of data points
L = 2*round(s(2))/2;       %Round number of points to the nearest even number
II = transpose(data(:,2)); %Determine which data you want to process, x=2, y=3, sum=4

Fs = 60;              % Sampling frequency                    
T = 1/Fs;             % Sampling period
t = (0:L-1)*T;        % Time vector

Y = fft(II);          %Perform fast fourier transform

P2 = abs(Y/L);    %Compute the two-sided spectrum P2
P1 = P2(1:L/2+1); %Compute the single-sided spectrum P1 based on P2 and the even-valued signal length L.
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
figure(3)
plot(f,P1) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

