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

rem Run a shell command on all slave hosts.
rem
rem Environment Variables
rem
rem   SPARK_SLAVES    File naming remote hosts.
rem     Default is ${SPARK_CONF_DIR}/slaves.
rem   SPARK_CONF_DIR  Alternate conf dir. Default is ${SPARK_HOME}/conf.
rem   SPARK_SLAVE_SLEEP Seconds to sleep between spawning remote commands.
rem   SPARK_SSH_OPTS Options passed to ssh when running remote commands.
rem

if "x%SPARK_HOME%"=="x" set SPARK_HOME=%~dp0..

call %SPARK_HOME%\sbin\spark-config.cmd
call %SPARK_HOME%\bin\load-spark-env.cmd

rem If the slaves file is specified in the command line,
rem then it takes precedence over the definition in
rem spark-env.sh. Save it here.
if exist "%SPARK_SLAVES%" (
	set SPARK_SLAVES_FILE=%SPARK_SLAVES%
) else (
	if exist "%SPARK_CONF_DIR%\slaves" (
		set SPARK_SLAVES_FILE=%SPARK_CONF_DIR%\slaves
	)
)

if "x!HOSTLIST!" == "x" (
	if not "x%SPARK_SLAVES_FILE%" == "x" (
		for /f "tokens=*" %%i in ('type %SPARK_SLAVES_FILE%^|findstr -v "#" ') do (
			set HOSTLIST=!HOSTLIST! %%i
		)
	) else (
	    set HOSTLIST=localhost
	)
)

for /f "tokens=*" %%i in ("!HOSTLIST!") do (
    if %2 == "start-slave.cmd" (
		echo starting org.apache.spark.deploy.worker.Worker
	) else (
		echo stopping org.apache.spark.deploy.worker.Worker
	)
	powershell Set-ExecutionPolicy RemoteSigned -force
	powershell remote-slaves-daemon.ps1 %%i %SPARK_HOME% %1 %2
)


