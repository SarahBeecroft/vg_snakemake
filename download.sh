#!/bin/bash -l

#SBATCH --job-name=download_pangenome
#SBATCH --account=pawseyxxxx
#SBATCH --partition=copy
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --nodes=1
#SBATCH --array=1-6
#SBATCH --time=2:00:00
#SBATCH --output=logs/download_pangenome_%A_%a.out
#SBATCH --error=logs/download_pangenome_%A_%a.err

set -euo pipefail

mkdir -p logs
mkdir -p ${MYSCRATCH}/vg_snakemake/refs/hprcv2.0/
cd ${MYSCRATCH}/vg_snakemake/refs/hprcv2.0/


module load aws-cli/2.13.0

export AWS_CONFIG_FILE="${SLURM_TMPDIR:-/tmp}/aws_config_${SLURM_JOB_ID}.ini"
export AWS_SHARED_CREDENTIALS_FILE="${SLURM_TMPDIR:-/tmp}/aws_creds_${SLURM_JOB_ID}.ini"
: > "${AWS_CONFIG_FILE}"
: > "${AWS_SHARED_CREDENTIALS_FILE}"


# Tune multipart parallelism (no credentials needed for public buckets)
aws configure set default.s3.max_concurrent_requests 20
aws configure set default.s3.multipart_chunksize 64MB
aws configure set default.s3.multipart_threshold 64MB

# One S3 URI per array task. Add/remove entries and update --array=1-N.
urls=(
  "s3://human-pangenomics/pangenomes/freeze/freeze1/minigraph-cactus/hprc-v1.1-mc-grch38/hprc-v1.1-mc-grch38.gbz"
  "s3://human-pangenomics/pangenomes/freeze/freeze1/minigraph-cactus/hprc-v1.1-mc-grch38/hprc-v1.1-mc-grch38.hapl"
  "s3://human-pangenomics/pangenomes/freeze/freeze1/minigraph-cactus/hprc-v1.1-mc-chm13/hprc-v1.1-mc-chm13.gbz"
  "s3://human-pangenomics/pangenomes/freeze/freeze1/minigraph-cactus/hprc-v1.1-mc-chm13/hprc-v1.1-mc-chm13.hapl"
  "s3://human-pangenomics/pangenomes/freeze/release2/minigraph-cactus/hprc-v2.0-mc-grch38.gbz"
  "s3://human-pangenomics/pangenomes/freeze/release2/minigraph-cactus/hprc-v2.0-mc-grch38.hapl"
)

URL="${urls[$((SLURM_ARRAY_TASK_ID - 1))]}"
echo "[task ${SLURM_ARRAY_TASK_ID}] downloading: ${URL}"

aws s3 cp --no-sign-request --region us-west-2 "${URL}" .

echo "[task ${SLURM_ARRAY_TASK_ID}] done"
