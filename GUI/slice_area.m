% slice_area.m
%
% SCRIPT for imlook4d to find the ROI slice area of the back-most (towards neck) VOI slice
%
% Instructions:
%   run this script after all the ROIs are thresholded for CSF
%
% Requires : 
%   Signal Processing Toolbox
%
% Jan Axelsson 2021-12-09

    IGNORE_LAST_ROI = true;  % true = Ignore last ROI, which is Ventricle volume, false = all ROIs

    
    % Initiate
    StoreVariables
    SelectOrientation('Ax');
    Export
    
    TAB=sprintf('\t');
    clipboardArea = '';
    area = [];
    dA = 0.01 * imlook4d_current_handles.image.pixelSizeX * imlook4d_current_handles.image.sliceSpacing; % cm2
    
    numberOfRois = length(imlook4d_ROINames) - 1;
    
    
    % Number of ROIs
    numberOfOutputs = numberOfRois;             % Alt 1) Use all ROIs
    if (IGNORE_LAST_ROI)
        numberOfOutputs = numberOfRois - 2;     % Alt 2) Ignore last two ROIs
    end
    
    
    % Calculate areas
    for i = 1 : numberOfOutputs
       ySlicePos(i) = min( find(  sum( ( imlook4d_ROI == i) , [1,3] ) > 0 ) );
       area(i) = sum( squeeze( imlook4d_ROI( :, ySlicePos(i), :) == i ), 'all')  * dA;  % Sum pixels in current ROI, for slice at y=ySlicePos

       clipboardArea = [clipboardArea num2str( area(i) ) TAB];
    end
    

    % Display
    rowNames = imlook4d_ROINames(1:numberOfOutputs);
    t = table( area', ySlicePos', ...
        'VariableNames',{'area (cm2)','y'},...
        'RowNames', rowNames );
    
    disp(t)

    
    % Clipboard
    clipboard('copy', clipboardArea(1:end-1));
    disp('area is copied to clipboard');

    
    % Finish
    ClearVariables
 
