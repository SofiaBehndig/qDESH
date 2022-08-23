% % csf_threshold.m
%
% SCRIPT for imlook4d to find a CSF threshold for a ROI
% determined from mid-distance between CSF-peak and nearest-tissue-peak
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
% Jan Axelsson 2021-02-16

%
% Prepare
%

    returnCode = 1; % Assume error, correct at end
    histWindow = 0; % Dummy handle to histogram window, so it won't be removed by ClearVariables

    
    threshold = 0; % Just so threshold variable won't be cleared
    StoreVariables

    % Output from 'SCRIPTS/ROI/Roi data to work space'
    data0 = imlook4d_ROI_data.pixels{imlook4d_ROI_number};
    
    % If called from GUI
    if (exist('deshify_data0') )
        data0 = deshify_data0;
    end
    
    data0 = data0( data0 > 0); % Make sure we have only positive values
    
    if isempty(data0)
        warning('No pixels in current ROI');
        return
    end

    
    % New method, better because does not assume data values starting at zero    
    s=sort(data0);
    dif=s(2:end)-s(1:end-1);
    u=unique(dif);
    u2=u(u>0);
    scale1=u2(1);
    data = data0 / scale1;
    
    % Correct for some odd files that have huge number of different values
    if (scale1 < 1)
        scale1 = 1;
        data = data0;
    end
    
    

    % Make histogram
    N = ceil( max( data)) ;
    binStep = 1;
    edges = 0.5:binStep:N+0.5;
    y = histcounts( data,edges);
    x = scale1 * ( edges(2:end) + 0.5 * binStep ); % Image amplitudes

    % Moving average filter
    windowSize = round( 0.05 * N ); % Depends on number of data points
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    yy = filtfilt(b,a,y); % Required if 

    
    % Plot
    histWindow = figure;
    plot(x,yy)
    hold on;
    plot(x,y)
    
%
% Find peaks
%


    % Peak 1
    i = 1; % Start at value 1
    d = windowSize; % Look ahead distance
    while ( yy(i+d) >= yy(i) )
       i = i + 1; 
    end
    peak1 = floor( i + 0.5*d ); % Initial guess
    try
        [M,I] = max( yy( peak1 - d : peak1 + d  )); % Find correct peak index
        peak1 = ( peak1 - d ) + I - 1; % Correct peak
    catch
    end
    
    disp( ['First peak at x = ' num2str( x(peak1) ) ]);
    line( [ x(peak1), x(peak1)], [ 0, max(y)] , 'LineWidth', 1, 'Color', 'blue');
    
    
    % Valley
    i = peak1 + d;
    while ( yy(i+d) < yy(i) -1 )
       i = i + 1; 
    end
    valley =  floor( i + 0.5*d);
   

    
    % Peak 2
    i = valley + d;
    while ( yy(i+d) > yy(i) )
       i = i + 1; 
    end
    peak2 = floor( i + 0.5*d - 1); % Initial guess
    [M,I] = max( yy( peak2 - d : peak2 + d  )); % Find correct peak index
    peak2 = ( peak2 - d ) + I - 1; % Correct peak
    
    disp( ['Second peak at x = ' num2str( x(peak2) ) ]);
    line( [ x(peak2), x(peak2)], [ 0, max(y)] , 'LineWidth', 1, 'Color', 'blue');


%
% Output
%
    threshold = x(peak1) + ( x(peak2) - x(peak1) ) / 2;
    disp( ['Threshold value at x = ' num2str( threshold ) ]);
    
    threshold_line = line( [ threshold, threshold], [ 0, max(y)] , 'LineWidth', 1, 'Color', 'green');
    

%    
% Clean up
%

    ClearVariables
    clear 'deshify_data0'
 

    returnCode = 0; % If it comes here a zero is returned