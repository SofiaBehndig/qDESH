% Threshold all VOIs
%
%
% Jan Axelsson 2022-JAN-21

% USER PARAMETERS


% -----------
returnCode = 1; % Assume error, correct at end

% Volumes from ROIs
SYLV_L = imlook4d_ROI_data.volume(1);
SYLV_R = imlook4d_ROI_data.volume(2);
TOPHAT = imlook4d_ROI_data.volume(3);

% Reference goal volume, and actual start volume
REF_VOLUME = Vgoal;             % Defined in top_hat_shrink
ACTUAL_START_VOLUME = Vtophat0; % Found in top_hat_shrink

% Q-DESH is ratio :  [ Sylvian-fissure-volume ] / [ Tophat volume ]
% where 
% [ Tophat volume ] = TOPHAT * (REF_VOLUME / ACTUAL_START_VOLUME) 
% which is normalized by factor  (REF_VOLUME / ACTUAL_START_VOLUME)  to correct for variation in actual start volume
%
% Q-DESH :
desh_value = ( SYLV_L + SYLV_R ) / (  TOPHAT * (REF_VOLUME / ACTUAL_START_VOLUME)  );  

%Import

% Clean up from GUI
clear SYLV_L SYLV_R TOPHAT REF_VOLUME ACTUAL_START_VOLUME

returnCode = 0; % If it comes here a zero is returned