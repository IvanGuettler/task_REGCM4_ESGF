#!/bin/bash

#Assumptions:
	#(1) original files are allready daily means (or daily min/max). If not, first prepare these files separately.
        #(2) cdo & nco installed on your system
        #(3) F90_gen_time.f90 successfully used
        #(4) Selected stages of preparing interpolated fileds: DM, MM, SM computed --> Domain reduced --> bilinear interpolation performed.

#The location of cdo & nco 
#--> DHMZ vihor
CDO_PATH='version 1.6.0 installed on the system (November 2014)'
NCO_PATH=/home1/regcm/regcmlibs_my_gfortran/bin/

#--> Select activities
       INDX=1 #WHICH VARIABLE? (use CORDEX_metadata_common to read more).
    collect=0 #Collect variable from various sources        
      means=0 #Calculate daily, monthly and seasonal means  
  rm_buffer=0 #Remove buffer zone e.g. 11 grid cells        
interpolate=0 #Interpolate to regular CORDEX grid (0.5 or 0.125 deg)
      split=1 #Split files into specific groups             
   metadata=0 #Edit meta-data                              
    convert=0 #Convert from netcdf3 > netcdf4 if needed

#General metadata
    source ./CORDEX_metadata_common
#Load meta data from separate file for specific experiment you are working on
    source ./CORDEX_metadata_specific_50km_ERAIN
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
${NCO_PATH}/ncks -O -h -v time,time_bnds,iy,jx,${varalica[${INDX}]},xlon,xlat,m2                           \
           ${sourceDIR[${INDX}]}/${sourceFILE[${INDX}]}.${YEAR}${MONTHS[${MNTH}]}0100.nc                   \
                         ${tempTarget}/${name[${INDX}]}_${YEAR}${MONTHS[${MNTH}]}0100.nc
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
cdo -r setreftime,${time_start_date},${time_start_hour},${time_start_unit} -setcalendar,${time_calendar} -settunits,days           ${tempTarget}/${name[${INDX}]}.nc ${FILE1}_all.nc
cdo -r setreftime,${time_start_date},${time_start_hour},${time_start_unit} -setcalendar,${time_calendar} -settunits,days -monmean  ${tempTarget}/${name[${INDX}]}.nc ${FILE2}_all.nc
cdo -r setreftime,${time_start_date},${time_start_hour},${time_start_unit} -setcalendar,${time_calendar} -settunits,days -seasmean ${tempTarget}/${name[${INDX}]}.nc ${FILE3}_all.nc

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
    cdo remapbil,${RegularGrid} ${FILE2}_all.nc ${FILE2i}_all.nc
    cdo remapbil,${RegularGrid} ${FILE3}_all.nc ${FILE3i}_all.nc

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
    	cdo seldate,${filenameDM[${j}]:1:4}-${filenameDM[${j}]:5:2}-${filenameDM[${j}]:7:4}T00:00:00,${filenameDM[${j}]:10:4}-${filenameDM[${j}]:14:2}-${filenameDM[${j}]:16:2}T23:59:59 ${FILE1}_all.nc   ${FILE1}${filenameDM[${j}]}.nc

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
	cdo seldate,${filenameMM[${j}]:1:4}-${filenameMM[${j}]:5:2}-01T00:00:00,${filenameMM[${j}]:8:4}-${filenameMM[${j}]:12:2}-31T23:59:59 ${FILE2}_all.nc    ${FILE2}${filenameMM[${j}]}.nc
	cdo seldate,${filenameMM[${j}]:1:4}-${filenameMM[${j}]:5:2}-01T00:00:00,${filenameMM[${j}]:8:4}-${filenameMM[${j}]:12:2}-31T23:59:59 ${FILE2i}_all.nc  ${FILE2i}${filenameMM[${j}]}.nc

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
	cdo seldate,${filenameSM[${j}]:1:4}-${filenameSM[${j}]:5:2}-01T00:00:00,${filenameSM[${j}]:8:4}-${filenameSM[${j}]:12:2}-31T23:59:59 ${FILE3}_all.nc    ${FILE3}${filenameSM[${j}]}.nc
	cdo seldate,${filenameSM[${j}]:1:4}-${filenameSM[${j}]:5:2}-01T00:00:00,${filenameSM[${j}]:8:4}-${filenameSM[${j}]:12:2}-31T23:59:59 ${FILE3i}_all.nc  ${FILE3i}${filenameSM[${j}]}.nc

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


fi









#==================================================
#STEP: Editing meta-data
#==================================================

