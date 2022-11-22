% Threshold all VOIs
%
%
% Jan Axelsson 2022-JAN-21

% USER PARAMETERS


% -----------
returnCode = 1; % Assume error, correct at end

SYLV_L = imlook4d_ROI_data.volume(1);
SYLV_R = imlook4d_ROI_data.volume(2);
TOPHAT = imlook4d_ROI_data.volume(3);
REF_VOLUME = Vgoal;  % From top_hat_shrink

desh_value = ( SYLV_L + SYLV_R ) / ( TOPHAT * REF_VOLUME / Vtophat0 );  % Vtophat0 is what we found

%Import

% Clean up from GUI
clear SYLV_L SYLV_R TOPHAT REF_VOLUME

returnCode = 0; % If it comes here a zero is returned