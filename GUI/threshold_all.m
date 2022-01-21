% Threshold all VOIs
%
%
% Jan Axelsson 2022-JAN-21

% USER PARAMETERS


% -----------
returnCode = 1; % Assume error, correct at end

binaryPixelsToKeep = cast( ( imlook4d_Cdata <= threshold ),'uint8'); % 0 or 1, pixels above threshold
imlook4d_ROI = imlook4d_ROI .* binaryPixelsToKeep;
    
Import

% Clean up from GUI
%clear binaryToPixelsToKeep

returnCode = 0; % If it comes here a zero is returned