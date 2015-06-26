#PBS -S /bin/bash
#PBS -N CRDX_nc32nc4
#PBS -l select=1:ncpus=1:mem=14gb
#PBS -q mono
#PBS -j oe
#PBS -m bae
#PBS -M ivan.guettler@gmail.com
#PBS -r n
#PBS -l cput=03:00:00

cd /home1/regcm/DIR_ivan/work/2014_CORDEX_METADATA_WORLD


#for VAR in tas tasmin tasmax ts pr ps sfcWind sfcWindmax uas vas zmla ; do
for VAR in pr                                                         ; do
for DOM in EUR-11 EUR-44                                              ; do

DIR14=/home1/regcm/DISK_WORK/temp/test_CORDEX/netcdf4/${DOM}/DHMZ/ECMWF-ERAINT/evaluation/r1i1p1/DHMZ-RegCM4-2/v1/day/
DIR24=/home1/regcm/DISK_WORK/temp/test_CORDEX/netcdf4/${DOM}/DHMZ/ECMWF-ERAINT/evaluation/r1i1p1/DHMZ-RegCM4-2/v1/mon/
DIR34=/home1/regcm/DISK_WORK/temp/test_CORDEX/netcdf4/${DOM}/DHMZ/ECMWF-ERAINT/evaluation/r1i1p1/DHMZ-RegCM4-2/v1/sem/

DIR13=/home1/regcm/DISK_WORK/temp/test_CORDEX/netcdf3/${DOM}/DHMZ/ECMWF-ERAINT/evaluation/r1i1p1/DHMZ-RegCM4-2/v1/day/
DIR23=/home1/regcm/DISK_WORK/temp/test_CORDEX/netcdf3/${DOM}/DHMZ/ECMWF-ERAINT/evaluation/r1i1p1/DHMZ-RegCM4-2/v1/mon/
DIR33=/home1/regcm/DISK_WORK/temp/test_CORDEX/netcdf3/${DOM}/DHMZ/ECMWF-ERAINT/evaluation/r1i1p1/DHMZ-RegCM4-2/v1/sem/

text1=${DOM}_ECMWF-ERAINT_evaluation_r1i1p1_DHMZ-RegCM4-2_v1

mkdir -p ${DIR14}/${VAR}
nccopy -k 4 -d 1    ${DIR13}/${VAR}/${VAR}_${text1}_day_19890101-19901231.nc ${DIR14}/${VAR}/${VAR}_${text1}_day_19890101-19901231.nc 
nccopy -k 4 -d 1    ${DIR13}/${VAR}/${VAR}_${text1}_day_19910101-19951231.nc ${DIR14}/${VAR}/${VAR}_${text1}_day_19910101-19951231.nc
nccopy -k 4 -d 1    ${DIR13}/${VAR}/${VAR}_${text1}_day_19960101-20001231.nc ${DIR14}/${VAR}/${VAR}_${text1}_day_19960101-20001231.nc
nccopy -k 4 -d 1    ${DIR13}/${VAR}/${VAR}_${text1}_day_20010101-20051231.nc ${DIR14}/${VAR}/${VAR}_${text1}_day_20010101-20051231.nc
nccopy -k 4 -d 1    ${DIR13}/${VAR}/${VAR}_${text1}_day_20060101-20081231.nc ${DIR14}/${VAR}/${VAR}_${text1}_day_20060101-20081231.nc

mkdir -p ${DIR24}/${VAR}
nccopy -k 4 -d 1    ${DIR23}/${VAR}/${VAR}_${text1}_mon_198901-199012.nc     ${DIR24}/${VAR}/${VAR}_${text1}_mon_198901-199012.nc
nccopy -k 4 -d 1    ${DIR23}/${VAR}/${VAR}_${text1}_mon_199101-200012.nc     ${DIR24}/${VAR}/${VAR}_${text1}_mon_199101-200012.nc
nccopy -k 4 -d 1    ${DIR23}/${VAR}/${VAR}_${text1}_mon_200101-200812.nc     ${DIR24}/${VAR}/${VAR}_${text1}_mon_200101-200812.nc

mkdir -p ${DIR34}/${VAR}
nccopy -k 4 -d 1    ${DIR33}/${VAR}/${VAR}_${text1}_sem_198903-199011.nc     ${DIR34}/${VAR}/${VAR}_${text1}_sem_198903-199011.nc
nccopy -k 4 -d 1    ${DIR33}/${VAR}/${VAR}_${text1}_sem_199012-200011.nc     ${DIR34}/${VAR}/${VAR}_${text1}_sem_199012-200011.nc
nccopy -k 4 -d 1    ${DIR33}/${VAR}/${VAR}_${text1}_sem_200012-200811.nc     ${DIR34}/${VAR}/${VAR}_${text1}_sem_200012-200811.nc

done
done

#for VAR in tas tasmin tasmax ts pr ps sfcWind sfcWindmax uas vas zmla   ; do
for VAR in pr                                                           ; do
for DOM in EUR-11i EUR-44i                                              ; do

DIR24=/home1/regcm/DISK_WORK/temp/test_CORDEX/netcdf4/${DOM}/DHMZ/ECMWF-ERAINT/evaluation/r1i1p1/DHMZ-RegCM4-2/v1/mon/
DIR34=/home1/regcm/DISK_WORK/temp/test_CORDEX/netcdf4/${DOM}/DHMZ/ECMWF-ERAINT/evaluation/r1i1p1/DHMZ-RegCM4-2/v1/sem/
DIR23=/home1/regcm/DISK_WORK/temp/test_CORDEX/netcdf3/${DOM}/DHMZ/ECMWF-ERAINT/evaluation/r1i1p1/DHMZ-RegCM4-2/v1/mon/
DIR33=/home1/regcm/DISK_WORK/temp/test_CORDEX/netcdf3/${DOM}/DHMZ/ECMWF-ERAINT/evaluation/r1i1p1/DHMZ-RegCM4-2/v1/sem/
text1=${DOM}_ECMWF-ERAINT_evaluation_r1i1p1_DHMZ-RegCM4-2_v1

mkdir -p ${DIR24}/${VAR}
nccopy -k 4 -d 1    ${DIR23}/${VAR}/${VAR}_${text1}_mon_198901-199012.nc     ${DIR24}/${VAR}/${VAR}_${text1}_mon_198901-199012.nc
nccopy -k 4 -d 1    ${DIR23}/${VAR}/${VAR}_${text1}_mon_199101-200012.nc     ${DIR24}/${VAR}/${VAR}_${text1}_mon_199101-200012.nc
nccopy -k 4 -d 1    ${DIR23}/${VAR}/${VAR}_${text1}_mon_200101-200812.nc     ${DIR24}/${VAR}/${VAR}_${text1}_mon_200101-200812.nc

mkdir -p ${DIR34}/${VAR}
nccopy -k 4 -d 1    ${DIR33}/${VAR}/${VAR}_${text1}_sem_198903-199011.nc     ${DIR34}/${VAR}/${VAR}_${text1}_sem_198903-199011.nc
nccopy -k 4 -d 1    ${DIR33}/${VAR}/${VAR}_${text1}_sem_199012-200011.nc     ${DIR34}/${VAR}/${VAR}_${text1}_sem_199012-200011.nc
nccopy -k 4 -d 1    ${DIR33}/${VAR}/${VAR}_${text1}_sem_200012-200811.nc     ${DIR34}/${VAR}/${VAR}_${text1}_sem_200012-200811.nc

done
done
