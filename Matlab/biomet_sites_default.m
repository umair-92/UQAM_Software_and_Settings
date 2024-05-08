function folderSites = biomet_sites_default
fPath = mfilename('fullpath');
fPath = fileparts(fPath);
ind = find(fPath==filesep);
projectFolder = fPath(1:ind(end)); 
folderSites = fullfile(projectFolder,'Sites');
