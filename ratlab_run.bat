@ECHO OFF
SET R_HOME=c:\Program Files\R\R-2.10.1
IF NOT EXIST "%R_HOME%\bin\R.lib" COPY "%R_HOME%\bin\R.dll" "%R_HOME%\bin\R.lib"
SET PATH=%PATH%;%R_HOME%\bin
IF NOT EXIST ratlab_internal.mex* GOTO freshstart
matlab
GOTO end
:freshstart
matlab -r "mex -I'%R_HOME%\include' -L'%R_HOME%\bin' -lR ratlab_internal.cpp"
:end
end
