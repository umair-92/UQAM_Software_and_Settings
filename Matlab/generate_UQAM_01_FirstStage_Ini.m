%% Create FirstStage ini file
structSetup.startYear = 2024;
structSetup.startMonth = 1;
structSetup.startDay = 1;
structSetup.endYear = 2999;
structSetup.endMonth = 12;
structSetup.endDay = 31;
structSetup.Site_name = 'UQAM_0';
structSetup.SiteID = 'UQAM_0';
structSetup.allMeasurementTypes = {'MET','Flux'};
structSetup.Difference_GMT_to_local_time = 5;  % local+Difference_GMT_to_local_time -> GMT time
structSetup.outputPath = []; % keep it in the local directory

createFirstStageIni(structSetup)