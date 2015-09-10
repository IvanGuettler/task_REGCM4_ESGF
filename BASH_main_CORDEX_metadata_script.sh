#!/bin/bash

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
       INDX=1  #WHICH VARIABLE? (use CORDEX_metadata_common to read more).
    collect=1  #Collect variable from various sources        
      means=1  #Calculate daily, monthly and seasonal means  
  rm_buffer=1  #Remove buffer zone e.g. 11 grid cells        
interpolate=1  #Interpolate to regular CORDEX grid (0.5 or 0.125 deg)
      split=1  #Split files into specific groups             
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
    for YEAR in $(seq ${STARTyyy} ${ENDyyy}); do
    echo ${YEAR}
            for MNTH in 0 1 2 3 4 5 6 7 8 9 10 11 ; do 
	    echo ${MNTH}
            if [ ${heights[${INDX}]} == 0 ] ; then
${NCO_PATH}/ncks -O -h -v time,time_bnds,iy,jx,${varalica[${INDX}]},xlon,xlat                              \
           ${sourceDIR[${INDX}]}/${sourceFILE[${INDX}]}.${YEAR}${MONTHS[${MNTH}]}0100.nc                   \
                         ${tempTarget}/${name[${INDX}]}_${YEAR}${MONTHS[${MNTH}]}0100.nc
            fi
            if [ ${heights[${INDX}]} == 2 ] ; then
${NCO_PATH}/ncks -O -h -v time,time_bnds,iy,jx,${varalica[${INDX}]},xlon,xlat,m2                           \
           ${sourceDIR[${INDX}]}/${sourceFILE[${INDX}]}.${YEAR}${MONTHS[${MNTH}]}0100.nc                   \
                         ${tempTarget}/${name[${INDX}]}_${YEAR}${MONTHS[${MNTH}]}0100.nc
            fi
            if [ ${heights[${INDX}]} == 10 ] ; then
${NCO_PATH}/ncks -O -h -v time,time_bnds,iy,jx,${varalica[${INDX}]},xlon,xlat,m10                          \
           ${sourceDIR[${INDX}]}/${sourceFILE[${INDX}]}.${YEAR}${MONTHS[${MNTH}]}0100.nc                   \
                         ${tempTarget}/${name[${INDX}]}_${YEAR}${MONTHS[${MNTH}]}0100.nc
            fi
            done #<<< MNTH
    done #<<< YEAR


    #---
    #Join all files into one file
    #---
     ${NCO_PATH}/ncrcat   -h ${tempTarget}/${name[${INDX}]}_??????0100.nc        ${tempTarget}/${name[${INDX}]}.nc
      rm -vf ${tempTarget}/${name[${INDX}]}_??????0100.nc

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
    # ps (hPa) --> ps (Pa)
    if [ ${INDX} == 5 ] ; then
	    ${NCO_PATH}/ncap2    -O -h -s "ps=ps*100"  ${tempTarget}/${name[${INDX}]}.nc  ${tempTarget}/test.nc
	    mv ${tempTarget}/test.nc                   ${tempTarget}/${name[${INDX}]}.nc
    fi

    #---
    #Delete all global metadata
    #---
     ${NCO_PATH}/ncatted -O -h -a ,global,d,, ${tempTarget}/${name[${INDX}]}.nc
     

fi









#==================================================
#STEP: DM,MM and SM
#==================================================

#---
# Define filenames: DM, MM and SM: original an interpolated
#---
    FILE1=${tempTarget}/${name[${INDX}]}_${CORDEX_domain}_${driving_model_id}_${driving_experiment_name}_${driving_model_ensemble_member}_${model_id}_${rcm_version_id}_day
    FILE2=${tempTarget}/${name[${INDX}]}_${CORDEX_domain}_${driving_model_id}_${driving_experiment_name}_${driving_model_ensemble_member}_${model_id}_${rcm_version_id}_mon
    FILE3=${tempTarget}/${name[${INDX}]}_${CORDEX_domain}_${driving_model_id}_${driving_experiment_name}_${driving_model_ensemble_member}_${model_id}_${rcm_version_id}_sem
    FILE1i=${tempTarget}/${name[${INDX}]}_${CORDEX_domain}i_${driving_model_id}_${driving_experiment_name}_${driving_model_ensemble_member}_${model_id}_${rcm_version_id}_day
    FILE2i=${tempTarget}/${name[${INDX}]}_${CORDEX_domain}i_${driving_model_id}_${driving_experiment_name}_${driving_model_ensemble_member}_${model_id}_${rcm_version_id}_mon
    FILE3i=${tempTarget}/${name[${INDX}]}_${CORDEX_domain}i_${driving_model_id}_${driving_experiment_name}_${driving_model_ensemble_member}_${model_id}_${rcm_version_id}_sem


