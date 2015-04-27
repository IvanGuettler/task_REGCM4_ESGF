#!/bin/bash

VAR=vas

for DOM in EUR-11 EUR-44; do

DIR1=/home1/regcm/DISK_WORK/temp/test_CORDEX/netcdf3/${DOM}/DHMZ/ECMWF-ERAINT/evaluation/r1i1p1/DHMZ-RegCM4-2/v1/day/
DIR2=/home1/regcm/DISK_WORK/temp/test_CORDEX/netcdf3/${DOM}/DHMZ/ECMWF-ERAINT/evaluation/r1i1p1/DHMZ-RegCM4-2/v1/mon/
DIR3=/home1/regcm/DISK_WORK/temp/test_CORDEX/netcdf3/${DOM}/DHMZ/ECMWF-ERAINT/evaluation/r1i1p1/DHMZ-RegCM4-2/v1/sem/
text1=${DOM}_ECMWF-ERAINT_evaluation_r1i1p1_DHMZ-RegCM4-2_v1
text2=${DOM}i_ECMWF-ERAINT_evaluation_r1i1p1_DHMZ-RegCM4-2_v1

ncdump -h ${DIR1}/${VAR}/${VAR}_${text1}_day_19890101-19901231.nc>  DM_metadata_report_${DOM}.txt
ncdump -h ${DIR1}/${VAR}/${VAR}_${text1}_day_19910101-19951231.nc>> DM_metadata_report_${DOM}.txt
ncdump -h ${DIR1}/${VAR}/${VAR}_${text1}_day_19960101-20001231.nc>> DM_metadata_report_${DOM}.txt
ncdump -h ${DIR1}/${VAR}/${VAR}_${text1}_day_20010101-20051231.nc>> DM_metadata_report_${DOM}.txt
ncdump -h ${DIR1}/${VAR}/${VAR}_${text1}_day_20060101-20081231.nc>> DM_metadata_report_${DOM}.txt


ncdump -h ${DIR2}/${VAR}/${VAR}_${text1}_mon_198901-199012.nc>  MM_metadata_report_${DOM}.txt
ncdump -h ${DIR2}/${VAR}/${VAR}_${text1}_mon_199101-200012.nc>> MM_metadata_report_${DOM}.txt
ncdump -h ${DIR2}/${VAR}/${VAR}_${text1}_mon_200101-200812.nc>> MM_metadata_report_${DOM}.txt
ncdump -h ${DIR2}/${VAR}/${VAR}_${text2}_mon_198901-199012.nc>> MM_metadata_report_${DOM}.txt
ncdump -h ${DIR2}/${VAR}/${VAR}_${text2}_mon_199101-200012.nc>> MM_metadata_report_${DOM}.txt
ncdump -h ${DIR2}/${VAR}/${VAR}_${text2}_mon_200101-200812.nc>> MM_metadata_report_${DOM}.txt


ncdump -h ${DIR3}/${VAR}/${VAR}_${text1}_sem_198903-199011.nc>  SM_metadata_report_${DOM}.txt
ncdump -h ${DIR3}/${VAR}/${VAR}_${text1}_sem_199012-200011.nc>> SM_metadata_report_${DOM}.txt
ncdump -h ${DIR3}/${VAR}/${VAR}_${text1}_sem_200012-200811.nc>> SM_metadata_report_${DOM}.txt
ncdump -h ${DIR3}/${VAR}/${VAR}_${text2}_sem_198903-199011.nc>> SM_metadata_report_${DOM}.txt
ncdump -h ${DIR3}/${VAR}/${VAR}_${text2}_sem_199012-200011.nc>> SM_metadata_report_${DOM}.txt
ncdump -h ${DIR3}/${VAR}/${VAR}_${text2}_sem_200012-200811.nc>> SM_metadata_report_${DOM}.txt

done
