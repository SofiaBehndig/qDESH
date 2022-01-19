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
    if ( ~exist( 'imlook4d_store_backup'))
        imlook4d_store_backup = []; % This should not be auto-cleaned
    end
    StoreVariables

    % Output from 'SCRIPTS/ROI/Roi data to work space'
    data0 = imlook4d_ROI_data.pixels{imlook4d_ROI_number};
    data0 = data0( data0 > 0); % Make sure we have only positive values
    
    if isempty(data0)
        warning('No pixels in current ROI');
        return
    end
    
        
    % scale indata to correct format? needs verification but is "close
    % enough"  to work
    %scale1 = min(data0);
    %data = data0 / scale1;
    % data=1000*data;
    
    s=sort(data);
    dif=s(2:end)-s(1:end-1);
    u=unique(dif);
    u2=u(u>0);
    scale1=u2(1);
    data = data0 / scale1;

    % Make histogram
    N = ceil( max( data)) ;
    binStep = 1;
    edges = 0.5:binStep:N+0.5;
    y = histcounts( data,edges);
    x = scale1 * ( edges(2:end) + 0.5 * binStep ); % Image amplitudes

    % Moving average filter
    windowSize = round( 0.025 * N ); % Depends on number of data points
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    yy = filtfilt(b,a,y); % Required if 
    
    % Plot
    figure;
    plot(x,yy)
    hold on;
    plot(x,y)
    
%
% Find peaks
%


    % Peak 1
    i = 1; % Start at value 1
    d = windowSize; % Look ahead distance
    while ( yy(i+d) > yy(i) )
       i = i + 1; 
    end
    peak1 = floor( i + 0.5*d);
    disp( ['First peak at x = ' num2str( x(peak1) ) ]);
    line( [ x(peak1), x(peak1)], [ 0, max(y)] , 'LineWidth', 1, 'Color', 'blue');
    
    % Half width Peak 1
    i = peak1 + 1;
    while ( yy(i) > 0.5 * yy(peak1) )
       i = i + 1; 
    end
    hwhm = floor( i-peak1 ); % Half width half maximum
    disp( ['Half width at half max = ' num2str( scale1 * hwhm ) ]);

    % Valley
    while ( yy(i+d) < yy(i) )
       i = i + 1; 
    end
    valley =  floor( i + 0.5*d);
    disp( ['Valley at x = ' num2str( x(valley) ) ]);
    line( [ x(valley), x(valley)], [ 0, y(valley)] , 'LineWidth', 1, 'Color', 'black');

    % Peak 2
    while ( yy(i+d) > yy(i) )
       i = i + 1; 
    end
    peak2 = floor( i + 0.5*d);
    disp( ['Second peak at x = ' num2str( x(peak2) ) ]);
    line( [ x(peak2), x(peak2)], [ 0, max(y)] , 'LineWidth', 1, 'Color', 'blue');


%
% Output
%
    threshold = x(peak1) + ( x(peak2) - x(peak1) ) / 2;
    disp( ['Threshold value at x = ' num2str( threshold ) ]);
    
    line( [ threshold, threshold], [ 0, max(y)] , 'LineWidth', 1, 'Color', 'green');

    % Set level in imlook4d Threshold GUI :
    imlook4d_store.Threshold.inputs{1}=num2str( threshold);
    imlook4d_store.Threshold.inputs{2}=num2str( min(data) );
    imlook4d_store.Threshold.inputs{3}='1';
    imlook4d_store.Threshold.inputs{4}='end';
    
    % Clean up
    imlook4d_store_backup = imlook4d_store; % Keep even if listed in ClearVariables
    %ClearVariables
    imlook4d_store = imlook4d_store_backup;
    clear 'imlook4d_store_backup'
    
%
% Do Thresholding and go to next ROI
%

    SelectROI( imlook4d_ROI_number  );

    INPUTS = Parameters( {num2str(threshold), num2str( min(data)),  '1', 'end'} );
    Threshold_within_ROI


    imlook4d_ROI_number = imlook4d_ROI_number +1   
