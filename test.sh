
rm -vf a.out

     for TYPE in filenames time timebnds ; do
     for DD   in MM DM SM                ; do
	rm -vf prepared_${TYPE}_${DD}.txt
	touch  prepared_${TYPE}_${DD}.txt
     done
     done

gfortran F90_gen_time.f90
./a.out
