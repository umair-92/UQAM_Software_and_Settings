% Testing wind direction issues
siteID = 'UQAM_3';
yearIn = 2025;
pathMain = fullfile('z:\uqam-site\database',num2str(yearIn),siteID);

tv=read_bor(fullfile(pathMain,'flux','clean_tv'),8);
tv_dt=datetime(tv,'ConvertFrom','datenum');
wind_dir=read_bor(fullfile(pathMain,'flux','wind_dir'));
wd = read_bor(fullfile(pathMain,'met','wd'));
figure(1);
plot(tv_dt,[wind_dir wd],'o')
zoom on
title('Original data')
legend('wind-dir','wd')
%%

% correct wd for the period before Aug 26, 2025
% by ADDING 120 degrees.
wd_c = wd;
wd_c( tv_dt<="Aug 26, 2025 14:00")=wd( tv_dt<="Aug 26, 2025 14:00")+120;
% keep all directions between 0-360
wd_c(wd_c>360 ) = wd_c(wd_c>360) - 360;
figure(2)
plot(tv_dt,[wind_dir wd_c],'o')
title('Corrected time series')
legend('wind_dir','wd')

figure(3)
plot(wind_dir,wd_c,'o')
title('Corrected time series')
xlabel('wind-dir')
ylabel('wd_c')