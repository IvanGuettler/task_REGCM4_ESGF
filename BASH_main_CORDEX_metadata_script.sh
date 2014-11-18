#!/bin/bash

#Assumptions:
	#(1) original files are allready daily means (or daily min/max). If not, first prepare these files separately.
        #(2) cdo & nco installed on your system
        #(3) F90_gen_time.f90 successfully used

#The location of nco
#DHMZ vihor
NCO_PATH=/home1/regcm/regcmlibs_my_gfortran/bin/

       INDX=1 #WHICH VARIABLE? (use CORDEX_metadata_common to read more).
    collect=0 #Collect variable from various sources        
      means=0 #Calculate daily, monthly and seasonal means  
  rm_buffer=0 #Remove buffer zone e.g. 11 grid cells        
interpolate=1 #Interpolate to regular CORDEX grid (0.5 or 0.125 deg)
      split=0 #Split files into specific groups             
   metadata=0 #Edit meta-data                              
    convert=0 #Convert from netcdf3 > netcdf4 if needed

#General metadata
    source ./CORDEX_metadata_common
#Load meta data from separate file for specific experiment you are working on
    source ./CORDEX_metadata_specific_50km_ERAIN
#All temporary output in
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

    cdo remapbil,CORDEX_latlon_grid.txt ${FILE1}_all.nc ${FILE1i}_all.nc
    cdo remapbil,CORDEX_latlon_grid.txt ${FILE2}_all.nc ${FILE2i}_all.nc
    cdo remapbil,CORDEX_latlon_grid.txt ${FILE3}_all.nc ${FILE3i}_all.nc

    ${NCO_PATH}/ncrename -O -h -d lon,jx -d lat,iy    ${FILE1i}_all.nc
    ${NCO_PATH}/ncrename -O -h -d lon,jx -d lat,iy    ${FILE2i}_all.nc
    ${NCO_PATH}/ncrename -O -h -d lon,jx -d lat,iy    ${FILE3i}_all.nc

    ${NCO_PATH}/ncrename -O -h -v xlon,lon -v xlat,lat ${FILE1}_all.nc
    ${NCO_PATH}/ncrename -O -h -v xlon,lon -v xlat,lat ${FILE2}_all.nc
    ${NCO_PATH}/ncrename -O -h -v xlon,lon -v xlat,lat ${FILE3}_all.nc

    ${NCO_PATH}/ncatted  -O -h -a coordinates,tas,m,c,"lon lat"  ${FILE1}_all.nc
    ${NCO_PATH}/ncatted  -O -h -a coordinates,tas,m,c,"lon lat"  ${FILE2}_all.nc
    ${NCO_PATH}/ncatted  -O -h -a coordinates,tas,m,c,"lon lat"  ${FILE3}_all.nc
    ${NCO_PATH}/ncatted  -O -h -a coordinates,tas,c,c,"lon lat"  ${FILE1i}_all.nc
    ${NCO_PATH}/ncatted  -O -h -a coordinates,tas,c,c,"lon lat"  ${FILE2i}_all.nc
    ${NCO_PATH}/ncatted  -O -h -a coordinates,tas,c,c,"lon lat"  ${FILE3i}_all.nc

fi








#==================================================
#STEP: splitting
#==================================================

#This part is sensitive to details of time axis. Add and modify it carefully!
#Datumi koji ce pisati u nazivu datoteke
    DAYstrt[1]=19700101
    DAYendi[1]=19701230
    DAYstrt[2]=19710101
    DAYendi[2]=19751230
    DAYstrt[3]=19760101
    DAYendi[3]=19801230
    DAYstrt[4]=19810101
    DAYendi[4]=19851230
    DAYstrt[5]=19860101
    DAYendi[5]=19901230
    DAYstrt[6]=19910101
    DAYendi[6]=19951230
    DAYstrt[7]=19960101
    DAYendi[7]=20001230
    DAYstrt[8]=20010101
    DAYendi[8]=20051130
#Datumi koji su mi potrebni za ispravno definiranje intervala
    DAYendX[1]=19710101 #cdo uzima unutar intervala pa moramo prilagoditi ovako
    DAYendX[2]=19760101
    DAYendX[3]=19810101
    DAYendX[4]=19860101
    DAYendX[5]=19910101
    DAYendX[6]=19960101
    DAYendX[7]=20010101
    DAYendX[8]=20051201





#Datumi koji ce pisati u nazivu datoteke
    MONstrt[1]=197001
    MONendi[1]=197012
    MONstrt[2]=197101
    MONendi[2]=198012
    MONstrt[3]=198101
    MONendi[3]=199012
    MONstrt[4]=199101
    MONendi[4]=200012
    MONstrt[5]=200101
    MONendi[5]=200511
#Datumi koji su mi potrebni za ispravno definiranje intervala
    YEARSforMON[1]='1970'
    YEARSforMON[2]='1971,1972,1973,1974,1975,1976,1977,1978,1979,1980'
    YEARSforMON[3]='1981,1982,1983,1984,1985,1986,1987,1988,1989,1990'
    YEARSforMON[4]='1991,1992,1993,1994,1995,1996,1997,1998,1999,2000'
    YEARSforMON[5]='2001,2002,2003,2004,2005'










