function setProjectDefaults(projectPath)
% Put all project paths under set(0,'UserData') so all functions have
% access to it
%
% NOTE: This is not used. Concept testing only!
%
% Zoran Nesic           File created:       May 5, 2024
%                       Last modification:  May 5, 2024

% Revisions
%


% 
% arg_default('databasePath',biomet_database_default);
% arg_default('sitesPath',biomet_sites_default);

if ~exist(projectPath,'dir')
    error('Folder: %s does not exist!',projectPath);
end

UserData = get(0,'UserData');
UserData.biomet.database_path   = fullfile(projectPath,'Database');
UserData.biomet.sites_path      = fullfile(projectPath,'Sites');
set(0,'UserData',UserData);