if [ ${means} == 1 ] ; then
#---
# Perform averaging
#---
echo 'DM, MM and SM...'
${CDO_PATH}/cdo -f nc -r setreftime,${time_start_date},${time_start_hour},${time_start_unit} -setcalendar,${time_calendar} -settunits,days           ${tempTarget}/${name[${INDX}]}.nc ${FILE1}_all.nc
${CDO_PATH}/cdo -f nc -r setreftime,${time_start_date},${time_start_hour},${time_start_unit} -setcalendar,${time_calendar} -settunits,days -monmean  ${tempTarget}/${name[${INDX}]}.nc ${FILE2}_all.nc
${CDO_PATH}/cdo -f nc -r setreftime,${time_start_date},${time_start_hour},${time_start_unit} -setcalendar,${time_calendar} -settunits,days -seasmean ${tempTarget}/${name[${INDX}]}.nc ${FILE3}_all.nc

#---
# Rename dimension x,y into jx,iy
#---
    ${NCO_PATH}/ncrename -O -h -d x,jx -d y,iy     ${FILE1}_all.nc
    ${NCO_PATH}/ncrename -O -h -d x,jx -d y,iy     ${FILE2}_all.nc
    ${NCO_PATH}/ncrename -O -h -d x,jx -d y,iy     ${FILE3}_all.nc

#---
# cdo did not copy varialbes iy,jx. (Recheck this step with new cdo version)
#---
    ${NCO_PATH}/ncks     -A -h -v iy,jx   ${tempTarget}/${name[${INDX}]}.nc   ${FILE1}_all.nc
    ${NCO_PATH}/ncks     -A -h -v iy,jx   ${tempTarget}/${name[${INDX}]}.nc   ${FILE2}_all.nc
    ${NCO_PATH}/ncks     -A -h -v iy,jx   ${tempTarget}/${name[${INDX}]}.nc   ${FILE3}_all.nc

#---
#Set specific _FillValue and missing_value
#---
    ${NCO_PATH}/ncatted  -O -a _FillValue,${name[${INDX}]},c,f,1e+20 -a  missing_value,${name[${INDX}]},c,f,1e+20 ${FILE1}_all.nc
    ${NCO_PATH}/ncatted  -O -a _FillValue,${name[${INDX}]},c,f,1e+20 -a  missing_value,${name[${INDX}]},c,f,1e+20 ${FILE2}_all.nc
    ${NCO_PATH}/ncatted  -O -a _FillValue,${name[${INDX}]},c,f,1e+20 -a  missing_value,${name[${INDX}]},c,f,1e+20 ${FILE3}_all.nc

#---
#Delete all global metadata
#---
     ${NCO_PATH}/ncatted -O -h -a ,global,d,, ${FILE1}_all.nc
     ${NCO_PATH}/ncatted -O -h -a ,global,d,, ${FILE2}_all.nc
     ${NCO_PATH}/ncatted -O -h -a ,global,d,, ${FILE3}_all.nc

fi









#==================================================
#STEP: remove buffer
#==================================================
if [ ${rm_buffer} == 1 ] ; then
    echo 'Remove buffer zone...'
#---
# Remove the buffer zone
#---
    ${NCO_PATH}/ncks -O -h -d jx,${NXstart},${NXendic} -d  iy,${NYstart},${NYendic} ${FILE1}_all.nc ${FILE1}_all_rmBuffer.nc
    ${NCO_PATH}/ncks -O -h -d jx,${NXstart},${NXendic} -d  iy,${NYstart},${NYendic} ${FILE2}_all.nc ${FILE2}_all_rmBuffer.nc
    ${NCO_PATH}/ncks -O -h -d jx,${NXstart},${NXendic} -d  iy,${NYstart},${NYendic} ${FILE3}_all.nc ${FILE3}_all_rmBuffer.nc