#Datumi koji ce pisati u nazivu datoteke
    SEMstrt[1]=197003
    SEMendi[1]=197011
    SEMstrt[2]=197012
    SEMendi[2]=198011
    SEMstrt[3]=198012
    SEMendi[3]=199011
    SEMstrt[4]=199012
    SEMendi[4]=200011
    SEMstrt[5]=200012
    SEMendi[5]=200511

#Datumi koji su mi potrebni za ispravno definiranje intervala
    SEMstrX[1]=19700530
    SEMendX[1]=19701230

    SEMstrX[2]=19710230
    SEMendX[2]=19801230

    SEMstrX[3]=19810230
    SEMendX[3]=19901230

    SEMstrX[4]=19910230
    SEMendX[4]=20001230

    SEMstrX[5]=20010230
    SEMendX[5]=20051230



if [ ${split} == 1 ] ; then
    echo 'Splitting files...'

    j=1
    while [ ${j} -le 8 ] ; do

#Splitting daily data
cdo setreftime,${time_start_date},${time_start_hour},${time_start_unit} -setcalendar,360days -settunits,days -seldate,${DAYstrt[${j}]},${DAYendX[${j}]} ${FILE1}_all.nc   ${FILE1}_${DAYstrt[${j}]}-${DAYendi[${j}]}.nc
cdo setreftime,${time_start_date},${time_start_hour},${time_start_unit} -setcalendar,360days -settunits,days -seldate,${DAYstrt[${j}]},${DAYendX[${j}]} ${FILE1i}_all.nc  ${FILE1i}_${DAYstrt[${j}]}-${DAYendi[${j}]}.nc

    ${NCO_PATH}/ncrename -O -h -d   y,iy -d   x,jx                           ${FILE1}_${DAYstrt[${j}]}-${DAYendi[${j}]}.nc
    ${NCO_PATH}/ncrename -O -h -d lat,iy -d lon,jx                           ${FILE1i}_${DAYstrt[${j}]}-${DAYendi[${j}]}.nc
    ${NCO_PATH}/ncks     -A -h -v iy,jx,lon,lat             ${FILE1}_all.nc  ${FILE1}_${DAYstrt[${j}]}-${DAYendi[${j}]}.nc



    if [ ${j} -le 5 ] ; then

#Splitting monthly data
cdo setreftime,${time_start_date},${time_start_hour},${time_start_unit} -setcalendar,360days -setday,15 -settunits,days   -selyear,${YEARSforMON[${j}]} ${FILE2}_all.nc   ${FILE2}_${MONstrt[${j}]}-${MONendi[${j}]}.nc
cdo setreftime,${time_start_date},${time_start_hour},${time_start_unit} -setcalendar,360days -setday,15 -settunits,days   -selyear,${YEARSforMON[${j}]} ${FILE2i}_all.nc  ${FILE2i}_${MONstrt[${j}]}-${MONendi[${j}]}.nc

    ${NCO_PATH}/ncrename -O -h -d y,iy   -d   x,jx                           ${FILE2}_${MONstrt[${j}]}-${MONendi[${j}]}.nc
    ${NCO_PATH}/ncrename -O -h -d lat,iy -d lon,jx                           ${FILE2i}_${MONstrt[${j}]}-${MONendi[${j}]}.nc
    ${NCO_PATH}/ncks     -A -h -v iy,jx,lon,lat             ${FILE2}_all.nc  ${FILE2}_${MONstrt[${j}]}-${MONendi[${j}]}.nc


#Splitting seasonal data
cdo setreftime,${time_start_date},${time_start_hour},${time_start_unit} -setcalendar,360days -setday,15 -shifttime,-1month -settunits,days  -seldate,${SEMstrX[${j}]},${SEMendX[${j}]} ${FILE3}_all.nc   ${FILE3}_${SEMstrt[${j}]}-${SEMendi[${j}]}.nc
cdo setreftime,${time_start_date},${time_start_hour},${time_start_unit} -setcalendar,360days -setday,15 -shifttime,-1month -settunits,days  -seldate,${SEMstrX[${j}]},${SEMendX[${j}]} ${FILE3i}_all.nc  ${FILE3i}_${SEMstrt[${j}]}-${SEMendi[${j}]}.nc

    ${NCO_PATH}/ncrename -O -h -d x,iy    -d   y,jx                          ${FILE3}_${SEMstrt[${j}]}-${SEMendi[${j}]}.nc
    ${NCO_PATH}/ncrename -O -h -d lat,iy  -d lon,jx                          ${FILE3i}_${SEMstrt[${j}]}-${SEMendi[${j}]}.nc
    ${NCO_PATH}/ncks     -A -h -v iy,jx,lon,lat             ${FILE3}_all.nc  ${FILE3}_${SEMstrt[${j}]}-${SEMendi[${j}]}.nc

    fi
    j=$((j+1))
    done
    mv ${name[${INDEX}]}*all.nc  ./temp
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
