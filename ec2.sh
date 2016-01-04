#!/usr/bin/env bash

set -uex

S3_DIR="/dev/shm/s3"
S3_BUCKET="r3.8xlarge"
IAM_ROLE="s3user"
PHV="${HOME}/phv"
S3_PHV="${S3_DIR}/phv_$(date +%s)"
SOC_CSV="input/csv/dt_soc.csv"

cd ${PHV}
[[ -f ${SOC_CSV} ]] || time Rscript prep_tables.R
if mkdir ${S3_DIR}; then
  sudo /usr/local/bin/s3fs ${S3_BUCKET} ${S3_DIR} \
    -o "rw,allow_other,$(id | sed 's/^.*\(uid=[0-9]\+\).*\(gid=[0-9]\+\).*$/\1,\2/g'),iam_role=${IAM_ROLE}"
fi
mkdir ${S3_PHV} && scp -r input output ${S3_PHV}

cd ${S3_PHV}
sed '1d' ${SOC_CSV} | cut -f 1 -d ' ' | xargs -P 9 -I {} time Rscript ${PHV}/hglm.R {} \
  || echo '*** Abnormal termination ***'
sudo poweroff