#---
# Overwrite full domain
#---
    mv ${FILE1}_all_rmBuffer.nc ${FILE1}_all.nc
    mv ${FILE2}_all_rmBuffer.nc ${FILE2}_all.nc
    mv ${FILE3}_all_rmBuffer.nc ${FILE3}_all.nc
fi









#==================================================
#STEP: interpolation
#==================================================
if [ ${interpolate} == 1 ] ; then
    echo 'Interpolating...'

#---
# Interpolate MM and SM (According to "CORDEX Archive Design" Version 3.1 only MM and SM are needed on regular grid
#---
    ${CDO_PATH}/cdo remapbil,${RegularGrid} ${FILE2}_all.nc ${FILE2i}_all.nc
    ${CDO_PATH}/cdo remapbil,${RegularGrid} ${FILE3}_all.nc ${FILE3i}_all.nc

#---
# Rename dimensions lon,lat into jx,iy
#---
    ${NCO_PATH}/ncrename -O -h -d lon,jx -d lat,iy    ${FILE2i}_all.nc
    ${NCO_PATH}/ncrename -O -h -d lon,jx -d lat,iy    ${FILE3i}_all.nc

#---
# After performing interpolation using cdo, variables xlon,xlat can be renamed to lon,lat
#---
    ${NCO_PATH}/ncrename -O -h -v xlon,lon -v xlat,lat ${FILE1}_all.nc
    ${NCO_PATH}/ncrename -O -h -v xlon,lon -v xlat,lat ${FILE2}_all.nc
    ${NCO_PATH}/ncrename -O -h -v xlon,lon -v xlat,lat ${FILE3}_all.nc

#--
# Rename information concering the coordinates in the local metadata
#--
    ${NCO_PATH}/ncatted  -O -h -a coordinates,${name[${INDX}]},m,c,"lon lat"  ${FILE1}_all.nc
    ${NCO_PATH}/ncatted  -O -h -a coordinates,${name[${INDX}]},m,c,"lon lat"  ${FILE2}_all.nc
    ${NCO_PATH}/ncatted  -O -h -a coordinates,${name[${INDX}]},m,c,"lon lat"  ${FILE3}_all.nc 
    
    ${NCO_PATH}/ncatted  -O -h -a coordinates,${name[${INDX}]},c,c,"lon lat"  ${FILE2i}_all.nc
    ${NCO_PATH}/ncatted  -O -h -a coordinates,${name[${INDX}]},c,c,"lon lat"  ${FILE3i}_all.nc

#---
#Delete all global metadata
#---
     ${NCO_PATH}/ncatted -O -h -a ,global,d,, ${FILE1}_all.nc
     ${NCO_PATH}/ncatted -O -h -a ,global,d,, ${FILE2}_all.nc
     ${NCO_PATH}/ncatted -O -h -a ,global,d,, ${FILE3}_all.nc

     ${NCO_PATH}/ncatted -O -h -a ,global,d,, ${FILE2i}_all.nc
     ${NCO_PATH}/ncatted -O -h -a ,global,d,, ${FILE3i}_all.nc

fi









#==================================================
#STEP: splitting entire DM, MM, SM files into smaller chunks according to the CORDEX Archive Design requirements
#==================================================

# This part of the code assumes everything was fine with the F90_gen_time.f90. Test carefully and send possible bug details to ivan.guettler@gmail.com.
#--
# Ingest files containg parts of the filenames (start-end)
#--
	source ./prepared_filenames_DM.txt
	source ./prepared_filenames_MM.txt
	source ./prepared_filenames_SM.txt

if [ ${split} == 1 ] ; then
    echo 'Splitting files...'

#--
#Splitting daily data
#--
    j=1
    while [ ${j} -le ${NFILES_DM} ] ; do
    	${CDO_PATH}/cdo seldate,${filenameDM[${j}]:1:4}-${filenameDM[${j}]:5:2}-${filenameDM[${j}]:7:4}T00:00:00,${filenameDM[${j}]:10:4}-${filenameDM[${j}]:14:2}-${filenameDM[${j}]:16:2}T23:59:59 ${FILE1}_all.nc   ${FILE1}${filenameDM[${j}]}.nc

