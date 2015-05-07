#PBS -S /bin/bash
#PBS -N CRDX_fixMeta2
#PBS -l select=1:ncpus=1:mem=14gb
#PBS -q mono
#PBS -j oe
#PBS -m bae
#PBS -M ivan.guettler@gmail.com
#PBS -r n
#PBS -l cput=01:00:00

NCO_PATH='/home1/regcm/regcmlibs_my_nco/bin'
cd /home1/regcm/DIR_ivan/work/2014_CORDEX_METADATA_WORLD


for VAR in tas tasmin tasmax ts pr ps sfcWind sfcWindmax uas vas zmla ; do
for DOM in EUR-11 EUR-44                                              ; do

DIR13=/home1/regcm/DISK_WORK/temp/test_CORDEX/netcdf3/${DOM}/DHMZ/ECMWF-ERAINT/evaluation/r1i1p1/DHMZ-RegCM4-2/v1/day/
DIR23=/home1/regcm/DISK_WORK/temp/test_CORDEX/netcdf3/${DOM}/DHMZ/ECMWF-ERAINT/evaluation/r1i1p1/DHMZ-RegCM4-2/v1/mon/
DIR33=/home1/regcm/DISK_WORK/temp/test_CORDEX/netcdf3/${DOM}/DHMZ/ECMWF-ERAINT/evaluation/r1i1p1/DHMZ-RegCM4-2/v1/sem/
text1=${DOM}_ECMWF-ERAINT_evaluation_r1i1p1_DHMZ-RegCM4-2_v1
text2=${DOM}i_ECMWF-ERAINT_evaluation_r1i1p1_DHMZ-RegCM4-2_v1

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

iFILE[1]=${DIR23}/${VAR}/${VAR}_${text2}_mon_198901-199012.nc
iFILE[2]=${DIR23}/${VAR}/${VAR}_${text2}_mon_199101-200012.nc
iFILE[3]=${DIR23}/${VAR}/${VAR}_${text2}_mon_200101-200812.nc
iFILE[4]=${DIR33}/${VAR}/${VAR}_${text2}_sem_198903-199011.nc
iFILE[5]=${DIR33}/${VAR}/${VAR}_${text2}_sem_199012-200011.nc
iFILE[6]=${DIR33}/${VAR}/${VAR}_${text2}_sem_200012-200811.nc

# New metadata
	convention="CF-1.4"
        falseEasting=0
        falseNorthing=0 
        DATE11="2014-11-15T12:00:00:00Z"
        DATE44="2015-04-15T12:00:00:00Z"

