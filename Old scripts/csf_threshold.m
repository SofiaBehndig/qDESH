% csf_threshold.m
%
% SCRIPT for imlook4d to find a CSF threshold for a ROI
% determined from CSF peak position in ROI
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
% Jan Axelsson 2020-12-14

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

    % Make histogram
    N = ceil( max( data));
    binStep = 1;
    y = histcounts( data,N);
    x = 1:binStep:N;

    % Moving average filter
    windowSize = round( 0.5*N / 10 ); % Depends on number of data points
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    yy = filtfilt(b,a,y); % Required if 
    
    % Plot
    figure;
    plot(x,yy)
    hold on;
    plot(x,y)
    
%
% Find peak
%

    % Peak 1 (old method)
    i = 1; % Start at value 1
    d = windowSize; % Look ahead distance
    while ( yy(i+d) > yy(i) )
       i = i + 1; 
    end
    peak1 = floor( i + 0.5*d);
    disp( ['First peak at x = ' num2str(peak1) ' (old method on filtered data)' ]);


    threshold = peak1  * 4; % Threshold value

    
%
% New find peak using centroid
%
    peak = peak1; % Peak based on above guess
    
    % Work on unfiltered data


    % Peak first estimate (highest value in unfiltered data)
    highest = 1;
    for i = 1 : length(y)
        if (y(i) > highest)
            highest = y(i);
            peak = i;
        end
    end
    disp( ['First peak estimate at x = ' num2str(peak)   ]);
    
    % Find start for centroid on unfiltered data
    h = 0.8 * highest ; % Amplitudes above this are in peak
    i = peak; 
    while ( y(i) > h  )
       i = i - 1; 
    end  
    start = i;
    
    % Find end for centroid
    i = peak; 
    while ( y(i) > h  )
       i = i + 1; 
    end  
    stop = i;

    % Calculate centroid
    disp( ['Calculate centroid in range = ' num2str(start) ' to ' num2str(stop)  ]);
    left = sum( y( start : peak) );
    right = sum( y( peak : stop) );
    leftDistance = peak - start;
    rightDistance = stop - peak;
    centroid = ( left * leftDistance + right * rightDistance ) / ( left + right);
    peakCentroidPosition = start + centroid;

    disp( ['Centroid peak at x = ' num2str(peakCentroidPosition) ]);

%
% Output
%
    threshold = 4 * peakCentroidPosition; 
    disp( ['-> Centroid threshold value at x = ' num2str( threshold ) ]);

    % Set level in imlook4d Threshold GUI :
    imlook4d_store.Threshold.inputs{1}=num2str( threshold);
    imlook4d_store.Threshold.inputs{2}=num2str( 0 );
    imlook4d_store.Threshold.inputs{3}='1';
    imlook4d_store.Threshold.inputs{4}='end';
    
    % Clean up
    imlook4d_store_backup = imlook4d_store; % Keep even if listed in ClearVariables
    %ClearVariables
    imlook4d_store = imlook4d_store_backup;
    clear 'imlook4d_store_backup'
    
