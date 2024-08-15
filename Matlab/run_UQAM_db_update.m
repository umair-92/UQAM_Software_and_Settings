function run_UQAM_db_update(yearIn,sitesIn)
% Main UQAM data processing function
%
% This program is based on run_BB_db_update (Micromet- UBC)
%
% Zoran Nesic           File created:       May  6, 2024
%                       Last modification:  Aug 13, 2024

%
% Revisions:
%
% Aug 15, 2024 (Zoran)
%   - Fixed bug. Proper call for potential_radiation is:
%       potential_radiation(now+5/48,45.5,73.7)
%     and NOT:
%       potential_radiation(now,45.5,-73.7)
% Aug 13, 2024 (Zoran)
%   - Limitted picture taking hours based on the potential radiation.
% Jul 10, 2024 (Zoran)
%   - Added UQAM_1 site.


startTime = datetime;
arg_default('yearIn',year(startTime));             % default - current year
arg_default('sitesIn',{'UQAM_0','UQAM_1'});        % default - all sites

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
    % Take time-lapse photos only once per hour during daytime
    if potential_radiation(now+5/48,45.5,73.7) > 50 && minute(datetime)<30
        hourIn = hour(datetime);
        switch siteID
            case 'UQAM_0'
                netCam_Link = 'http://173.182.84.12:4925/netcam.jpg';
                take_Phenocam_picture(siteID,netCam_Link,hourIn)
            case 'UQAM_1'
                netCam_Link = 'http://68.182.132.135:4925/netcam.jpg';
                take_Phenocam_picture(siteID,netCam_Link,hourIn)            
            otherwise
        end
    end
end
fprintf('\n\n%s\n',datetime);
fprintf('**** run_UQAM_db_update finished in %6.1f sec.******\n',seconds(datetime-startTime));
fprintf('=====================================================\n\n\n');

