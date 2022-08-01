#!/bin/bash
####################################################
# Archive script
# ------------------------
# Author: Simon Anliker
# Description: Creates a zip archive with all
#   files required for the submission.
#   The content of the generated zip is added
#   to the zip file as 'zip_content.txt' and
#   printed out to the console
####################################################

NAME=$1

# create archive
7z -xr!.idea -xr!.git* -x!index.txt a $NAME .

# additionally add content as txt to zip
7z l $NAME >zip_content.txt
7z a $NAME zip_content.txt

# list for verification
7z l $NAME
