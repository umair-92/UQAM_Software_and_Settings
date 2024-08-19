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
REM @del Z:\uqam-site\Scripts\FTP\log\UQAM_0_SmartFlux_download.log
REM start /min winscp.exe  /script=Z:\uqam-site\Scripts\FTP\UQAM_0_SmartFlux_Download.txt  /log="Z:\uqam-site\Scripts\FTP\log\UQAM_0_SmartFlux_download.log"
REM timeout 10 > nul

REM -------------------------------
REM  UQAM_1
REM -------------------------------
@del Z:\uqam-site\Scripts\FTP\log\UQAM_1_SmartFlux_download.log
start /min winscp.exe  /script=Z:\uqam-site\Scripts\FTP\UQAM_1_SmartFlux_Download.txt  /log="Z:\uqam-site\Scripts\FTP\log\UQAM_1_SmartFlux_download.log"
timeout 10 > nul

REM ---------------------------------------------
REM  Data base processing and data upload to Web
REM ---------------------------------------------
REM -nodesktop -nosplash -minimize
@REM "C:\Program Files\MATLAB\R2024a\bin\matlab.exe"  -noFigureWindows -batch "try; cd Z:\uqam-site\Matlab; startup;run_UQAM_db_update; catch ME; disp(ME);end; quit" > Z:\uqam-site\Scripts\Automatic_site_data_processing.log
"C:\Program Files\MATLAB\R2024a\bin\matlab.exe"  -noFigureWindows -batch "try; set_TAB_project('Z:\uqam-site\');run_UQAM_db_update; catch ME; disp(ME);end; quit" > Z:\uqam-site\Scripts\Automatic_site_data_processing.log


exit