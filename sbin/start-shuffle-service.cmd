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

rem Starts the external shuffle server on the machine this script is executed on.
rem
rem Usage: start-shuffle-server.cmd
rem
rem Use the SPARK_SHUFFLE_OPTS environment variable to set shuffle server configuration.
rem

if "x%SPARK_HOME%"=="x" set SPARK_HOME=%~dp0..
set CLASS=org.apache.spark.deploy.ExternalShuffleService 

call %SPARK_HOME%\sbin\spark-config.cmd
call %SPARK_HOME%\bin\load-spark-env.cmd

start /b %SPARK_HOME%\sbin\spark-daemon.cmd start %CLASS% 1
