R_HOME=$$(R --vanilla --slave -e "cat (R.home())")

all:
	export R_HOME=$(R_HOME)
	mkoctfile --mex -I"$(R_HOME)/include" -L"$(R_HOME)/lib" ratlab_internal.cpp -lR -lm

clean:
	rm -rf *.o *.mex

test:
#	export R_HOME=$(R_HOME); export LD_LIBRARY_PATH=$(R_HOME)/lib; echo "a = dataframe( {{'A','A','B','B'}, [0,1,0,1]}, {'col1', 'col2'}); ratlab( {'a'}, {a}, 'table(a)')" | octave --quiet
	export R_HOME=$(R_HOME); export LD_LIBRARY_PATH=$(R_HOME)/lib; echo "a = dataframe({round(rand(100,1)*10)}); ratlab( {'a'}, {a}, 'table(a)')" | octave --quiet
