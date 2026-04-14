#!/bin/bash -l

#SBATCH --job-name=run_vg
#SBATCH --account=pawseyxxxx
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=6G
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --mail-user=
#SBATCH --mail-type=END

module load singularity/4.1.0-nompi

#Load conda env

source ${MYSOFTWARE}/miniforge3/etc/profile.d/conda.sh
conda activate ${MYSOFTWARE}/miniforge3/envs/snakemake1

#Change cache dir
export XDG_CACHE_HOME=${MYSCRATCH}/vg_snakemake/.cache

#Unlock working directory
snakemake -s ${MYSCRATCH}/vg_snakemake/workflow/Snakefile --cores 4 --unlock

#Run snakemake
snakemake -s ${MYSCRATCH}/vg_snakemake/workflow/Snakefile --configfile ${MYSCRATCH}/vg_snakemake/config/config.hprc.yaml --profile ${MYSCRATCH}/vg_snakemake/setonix_profile --use-singularity -p map_surject_reads --rerun-incomplete --rerun-triggers mtime