#!/usr/bin/env bash

# Notes:
#
# For running test web server
# https://github.com/marc0der/gradle-spawn-plugin
#

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Checking prerequisites..."
echo
if ! command -v javac &> /dev/null
then
    echo -e "${RED}JDK not installed. Please install a distribution of JDK 17. Visit: https://github.com/shyiko/jabba${NC}"
    exit 1
fi
echo -e "${GREEN}JDK installed.${NC}"

if ! command -v gradle &> /dev/null
then
  echo -e "${RED}gradle not installed. Please visit: https://gradle.org/install/${NC}"
  while true; do
    read -p "Continue anyway? (y)es, (n)o" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
  done
  echo -e "${YELLOW}Continuing without gradle. If you encounter errors, please install gradle.${NC}"
else
  echo -e "${GREEN}Gradle installed.${NC}"
fi

while true; do
  echo "Project types:"
  echo "  a - accessor"
  echo "  c - connector"
  read -p "Enter the type  " projectType
  case $projectType in
      [a]* ) break;;
      [c]* ) break;;
      * ) echo -e "${RED}Invalid type $projectType${NC}";;
  esac
done

if [ "$projectType" = "a" ]; then
  read -p "Enter name of system to integrate (pascal-case. example: CheckFree) " systemName
  systemNameLc="$(echo "$systemName" | tr [:upper:] [:lower:])" ## lowercase the project name
  projectFolder="path-accessor-$systemNameLc"

  echo -e "${GREEN}Setting up accessor project in folder $projectFolder...${NC}"

  if [ -d "$projectFolder" ]; then
    while true; do
      read -p "$projectFolder already exists. (d)elete, (c)ontinue, (a)bort ? " dca
      case $dca in
        [Dd]* ) rm -Rf "$projectFolder"; break;;
        [Cc]* ) break;;
        * ) echo "Exiting..."; exit 1;;
      esac
    done
  fi

  echo -e "${GREEN}Creating project folder $projectFolder...${NC}"
  mkdir "./$projectFolder"
  cd "$projectFolder"

  echo -e "${GREEN}Loading bootstrap gradle files...${NC}"
  curl -O https://raw.githubusercontent.com/mxenabled/path-tools/master/bootstrap/template/build.gradle
  curl -O https://raw.githubusercontent.com/mxenabled/path-tools/master/bootstrap/template/settings.gradle

  echo -e "${GREEN}Setting up gradle wrapper...${NC}"
  gradle wrapper --distribution-type all

  echo -e "${GREEN}Scaffolding accessor project...${NC}"
  ./gradlew initAccessor --name=$systemName --language=JAVA --javaVersion=VERSION_17
  ./gradlew assemble

  echo ""
  echo -e "${GREEN}-----------------------------------------------${NC}"
  echo -e "${GREEN}- Project setup in $projectFolder${NC}"
  echo -e "${GREEN}-----------------------------------------------${NC}"
  echo ""
  exit 0
fi

echo ""
echo -e "${YELLOW}¯\_(ツ)_/¯${NC}"
exit 1
