#!/bin/bash

DIR=/home1/regcm/DISK_WORK/temp/test_CORDEX
VAR=tas
text1=EUR-44_ECMWF-ERAINT_evaluation_r1i1p1_DHMZ-RegCM4-2_v1
text2=EUR-44i_ECMWF-ERAINT_evaluation_r1i1p1_DHMZ-RegCM4-2_v1

ncdump -h ${DIR}/${VAR}_${text1}_day_19890101-19901231.nc>  DM_metadata_report.txt
ncdump -h ${DIR}/${VAR}_${text1}_day_19910101-19951231.nc>> DM_metadata_report.txt
ncdump -h ${DIR}/${VAR}_${text1}_day_19960101-20001231.nc>> DM_metadata_report.txt
ncdump -h ${DIR}/${VAR}_${text1}_day_20010101-20051231.nc>> DM_metadata_report.txt
ncdump -h ${DIR}/${VAR}_${text1}_day_20060101-20081231.nc>> DM_metadata_report.txt


ncdump -h ${DIR}/${VAR}_${text1}_mon_198901-199012.nc>  MM_metadata_report.txt
ncdump -h ${DIR}/${VAR}_${text1}_mon_199101-200012.nc>> MM_metadata_report.txt
ncdump -h ${DIR}/${VAR}_${text1}_mon_200101-200812.nc>> MM_metadata_report.txt
ncdump -h ${DIR}/${VAR}_${text2}_mon_198901-199012.nc>> MM_metadata_report.txt
ncdump -h ${DIR}/${VAR}_${text2}_mon_199101-200012.nc>> MM_metadata_report.txt
ncdump -h ${DIR}/${VAR}_${text2}_mon_200101-200812.nc>> MM_metadata_report.txt


ncdump -h ${DIR}/${VAR}_${text1}_sem_198903-199011.nc>  SM_metadata_report.txt
ncdump -h ${DIR}/${VAR}_${text1}_sem_199012-200011.nc>> SM_metadata_report.txt
ncdump -h ${DIR}/${VAR}_${text1}_sem_200012-200811.nc>> SM_metadata_report.txt
ncdump -h ${DIR}/${VAR}_${text2}_sem_198903-199011.nc>> SM_metadata_report.txt
ncdump -h ${DIR}/${VAR}_${text2}_sem_199012-200011.nc>> SM_metadata_report.txt
ncdump -h ${DIR}/${VAR}_${text2}_sem_200012-200811.nc>> SM_metadata_report.txt
