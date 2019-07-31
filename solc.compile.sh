#!/usr/bin/env bash

# https://stackoverflow.com/questions/4906579/how-to-use-bash-to-create-a-folder-if-it-doesnt-already-exist
# -d  file is a directory
# see: bash file test operators https://www.tldp.org/LDP/abs/html/fto.html
if [[ ! -d ./compiled ]]; then
  # the -p flag causes any parent directories to be created if necessary
  echo "creating ./compiled";
  mkdir ./compiled;
fi

# compile:
solc --version
solc ./token/ERC223/ERC223_token.sol --bin --abi --optimize --gas --overwrite -o ./compiled/ > ./compiled/gas.estimation.txt