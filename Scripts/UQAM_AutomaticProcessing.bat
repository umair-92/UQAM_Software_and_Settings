REM =====================================================
REM    Download data and process all UQAM sites
REM 
REM - Start all WinSCP transfers (space them out 10s)
REM - Wait 2 minutes for all transfers to complete (fingers crossed)
REM - Start Matlab data processing for all the sites
REM =====================================================

@c:
@cd "C:\Program Files (x86)\WinSCP"

REM -------------------------------
REM  UQAM_0
REM -------------------------------
@del C:\Projects\UQAM\Scripts\FTP\log\UQAM_0_SmartFlux_download.log
start /min winscp.exe  /script=C:\Projects\UQAM\Scripts\FTP\UQAM_0_SmartFlux_Download.txt  /log="C:\Projects\UQAM\Scripts\FTP\log\UQAM_0_SmartFlux_download.log"
timeout 10 > nul

REM ---------------------------------------------
REM  Data base processing and data upload to Web
REM ---------------------------------------------
REM -nodesktop -nosplash -minimize
"C:\Program Files\MATLAB\R2024a\bin\matlab.exe"  -noFigureWindows -batch "try; cd C:\Projects\UQAM\Matlab; startup;run_UQAM_db_update; catch ME; disp(ME);end; quit" > C:\Projects\UQAM\Scripts\Automatic_site_data_processing.log


exit