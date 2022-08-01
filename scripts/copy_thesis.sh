#!/bin/bash
####################################################
# Thesis copy script
# ------------------------
# Author: Simon Anliker
# Description: Prepares the thesis for the submission
####################################################

NAME=$1

# copy compiled thesis
cp -f ../bsc-thesis/main.pdf $NAME

# use the last two pages (submission content) as index
pdftk $NAME cat 118-129 output index.pdf
