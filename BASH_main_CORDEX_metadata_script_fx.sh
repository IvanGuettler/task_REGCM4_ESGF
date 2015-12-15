#!/bin/bash

#Only for orog and sftls

#Assumptions:
	#(1) original files are allready daily means (or daily min/max). If not, first prepare these files separately.
        #(2) cdo & nco installed on your system. Important: ncap2 tool from the nco suit is needed.
        #(3) F90_gen_time.f90 successfully used
        #(4) Selected stages of preparing interpolated fileds: DM, MM, SM computed --> Domain reduced --> bilinear interpolation performed (only MM&SM)


#The location of cdo & nco 
#--> DHMZ vihor
CDO_PATH='/home1/regcm/regcmlibs_my_nco/bin'
NCO_PATH='/home1/regcm/regcmlibs_my_nco/bin'

#--> Select activities
       INDX=63 #WHICH VARIABLE? (use CORDEX_metadata_common to read more).
    collect=1  #Collect variable from various sources        
  rm_buffer=1  #Remove buffer zone e.g. 11 grid cells        
   metadata=1  #Edit meta-data                              
    convert=1  #Convert from netcdf3 > netcdf4 if needed

#General metadata
    source ./CORDEX_metadata_common
#Load meta data from separate file for specific experiment you are working on
    #source ./CORDEX_metadata_specific_50km_ERAIN
    source ./CORDEX_metadata_specific_12km_ERAIN
    export HDF5_DISABLE_VERSION_CHECK=1
#All temporary output in the following directory
    tempTarget=/work/regcm/temp/test_CORDEX



#==================================================
#STEP: prepare variable
#==================================================
if [ ${collect} == 1 ] ; then
    echo 'Collecting variable...'

    #---
    #Collect specific variable from RegCM output or separately prepared quantities
    #---
${NCO_PATH}/ncks -O -h -v iy,jx,${varalica[${INDX}]},xlon,xlat ${sourceDIR[${INDX}]}/${sourceFILE[${INDX}]} \
                                ${tempTarget}/${name[${INDX}]}.nc

    #---
    #Rename original RegCM variable to CORDEX variable
    #---
     ${NCO_PATH}/ncrename -v ${varalica[${INDX}]},${name[${INDX}]} ${tempTarget}/${name[${INDX}]}.nc

    #---
    #Set specific _FillValue and missing_value
    #---
     ${NCO_PATH}/ncatted  -O -a    _FillValue,${name[${INDX}]},c,f,1e+20    \
                             -a missing_value,${name[${INDX}]},c,f,1e+20 ${tempTarget}/${name[${INDX}]}.nc
    #---
    #Change units if needed
    #---
    # sftlf (-) -> sftlf (%)
    if [ ${INDX} == 63 ] ; then
	    ${NCO_PATH}/ncap2    -O -h -s "sftlf=sftlf*100"  ${tempTarget}/${name[${INDX}]}.nc  ${tempTarget}/test.nc
	    mv ${tempTarget}/test.nc                         ${tempTarget}/${name[${INDX}]}.nc
    fi

    #---
    #Convert to nc3
    #---
    nccopy -k 1              ${tempTarget}/${name[${INDX}]}.nc ${tempTarget}/temp.nc
    mv ${tempTarget}/temp.nc ${tempTarget}/${name[${INDX}]}.nc

    #---
    #Delete all global metadata
    #---
     ${NCO_PATH}/ncatted -O -h -a ,global,d,, ${tempTarget}/${name[${INDX}]}.nc
fi



#---
# Define filenames
#---
    FILE1=${tempTarget}/${name[${INDX}]}_${CORDEX_domain}_${driving_model_id}_${driving_experiment_name}_${driving_model_ensemble_member}_${model_id}_${rcm_version_id}_fx
    cp ${tempTarget}/${name[${INDX}]}.nc ${FILE1}.nc


#==================================================
#STEP: remove buffer
#==================================================
if [ ${rm_buffer} == 1 ] ; then
    echo 'Remove buffer zone...'
#---
# Remove the buffer zone
#---
    ${NCO_PATH}/ncks -O -h -d jx,${NXstart},${NXendic} -d  iy,${NYstart},${NYendic} ${FILE1}.nc ${FILE1}_rmBuffer.nc
