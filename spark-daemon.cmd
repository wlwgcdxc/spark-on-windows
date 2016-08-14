@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

rem
rem Licensed to the Apache Software Foundation (ASF) under one or more
rem contributor license agreements.  See the NOTICE file distributed with
rem this work for additional information regarding copyright ownership.
rem The ASF licenses this file to You under the Apache License, Version 2.0
rem (the "License"); you may not use this file except in compliance with
rem the License.  You may obtain a copy of the License at
rem
rem    http://www.apache.org/licenses/LICENSE-2.0
rem
rem Unless required by applicable law or agreed to in writing, software
rem distributed under the License is distributed on an "AS IS" BASIS,
rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
rem See the License for the specific language governing permissions and
rem limitations under the License.
rem

rem Runs a Spark command as a daemon.
rem
rem Environment Variables
rem
rem   SPARK_CONF_DIR  Alternate conf dir. Default is ${SPARK_HOME}/conf.
rem   SPARK_LOG_DIR   Where log files are stored. ${SPARK_HOME}/logs by default.
rem   SPARK_MASTER    host:path where spark code should be rsync'd from
rem   SPARK_PID_DIR   The pid files are stored. /tmp by default.
rem   SPARK_IDENT_STRING   A string representing this instance of spark. $USER by default
rem   SPARK_NICENESS The scheduling priority for daemons. Defaults to 0.
rem
set usage="Usage: spark-daemon.sh [--config <conf-dir>] (start|stop|submit|status) <spark-command> <spark-instance-number> <args...>"
rem if no args specified, show usage
if "x%1" == "x" (
	echo %usage%
	exit /B 1
)
 
if "x%SPARK_HOME%"=="x" set SPARK_HOME=%~dp0..

call %SPARK_HOME%\sbin\spark-config.cmd

rem get arguments

rem Check if --config is passed as an argument. It is an optional parameter.
rem Exit if the argument is not a directory.
if %1 == "--config" (
	shift
    set conf_dir=%1
    if not exist "%conf_dir%" (
		echo ERROR : %conf_dir% is not a directory
		echo %usage%
		exit /B 1
	) else (
		set SPARK_CONF_DIR=%conf_dir%
	)
	shift
)
set option=%1
shift
set command=%1
shift
set instance=%1
shift

call %SPARK_HOME%\bin\load-spark-env.cmd

if "x%SPARK_IDENT_STRING%"=="x" set SPARK_IDENT_STRING=%USERNAME%

set SPARK_PRINT_LAUNCH_COMMAND=1

rem get log directory
if "x%SPARK_LOG_DIR%"=="x" set SPARK_LOG_DIR=%SPARK_HOME%\logs
if not exist %SPARK_LOG_DIR% (
	md %SPARK_LOG_DIR%
	takeown /f %SPARK_LOG_DIR% /r
)
if "x%SPARK_PID_DIR%"=="x" set SPARK_PID_DIR=%temp%
if not exist %SPARK_PID_DIR% (
	md %SPARK_PID_DIR%
	takeown /f %SPARK_PID_DIR% /r
)
rem some variables
set log=%SPARK_LOG_DIR%\spark-%SPARK_IDENT_STRING%-%command%-%instance%-%computername%.out
set pid=%SPARK_PID_DIR%\spark-%SPARK_IDENT_STRING%-%command%-%instance%.pid
rem Set default scheduling priority
if "x%SPARK_NICENESS%"=="x" set SPARK_NICENESS=0

if %option% == submit (
	call:run_command submit %*
) else if %option% == start (
	call:run_command class %*
) else if %option% == stop (
	if exist %pid% (
		for /f "tokens=*" %%i in ('type %pid%') do (
			echo %%i
			set TARGET_ID=%%i
			for /f "tokens=1" %%a in ('tasklist^|findstr "!TARGET_ID!"') do (
				if "%%a" == "java.exe" (
					echo "stopping %class%"
					taskkill /f /pid !TARGET_ID!
					del %pid%
				) else (
					echo "no %class% to stop"
				)
			)
		)
	) else (
		echo "no %class% to stop"
	)
) else if %option% == status (
    rem haha
	if exist %pid% (
		echo %command% is running.
		exit /B 0
	) else (
		echo %command% not running.
        exit /B 0
	)
) else (
	echo %usage%
    exit /B 1
)
goto end

:spark_rotate_log
    set log=%1
    set /a num=5
	if exist %log% (
:LOOP
		set /a prev=%num% - 1
		if not "x%prev%" == "x" (
			if exist %log%.%prev% (
				move /y %log%.%prev% %log%.%num%
			)
			set /a num=%prev%
		)
		if %num% gtr 1 goto LOOP
		move /y %log% %log%.%num%
	)
goto:EOF

:run_command
set mode=%1
for /l %%i in (1,1,4) do shift

call:spark_rotate_log %log%
echo starting %command%, logging to %log%

:loop_arg
if not "x%1" == "x" (
	set otherArgs=%otherArgs% %1
	shift
	goto loop_arg
)

if %mode% == class (
	start /b %SPARK_HOME%\bin\spark-class2.cmd %command% %otherArgs% >> %log% 2>&1
) else if %mode% == submit (
	start /b %SPARK_HOME%\bin\spark-submit --class %command% %otherArgs% >> %log% 2>&1
) else (
	echo unknown mode: %mode%
    exit /B 1
)

ping 127.0.0.1 -n 8 -w 1000 > nul
if %command% == org.apache.spark.deploy.worker.Worker (
    set /a times=0
	for /f "tokens=*" %%i in ('wmic process where "name='java.exe'" get commandline^,processid ^|findstr /L "%SPARK_HOME%"^|findstr /L "%command%"') do (
		if "!times!" == "%WORKER_NUM%" (
			set newpid_tmp=%%i
		)
		set /a times=!times! + 1
	)
) else (
	for /f "tokens=*" %%i in ('wmic process where "name='java.exe'" get commandline^,processid ^|findstr /L "%SPARK_HOME%"^|findstr /L "%command%"') do (
		set newpid_tmp=%%i
	)
)
set newpid=%newpid_tmp:~-14%
echo %newpid: =% > %pid%
goto:EOF 

:end
exit /B 0