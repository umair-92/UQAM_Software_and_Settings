function [t,x] = uqam_pl(ind, yearIn, siteID, select, fig_num_inc,flgPause) 
%
% [t,x] = UQAM_pl(ind, yearIn,siteID, select, fig_num_incflgPause)
%
%   This function plots selected data from the data-logger files. It reads from
%   the UBC data-base formated files.
%
% (c) c) Nesic Zoran         File created:       Jul 15, 2024      
%                            Last modification:  Apr 11, 2025
%           
%

% Revisions:
%
% Apr 11, 2025 (Zoran)
%   - added UQAM-3
%   - chaged input variable name "year" to "yearIn"
%   - chagned how default year is created (used datetime)
% Jan 2, 2025 (Zoran)
%   - added try/catch/end when setting up xlim for cumulative precip.
%     Otherwise the program doesn't work well at the beginning of a new yearIn.

arg_default('fig_num_inc',1);
arg_default('select',1);
arg_default('siteID',{'UQAM_1','UQAM_3'});
arg_default('flgPause',1);              % default is show one figure and pause

arg_default('yearIn',year(datetime));              % assume current yearIn

pthSite = biomet_path('yyyy',siteID);

if nargin < 1 
    error 'Too few imput parameters!'
end

GMTshift = 0/24;                            % offset to convert GMT to PST
siteID = upper(siteID);                     % convert to uppercase

st = min(ind);                              % first day of measurements
ed = max(ind)+1;                            % last day of measurements (approx.)
ind = st:ed; %#ok<*NASGU>

datesTmp = datenum(yearIn,1,[st ed]);
[rangeYears,~,~,~,~,~] = datevec(datesTmp);
rangeYears = rangeYears(1):rangeYears(2);

tv=fr_round_time(read_bor(fullfile(pthSite,'MET','TimeVector'),8,[],rangeYears)); % get time from the data base
t = tv - datenum(yearIn,1,0) - GMTshift;               % convert decimal time to
                                                    % decimal DOY local time
t_all = t;                                          % save time trace for later                                                    
ind = find( t >= st & t <= ed );                    % extract the requested period
t = t(ind);
fig_num = 1 - fig_num_inc;

allAxes = [];
indAxes = 0;
%----------------------------------------------------------
% HMP air temperatures
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Air Temperature');

trace_path  = char(fullfile(pthSite,'MET','TA_1_1_1_AVG'),...
                   fullfile(pthSite,'MET','TA_1_2_1_AVG'),...
                   fullfile(db_pth_root,'yyyy\ECCC\10732\30min','Tair'),...
                   fullfile(pthSite,'Flux','air_temperature')...                   
                   );
tempOffset = [0 0 0 273.15];   %273.15 273.15];
trace_legend = char('T_{HMP-1}','T_{HMP-2}','ECCC 10732','SonicT');
trace_units = 'T_{air}(degC)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num,[],tempOffset );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% HMP RH
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Relative Humidity');

trace_path  = char(fullfile(pthSite,'MET','RH_1_1_1_AVG'),...
                   fullfile(pthSite,'MET','RH_1_2_1_AVG'),...
                   fullfile(db_pth_root,'yyyy\ECCC\10732\30min','RH')...
                   );
trace_legend = char('RH_{HMP-1}','RH_{HMP-2}','ECCC 10732');
trace_units = 'RH (%)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;


%----------------------------------------------------------
% Rain gauges
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,'Precipitation');

trace_path  = char(fullfile(pthSite,'MET','P_1_1_1_tot'),...
                   fullfile(db_pth_root,'yyyy\ECCC\10732\30min','Precip')...
                   );
trace_legend = char('TB-Site','TB-ECCC');

trace_units = 'Precipitation (mm/30-min)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;
% remember xlim, you'll need it to rescale cumulative rain
originalXlim = xlim;

%----------------------------------------------------------
% Cumulative rain
%----------------------------------------------------------
% *** in case of multiple-yearIn plots it plots only the last yearIn
indx = find( t_all >= 1 & t_all <= ed );                    % extract the period from
tx = t_all(indx);                                           % the beginning of the last yearIn
indNew = [1:length(indx)]+round(GMTshift*48);               % use GMTshift to align the data with time vector


