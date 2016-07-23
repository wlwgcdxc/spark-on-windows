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

rem Starts the master on the machine this script is executed on.
if "x%SPARK_HOME%"=="x" set SPARK_HOME=%~dp0..
set CLASS=org.apache.spark.deploy.master.Master
set ORIGINAL_ARGS=%*

rem set IS_HELP=false
rem echo %*|find "--help">nul&&set IS_HELP=true
rem echo %*|find "-h">nul&&set IS_HELP=true
rem if %IS_HELP%==true (  
rem     echo 1  
rem ) 

call %SPARK_HOME%\sbin\spark-config.cmd
call %SPARK_HOME%\bin\load-spark-env.cmd

if "x%SPARK_MASTER_PORT%"=="x" set SPARK_MASTER_PORT=7077
if "x%SPARK_MASTER_IP%"=="x" set SPARK_MASTER_IP=%computername%
if "x%SPARK_MASTER_WEBUI_PORT%"=="x" set SPARK_MASTER_WEBUI_PORT=8080
start /b %SPARK_HOME%\sbin\spark-daemon.cmd start %CLASS% 1 --ip %SPARK_MASTER_IP% --port %SPARK_MASTER_PORT% --webui-port %SPARK_MASTER_WEBUI_PORT% %ORIGINAL_ARGS%