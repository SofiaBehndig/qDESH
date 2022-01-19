% Determine_threshold.m
%
% SCRIPT for imlook4d to find a threshold for a ROI
% using a fit to two gaussian distributions
%
% Instructions:
%   draw coarse ROIs with some substance which you don't want to include in final ROI
%   run 'SCRIPTS/ROI/Roi data to work space'
%   run this script
%   run 'SCRIPTS/ROI/Threshold within ROI' using the reported threshold value
%
% Requires : 
%   peakfit.m  (from  https://www.mathworks.com/matlabcentral/fileexchange/23611-peakfit-m)
%
% Jan Axelsson


% First: in imlook4d, run 'SCRIPTS/ROI/Roi data to work space'
data = imlook4d_ROI_data.pixels{imlook4d_ROI_number};
data = data( data > 0); % Make sure we have only positive values
N = 80;
binStep = max( data) / N; 
y = histcounts( data,N);
x = 1:binStep:max( data);

figure;
[FitResults,GOF,baseline,coeff,residual,xi,yi,BootResults] = peakfit([x' y'],0,0,2)

peak1 = FitResults(1,2)
peak2 = FitResults(2,2)

threshold = 0.5 * abs( peak2 - peak1) + min( [ peak1 peak2])