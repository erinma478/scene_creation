%Average L, RG and BY contrast of an object in an ROI to get a contrast score 
%% set up variables
mypath = "C:\Users\erinm\Desktop\osf\rawImages";
coords = readtable("C:\Users\erinm\Desktop\osf\bounding_box_coords_v2.csv");
coords.rawImage = convertCharsToStrings(coords.rawImage);

idlist = unique(coords.uniqueid(:));

RMS_in = NaN(height(idlist),1);
RMS_all = NaN(height(idlist),1);
RMS_prop = NaN(height(idlist),1);
%% calculate contrast in a loop
for i = 1:height(idlist)
    df = coords(coords.uniqueid == idlist(i),:);
    v = max(df.vertex);
    myname = append(df.rawImage{1},'.jpg');
    I = imread(fullfile(mypath,myname));    
    
    r = df.x(1:v).';
    c = df.y(1:v).';
    
    mask_in = roipoly(I,r,c); % mask based on coder bounding
    
    % crop mask_out to smaller window centered on mask
    pgon = polyshape(r,c);
    [xc,yc] = centroid(pgon); % object centerpoint
    x1 = xc-200; % left edge of window
    y1 = yc-200; % top edge of window
    
    mask_in = imcrop(mask_in,[x1,y1,400,400]);
    
    thisIm = imcrop(I,[x1,y1,400,400]);    
    ILab = rgb2lab(double(thisIm)./256);
    FinalLum = ILab(:,:,1);
    RMS_in(i) = std(FinalLum(mask_in))./mean(FinalLum(mask_in));
    RMS_all(i) = std(FinalLum(:))./mean(FinalLum(:));
    RMS_prop(i) = RMS_in(i)/RMS_all(i);
end    

%%
df = array2table([RMS_in,RMS_all,RMS_prop]);
writetable(df, "Lumcontrast.csv")