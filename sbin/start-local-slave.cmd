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

rem Starts a slave on the machine this script is executed on.
rem
rem Environment Variables
rem
rem   SPARK_WORKER_INSTANCES  The number of worker instances to run on this
rem                           slave.  Default is 1.
rem   SPARK_WORKER_PORT       The base port number for the first worker. If set,
rem                           subsequent workers will increment this number.  If
rem                           unset, Spark will find a valid port number, but
rem                           with no guarantee of a predictable pattern.
rem   SPARK_WORKER_WEBUI_PORT The base port for the web interface of the first
rem                           worker.  Subsequent workers will increment this
rem                           number.  Default is 8081.
if "x%SPARK_HOME%"=="x" set SPARK_HOME=%~dp0..

rem NOTE: This exact class name is matched downstream by SparkSubmit.
rem Any changes need to be reflected there.
set CLASS=org.apache.spark.deploy.worker.Worker

call %SPARK_HOME%\sbin\spark-config.cmd
call %SPARK_HOME%\bin\load-spark-env.cmd

rem First argument should be the master; we need to store it aside because we may
rem need to insert arguments between it and the other arguments
if "x%SPARK_MASTER_PORT%"=="x" set SPARK_MASTER_PORT=7077
if "x%SPARK_MASTER_IP%"=="x" set SPARK_MASTER_IP=%computername%
set MASTER=spark://%SPARK_MASTER_IP%:%SPARK_MASTER_PORT%

rem Determine desired worker port
if "x%SPARK_WORKER_WEBUI_PORT%" == "x" set SPARK_WORKER_WEBUI_PORT=8081
if "x%SPARK_WORKER_INSTANCES%" == "x" set /a SPARK_WORKER_INSTANCES=2
set /a REAL_WORKER=0
:instance_worker
if "%REAL_WORKER%" == "%SPARK_WORKER_INSTANCES%" goto exit
set WORKER_NUM=%REAL_WORKER%
if "x%SPARK_WORKER_PORT%" == "x" (
	set PORT_FLAG=
	set PORT_NUM=
) else (
	set PORT_FLAG=--port
	set /a PORT_NUM=%SPARK_WORKER_PORT% + %WORKER_NUM%
)
set /a WEBUI_PORT=%SPARK_WORKER_WEBUI_PORT% + %WORKER_NUM%

call %SPARK_HOME%\sbin\spark-daemon.cmd start %CLASS% %WORKER_NUM% --webui-port %WEBUI_PORT% %PORT_FLAG% %PORT_NUM% %MASTER% %*

set /a REAL_WORKER=%REAL_WORKER%+1
goto instance_worker
:exit
