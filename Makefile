R_HOME=$$(R --vanilla --slave -e "cat (R.home())")

all:
	export R_HOME=$(R_HOME)
	mkoctfile --mex -I"$(R_HOME)/include" -L"$(R_HOME)/lib" ratlab_internal.cpp -lR -lm

clean:
	rm -rf *.o *.mex

example:
	echo "a = dataframe( {'col1', 'col2'}, {}, {{'A','A','B','B'}, [0,1,0,1]} ); ratlab( {'a'}, {a}, 'print(table(a))')" | octave
