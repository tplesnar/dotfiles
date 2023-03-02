#!/usr/bin/env bash

defaults read > settings-before.txt

echo "Toggle your setting and press any key"
read

defaults read > settings-after.txt

code --diff settings-before.txt settings-after.txt