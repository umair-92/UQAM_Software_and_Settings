function UQAM_rename_csi_and_process_ECCC
pthSites = biomet_sites_default;

diary(fullfile(pthSites,'UQAM_rename_csi_and_process_ECCC.log'));
fprintf('=================================================\n')
fprintf('Started: %s\n',datetime);
try
    timestamp_csi_files(fullfile(pthSites,'UQAM_0','Met'));
catch
end

try
    fprintf('Start ECCC processing\n');
    monthRange = month(datetime)+[-1:0];
    stationIDs = [27646];
    run_ECCC_climate_station_update(year(datetime),monthRange,stationIDs,db_pth_root)
    fprintf('Finish ECCC processing\n');
catch ME
    disp(ME);
end
fprintf('Finished: %s\n',datetime);
fprintf('-------------------------------------------------\n')
diary off
