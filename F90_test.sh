
rm -vf a.out
rm -vf prepared_*.txt

#    for TYPE in filenames time timebnds ; do
     for TYPE in filenames               ; do
     for DD   in MM DM SM                ; do
#001,002	rm -vf prepared_${TYPE}_${DD}.txt
#001,002	touch  prepared_${TYPE}_${DD}.txt
	rm -vf prepared_${TYPE}_${DD}_ECEARTH.txt
	touch  prepared_${TYPE}_${DD}_ECEARTH.txt
     done
     done

gfortran F90_gen_time.f90
./a.out
rm ./a.out