trace_name  = sprintf('%s: %s',siteID,'Cumulative Rain (current yearIn only)');
trace_units = 'Precipitation (mm)';
trace_legend = char('TB-Site','TB-ECCC');
y_axis      = [];

trace_path  = char(fullfile(pthSite,'MET','P_1_1_1_tot'));
[x1,tx_new] = read_sig(trace_path(1,:), indNew,yearIn, tx,0); %#ok<*ASGLU>
x1(isnan(x1)) = 0; % replace NaNs with 0 so that cumsum can work

trace_path  = char(fullfile(db_pth_root,'yyyy\ECCC\10732\30min','Precip'));
[x2,tx_new] = read_sig(trace_path(1,:), indNew,yearIn, tx,0); %#ok<*ASGLU>
x2(isnan(x2)) = 0; % replace NaNs with 0 so that cumsum can work

fig_num = fig_num + fig_num_inc;
x = plt_msig( [cumsum(x1) cumsum(x2)], ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
try
    xlim(originalXlim);
    indAxes = indAxes+1; allAxes(indAxes) = gca;
catch
    close(fig_num);
    fig_num = fig_num - fig_num_inc;
end


%----------------------------------------------------------
% CNR4 components
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' CNR4 components');

trace_path  = char(fullfile(pthSite,'MET','SW_IN_AVG'),...
                   fullfile(pthSite,'MET','SW_OUT_AVG'),...
                   fullfile(pthSite,'MET','LW_IN_AVG'),...
                   fullfile(pthSite,'MET','LW_OUT_AVG')...
                   );
trace_legend = char('SW_{IN}','SW_{OUT}','LW_{IN}','LW_{OUT}');
trace_units = '(W)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% NET radiation
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' NETRAD');

trace_path  = char(fullfile(pthSite,'MET','NETRAD_AVG')...
                   );
trace_legend = [];
trace_units = '(µmol/m2/s)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% PPFD
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' PPFD');
trace_path  = char(fullfile(pthSite,'MET','PPFD_IN_AVG'),...
                   fullfile(pthSite,'MET','PPFD_OUT_AVG')...
    );
trace_legend = char('PPFD_{IN}','PPFD_{OUT}');
trace_units = '(µmol/m2/s)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% Wind Speed
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,'Wind Speed');
trace_path  = char(fullfile(pthSite,'MET','WS_AVG'),...
                   fullfile(pthSite,'MET','WS_MAX'),...
                   fullfile(db_pth_root,'yyyy\ECCC\10732\30min','WindSpeed')...
                  );
trace_legend = char('MET (avg)','MET (max)','ECCC');
trace_units = '(m/s)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% Wind Direction
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,'Wind Direction');
trace_path  = char(fullfile(pthSite,'MET','WD'),...
                   fullfile(db_pth_root,'yyyy\ECCC\10732\30min','WindDir')...
                   );
trace_legend = char('MET','ECCC');
trace_units = 'deg';
unitCorrection = [1 10];
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num,unitCorrection );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% Samples collected
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Samples in 30min');
trace_path  = char(fullfile(pthSite,'flux','file_records'),fullfile(pthSite,'flux','used_records'));
trace_legend = char('Collected','Used');
trace_units = '# of Samples';
y_axis      = [34000 37000];
fig_num = fig_num + fig_num_inc;
[x, dTV]= plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indNans = find(isnan(sum(x,2)));
if ~isempty(indNans)
    line(dTV(indNans,1),ones(length(indNans),1)*36000,...
        'LineStyle','none','Marker','x','Color','k','MarkerSize',10,...
        'DisplayName','Missing')
end
indAxes = indAxes+1; allAxes(indAxes) = gca;


%----------------------------------------------------------
% 24V Battery Voltage
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Battery Voltage');
trace_path  = char( fullfile(pthSite,'flux','hit_vin_mean'),...
                    fullfile(pthSite,'flux','vin_sf_mean')...
                   );
