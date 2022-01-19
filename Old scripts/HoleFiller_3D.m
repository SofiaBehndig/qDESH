% Hole_Fill_ROI.m
%
% SCRIPT for imlook4d to Hole Fill a ROI
%
%
% Jan Axelsson

%
% INITIALIZE
%

    % Export to workspace
    StartScript


    % Voxel size
    try
        dX=imlook4d_current_handles.image.pixelSizeX;
        dY=imlook4d_current_handles.image.pixelSizeY;
        dZ=imlook4d_current_handles.image.sliceSpacing;
    catch
        warning('Imlook4d: Pixel dimensions unknown -- Assuming 1x1x1 mm voxels');
        dX=1;
        dY=1;
        dZ=1;
    end

    
    % Define filter
        prompt={'x radius [mm]', 'y radius [mm]', 'z radius [mm]'};
        title='Hole filling filter';
        numlines=1;
        defaultanswer={ '3', '3', '3' };
        answer=inputdlg(prompt,title,numlines,defaultanswer);
        
        % Calculate width (in number of pixels)           
            widthInMmX = str2num(answer{1});
            widthInMmY = str2num(answer{2});
            widthInMmZ = str2num(answer{3});
            
            radX = round(widthInMmX/dX);
            radY = round(widthInMmY/dY);
            radZ = round(widthInMmZ/dZ);
 
            disp(['Radius [mm] (x,y,z)=(' ...
                num2str(widthInMmX) ', ' ...
                num2str(widthInMmY) ', '...
                num2str(widthInMmZ) ...
                ') mm']);   
            
            disp(['Radius [pixels] (x,y,z)=(' ...
                num2str(radX) ', ' ...
                num2str(radY) ', '...
                num2str(radZ) ...
                ') pixels']);



%
%  PROCESS
%


    imgbw = imlook4d_ROI == imlook4d_ROI_number;

    img_close = imclose(imgbw , strel('cuboid', [ radX radY radZ ]) );

    imlook4d_ROI = uint8(img_close);



%
% FINALIZE
% 
    % Record history (what this image has been through)
    historyDescriptor = 'HoleFilled';
    imlook4d_current_handles.image.history=[historyDescriptor '-' imlook4d_current_handles.image.history  ];
    guidata(imlook4d_current_handle, imlook4d_current_handles);
    
    imlook4d('importFromWorkspace_Callback', imlook4d_current_handle,{},imlook4d_current_handles);  % Import from workspace
   
    EndScript
