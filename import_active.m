% Active object import
% make list of files to import
thisfolder = 'C:\Users\erinm\OneDrive - Indiana University\MATLAB files\raw_data\active output';
filelist = dir(fullfile(thisfolder,'*.txt')); % list of txt files in folder
%% Import each subject file in the folder and combine
for i = 1:size(filelist,1) %for each file
    filename = filelist(i); % whatever item in the list
    T = readtable(fullfile(thisfolder,filename.name));
    T = T(:,1:5);
    if i == 1
        Tbl = T;
    else
        Tbl = [Tbl; T];
    end
end
%% Table 1 - coordinates
    a = unique(Tbl.imageFilename); % how many unique images?
    n = 0; 
    for i = 1:size(a,1) %how many unique objects?
    thisone = Tbl(strcmp(Tbl.imageFilename, a{i}),:); % subset by image
    objnum = length(unique(thisone.obj_num)); % how many objects were labeled?  
     for j = 1:length(objnum)
            this2 = thisone(thisone.obj_num == j,:);
            if height(this2) > 0
            n = n + 1;
        end
     end
    end
    
    Active = Tbl;
 %% extract filename info   
    raw = string.empty;
    Active.active_num = Active.obj_num;
    full = string.empty;
    subject = string.empty;
    for i = 1:height(Active)
        somestring = Active.imageFilename{i}; % find current image name
        slash_indices = strfind(somestring,'\');
        under_indices = strfind(somestring,'_');
        jpg_indices = strfind(somestring,'.jpg'); 
        raw_imNumber = somestring(slash_indices(end)+1:jpg_indices-1);
        raw(i) = raw_imNumber; % find original image #
        subject(i) = somestring(under_indices(end-1)+1:under_indices(end)-1);
    formatSpec = "%s_%d";
    a1 = raw(i);
    a2 = Active.active_num(i);
    full(i) = sprintf(formatSpec,a1,a2);
    end
    
    Active.rawImage(:) = raw.';
    Active.act_name(:) = full.';
    Active.subject(:) = subject.';
    Active.imageFilename = [];
    %Active2 = Active(ismember(Active.subject(:), current_subs),:);
    %% Table 2 - size & centerpoint - create an empty table to store these values
    variables = [["rawImage", "string"]; ...
                ["active_num", "double"]; ...
                ["centerx","double"];...
                ["centery", "double"];...
                ["dist_centerx","double"];...
                ["dist_centery","double"];...
                ["size", "double"];...
                ["obj_num", "double"];...
                ["subject", "string"]];
            
    a = unique(Active(:,[6,7]),'rows');
    active_size_center = table('Size',[height(a),size(variables,1)],... 
	'VariableNames', variables(:,1),...
	'VariableTypes', variables(:,2));

%% Calculate and store DVs
% variables should be: rawImage, active num, obj num (zero for active), size,
% subject, x, y

 for i = 1:height(a) % for each unique image...
        this = Active(Active.act_name == a.act_name(i),:);
        active_size_center.rawImage(i) = this.rawImage(1);
        active_size_center.active_num(i) = this.active_num(1);
        active_size_center.obj_num(i) = this.active_num(1);
        active_size_center.centerx(i) = mean(this.active_x(:)); % find centerpoint x
        active_size_center.centery(i) = mean(this.active_y(:)); % find centerpoint y
        active_size_center.dist_centerx(i) = abs(active_size_center.centerx(i)-360);
        active_size_center.dist_centery(i) = abs(active_size_center.centery(i)-240);
        active_size_center.size(i) = polyarea(this.active_x(:),this.active_y(:));
        somestring = a.rawImage{i}; % find current image name
        under_indices = strfind(somestring,'_');
        active_size_center.subject(i) = somestring(under_indices(end-1)+1:under_indices(end)-1);
 end
%% clean up
if exist('keepVars','var')
    keepVars = [keepVars, 'Active' 'active_size_center'];
else
    keepVars = {'Active' 'active_size_center', 'keepVars'};
end
clearvars('-except',keepVars{:})