if [ ${metadata} == 1 ] ; then
    echo 'Editing meta-data...'

    EDITIN=(${name[${INDEX}]}*nc)

    file=0
    while [ ${file} -le 35 ] ; do #jer je 35+1 datoteka koju treba obraditi
        echo ${EDITIN[${file}]}
        EDITING=${EDITIN[${file}]} #Datoteka na kojoj radim
        part1=${EDITING:8:3}       #Jel li osnovna mreza ili interpolirano. 8 znak, 3 unaprijed. Ovisit ce o varijabli
        if [ ${part1} == '44_' ] ; then
            INTERPI=0 #Originalni grid
            FREQ=${EDITING:61:3}
        fi
        if [ ${part1} == '44i' ] ; then
            INTERPI=1 #Interpolirano
            FREQ=${EDITING:62:3}
        fi



    #---
    #PHASE 1: delete many unnecessar global atributes
    #---
    ${NCO_PATH}/ncatted -O -h -a CDI,global,d,,     \
                           -a history,global,d,, \
                           -a title,global,d,,   \
                           -a model_timestep_in_hours_boundary_input,global,d,, \
                           -a model_timestep_in_hours_radiation_calc,global,d,, \
                           -a model_timestep_in_seconds_bats_calc,global,d,, \
                           -a model_timestep_in_minutes_solar_rad_calc,global,d,, \
                           -a model_timestep_in_seconds,global,d,, \
                           -a model_simulation_is_a_restart,global,d,, \
                           -a model_simulation_expected_end,global,d,, \
                           -a model_simulation_start,global,d,, \
                           -a model_simulation_initial_start,global,d,, \
                           -a model_seasonal_desert_albedo_effect,global,d,, \
                           -a model_seaice_effect,global,d,, \
                           -a model_diurnal_cycle_sst,global,d,, \
                           -a model_chemistry,global,d,, \
                           -a model_use_lake_model,global,d,, \
                           -a model_use_emission_factor,global,d,, \
                           -a model_pressure_gradient_force_scheme,global,d,, \
                           -a model_ocean_flux_scheme,global,d,, \
                           -a model_moist_physics_scheme,global,d,, \
                           -a model_boundary_layer_scheme,global,d,, \
                           -a model_cumulous_convection_scheme,global,d,, \
                           -a model_boundary_conditions,global,d,, \
                           -a model_IPCC_scenario,global,d,, \
                           -a projection,global,d,, \
                           -a grid_mapping_name,global,d,, \
                           -a grid_size_in_meters,global,d,, \
                           -a latitude_of_projection_origin,global,d,, \
                           -a longitude_of_projection_origin,global,d,,  \
                           -a longitude_of_central_meridian,global,d,, \
                           -a standard_parallel,global,d,, \
                           -a NCO,global,d,,     \
                           -a CDO,global,d,,     $EDITING
    #---
    #PHASE 2: add global atributes needed by CORDEX (some are modified, some are created)
    #---
    ${NCO_PATH}/ncatted -O -h -a contact,global,c,c,"${contact}" \
                              -a comment,global,c,c,"${comment}" \
                              -a creation_date,global,c,c,"${creation_date}" \
                              -a experiment_id,global,c,c,"${experiment_id}" \
                              -a experiment,global,m,c,"${experiment}"       \
                              -a driving_experiment,global,c,c,"${driving_experiment}" \
                              -a driving_model_id,global,c,c,"${driving_model_id}"     \
                              -a driving_model_ensemble_member,global,c,c,"${driving_model_ensemble_member}"   \
                              -a driving_experiment_name,global,c,c,"${driving_experiment_name}"  \
                              -a frequency,global,c,c,"${FREQ}" \
                              -a institude_id,global,c,c,"${institude_id}" \
                              -a institution,global,m,c,"${institution}" \
                              -a model_id,global,c,c,"${model_id}" \
                              -a project_id,global,c,c,"${project_id}" \
                              -a CORDEX_domain,global,c,c,"${CORDEX_domain}" \
                              -a RCM_version_id,global,c,c,"${RCM_version_id}" \
                              -a product,global,c,c,"${product}" \
                              -a references,global,m,c,"${references}" $EDITING
    #---
    #PHASE 3: rename dimensions m2,x,y,xlon,xlat
    #---
    ${NCO_PATH}/ncrename -O -h -d m2,lev \
                               -v m2,height \
                               -d iy,yc \
                               -d jx,xc $EDITING
    if [ ${INTERPI} == 0 ]; then
    ${NCO_PATH}/ncrename -O -h -v iy,yc \
                               -v jx,xc $EDITING
    fi

    #---
    #PHASE 4: edit local attributes of variables and variable-dimnesion
    #---
    ${NCO_PATH}/ncatted -O -h -a     long_name,${name[${INDEX}]},m,c,"${long_name[${INDEX}]}" \
                              -a standard_name,${name[${INDEX}]},m,c,"${stand_name[${INDEX}]}" \
                              -a   coordinates,${name[${INDEX}]},m,c,"lon lat" \
                              -a         units,${name[${INDEX}]},m,c,"${units[${INDEX}]}" \
                              -a  cell_methods,${name[${INDEX}]},m,c,"time: ${cellMethod[${INDEX}]}" $EDITING

    ${NCO_PATH}/ncap -O -h -s "height=double(2);lon=double(lon);lat=double(lat)"  $EDITING test.nc
    mv test.nc $EDITING

    ${NCO_PATH}/ncatted -O -h -a long_name,height,c,c,${H2_longname} \
                              -a standard_name,height,c,c,${H2_standardname} \
                              -a units,height,c,c,${H2_units} \
                              -a axis,height,c,c,${H2_axis} \
                              -a positive,height,c,c,${H2_positive} \
                              -a axis,lon,c,c,"Y" \
                              -a axis,lat,c,c,"X" \
                              -a units,lon,c,c,"degrees_east" \
                              -a units,lat,c,c,"degrees_north"  \
                              -a long_name,lon,c,c,"longitude" \
                              -a long_name,lat,c,c,"latitude"  \
                              -a standard_name,lon,c,c,"longitude" \
                              -a standard_name,lat,c,c,"latitude" $EDITING

    #---
    #PHASE 5: edit projection related stuff
    #---
    if [ ${INTERPI} == 0 ]; then
    ${NCO_PATH}/ncatted -O -h -a  grid_mapping,${name[${INDEX}]},c,c,"${projection_name}" $EDITING
    ${NCO_PATH}/ncks -A -h -v ${projection_name} map.nc $EDITING
    fi

    #---
    #PHASE 5: edit time related stuff
    #---
    ${NCO_PATH}/ncatted -O -h -a long_name,time,c,c,${time_long_name} \
                              -a standard_name,time,c,c,${time_standard_name}  \
                              -a axis,time,c,c,${time_axis} $EDITING

    #---
    #PHASE 6: editing missing values one more time
    #---
