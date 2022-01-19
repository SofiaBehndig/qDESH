% find_threshold.m
%
% SCRIPT for imlook4d to find a threshold for a ROI
% by walking the histogram to find the valley between the first two peaks
%
% Instructions:
%   draw coarse ROIs with some substance which you don't want to include in final ROI
%   run 'SCRIPTS/ROI/Roi data to work space'
%   run this script
%   run 'SCRIPTS/ROI/Threshold within ROI' using the pre-filled threshold value
%
% Requires : 
%   Signal Processing Toolbox
%
% Jan Axelsson 2020-12-10

%
% Prepare
%
    % Store list of variables to clean at end
    imlook4d_store_backup = []; % This should not be auto-cleaned
    StoreVariables

    % Output from 'SCRIPTS/ROI/Roi data to work space'
    data = imlook4d_ROI_data.pixels{imlook4d_ROI_number};
    data = data( data > 0); % Make sure we have only positive values
    
    if isempty(data)
        warning('No pixels in current ROI');
        return
    end
    
    % scale indata to correct format? needs verification but is "close
    % enough"  to work
    scale1=min(data)
    scale2=(max(data)-min(data))/(length(unique(data)))
    
    data0=data;
    data=data./scale1;

    % Make histogram
    N = ceil( max( data));
    binStep = 1;
    y = histcounts( data,N);
    
%     % first attempt to correct for old images with discrete data values (empty bins in histogram)
%     empty_bins=find(y==0);
%     no_empty_bins=length(empty_bins);
%     if no_empty_bins>100 %some margin of error for "skips" in normal gray scale (empty bins ~ 1000 in old images)
%         y(empty_bins)=[]; % remove empty bins
%         windowSize = round( 0.5*length(y) / 10 ); % Depends on number of bins (unique data points)
%         x = 1:binStep:length(y);
%         scale=max( data)/length(y) %scale factor to translate bin number to pixel intensity 
%     else
%         windowSize = round( 0.5*N / 10 ); % Depends on number of data points
%         x = 1:binStep:N;
%         scale=N/length(y) %scale factor will be one for "correct" images
%     end
   
    windowSize = round( 0.5*N / 10 ); % Depends on number of data points
    x = 1:binStep:N;

    % Moving average filter
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    yy = filtfilt(b,a,y);
    
    % Plot
    figure;
    plot(x,yy)

%
% Find peaks
%

    % Peak 1
    i = 1; % Start at value 1
    d = windowSize % Look ahead distance
    while ( yy(i+d) > yy(i) )
       i = i + 1; 
    end
    peak1 = floor( i + 0.5*d);
    disp( ['First peak at x = ' num2str(peak1) ]);
    
    % Half width Peak 1
    i = peak1 + 1;
    while ( yy(i) > 0.5 * yy(peak1) )
       i = i + 1; 
    end
    hwhm = floor( i-peak1 ); % Half width half maximum
    disp( ['Half width at half max = ' num2str(peak1) ]);

    % Valley
    while ( yy(i+d) < yy(i) )
       i = i + 1; 
    end
    valley =  floor( i + 0.5*d);
    disp( ['Valley at x = ' num2str(valley) ]);

    % Peak 2
    while ( yy(i+d) > yy(i) )
       i = i + 1; 
    end
    peak2 = floor( i + 0.5*d);
    disp( ['Second peak at x = ' num2str(peak2) ]);

%
% Output
%

    % Set level in imlook4d Threshold GUI :
    imlook4d_store.Threshold.inputs{1}=num2str( valley*scale1);
    imlook4d_store.Threshold.inputs{2}=num2str( 0 );
    imlook4d_store.Threshold.inputs{3}='1';
    imlook4d_store.Threshold.inputs{4}='end';

    % Test
    disp( ['Test: threshold from middle between peaks (should be close to valley), distance = ' num2str( (peak1 + 0.5*(peak2 - peak1))*scale1 ) ]);
    
    % Alternative peak
    disp( ['Alt1: threshold from first peak width, threshold = ' num2str(  (peak1 + hwhm * 4)*scale1) ]);
    
    
    % Clean up
    imlook4d_store_backup = imlook4d_store; % Keep even if listed in ClearVariables
    %ClearVariables
    imlook4d_store = imlook4d_store_backup;
    clear 'imlook4d_store_backup'
