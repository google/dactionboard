#!/bin/bash

APP_CONFIG_FILE=$(git config -f "./settings.ini" config.config-file)

chmod +x ./run-local.sh
./run-local.sh --quiet --config $APP_CONFIG_FILE --google-ads-config google-ads.yaml
