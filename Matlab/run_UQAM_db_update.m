function run_UQAM_db_update(yearIn,sitesIn)
% Main UQAM data processing function
%
% This program is based on run_BB_db_update (Micromet- UBC)
%
% Zoran Nesic           File created:       May  6, 2024
%                       Last modification:  May  6, 2024

%
% Revisions:
%


startTime = datetime;
arg_default('yearIn',year(startTime));             % default - current year
arg_default('sitesIn',{'UQAM_0'});                 % default - all sites

if ischar(sitesIn)
    sitesIn = {sitesIn};
end

fprintf('===============================\n');
fprintf('***** run_UQAM_db_update ******\n');
fprintf('===============================\n');
fprintf('%s\n',datetime);
% Run database updates for on-line data
db_update_UQAM_site(yearIn,sitesIn);

% Cycle through all the sites and do site specific chores
% (netCam picture taking, ...)
for currentSiteID = sitesIn
    siteID = char(currentSiteID);
    % Take time-lapse photos 
    switch siteID
        case 'UQAM_0'
            netCam_Link = 'http://68.182.132.135:4925/netcam.jpg';
            take_Phenocam_picture(siteID,netCam_Link,0:24)
        otherwise
    end

end
fprintf('\n\n%s\n',datetime);
fprintf('**** run_UQAM_db_update finished in %6.1f sec.******\n',seconds(datetime-startTime));
fprintf('=====================================================\n\n\n');

