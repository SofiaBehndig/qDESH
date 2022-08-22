% Run this script after rough ROIs are created in imlook4d
% 
%
% The parameter N tells how many slices to keep
% The script keeps N slices from ROI 1, 2, 3
% starting at the anterior-most slice, and removes the rest
%
% Usage example 1) :
% a) Use Deshify first tab, and press select-button 
% b) run this command :
%    Fixate_number_of_slices( 67 ) % Keeps 67 slices starting from first slice in ROI 
%
% Usage example 2) :
% a) Use imlook4d menu Workspace/Export (untouched)
% b) run this command :
%    Fixate_number_of_slices( 67 ) % Keeps 67 slices starting from first slice in ROI 
%
% Jan Axelsson 2022-AUG-22

function Fixate_number_of_slices( N)

    % Work in coronal view (work in BASE workspace)
    evalin('base', 'SelectOrientation(''Cor'')');
    evalin('base', 'Export');
    imlook4d_ROI = evalin('base', 'imlook4d_ROI');
    sz = size(imlook4d_ROI);
    lastIndex = sz(1) * sz(2) * sz(3);


    % Find anterior-most slice for ROIs 1, 2, 3
    for i = 1:3
        indeces = find ( imlook4d_ROI == i );
        [ r, c, z(i) ] = ind2sub( sz, indeces(1) ); % First index must be in first slice
    end

    % Warn if not same slice
    if ~all(z == z(1))
        warning([ 'Different slices in the ROIs : ' num2str( z) ])
    end

    % Keep only N first slicesd for ROIs 1, 2, 3
    roiPixels =  (imlook4d_ROI > 0) & (imlook4d_ROI < 4) ; % ROI pixels for ROI 1, 2, 3
    rangeToModify = ( z(i) + N ) : sz(3) ;
    rangeToZero = false( sz);  
    rangeToZero(:,:,rangeToModify) = true;   % This range should  be zeroed if containing ROIs 1, 2 or 3
    imlook4d_ROI( rangeToZero & roiPixels) = 0; % Zero ROI pixels with overlapping range and ROI pixels

    % Export back to BASE workspace 
    assignin('base','imlook4d_ROI', imlook4d_ROI);
    evalin('base', 'Import');
    
    disp('DONE!');

end