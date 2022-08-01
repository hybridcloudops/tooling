#!/bin/bash
####################################################
# Index script
# ------------------------
# Author: Simon Anliker
# Description: Creates an index of all files
#   submitted and git hashes of the submodule
#   repositories and uses them to create
#   bsc-thesis/submission.tex
####################################################

TEMPLATE=../bsc-thesis/submission-template.tex
OUT=../bsc-thesis/submission.tex

TMP=index.tmp
GIT_TMP=git.tmp
SUB_TMP=submission.tmp

# use first 20 digits of commit hash for this repository
git rev-parse HEAD | awk '$1>0 { print substr($1,0,20)" bsc-all"}' >> $GIT_TMP
# use first 20 digits of commit hashes for summodules
git submodule status --recursive | awk -F" |+" '$2$3>0 { print substr($2,0,20)" "$3}' >> $GIT_TMP

# add refs to the submission file
awk 'NR==FNR { a[n++]=$0; next }/REFS/{ for (i=0;i<n;++i) print a[i]; next }1' $GIT_TMP $TEMPLATE > $SUB_TMP

# create tree of all files exluding .git* and .idea
tree -a -I ".git*|.idea|*.tmp" --dirsfirst --sort=name --charset=unicode >> $TMP

# add index to the submission file
awk 'NR==FNR { a[n++]=$0; next }/INDEX/{ for (i=0;i<n;++i) print a[i]; next }1' $TMP $SUB_TMP > $OUT

# remove index tmp file
rm $TMP $GIT_TMP $SUB_TMP
