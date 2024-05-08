function folderDatabase = biomet_database_default
fPath = mfilename('fullpath');
fPath = fileparts(fPath);
ind = find(fPath==filesep);
projectFolder = fPath(1:ind(end)); 
folderDatabase = fullfile(projectFolder,'Database');