#---
# Overwrite full domain
#---
    mv ${FILE1}_rmBuffer.nc ${FILE1}.nc
#---
# Now variables xlon,xlat can be renamed to lon,lait
#---
    ${NCO_PATH}/ncrename -O -h -v xlon,lon -v xlat,lat ${FILE1}.nc
#--
# Rename information concering the coordinates in the local metadata
#--
    ${NCO_PATH}/ncatted  -O -h -a coordinates,${name[${INDX}]},m,c,"lon lat"  ${FILE1}.nc
fi

#==================================================
#STEP: Editing meta-data
#==================================================

if [ ${metadata} == 1 ] ; then
    echo 'Editing meta-data...'

       EDITING=${FILE1}.nc #This is the file we will work on

    #---
    #PREPHASE 1: determine grid type from the filename
    #---
            INTERPI=0     #--------------------------> Original grid
    #---
    #PREPHASE 2: determine grid type from the filename day mon sem
    #---
            FREQ='fx'

echo "-----------------------------------------------------------------------------1"
    #---
    #PHASE 1: remove all global&local atributes
    #---
    ${NCO_PATH}/ncatted -O -h -a ,global,d,,     $EDITING
    ${NCO_PATH}/ncatted -O -h -a ,,d,,           $EDITING

echo "-----------------------------------------------------------------------------2"
    #---
    #PHASE 2: add global atributes needed by CORDEX
    #---
    ${NCO_PATH}/ncatted -O -h -a contact,global,c,c,"${contact}"                                               \
                              -a Conventions,global,c,c,"${Conventions}"                                       \
                              -a creation_date,global,c,c,"${creation_date}"                                   \
                              -a experiment,global,c,c,"${experiment}"                                         \
                              -a experiment_id,global,c,c,"${experiment_id}"                                   \
                              -a driving_model_id,global,c,c,"${driving_model_id}"                             \
                              -a driving_model_ensemble_member,global,c,c,"${driving_model_ensemble_member}"   \
                              -a driving_experiment_name,global,c,c,"${driving_experiment_name}"               \
                              -a driving_experiment,global,c,c,"${driving_experiment}"                         \
                              -a frequency,global,c,c,"${FREQ}"                                                \
                              -a institute_id,global,c,c,"${institute_id}"                                     \
                              -a institution,global,c,c,"${institution}"                                       \
                              -a model_id,global,c,c,"${model_id}"                                             \
                              -a rcm_version_id,global,c,c,"${rcm_version_id}"                                 \
                              -a project_id,global,c,c,"${project_id}"                                         \
                              -a product,global,c,c,"${product}"                                               \
                              -a references,global,c,c,"${references}" ${EDITING}

     export traka=$(uuidgen -r)
     ${NCO_PATH}/ncatted -O -h -a tracking_id,global,c,c,"${traka}"       ${EDITING}                        

echo "-----------------------------------------------------------------------------3"
    #---
    #PHASE 3: rename dimensions
    #---
    if [ ${INTERPI} == 0 ]; then
    ${NCO_PATH}/ncrename -O -h -v iy,y \
                               -v jx,x \
                               -d iy,y \
                               -d jx,x ${EDITING}
    ${NCO_PATH}/ncatted -O -h -a CORDEX_domain,global,c,c,"${CORDEX_domain}"   ${EDITING}
    fi
    
        	cd /home1/regcm/DISK_WORK/temp/test_CORDEX
	        ${NCO_PATH}/ncap2    -O -h -s "x=double(x(:)); y=double(y(:))"  ${EDITING} test_GRISHA.nc
	        ${NCO_PATH}/ncatted -O -h -a standard_name,x,c,c,"projection_x_coordinate"     \
	                                  -a     long_name,x,c,c,"x-coordinate in Cartesian"   \
                                          -a         units,x,c,c,"km"                          \
                                          -a          axis,x,c,c,"X"                           \
                                          -a standard_name,y,c,c,"projection_y_coordinate"     \
                                          -a     long_name,y,c,c,"y-coordinate in Cartesian"   \
                                          -a         units,y,c,c,"km"                          \
                                          -a          axis,y,c,c,"Y"                           test_GRISHA.nc
		mv test_GRISHA.nc ${EDITING}
	        cd /home1/regcm/DIR_ivan/work/2014_CORDEX_METADATA_WORLD