#--
#Fixing some names
#--
        ${NCO_PATH}/ncrename -O -h -d   y,iy -d   x,jx                        ${FILE1}${filenameDM[${j}]}.nc
	${NCO_PATH}/ncks     -A -h -v  iy,jx                 ${FILE1}_all.nc  ${FILE1}${filenameDM[${j}]}.nc
#---
#Delete all global metadata
#---
        ${NCO_PATH}/ncatted -O -h -a ,global,d,, ${FILE1}${filenameDM[${j}]}.nc
        j=$((j+1))
    done # j loop

#--
#Splitting monthly data
#--
    j=1
    while [ ${j} -le ${NFILES_MM} ] ; do
${CDO_PATH}/cdo seldate,${filenameMM[${j}]:1:4}-${filenameMM[${j}]:5:2}-01T00:00:00,${filenameMM[${j}]:8:4}-${filenameMM[${j}]:12:2}-31T23:59:59 ${FILE2}_all.nc    ${FILE2}${filenameMM[${j}]}.nc

${CDO_PATH}/cdo seldate,${filenameMM[${j}]:1:4}-${filenameMM[${j}]:5:2}-01T00:00:00,${filenameMM[${j}]:8:4}-${filenameMM[${j}]:12:2}-31T23:59:59 ${FILE2i}_all.nc  ${FILE2i}${filenameMM[${j}]}.nc

#--
#Time step has to be centered between two time_bnds. This is great idea from Grigory Nikulin:
#--
${NCO_PATH}/ncap2 -s "time=((time_bnds(:,0)+time_bnds(:,1))/2.0)" ${FILE2}${filenameMM[${j}]}.nc ${tempTarget}/temp.nc
mv ${tempTarget}/temp.nc ${FILE2}${filenameMM[${j}]}.nc
${NCO_PATH}/ncap2 -s "time=((time_bnds(:,0)+time_bnds(:,1))/2.0)" ${FILE2i}${filenameMM[${j}]}.nc ${tempTarget}/temp.nc
mv ${tempTarget}/temp.nc ${FILE2i}${filenameMM[${j}]}.nc


#--
#Fixing some names
#--
        ${NCO_PATH}/ncrename -O -h -d y,iy   -d   x,jx                            ${FILE2}${filenameMM[${j}]}.nc
        ${NCO_PATH}/ncks     -A -h -v iy,jx                     ${FILE2}_all.nc   ${FILE2}${filenameMM[${j}]}.nc

#---
#Delete all global metadata
#---
        ${NCO_PATH}/ncatted -O -h -a ,global,d,,  ${FILE2}${filenameMM[${j}]}.nc
        ${NCO_PATH}/ncatted -O -h -a ,global,d,, ${FILE2i}${filenameMM[${j}]}.nc

        j=$((j+1))
    done # j loop

#--
#Splitting seasonal data
#--
    j=1
    while [ ${j} -le ${NFILES_SM} ] ; do
${CDO_PATH}/cdo seldate,${filenameSM[${j}]:1:4}-${filenameSM[${j}]:5:2}-01T00:00:00,${filenameSM[${j}]:8:4}-${filenameSM[${j}]:12:2}-31T23:59:59 ${FILE3}_all.nc    ${FILE3}${filenameSM[${j}]}.nc
${CDO_PATH}/cdo seldate,${filenameSM[${j}]:1:4}-${filenameSM[${j}]:5:2}-01T00:00:00,${filenameSM[${j}]:8:4}-${filenameSM[${j}]:12:2}-31T23:59:59 ${FILE3i}_all.nc  ${FILE3i}${filenameSM[${j}]}.nc

#--
#Time step has to be centered between two time_bnds. This is great idea from Grigory Nikulin:
#--
${NCO_PATH}/ncap2 -s "time=((time_bnds(:,0)+time_bnds(:,1))/2.0)"  ${FILE3}${filenameSM[${j}]}.nc ${tempTarget}/temp.nc
mv ${tempTarget}/temp.nc ${FILE3}${filenameSM[${j}]}.nc
${NCO_PATH}/ncap2 -s "time=((time_bnds(:,0)+time_bnds(:,1))/2.0)" ${FILE3i}${filenameSM[${j}]}.nc ${tempTarget}/temp.nc
mv ${tempTarget}/temp.nc ${FILE3i}${filenameSM[${j}]}.nc

