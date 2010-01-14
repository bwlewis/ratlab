@ECHO OFF
SET R_HOME=c:\Program Files\R\R-2.10.1\
IF EXIST %R_HOME%\bin\R.lib GOTO cpycmplt
COPY %R_HOME%\bin\R.dll %R_HOME%\bin\R.lib
:cpycmplt
SET PATH=%PATH%;%R_HOME%\bin\
IF EXIST ratlab_internal.mex GOTO launch
mex -I"C:\Program Files\R\R-2.10.1\include" -L"C:\Program Files\R\R-2.10.1\bin" -lR ratlab_internal.cpp
:launch
matlab