trace_legend = char('hit-vin-mean','vin_sf_mean');
trace_units = '24V Battery Voltage (V)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% Battery Current
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Battery Current');
coeffSign = 0;
trace_path = [];     % this indicates that trace is not available
fig_num = fig_num-1;
trace_units = '24V Battery Current (Amps)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
sysCurrent = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num,[1 1]*coeffSign ); 
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% Cumulative Battery Current
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Cumulative Battery Current');
switch siteID
    case {'BB2','DSM','RBM'}
        Ibb1 = read_sig( fullfile(pthSite,'MET', 'SYS_Batt_DCCurrent_Avg'), ind,yearIn, t, 0 );
        Ibb1(isnan(Ibb1))=0;
        trace_path = (1+cumsum(Ibb1/2)/2600)*100;    % Ah / Ah
        trace_legend = [];
end
trace_units = 'Cummulative Current (%)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;


%----------------------------------------------------------
% System Voltage
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,'Logger Voltage');

trace_path  = char(fullfile(pthSite,'flux','Voltage_12V_Avg'),...
    fullfile(pthSite,'met','SYS_Logger_Batt_Min'));
trace_legend = char('Voltage 12V Avg','SYS Logger Batt Min');      
trace_units = 'Instrument Voltage (V)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
sysVoltage = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

% %----------------------------------------------------------
% % System Power
% %----------------------------------------------------------
% 
% trace_name  = sprintf('%s: %s',siteID,' System Power');
% switch siteID
%     case 'BB1'
%         if tv(ind(1))<datenum(2021,11,17)
%             trace_path = sum(-sysVoltage(:,1:2).*sysCurrent(:,1:2),2,'omitnan');
%         else
%             trace_path = sum(-sysVoltage(:,1).*sysCurrent(:,1),2,'omitnan');
%         end
%     case {'BB2','DSM','RBM'}
%         trace_path = sum(sysVoltage(:,1).*sysCurrent,2,'omitnan');
%     case {'HOGG','YOUNG','OHM'}
%         trace_path = [];
%         fig_num = fig_num-1;
% end
% trace_units = 'System Power (W)';
% y_axis      = [];
% fig_num = fig_num + fig_num_inc;
% sysPower = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
% indAxes = indAxes+1; allAxes(indAxes) = gca;
% 
% %----------------------------------------------------------
% % System Energy
% %----------------------------------------------------------
% trace_name  = sprintf('%s: %s',siteID,' System Energy');
% switch siteID
%     case {'HOGG','YOUNG','OHM'}
%         trace_path = [];
%         fig_num = fig_num-1;
%     otherwise
%         trace_path = cumsum(sysPower/2,'omitnan');
% end
% trace_units = 'System Energy (Wh)';
% y_axis      = [];
% fig_num = fig_num + fig_num_inc;
% sysEnergy = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
% indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% System Temperatures
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' System Temperatures');
trace_path  = char(fullfile(pthSite,'MET','SYS_Logger_Temp_Avg')...  
           );
trace_legend = char('CR1000x');
trace_units = 'Temperature (\circC)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% LI-7200 Thermocouples
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' LI-7200 Thermocouples');
trace_path  = char(fullfile(pthSite,'monitorSites',sprintf('%s.tempIn.avg',siteID)),...
                   fullfile(pthSite,'monitorSites',sprintf('%s.tempOut.avg',siteID)));
trace_legend = char('T_{in}','T_{out}');
trace_units = 'Temperature (\circC)'; % flowrate_min needs to be converted from m^3/sec *1000*60 (L/min)
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, ...
              trace_legend, yearIn, trace_units, ...
              y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;


%----------------------------------------------------------
% LI-7200 Flow rate
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' LI-7200 Flow Rate');
switch siteID
    case {'HOGG','YOUNG','OHM'}
        trace_path = [];
        fig_num = fig_num-1;
    otherwise
        trace_path  = char(fullfile(pthSite,'monitorSites',sprintf('%s.flowRate.avg',siteID)),...
                           fullfile(pthSite,'Flux','flowrate_mean'));
end
trace_legend = char('Monitor','EddyPro');
trace_units = 'Flow (lpm)'; % flowrate_min needs to be converted from m^3/sec *1000*60 (L/min)
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num,[1 1000*60] );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% Flow Drive
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Flow Drive');
switch siteID
    case {'HOGG','YOUNG','OHM'}
        trace_path = [];
        fig_num = fig_num-1;
    otherwise
        trace_path  = char(fullfile(pthSite,'monitorSites',sprintf('%s.FlowDrive.avg',siteID)),...
                           fullfile(pthSite,'monitorSites',sprintf('%s.FlowDrive.min',siteID)),...
                           fullfile(pthSite,'monitorSites',sprintf('%s.FlowDrive.max',siteID))...
        );
        trace_legend = char('Avg','Min','Max');
