#PBS -S /bin/bash
#PBS -N job_nc3tonc4
#PBS -l select=1:ncpus=1:mem=4gb
#PBS -l place=pack:shared
#PBS -q mono
#PBS -j oe
#PBS -m bae
#PBS -M ivan.guettler@gmail.com
#PBS -r n
#PBS -l cput=24:00:00


export            PATH=/opt/sgi/mpt/mpt-2.07/bin:/opt/intel/bin:${PATH}
export LD_LIBRARY_PATH=/opt/sgi/mpt/mpt-2.07/lib:/opt/intel/lib/intel64:${LD_LIBRARY_PATH}


cd /disk/regcm/CORDEX/TEST/RegCM-version/output_CORDEX_MAR2012/FILES_STS

for YEAR in {1989..2008}                        ; do
for MONT in 01 02 03 04 05 06 07 08 09 10 11 12 ; do
	nccopy -k 4 -d 1 EUROPE_STS.${YEAR}${MONT}0100.nc EUROPE_STS.${YEAR}${MONT}0100_nc4.nc
done
done
for YEAR in 2009                                ; do
for MONT in 01 02 03 04 05                      ; do
	nccopy -k 4 -d 1 EUROPE_STS.${YEAR}${MONT}0100.nc EUROPE_STS.${YEAR}${MONT}0100_nc4.nc
done
done

