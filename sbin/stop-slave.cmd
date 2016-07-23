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

rem A shell script to stop all workers on a single slave
rem
rem Environment variables
rem
rem   SPARK_WORKER_INSTANCES The number of worker instances that should be
rem                          running on this slave.  Default is 1.

rem Usage: stop-slave.sh
rem   Stops all slaves on this worker machine

if "x%SPARK_HOME%"=="x" set SPARK_HOME=%~dp0..

call %SPARK_HOME%\sbin\spark-config.cmd
call %SPARK_HOME%\bin\load-spark-env.cmd

set CLASS=org.apache.spark.deploy.worker.Worker

if "x%SPARK_WORKER_INSTANCES%" == "x" set /a SPARK_WORKER_INSTANCES=2
set /a WORKER_NUM=0
:stop_worker
if "%WORKER_NUM%" == "%SPARK_WORKER_INSTANCES%" goto exit

call %SPARK_HOME%\sbin\spark-daemon.cmd stop %CLASS% %WORKER_NUM%

set /a WORKER_NUM=%WORKER_NUM%+1
goto stop_worker
:exit