function UQAM_process_ECCC

pthSites = biomet_sites_default;

diary(fullfile(pthSites,'UQAM_process_ECCC.log'));
fprintf('=================================================\n')
fprintf('Started: %s\n',datetime);

try
    fprintf('Start ECCC processing\n');
    monthRange = month(datetime)+[-1:0];
    stationIDs = [8321 10732 27646];
    run_ECCC_climate_station_update(year(datetime),monthRange,stationIDs,db_pth_root)
    fprintf('Finish ECCC processing\n');
catch ME
    disp(ME);
end
fprintf('Finished: %s\n',datetime);
fprintf('-------------------------------------------------\n')
diary off