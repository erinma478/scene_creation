% calculate visual area and position in image from bounding box coordinates
%% set up variables
coords = readtable('C:\Users\erinm\Desktop\osf\bounding_box_coords_v2.csv');

idlist = unique(coords.uniqueid(:));
centerx = NaN(height(idlist),1);
centery = NaN(height(idlist),1);
dist_centerx = NaN(height(idlist),1);
dist_centery = NaN(height(idlist),1);
dist_center = NaN(height(idlist),1);
size_px = NaN(height(idlist),1);
size_px_log = NaN(height(idlist),1);
size_deg = NaN(height(idlist),1);
%% calculate contrast in a loop
for i = 1:height(idlist)
    df = coords(coords.uniqueid == idlist(i),:);
    
    r = df.x(:).';
    c = df.y(:).';
    
    size_px(i) = polyarea(r,c);
    size_px_log(i) = log10(size_px(i));
    
    horzFOV = 79.5;
    imWidth = 720;
    deg_per_px = horzFOV/imWidth;
    size_deg(i) = size_px(i) * deg_per_px;
    
    pgon = polyshape(r,c);
    [centerx(i),centery(i)] = centroid(pgon);
    dist_centerx(i) = abs(centerx(i)-240);
    dist_centery(i) = abs(centery(i)-360);
    dist_center(i) = sqrt(dist_centerx(i)^2 + dist_centery(i)^2);
    dist_center_deg(i) = dist_center(i) * deg_per_px;
end

%% write file
fullDF = array2table([idlist,size_px, size_px_log, size_deg, centerx, centery,...
    dist_centerx, dist_centery, dist_center]);

fullDF.Properties.VariableNames = {'uniqueid','size_px', 'sizelog', 'size_deg',...
    'centerx','centery','dist_centerx', 'dist_centery', 'dist_center'};

writetable(fullDF, "size_center.csv",'Delimiter',',');