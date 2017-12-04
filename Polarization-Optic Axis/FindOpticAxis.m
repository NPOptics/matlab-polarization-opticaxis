% FindOpticAxis.m
% This code takes a known polarization, and a .mat video file and draws
% vectors corresponding to the optic axis of the crystal
% L. Tracy, July 2017
% Section on conversion, smoothing, and plotting the derivative based on ProcessData_v4.m by:
% N. Cartwright, C. Herne, January 2017

% Enter polarization in degrees
pdg = 45;
% Convert to radians
pra = pdg*(180/pi);
% Convert from degrees from y-axis to degrees from x-axis
pra = (pi/2-pra);

% Find and select file to be uploaded
[fname, pname] = uigetfile('*.lvm','Choose .lvm QPD Data File');
% change file path
cd(pname);

data = importdata(fname);

convert = 1.03; %conversion between QPD and VID time; convert = VID/QPD, generally set to 1.03 for our purposes
tt = convert*transpose(data(:,1)); 
II = transpose(data(:,2)); %2=x, 3=y, 4=sum

% This section applies a low-pass filter to the data.  It can be commented
% out if the data is not especially noisy.  The correct values for the
% 'PassbandFrequency', and 'StopbandFrequency' parameters can be determined
% by performing a Fast Fourier Transform on the data and determining what
% frequency range the useful data resides in.
lpf = designfilt('lowpassfir', 'PassbandFrequency', 1, 'StopbandFrequency', 1.5, 'PassbandRipple', 1, 'StopbandAttenuation', 60, 'SampleRate', 60);
II = filter(lpf, II);


% This section smooths the data using some functions written by N. Cartwright and
% is an artefact of the old code.  It may not actually be
% necessary to smooth the data any more since it is now being filtered. May
% be removed in future versions of the code.
newdata = fastsmooth((II),5,2,1); 
newII = newdata;

% compute derivative using central difference
n=length(newII);
dII=zeros(size(newII));
dIIdtt(1)=newII(2)-newII(1)/(tt(2)-tt(1));
dIIdtt(n)=newII(n)-newII(n-1)/(tt(n) - tt(n-1));

for j = 2:n-1;
  dIIdtt(j)=(newII(j+1)-newII(j-1)) ./ (tt(j+1)-tt(j-1));
end

%subset and normalize data
st = size(tt);
s = int64(st(2)/1);

ttnorm = tt(2:s);
IInorm = (II(2:s)-min(II(2:s)))/(max(II(2:s))-min(II(2:s))); %divide by max
newIInorm = (newII(2:s)-min(newII(2:s)))/(max(newII(2:s))-min(newII(2:s)));
dIIdttnorm = dIIdtt(2:s)/max(dIIdtt(2:s));

% find maxima/minima
% MinPeakDistance, and MinPeakHeight may need to be tweaked depending on the
% dataset being used (don't forget to change them in the plot section as
% well!)
[Maxima, MaxIdx] = findpeaks(dIIdttnorm,ttnorm,'MinPeakDistance',.3,'MinPeakHeight',.015);
[Minima, MinIdx] = findpeaks(-dIIdttnorm,ttnorm,'MinPeakDistance',.3,'MinPeakHeight',.015);
Minima = -Minima;

% set framerate of video
framerate = 30;

% convert maxima/minima from seconds to frames, rounding to nearest integer
% frame
MaxFrames = round(MaxIdx*framerate);
MinFrames = round(MinIdx*framerate);

% load in circular/elliptical polarization .mat file
[Vidfname, Vidpname] = uigetfile('*.mat','Choose circular/elliptical polarization .mat file');
cd(Vidpname);
load(Vidfname);

% find center position
imagesc(vidFrame(:,:,:,MaxFrames(4)))
title('Locate Center of Rotation')
[xc,yc]=ginput;
close

% Draw arrow on image aligned with the optic axis
r = 100; % magnitude (length) of arrow to plot
% Convert from polar to Cartesian coordinates
u = -(r * cos(pra)); % A negative sign is added to this value due to the strange coordinates of the video frame
v = r * sin(pra);
% Bring video frame back up
imagesc(vidFrame(:,:,:,MaxFrames(1)))
% Make sure image doesn't go away when drawing the arrow
hold on
% Draw arrow
q1 = quiver(xc,yc,u,v);
q1.LineWidth = 2;
q1.Color = 'red';
q2 = quiver(xc,yc,-u,-v);
q2.LineWidth = 2;
q2.Color = 'red';

