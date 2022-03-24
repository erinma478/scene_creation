%% this script is based off placing points on individual toys in MATLAB imageLabeler
% input is croppedImages
% label type = line labels; export to workspace as table

oc = NaN(height(objCount),1);
files = strings(height(objCount),1);

for i = 1:height(objCount) %how many images labeled?
    oc(i) = size(objCount.objects{i,1},1); 
    files(i) = objCount.imageFilename{i};
end

tbl = array2table(files);
tbl.objCount = oc;
writetable(tbl,"objectcount.csv")
