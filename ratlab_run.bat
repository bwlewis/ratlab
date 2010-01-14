@ECHO OFF
IF NOT "%1"=="" SET R_HOME=%1 ELSE SET R_HOME=c:\Program Files\R\R-2.10.1\
IF NOT EXIST "%R_HOME%\bin\R.lib" COPY "%R_HOME%\bin\R.dll" "%R_HOME%\bin\R.lib"
IF ERRORLEVEL 1 GOTO bigerror
SET PATH=%PATH%;%R_HOME%\bin
IF NOT EXIST ratlab_internal.mex* GOTO freshstart
matlab
GOTO end
:freshstart
matlab -r "mex -I'%R_HOME%\include' -L'%R_HOME%\bin' -lR ratlab_internal.cpp"
:end
end
:bigerror
ECHO "Hit an error.  Please check path!"