echo "-----------------------------------------------------------------------------4"
    #---
    #PHASE 4: edit local attributes of variables and variable-dimnesion
    #---
    ${NCO_PATH}/ncatted -O -h -a     long_name,${name[${INDX}]},c,c,"${long_name[${INDX}]}"  \
                              -a standard_name,${name[${INDX}]},c,c,"${stand_name[${INDX}]}" \
                              -a   coordinates,${name[${INDX}]},c,c,"lon lat"                \
                              -a         units,${name[${INDX}]},c,c,"${units[${INDX}]}"      \
                              -a       _FillValue,${name[${INDX}]},c,f,1e+20                 \
                              -a    missing_value,${name[${INDX}]},c,f,1e+20                 ${EDITING}

echo "-----------------------------------------------------------------------------5"
    #---
    #PHASE 5: edit height (this has to be generalized)
    #---

echo "-----------------------------------------------------------------------------5"
    #---
    #PHASE 6: lon/lat float > double
    #---

    ${NCO_PATH}/ncap2    -O -h -s "lon=double(lon);lat=double(lat)"  ${EDITING} ${tempTarget}/test.nc
    mv ${tempTarget}/test.nc ${EDITING}


echo "-----------------------------------------------------------------------------6"
    #---
    #PHASE 7: edit projection related stuff
    #---
    ${NCO_PATH}/ncatted -O -h -a units,lon,c,c,"degrees_east"      \
                              -a units,lat,c,c,"degrees_north"     \
                              -a long_name,lon,c,c,"longitude"     \
                              -a long_name,lat,c,c,"latitude"      \
                              -a standard_name,lon,c,c,"longitude" \
                              -a standard_name,lat,c,c,"latitude" ${EDITING}
    if [ ${INTERPI} == 0 ]; then
           ${NCO_PATH}/ncatted -O -h -a  grid_mapping,${name[${INDX}]},c,c,"${projection_name}" ${EDITING}
           ${NCO_PATH}/ncap2   -O -h -s  'Lambert_Conformal="Lambert_Conformal"'                ${EDITING}
           ${NCO_PATH}/ncatted -O -h -a grid_mapping_name,Lambert_Conformal,c,c,${projection_grid_mapping_name}                          \
                                     -a standard_parallel,Lambert_Conformal,c,f,${projection_standard_parallel1}                         \
                                     -a standard_parallel,Lambert_Conformal,a,f,${projection_standard_parallel2}                         \
                                     -a longitude_of_central_meridian,Lambert_Conformal,c,f,${projection_longitude_of_central_meridian}  \
                                     -a  false_easting,Lambert_Conformal,c,f,"${falseEasting}"                                           \
                                     -a false_northing,Lambert_Conformal,c,f,"${falseNorthing}"                                          \
                                     -a latitude_of_projection_origin,Lambert_Conformal,c,f,${projection_latitude_of_projection_origin}  ${EDITING}

    fi

echo "-----------------------------------------------------------------------------7"
    #---
    #PHASE 8: edit time related stuff
    #---
fi










#==================================================
#STEP: convert
#==================================================

if [ ${convert} == 1 ] ; then
    echo 'Converting netcdf3 > netcdf4...'

    cd ${tempTarget}
    EDITIN=(${name[${INDX}]}*${CORDEX_domain}*nc)

       EDITING=${EDITIN} #This is the file we will work on
    #---
    #PREPHASE 1: determine grid type from the filename day mon sem
    #---
       if  grep -q "_fx_"  <<< "${EDITING}"  ; then
            FREQ='fx'
       fi
        
        DIR=/${CORDEX_domain}/${institute_id}/${driving_model_id}/${driving_experiment_name}/${driving_model_ensemble_member}/${model_id}/${rcm_version_id}/${FREQ}/${name[${INDX}]}

         DIRIN=./netcdf3/${DIR}
        DIROUT=./netcdf4/${DIR}

        mkdir -p  ${DIRIN}
        mkdir -p ${DIROUT}

        mv ${EDITING} ${DIRIN}

        nccopy -k 4 -d 1 ${DIRIN}/${EDITING} ${DIROUT}/${EDITING}

fi

