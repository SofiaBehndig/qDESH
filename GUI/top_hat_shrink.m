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

% Use Vgoal = 30 ml, or use VolumeGoalInCm3 from deshify if exists
Vgoal = 30; % ml
if exist('VolumeGoalInCm3')
    Vgoal = VolumeGoalInCm3;
end

disp( ['Vgoal = ' num2str(Vgoal) ]);



% -----------

returnCode = 1; % Assume error, correct at end

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
    Vtophat0 = V(roiMatrix, dV);
    disp( [ 'i = ' num2str(i) '   V = ' num2str( Vtophat0 ) ' [ml]' ]);
    i = i + 1;
end
    
% Put back new ROI into imlook4d
imlook4d_ROI(origRoiMatrix) = 0; % Clear current ROI
imlook4d_ROI(roiMatrix) = imlook4d_ROI_number; % Set
Import

returnCode = 0; % If it comes here a zero is returned

% ----------------------------------

% Defined functions
function volume = V(roiMatrix, dV)
    volume = sum( roiMatrix(:) ) * dV;
end