#    ${NCO_PATH}/ncatted -O -h -a _FillValue,${name[${INDEX}]},c,f,1e+20    $EDITING
#    ${NCO_PATH}/ncatted -O -h -a missing_value,${name[${INDEX}]},c,f,1e+20 $EDITING

    file=$((file+1))
    done
fi










#==================================================
#STEP: convert
#==================================================

if [ ${convert} == 1 ] ; then
    echo 'Converting netcdf3 > netcdf4...'

    NCCOPY_NETCDF4=/disk2/home/regcm/ivan/PROGRAM_GFORTRAN_HDF5/bin
    EDITIN=(${name[${INDEX}]}*nc)

    file=0
    while [ ${file} -le 35 ] ; do #jer je 35+1 datoteka koju treba obraditi
        echo ${EDITIN[${file}]}
        EDITING=${EDITIN[${file}]}
        part1=${EDITING:8:3}       #Jel li osnovna mreza ili  interpolirano. 8 znak, 3 unaprijed. Ovisit ce o varijabli
        if [ ${part1} == '44_' ] ; then
                INTERPI=0 #Originalni grid
                FREQ=${EDITING:61:3}
        fi
        if [ ${part1} == '44i' ] ; then
                INTERPI=1 #Interpolirano
                FREQ=${EDITING:62:3}
        fi

        DOMAIN=${CORDEX_domain}
        INSTITUTE=${institude_id}
        GCMModelName=${driving_model_id}
        CMIP5ExperimentName=${driving_experiment_name}
        CMIP5EnsembleMember=${driving_model_ensemble_member}
        RCMModelName=DHMZ-REGCM42
        RCMVersionID=${RCM_version_id}
        DIR=/${DOMAIN}/${INSTITUTE}/${GCMModelName}/${CMIP5ExperimentName}/${CMIP5EnsembleMember}/${RCMModelName}/${RCMVersionID}/${FREQ}/${name[${INDEX}]}

         DIRIN=./netcdf3/${DIR}
        DIROUT=./netcdf4/${DIR}

        mkdir -p ./netcdf3/${DIR}
        mkdir -p ./netcdf4/${DIR}

      ${NCO_PATH}/ncatted -O -h -a axis,lon,c,c,'X' \
                                -a axis,lon,m,c,'X' \
                                -a axis,lat,c,c,'Y' \
                                -a axis,lat,m,c,'Y' ${EDITING}
        mv ${EDITING} ./netcdf3/${DIR}

        ${NCCOPY_NETCDF4}/nccopy -k 4 -d 1 ${DIRIN}/${EDITING} ${DIROUT}/${EDITING}

        file=$((file+1))
    done

fi