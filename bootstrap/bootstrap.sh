#!/usr/bin/env bash

# Notes:
#
# For running test web server
# https://github.com/marc0der/gradle-spawn-plugin
#

echo "Checking prerequisites..."
echo
if ! command -v javac &> /dev/null
then
    echo "JDK not installed. Please install a distribution of JDK 17. Visit: https://github.com/shyiko/jabba"
    exit 1
fi
echo "JDK installed."

if ! command -v gradle &> /dev/null
then
  echo "gradle not installed. Please visit: https://gradle.org/install/"
  while true; do
    read -p "Do you wish to continue anyway? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
  done
  echo "Continuing without gradle. If you encounter errors, please install gradle."
else
  echo "Gradle installed."
fi

while true; do
  echo "Project types:"
  echo "  a - accessor"
  echo "  c - connector"
  read -p "Enter the type  " projectType
  case $projectType in
      [a]* ) break;;
      [c]* ) break;;
      * ) echo "Invalid type";;
  esac
done

if [ "$projectType" = "a" ]; then
  read -p "Enter name of system to integrate (lower case) " systemName
  projectFolder="accessor-$systemName"
  mkdir "./$projectFolder"
  pushd "$projectFolder"

  curl -o build.gradle -L https://raw.github.com/mxenabled/path-tools/add_bootstrap/bootstrap/template/build.gradle
  curl -o build.gradle -L https://raw.github.com/mxenabled/path-tools/add_bootstrap/bootstrap/template/settings.gradle

  gradle wrapper --distribution-type all

  gradle tasks
fi

exit 0
