function UQAM_rename_csi

allSites      = get_TAB_site_names;
arg_default('sitesIn',allSites);        % default - all sites
pthSites = biomet_sites_default;

diary(fullfile(pthSites,'UQAM_rename_csi.log'));
fprintf('=================================================\n')
fprintf('Started: %s\n',datetime);

for currentSiteID = sitesIn
    siteID = char(currentSiteID);
    try
        timestamp_csi_files(fullfile(pthSites,siteID,'Met'));
    catch
    end
end

fprintf('Finished: %s\n',datetime);
fprintf('-------------------------------------------------\n')
diary off