for FFF in 1 2 3 4 5 6 7 8 9 10 11; do
        #-----------------------------
	#--> Grisha (1/8 and 2/8)
        #-----------------------------
	if [ ${VAR} == tas ] || [ ${VAR} == tasmin ] || [ ${VAR} == tasmax ] || [ ${VAR} == sfcWind ] || [ ${VAR} == sfcWindmax ] || [ ${VAR} == uas ] || [ ${VAR} == vas ] ; then
        # 1/8
        	cd /home1/regcm/DISK_WORK/temp/test_CORDEX
	        ${NCO_PATH}/ncwa -O -h --no_cll_mth -a lev ${FILE[${FFF}]} temp_GRISHA.nc
        	mv temp_GRISHA.nc ${FILE[${FFF}]}
	        cd /home1/regcm/DIR_ivan/work/2014_CORDEX_METADATA_WORLD
        # 2/8
		${NCO_PATH}/ncatted -O -h -a coordinates,${VAR},m,c,"lon lat height"  ${FILE[${FFF}]}
	fi #od fi
        #-----------------------------
	#--> Grisha (3/8)
        #-----------------------------
	${NCO_PATH}/ncatted -O -h -a Conventions,global,c,c,"${convention}"  ${FILE[${FFF}]}
        #-----------------------------
	#--> Grisha (4/8)
        #-----------------------------
        if [ ${DOM} == EUR-11 ] ; then
	${NCO_PATH}/ncatted -O -h -a creation_date,global,m,c,"${DATE11}"  ${FILE[${FFF}]}
        fi
        if [ ${DOM} == EUR-44 ] ; then
	${NCO_PATH}/ncatted -O -h -a creation_date,global,m,c,"${DATE44}"  ${FILE[${FFF}]}
        fi
        #-----------------------------
	#--> Grisha (5/8)
        #-----------------------------
	export traka=$(uuidgen -r)
	${NCO_PATH}/ncatted -O -h -a tracking_id,global,c,c,"${traka}"       ${FILE[${FFF}]}
        #-----------------------------
	#--> Grisha (6/8)
        #-----------------------------
        	cd /home1/regcm/DISK_WORK/temp/test_CORDEX
	        ${NCO_PATH}/ncap2    -O -h -s "x(:)=double(x(:)); y=double(y(:))"  ${FILE[${FFF}]} test_GRISHA.nc
	        ${NCO_PATH}/ncatted -O -h -a standard_name,x,c,c,"projection_x_coordinate"     \
	                                  -a     long_name,x,c,c,"x-coordinate in Cartesian"   \
                                          -a         units,x,c,c,"km"                          \
                                          -a          axis,x,c,c,"X"                           \
                                          -a standard_name,y,c,c,"projection_y_coordinate"     \
                                          -a     long_name,y,c,c,"y-coordinate in Cartesian"   \
                                          -a         units,y,c,c,"km"                          \
                                          -a          axis,y,c,c,"Y"                           test_GRISHA.nc
		mv test_GRISHA.nc ${FILE[${FFF}]}
	        cd /home1/regcm/DIR_ivan/work/2014_CORDEX_METADATA_WORLD
        #-----------------------------
	#--> Grisha (7/8)
        #-----------------------------
	${NCO_PATH}/ncatted -O -h -a  false_easting,Lambert_Conformal,c,f,"${falseEasting}"   ${FILE[${FFF}]}
	${NCO_PATH}/ncatted -O -h -a false_northing,Lambert_Conformal,c,f,"${falseNorthing}"  ${FILE[${FFF}]}
        #-----------------------------
	#--> Grisha (8/8)
        #-----------------------------
	${NCO_PATH}/ncatted -O -h -a  axis,x,d,,   ${FILE[${FFF}]}
	${NCO_PATH}/ncatted -O -h -a  axis,y,d,,   ${FILE[${FFF}]}
done #od FFF

for FFF in 1 2 3 4 5 6            ; do
        #-----------------------------
	#--> Grisha (1/8) and (2/8)
        #-----------------------------
	if [ ${VAR} == tas ] || [ ${VAR} == tasmin ] || [ ${VAR} == tasmax ] || [ ${VAR} == sfcWind ] || [ ${VAR} == sfcWindmax ] || [ ${VAR} == uas ] || [ ${VAR} == vas ] ; then
        # 1/8
        	cd /home1/regcm/DISK_WORK/temp/test_CORDEX
	        ${NCO_PATH}/ncwa -O -h --no_cll_mth -a lev ${iFILE[${FFF}]} temp_GRISHA.nc
	        mv temp_GRISHA.nc                          ${iFILE[${FFF}]}
        	cd /home1/regcm/DIR_ivan/work/2014_CORDEX_METADATA_WORLD
        # 2/8
		${NCO_PATH}/ncatted -O -h -a coordinates,${VAR},m,c,"lon lat height"  ${iFILE[${FFF}]}
	fi #od fi
        #-----------------------------
	#--> Grisha (3/8)
        #-----------------------------
	${NCO_PATH}/ncatted -O -h -a Conventions,global,c,c,"${convention}"   ${iFILE[${FFF}]}
        #-----------------------------
	#--> Grisha (4/8)
        #-----------------------------
        if [ ${DOM} == EUR-11 ] ; then
	${NCO_PATH}/ncatted -O -h -a creation_date,global,m,c,"${DATE11}"  ${iFILE[${FFF}]}
        fi
        if [ ${DOM} == EUR-44 ] ; then
	${NCO_PATH}/ncatted -O -h -a creation_date,global,m,c,"${DATE44}"  ${iFILE[${FFF}]}
        fi
        #-----------------------------
	#--> Grisha (5/8)
        #-----------------------------
	export traka=$(uuidgen -r)
	${NCO_PATH}/ncatted -O -h -a tracking_id,global,c,c,"${traka}"        ${iFILE[${FFF}]}
        #-----------------------------
	#--> Grisha (6/8)
        #-----------------------------
	# None! Only original output.
        #-----------------------------
	#--> Grisha (7/8)
        #-----------------------------
	# None! Only original output.
        #-----------------------------
	#--> Grisha (8/8)
        #-----------------------------
	# None! Only original output.
done #od FFF


done #od DOM
done #od VAR
