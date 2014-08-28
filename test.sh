
rm -vf a.out

	rm -vf filenames_MM.txt
	touch  filenames_MM.txt
	rm -vf filenames_DM.txt
	touch  filenames_DM.txt
	rm -vf filenames_SM.txt
	touch  filenames_SM.txt

gfortran F90_gen_time.f90
./a.out