end
trace_units = 'Flow Drive (%)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% Head Pressure
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,'Head Pressure');
switch siteID
    case {'HOGG','YOUNG','OHM'}
        trace_path = [];
        fig_num = fig_num-1;
    otherwise
        trace_path  = char(fullfile(pthSite,'monitorSites',sprintf('%s.Phead.avg',siteID)),...
                           fullfile(pthSite,'monitorSites',sprintf('%s.Phead.min',siteID)),...
                           fullfile(pthSite,'monitorSites',sprintf('%s.Phead.max',siteID))...
        );
        trace_legend = char('Avg','Min','Max');
end
trace_units = 'Phead (kPa)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% Air pressure
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Air Pressure');
trace_path  = char(fullfile(pthSite,'Flux','air_pressure'),...
                   fullfile(pthSite,'Flux','air_p_mean')...
    );
trace_legend = char('air\_pressure','air\_P\_mean');
trace_units = 'Barometric Pressure (kPa)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num, [ 1 1] * 0.001 );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% Spikes
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Spikes');
trace_path = char(fullfile(pthSite,'Flux','w_spikes'),...
                  fullfile(pthSite,'Flux','ts_spikes'),...
                  fullfile(pthSite,'Flux','co2_spikes'),...
                  fullfile(pthSite,'Flux','h2o_spikes'),...
                  fullfile(pthSite,'Flux','ch4_spikes')...
                  );
trace_legend = char('w_{spikes}','ts_{spikes}','co2_{spikes}','h2o_{spikes}','ch4_{spikes}');
trace_units = 'Number of spikes';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;


%----------------------------------------------------------
% Diagnostics
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Diagnostics');
switch siteID
    case {'HOGG','YOUNG','OHM'}
        trace_path  = char(fullfile(pthSite,'Flux','chopper_LI_7500'),...
                          fullfile(pthSite,'Flux','detector_LI_7500'),...
                          fullfile(pthSite,'Flux','pll_LI_7500'),...
                          fullfile(pthSite,'Flux','sync_LI_7500'),...
                          fullfile(pthSite,'Flux','not_ready_LI_7700'),...
                          fullfile(pthSite,'Flux','no_signal_LI_7700'),...
                          fullfile(pthSite,'Flux','bad_temp_LI_7700'),...
                          fullfile(pthSite,'Flux','laser_temp_unregulated_LI_7700'),...
                          fullfile(pthSite,'Flux','motor_failure_LI_7700'),...
                          fullfile(pthSite,'Flux','block_temp_unregulated_LI_7700')...
                           );
        trace_legend = char('chopper_{LI-7500}','detector_{LI-7500}',...
                            'pll_{LI-7500}','sync_{LI-7500}','notReady_{LI-7700}',...
                            'nosignal_{LI-7700}','badTemp_{LI-7700}',...
                            'laserTemp_{LI-7700}','motor_{LI-7700}',...
                            'blockTemp_{LI-7700}');
    otherwise
        trace_path  = char(fullfile(pthSite,'Flux','head_detect_LI_7200'),...
                          fullfile(pthSite,'Flux','t_in_LI_7200'),...
                          fullfile(pthSite,'Flux','t_out_LI_7200'),...
                          fullfile(pthSite,'Flux','chopper_LI_7200'),...
                          fullfile(pthSite,'Flux','detector_LI_7200'),...
                          fullfile(pthSite,'Flux','pll_LI_7200'),...
                          fullfile(pthSite,'Flux','sync_LI_7200'),...
                          fullfile(pthSite,'Flux','not_ready_LI_7700'),...
                          fullfile(pthSite,'Flux','no_signal_LI_7700'),...
                          fullfile(pthSite,'Flux','bad_temp_LI_7700'),...
                          fullfile(pthSite,'Flux','laser_temp_unregulated_LI_7700'),...
                          fullfile(pthSite,'Flux','motor_failure_LI_7700'),...
                          fullfile(pthSite,'Flux','block_temp_unregulated_LI_7700')...
                           );
        trace_legend = char('head_{LI-7200}','Tin_{LI-7200}',...
                            'Tout_{LI-7200}','chopper_{LI-7200}',...
                            'detector_{LI-7200}','pll_{LI-7200}','sync_{LI-7500}',...                            
                            'detector_{LI-7700}',...
                            'nosignal_{LI-7700}','badTemp_{LI-7700}',...
                            'laserTemp_{LI-7700}','motor_{LI-7700}',...
                            'blockTemp_{LI-7700}');
