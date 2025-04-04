% This script takes the original TopHat ROI from Deshify program, and makes two ROIs :
% 1) Falx top (1 cm heigh), and 
% 2) Falx bottom (2 cm heigh, below top) 
%
% COR :   _____________________ . . . . . .
%        /        |___| . . . .\ . . . . . | 1 cm     
%       /         |   |         \     |            |
%      /          |___| . . . .  \  . | 2 cm       | original top had ROI (illustrating not same height)
%                 |   |                            |
%
% 
% SAG :         ____------_______
%              /       |___ 1|    ----              New ROIs 1 & 2 follow brain shape in Sagital view
%             /        |   --|         \    
%            /         |___ 2|          \    
%   (nose)  /          |   --|           |  (Neck)              
%
%     
% Assumptions:
% - AC-PC line is centered in coronal view
% - Top Hat ROI is created by Deshify
%
%
% HOW TO USE
% 1) Select Top Hat ROI in imlook4d
% 2) In imlook4d select "Workspace/Export Untouched"
% 3) Run this script 

%
% Jan Axelsson 2025-APR-03

%
% Input parameters
% 
    
    % Width and height for falx roi 
    falxRoiWidthInMm = 30;        % mm
    falxTopROiHeightInMm = 10;    % mm
    falxBottomROiHeightInMm = 20; % mm

%
% Prepare before creating ROIs
% 

    % Top hat initial mask (will be shrunk later)
    mask = (imlook4d_ROI == imlook4d_ROI_number);
    
    
    % Make sure coronal view
    SelectOrientation('Cor');
    
    
    % Get boundaries in x
    [xPixels,~,~] = size(imlook4d_Cdata);
    xCenter = round( xPixels / 2);
    
    mmX = imlook4d_current_handles.image.pixelSizeX;           % mm / pixel
    xHalfWidthInPixels = round( 0.5 * falxRoiWidthInMm / mmX); % half width
    
    xStart = xCenter - xHalfWidthInPixels;
    xEnd = xCenter + xHalfWidthInPixels;

    % Trim mask in x-direction
    mask( 1:xStart, :, : ) = 0;
    mask( xEnd:end, :, : ) = 0;
    
    % Get boundaries in z 
    proj_z = any(mask, [1, 2]); % Project x,y data to z-axis
    proj_z = proj_z(:); % Ensure it's a column vector
    
    zStart = find(proj_z, 1, 'first');
    zEnd = find(proj_z, 1, 'last');
    
    % Get height of ROIs in pixels
    mmY = imlook4d_current_handles.image.pixelSizeY;           % mm / pixel

    yTopRoiHeightInPixels = round( falxTopROiHeightInMm / mmY);       % full height
    yBottomRoiHeightInPixels = round( falxBottomROiHeightInMm / mmY); % full height

    % Get ROI top contour
    proj_y = any(mask, [1, 3]);
    proj_y = proj_y(:); % Ensure it's a column vector
    yTop = find(proj_y, 1, 'first');

%
% Create new ROIs
% 

    newROIs = zeros( size(imlook4d_ROI) , 'uint8' );

    % Slice by slice (coronal view)
    for iz = zStart : zEnd
        disp(iz)
        mask2D = mask(:,:,iz);

        % Drop down from tophat top-pixels -- creating fixed height ROIs following brain contour
        for ix = xStart : xEnd % Outside is already trimmed away in x-direction

            % All pixels in y-direction
            vector = mask2D( ix, :);  % All pixels in y-direction
            vector = vector(:);       % Ensure it's a column vector
            yTop = find( vector , 1, 'last');  % top pixel positions profile in y

            % Top ROI y-pixel profile
            topRoiHeighest = yTop;
            topRoiLowest = topRoiHeighest - yTopRoiHeightInPixels;
            
            % Bottom ROI y-pixel profile
            bottomRoiHeighest = topRoiLowest;
            bottomRoiLowest = bottomRoiHeighest - yBottomRoiHeightInPixels;

            newROIs( ix, yTop, iz ) = 1;  % Top ROI
            newROIs( ix, topRoiLowest : topRoiHeighest, iz ) = 1;  % Top ROI
            newROIs( ix, bottomRoiLowest : bottomRoiHeighest, iz ) = 2;  % Top ROI

        end

    end

    imlook4d_ROI = newROIs; Import
   
