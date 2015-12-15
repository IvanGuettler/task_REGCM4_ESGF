#PBS -S /bin/bash
#PBS -N CRDX_fixDKRZ
#PBS -l select=1:ncpus=1:mem=14gb
#PBS -q mono
#PBS -j oe
#PBS -m bae
#PBS -M ivan.guettler@gmail.com
#PBS -r n
#PBS -l cput=01:00:00

NCO_PATH='/home1/regcm/regcmlibs_my_nco/bin'
cd /home1/regcm/DIR_ivan/work/2014_CORDEX_METADATA_WORLD


#for VAR in tas tasmin tasmax ts pr ps sfcWind sfcWindmax uas vas zmla ; do
for VAR in pr                                                         ; do
for DOM in EUR-11 EUR-44                                              ; do

DIR13=/home1/regcm/DISK_WORK/temp/test_CORDEX/netcdf3/${DOM}/DHMZ/ECMWF-ERAINT/evaluation/r1i1p1/DHMZ-RegCM4-2/v1/day/
DIR23=/home1/regcm/DISK_WORK/temp/test_CORDEX/netcdf3/${DOM}/DHMZ/ECMWF-ERAINT/evaluation/r1i1p1/DHMZ-RegCM4-2/v1/mon/
DIR33=/home1/regcm/DISK_WORK/temp/test_CORDEX/netcdf3/${DOM}/DHMZ/ECMWF-ERAINT/evaluation/r1i1p1/DHMZ-RegCM4-2/v1/sem/
text1=${DOM}_ECMWF-ERAINT_evaluation_r1i1p1_DHMZ-RegCM4-2_v1


 FILE[1]=${DIR13}/${VAR}/${VAR}_${text1}_day_19890101-19901231.nc 
 FILE[2]=${DIR13}/${VAR}/${VAR}_${text1}_day_19910101-19951231.nc
 FILE[3]=${DIR13}/${VAR}/${VAR}_${text1}_day_19960101-20001231.nc
 FILE[4]=${DIR13}/${VAR}/${VAR}_${text1}_day_20010101-20051231.nc
 FILE[5]=${DIR13}/${VAR}/${VAR}_${text1}_day_20060101-20081231.nc
 FILE[6]=${DIR23}/${VAR}/${VAR}_${text1}_mon_198901-199012.nc
 FILE[7]=${DIR23}/${VAR}/${VAR}_${text1}_mon_199101-200012.nc
 FILE[8]=${DIR23}/${VAR}/${VAR}_${text1}_mon_200101-200812.nc
 FILE[9]=${DIR33}/${VAR}/${VAR}_${text1}_sem_198903-199011.nc
FILE[10]=${DIR33}/${VAR}/${VAR}_${text1}_sem_199012-200011.nc
FILE[11]=${DIR33}/${VAR}/${VAR}_${text1}_sem_200012-200811.nc

for FFF in 1 2 3 4 5 6 7 8 9 10 11; do
        #-----------------------------
	#--> DKRZ (2/5)
        #-----------------------------
        	cd /home1/regcm/DISK_WORK/temp/test_CORDEX
	        ${NCO_PATH}/ncap2    -O -h -s "x=double(x(:)); y=double(y(:))"  ${FILE[${FFF}]} test_GRISHA.nc
		mv test_GRISHA.nc ${FILE[${FFF}]}
	        cd /home1/regcm/DIR_ivan/work/2014_CORDEX_METADATA_WORLD
done #od FFF
done #od DOM
done #od VAR
