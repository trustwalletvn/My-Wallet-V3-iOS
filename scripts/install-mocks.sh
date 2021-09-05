#!/bin/sh
#
#  scripts/generate_mocks.sh
#
#  What It Does
#  ------------
#  Install mock generating script using mockingbird.
#
#  If you need to install mocks to a test target from package source add a line to this script.
#  You can exclude unwanted or problematic sources from being mocked by adding a .mockingbird-ignore file.
#
#  Mocks will be actually generated when you first run tests.

echo "generate_mocks.sh begin"
echo "\n"

echo "AnalyticsKit mocks"
cd Modules/Analytics
sh Scripts/generate_mocks.sh
cd ../..

echo "\n"
echo "generate_mocks.sh end"
