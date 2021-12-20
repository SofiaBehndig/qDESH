% % Inflate a VOI in all directions
%
% Idea: inflate a ventricle VOI created from thresholding a low pass
% filtered MRI image (which makes the VOI a bit small for search volume in
% a thresholding algorithm)
%
% Other VOIs are not overwritten
%
% Use with imlook4d
%
% How to use :
% Make a VOI
% Export to Workspace
% Run this script
% Threshold as you wish
%
% Jan Axelsson 2020-NOV-2

% USER PARAMETERS

dr=7
; % amount to inflate in all directions

% -----------

roiMatrix = imlook4d_ROI == imlook4d_ROI_number;

se = strel('cuboid',[ dr dr dr]);
newRoi = imdilate(roiMatrix,se); 

imlook4d_ROI( newRoi & ( imlook4d_ROI == 0) ) ... 
    = imlook4d_ROI_number; % Only voxels that have no ROI in them
    
Import
