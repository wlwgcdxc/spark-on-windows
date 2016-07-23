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

rem Starts a slave instance on each machine specified in the conf/slaves file.

if "x%SPARK_HOME%"=="x" set SPARK_HOME=%~dp0..

call %SPARK_HOME%\sbin\spark-config.cmd
call %SPARK_HOME%\bin\load-spark-env.cmd

rem Find the port number for the master
if "x%SPARK_MASTER_PORT%"=="x" set SPARK_MASTER_PORT=7077
if "x%SPARK_MASTER_IP%"=="x" set SPARK_MASTER_IP=%computername%

rem Launch the slaves
start /b %SPARK_HOME%\sbin\slaves.cmd spark://%SPARK_MASTER_IP%:%SPARK_MASTER_PORT% "start-slave.cmd"
