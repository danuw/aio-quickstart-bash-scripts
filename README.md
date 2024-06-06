# AIO Quickstart Bash Scripts

A growing set of bash scripts to kickstart Azure IoT Operations in Github Codespaces.

## Overview

This project provides a set of bash scripts to quickly set up and start Azure IoT Operations in Github Codespaces. These scripts are designed to automate the setup process, making it easier and faster to get started with Azure IoT Operations, or re-run scenarios and quickly move onto the next learning steps.

## Prerequisites

Before you can use these scripts, you will need:

- Pre-requisites listed in https://learn.microsoft.com/en-us/azure/iot-operations/get-started/quickstart-deploy and in particular, having create a codespace using the [given link](https://github.com/codespaces/new/Azure-Samples/explore-iot-operations?quickstart=1)
- Ensure you have a user created as a member of your tenant (see [`az add user create`](https://learn.microsoft.com/en-us/cli/azure/ad/user?view=azure-cli-latest#az-ad-user-create) )

## How to use

The scripts are numbered to show the sequence in which to run. Here is the sequence:

1. `1-envs.sh`: This script sets and exports all the environment variables that will be needed to run the subsequent scripts. Be sure to edit this script with your own settings before running.
2. `1-azlogin.sh`: Simply ensuring you have signed into to your Azure account using the --use-device-code before you carry on to the next steps.
3. `2-quickstart-deploy.sh`: Re-run steps from https://learn.microsoft.com/en-us/azure/iot-operations/get-started/quickstart-deploy. It also ensures you have set the permissions on your tenant member user account for access to the https://iotoperations.azure.com UI
4. more to follow...
...

## What to expect

At first these scripts will follow the quickstart tutorial structure from the official documentation.

In the future, they will offer alternatives to cover Ubuntu cluster set up and other testing environements, as well as new scenarios.

## Troubleshooting

If you run into any issues while using these scripts, check for the following :

- These scripts were tested with [v0.5.0-preview release of IoT Operations](https://github.com/Azure/azure-iot-operations/releases/tag/v0.5.0-preview) and may need some updates if you are using a different version
- Ensure you have completed the prerequisites at https://learn.microsoft.com/en-us/azure/iot-operations/get-started/quickstart-deploy#prerequisites

## For more

These scripts were originally made available as gists [here](https://gist.github.com/danuw/37c931341d5cde145564a5bfe05cc4c7). The remaining scripts will be moved to this repo once they have been tested and verified.