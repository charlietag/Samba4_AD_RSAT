#!/bin/bash
#*****************************************************************************
#* Choose "Minimal Server" during the intstallation (works With Minimal ISO)
#*****************************************************************************
# --- Define github url for os_pre_lib
OS_PRE_LIB_GITHUB="https://github.com/charlietag/os_preparation_lib.git"

# --- Define filepath ---
## also in L_01_filepath.sh ##
CURRENT_SCRIPT="$(readlink -m $0)"
CURRENT_FOLDER="$(dirname "${CURRENT_SCRIPT}")"

# --- Define os_preparation_lib path ---
echo "#############################################"
echo "         Preparing required lib"
echo "#############################################"
OS_PRE_LIB="${CURRENT_FOLDER}/../os_preparation_lib"

# ### Make sure os_preparation_lib exists correctly ###
RC=1
if [[ ! -d "${OS_PRE_LIB}" ]]; then
  cd "$CURRENT_FOLDER/../"
  echo "Downloading required lib..."
  git clone $OS_PRE_LIB_GITHUB
  RC=$?
else
  cd $OS_PRE_LIB
  echo "Updating required lib to lastest version..."
  git pull
  RC=$?
fi

if [[ $RC -ne 0 ]]; then
  echo "Error occurs fetching github... !"
  exit
fi

if [[ ! -d "${OS_PRE_LIB}" ]]; then
  echo "${OS_PRE_LIB} does not exist... !"
  exit
fi
echo ""
# ### Make sure os_preparation_lib exists correctly ###

# --- Start ---
echo "#############################################"
echo "            Running start.sh"
echo "#############################################"
echo ""

cd $CURRENT_FOLDER
. "${OS_PRE_LIB}/lib/app.sh"

