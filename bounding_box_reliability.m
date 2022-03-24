%% read in files 
mypath = "C:\Users\erinm\Desktop\osf\older docs";
fulldf = readtable(fullfile(mypath,"allcoords.csv"));
fulldf.rawImage = convertCharsToStrings(fulldf.rawImage);

U = unique(fulldf(:,[2,6,7]),'rows'); %extract unique combos 
%% calculate intersection between bounds for the same object-image combo
Agreement = zeros(height(U),1);
for i = 1:height(U)
    x = fulldf(fulldf.rawImage == U.rawImage(i) & fulldf.obj_num == U.obj_num(i),:);
    x2 = unique(x,'rows');
    starts = find(x2.vertex(:) == 1);
    if length(starts) > 1
        rater1 = x2{starts(1):starts(2)-1,4:5};
        rater2 = x2{starts(2):starts(2)+3,4:5};
        poly1 = polyshape(rater1(:,1).',rater1(:,2).');
        poly2 = polyshape(rater2(:,1).',rater2(:,2).');
        
        int = intersect(poly1,poly2);
        int2 = polyarea(int.Vertices(:,1).',int.Vertices(:,2).');
        uni = union(poly1,poly2);
        uni2 = polyarea(uni.Vertices(:,1).',uni.Vertices(:,2).');
        Agreement(i) = int2/uni2;
    end
end
%% to get overall agrrement, take rows without 0 & average
A2 = Agreement(Agreement > 0);
A3 = A2(A2 < 1);
mean(A3)