end
trace_units = 'Num of errors';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% Signal Strength
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Signal Strength');
switch siteID
    case {'HOGG','YOUNG'}
        trace_path = char(fullfile(pthSite,'monitorSites',sprintf('%s.signalStrength7200.avg',siteID)),...
                           fullfile(pthSite,'monitorSites',sprintf('%s.signalStrength7700.avg',siteID)),...
                           fullfile(pthSite,'Flux','mean_value_LI_7500'),...
                          fullfile(pthSite,'Flux','rssi_77_mean')...
                          );
        trace_legend = char('7500_{MO}','7700_{MO}','7500_{EP}','7700_{EP}');
    case {'OHM'}
        trace_path = char(fullfile(pthSite,'Flux','mean_value_LI_7500'),...
                          fullfile(pthSite,'Flux','rssi_77_mean')...
                          );
        trace_legend = char('7500_{EP}','7700_{EP}');
    otherwise
        trace_path  = char(fullfile(pthSite,'monitorSites',sprintf('%s.signalStrength7200.avg',siteID)),...
                           fullfile(pthSite,'monitorSites',sprintf('%s.signalStrength7700.avg',siteID)),...
                           fullfile(pthSite,'Flux','avg_signal_strength_7200_mean'),...
                           fullfile(pthSite,'Flux','rssi_77_mean')...                           
                           );
        trace_legend = char('7200_{MO}','7700_{MO}','7200_{EP}','7700_{EP}');
end
trace_units = 'Signal Strength (%)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% Delay times
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Delay Times');
trace_path  = char(fullfile(pthSite,'Flux','h2o_time_lag'),...
                   fullfile(pthSite,'Flux','co2_time_lag'),...
                   fullfile(pthSite,'Flux','ch4_time_lag')...
                   );
trace_legend = char('h_2o','co_2','ch_4');
trace_units = 'Delay Times (Seconds)';
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num,[],[],char('o') );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% Soil moisture
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' Soil Moisture');

trace_path  = char( fullfile(pthSite,'met','a_CS650_1_1_1_Avg'),...
                    fullfile(pthSite,'met','a_CS650_1_2_1_Avg'),...
                    fullfile(pthSite,'met','a_CS650_1_3_1_Avg'),...
                    fullfile(pthSite,'met','a_CS650_1_4_1_Avg')...
                   );

trace_legend = char('1','2','3','4');
trace_units = '(%)'; 
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% CO2
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' CO_2');

trace_path  = char( fullfile(pthSite,'flux','co2_mixing_ratio')...
                   );

trace_legend = [];
trace_units = '(umol/mol)'; 
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% CH4
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' CH_4');

trace_path  = char( fullfile(pthSite,'flux','ch4_mixing_ratio')...
                   );

trace_legend = [];
trace_units = '(umol/mol)'; 
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

%----------------------------------------------------------
% H2O
%----------------------------------------------------------
trace_name  = sprintf('%s: %s',siteID,' H_2O');

trace_path  = char( fullfile(pthSite,'flux','h2o_mixing_ratio')...
                   );

trace_legend = [];
trace_units = '(mmol/mol)'; 
y_axis      = [];
fig_num = fig_num + fig_num_inc;
x = plt_msig( trace_path, ind, trace_name, trace_legend, yearIn, trace_units, y_axis, t, fig_num );
indAxes = indAxes+1; allAxes(indAxes) = gca;

linkaxes(allAxes,'x');


if flgPause ~= 1
    return
end
%------------------------------------------
if select == 1 %diagnostics only
    childn = get(0,'children');
    allFig = {childn.Number};
    allfFig = cell2mat(allFig);
    allfFig = sort(allfFig);
    N = length(allfFig);
    for i=1:N
        if i < 200
            figNum = get(allfFig(i),'number');
            figure(figNum);
            pause;
        end
    end
    return
end

end