#--
#Fixing some names
#--
        ${NCO_PATH}/ncrename -O -h -d y,iy   -d   x,jx                            ${FILE3}${filenameSM[${j}]}.nc
        ${NCO_PATH}/ncks     -A -h -v iy,jx                     ${FILE3}_all.nc   ${FILE3}${filenameSM[${j}]}.nc

#---
#Delete all global metadata
#---
        ${NCO_PATH}/ncatted -O -h -a ,global,d,,  ${FILE3}${filenameSM[${j}]}.nc
        ${NCO_PATH}/ncatted -O -h -a ,global,d,, ${FILE3i}${filenameSM[${j}]}.nc

       j=$((j+1))
   done # j loop

#---
#Move unsplitted data to temp directory
#---
        mkdir -p                             ${tempTarget}/temp
	# 2015-04-07 mv ${tempTarget}/*_all.nc            ${tempTarget}/temp
	rm -vf          ${tempTarget}/*_all.nc        
        mv ${tempTarget}/${name[${INDX}]}.nc ${tempTarget}/temp
fi









#==================================================
#STEP: Editing meta-data
#==================================================

if [ ${metadata} == 1 ] ; then
    echo 'Editing meta-data...'

    EDITIN=(${tempTarget}/${name[${INDX}]}*${CORDEX_domain}*nc)
    FILENUMBER=${#EDITIN[@]}
    FILENUMBER=$((FILENUMBER-1))

    file=0
     while [ ${file} -le ${FILENUMBER} ] ; do
#    while [ ${file} -le 0 ] ; do
          echo ${EDITIN[${file}]}
       EDITING=${EDITIN[${file}]} #This is the file we will work on

    #---
    #PREPHASE 1: determine grid type from the filename
    #---
       if   grep -q "44_"  <<< "${EDITING}"  ; then
            INTERPI=0     #--------------------------> Original grid
       fi
       if   grep -q "44i_" <<< "${EDITING}"  ; then
            INTERPI=1     #--------------------------> Interpolated grid
       fi
       if   grep -q "11_"  <<< "${EDITING}"  ; then
            INTERPI=0     #--------------------------> Original grid
       fi
       if   grep -q "11i_" <<< "${EDITING}"  ; then
            INTERPI=1     #--------------------------> Interpolated grid
       fi
    #---
    #PREPHASE 2: determine grid type from the filename day mon sem
    #---
       if  grep -q "_day_"  <<< "${EDITING}"  ; then
            FREQ='day'
       fi
       if  grep -q "_mon_"  <<< "${EDITING}"  ; then
            FREQ='mon'
       fi
       if  grep -q "_sem_"  <<< "${EDITING}"  ; then
            FREQ='sem'
       fi

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
    if [ ${INTERPI} == 1 ]; then
    ${NCO_PATH}/ncatted -O  -h -a CORDEX_domain,global,c,c,"${CORDEX_domain_i}" ${EDITING}
    fi
    if [ ${heights[${INDX}]} == 2 ]; then
    ${NCO_PATH}/ncrename -O -h -d m2,lev ${EDITING}
    fi
    if [ ${heights[${INDX}]} == 10 ]; then
    ${NCO_PATH}/ncrename -O -h -d m10,lev ${EDITING}
    fi
   

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
     if [ ${FREQ} == 'day' ]; then
	${NCO_PATH}/ncatted -O -h -a     cell_methods,${name[${INDX}]},c,c,"${cellMethodDM[${INDX}]}"    ${EDITING}
     fi
     if [ ${FREQ} == 'mon' ]; then
	${NCO_PATH}/ncatted -O -h -a     cell_methods,${name[${INDX}]},c,c,"${cellMethodMMSM[${INDX}]}"  ${EDITING}
     fi
     if [ ${FREQ} == 'sem' ]; then
	${NCO_PATH}/ncatted -O -h -a     cell_methods,${name[${INDX}]},c,c,"${cellMethodMMSM[${INDX}]}"  ${EDITING}
     fi

echo "-----------------------------------------------------------------------------5"
    #---
    #PHASE 5: edit height (this has to be generalized)
    #---
    if [ ${heights[${INDX}]} == 2 ]; then
    ${NCO_PATH}/ncrename -O -h -v m2,height              ${EDITING}
    ${NCO_PATH}/ncap2    -O -h -s "height(:)=double(2)"  ${EDITING} ${tempTarget}/test.nc
    mv ${tempTarget}/test.nc ${EDITING}
    ${NCO_PATH}/ncatted -O -h -a long_name,height,c,c,${H2_longname}         \
                              -a standard_name,height,c,c,${H2_standardname} \
                              -a units,height,c,c,${H2_units}                \
                              -a axis,height,c,c,${H2_axis}                  \
                              -a positive,height,c,c,${H2_positive}          ${EDITING}
    fi
    if [ ${heights[${INDX}]} == 10 ]; then
    ${NCO_PATH}/ncrename -O -h -v m10,height              ${EDITING}
    ${NCO_PATH}/ncap2    -O -h -s "height(:)=double(10)"  ${EDITING} ${tempTarget}/test.nc
    mv ${tempTarget}/test.nc ${EDITING}
    ${NCO_PATH}/ncatted -O -h -a long_name,height,c,c,${H2_longname}         \
                              -a standard_name,height,c,c,${H2_standardname} \
                              -a units,height,c,c,${H2_units}                \
                              -a axis,height,c,c,${H2_axis}                  \
                              -a positive,height,c,c,${H2_positive}          ${EDITING}
    fi

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
    ${NCO_PATH}/ncatted -O -h -a axis,lon,c,c,"X"                  \
                              -a axis,lat,c,c,"Y"                  \
                              -a units,lon,c,c,"degrees_east"      \
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
                                     -a latitude_of_projection_origin,Lambert_Conformal,c,f,${projection_latitude_of_projection_origin}  ${EDITING}

    fi

echo "-----------------------------------------------------------------------------7"
  
    #---
    #PHASE 8: edit time related stuff
    #---
    ${NCO_PATH}/ncatted -O -h -a long_name,time,c,c,${time_long_name}             \
                              -a standard_name,time,c,c,${time_standard_name}     \
                              -a axis,time,c,c,${time_axis}                       \
                              -a units,time,c,c,"days since 1949-12-01 00:00:00Z" \
                              -a calendar,time,c,c,${time_calendar}               \
                              -a bounds,time,c,c,${time_bounds}                   ${EDITING}
    ${NCO_PATH}/ncrename -O -h -d nb2,bnds                                        ${EDITING}
    
    file=$((file+1))
    done
fi










#==================================================
#STEP: convert
#==================================================

if [ ${convert} == 1 ] ; then
    echo 'Converting netcdf3 > netcdf4...'

    cd ${tempTarget}
    EDITIN=(${name[${INDX}]}*${CORDEX_domain}*nc)
    FILENUMBER=${#EDITIN[@]}
    FILENUMBER=$((FILENUMBER-1))

    file=0
     while [ ${file} -le ${FILENUMBER} ] ; do
          echo ${EDITIN[${file}]}
       EDITING=${EDITIN[${file}]} #This is the file we will work on
    #---
    #PREPHASE 1: determine grid type from the filename day mon sem
    #---
       if  grep -q "_day_"  <<< "${EDITING}"  ; then
            FREQ='day'
       fi
       if  grep -q "_mon_"  <<< "${EDITING}"  ; then
            FREQ='mon'
       fi
       if  grep -q "_sem_"  <<< "${EDITING}"  ; then
            FREQ='sem'
       fi

        
        DIR=/${CORDEX_domain}/${institute_id}/${driving_model_id}/${driving_experiment_name}/${driving_model_ensemble_member}/${model_id}/${rcm_version_id}/${FREQ}/${name[${INDX}]}

         DIRIN=./netcdf3/${DIR}
        DIROUT=./netcdf4/${DIR}

        mkdir -p  ${DIRIN}
        mkdir -p ${DIROUT}

        mv ${EDITING} ${DIRIN}

        nccopy -k 4 -d 1 ${DIRIN}/${EDITING} ${DIROUT}/${EDITING}

        file=$((file+1))
    done

fi

