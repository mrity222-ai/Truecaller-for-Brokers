@echo off
title RealEstate Pro CRM - Web Admin Panel & Backend
echo ======================================================================
echo    Starting Truecaller-for-Brokers Web Admin Panel & Cloud Backend
echo ======================================================================
echo.

cd /d "%~dp0"

set "JAVA_EXE=C:\Program Files\Android\Android Studio\jbr\bin\java.exe"
if not exist "%JAVA_EXE%" (
    set "JAVA_EXE=java"
)

echo [1/2] Verifying Java Runtime...
"%JAVA_EXE%" -version
echo.

echo [2/2] Launching Spring Boot Web Server on Port 8080...
echo ----------------------------------------------------------------------
echo  - Broker Agent Portal : http://localhost:8080/user
echo  - Web Admin Dashboard : http://localhost:8080/admin
echo  - H2 Database Console : http://localhost:8080/h2-console
echo  - Customer Story Demo : http://localhost:8080/s/ats402
echo ----------------------------------------------------------------------
echo Press Ctrl + C to stop the server at any time.
echo.

"%JAVA_EXE%" -jar "%~dp0realestate_backend_api\target\realestate-backend-api-1.0.0-SNAPSHOT.jar"

pause
