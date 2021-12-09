% % Shrink a VOI coronal view from bottom (neck side) towards top of head
% until given volume is found
%
% Use with imlook4d
%
% How to use :
% Make a standardized VOI
% Export to Workspace (make sure flip and rotate is checked)
% Run this script
% Threshold
%
% Jan Axelsson 2020-NOV-20

% USER PARAMETERS

Vgoal = 30; % ml

% -----------

% Voxel size in ml
dV = 1e-3 * ...
    imlook4d_current_handles.image.pixelSizeX ...
    * imlook4d_current_handles.image.pixelSizeY ...
    * imlook4d_current_handles.image.sliceSpacing;  

SelectOrientation('Cor');
Export

origRoiMatrix = imlook4d_ROI == imlook4d_ROI_number;
roiMatrix = origRoiMatrix;

% First row
nonzero_y_roi_rows = sum( sum( roiMatrix, 3) , 1); % Sum over slices, then over columns (all 1 because of flipped and rotated)
i = min( find(nonzero_y_roi_rows>0) );
N = length(nonzero_y_roi_rows);

% Print info
disp( [ 'Original ROI volume = '  num2str( V(roiMatrix, dV) ) ' ml']);

% Shrink
while ( V(roiMatrix, dV) > Vgoal  &&  i < N )
    roiMatrix( :, i, :) = false;
    disp( [ 'i = ' num2str(i) '   V = ' num2str( V(roiMatrix, dV) ) ' [ml]' ]);
    i = i + 1;
end
    
% Put back new ROI into imlook4d
imlook4d_ROI(origRoiMatrix) = 0; % Clear current ROI
imlook4d_ROI(roiMatrix) = imlook4d_ROI_number; % Set
Import

% ----------------------------------

% Defined functions
function volume = V(roiMatrix, dV)
    volume = sum( roiMatrix(:) ) * dV;
end