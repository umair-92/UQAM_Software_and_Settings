%===================================================================
%
%               Startup.m file for McGill server
%
%===================================================================

%
% (c) Zoran Nesic           File created:        May  9, 2024
%                           Last modification:   May  9, 2024

%
% Revisions:
%

%
% Biomet toolbox path 
%
path('c:\biomet.net\matlab\TraceAnalysis_FCRN_THIRDSTAGE',path);
path('c:\biomet.net\matlab\TraceAnalysis_Tools',path);
path('c:\biomet.net\matlab\TraceAnalysis_SecondStage',path);
path('c:\biomet.net\matlab\TraceAnalysis_FirstStage',path);
path('c:\biomet.net\matlab\soilchambers',path);
path('c:\biomet.net\matlab\biomet',path);  
path('c:\biomet.net\matlab\boreas',path);
path('c:\biomet.net\matlab\biomet',path);      
path('c:\biomet.net\matlab\new_met',path);      
path('c:\biomet.net\matlab\met',path);    
path('c:\biomet.net\matlab\new_eddy',path); 
path('c:\biomet.net\MATLAB\SystemComparison',path);         % use this line on the workstations
path('c:\biomet.net\matlab\Micromet',path);

path(user_dir,path);

% If the user wants to customize his Matlab environment he may create
% the localrc.m file in Matlab's main directory

if exist('localrc','file') ~= 0
    localrc
end

system_dependent(14,'on')
clear server user_dir
