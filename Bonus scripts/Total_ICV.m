% Intracrainial brain volume from SPM propabilaty map
%Step 1: Segment
%Step 2: Open non-segmented image in imlook4d
%Step 3: Scripts/ SPM/ SPM tissue propabilaty map ROIs
%Step 4: Export to workspace
%Step 5: run this script
imlook4d_ROI = and( (imlook4d_ROI < 4) , (imlook4d_ROI > 0) ); Import %
