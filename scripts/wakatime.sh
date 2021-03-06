#!/bin/bash +e

GITCONFIG_FILE="${HOME}/.gitconfig.local"
WAKATIME_ENV_FILE="${HOME}/.zshrc.d/099-wakatime.zsh"

if [ -f .env ]; then

  eval $(cat .env | sed 's/^/export /')
  
  # WAKATIME
  if [ ! -z "$WAKATIME_API_KEY" ]; then
    if [ $(uname -a | grep -ci Darwin) = 1 ]; then
      echo "export ZSH_WAKATIME_BIN=$(which wakatime-cli)" | tee $WAKATIME_ENV_FILE
    else
      echo "export ZSH_WAKATIME_BIN=$(which wakatime)" | tee -a $WAKATIME_ENV_FILE
    fi
    echo "export WAKATIME_API_KEY=${WAKATIME_API_KEY}" | tee -a $WAKATIME_ENV_FILE
    echo "export PATH=\$PATH:\$ZSH_WAKATIME_BIN" | tee -a $WAKATIME_ENV_FILE
  fi
  
else
  echo "You need to write a .env file. Use example.env to create it!!!"
  exit 1
fi
