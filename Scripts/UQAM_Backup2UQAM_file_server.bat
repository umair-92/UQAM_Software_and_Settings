REM =====================================================
REM    Synchronize uqam-site with ANNEX001
REM 
REM =====================================================

@c:
@cd "C:\Program Files (x86)\WinSCP"

REM -------------------------------
REM  
REM -------------------------------
@del Z:\uqam-site\Scripts\FTP\log\UQAM_Backup2UQAM_file_server.log

start /min winscp.exe  /script=Z:\uqam-site\Scripts\FTP\UQAM_Backup2UQAM_file_server.txt  /log="Z:\uqam-site\Scripts\FTP\log\UQAM_Backup2UQAM_file_server.log"
