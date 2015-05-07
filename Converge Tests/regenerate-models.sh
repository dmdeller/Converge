#!/usr/bin/env bash

#  regenerate-models.sh
#
#  Created by David Deller on 12/4/12.
#  Copyright (c) 2012-2015 TripCraft. All rights reserved.


command -v mogenerator >/dev/null 2>&1 || { echo >&2 "You need to install mogenerator with this command: brew install mogenerator"; exit 1; }


folder="Data Model"
datamodeld_path="TestModel.xcdatamodeld"
base_class="ConvergeRecord"

mogen_cmd="cd \"$folder\" && mogenerator --v2 -m \"./$datamodeld_path\" --base-class $base_class"
echo "$mogen_cmd"
echo
eval $mogen_cmd
