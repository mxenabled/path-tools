#!/usr/bin/env bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Args
REPOSITORY="https://artifactory.internal.mx:443"
FORCE=false
while getopts 'n:t:a:r:f' opt; do
  case "$opt" in
    n)
    NAME=${OPTARG}
    ;;

    t)
    PROJECT_TYPE=${OPTARG}
    ;;

    a)
    ACCESSOR=${OPTARG}
    ;;

    r)
    REPOSITORY=${OPTARG}
    ;;

    f)
    FORCE=true
    ;;

    ?|h)
    echo ""
    echo "Usage: ./bootstrap.sh [OPTIONS]"
    echo "  -n [NAME]         - project name (in Pascal Case. Example: CheckFree)"
    echo "  -t [PROJECT_TYPE] - project type (a - accessor, c - connector)"
    echo "  -a [ACCESSOR]     - accessor coordinates"
    echo "  -r [REPOSITORY]   - repository (default: https://artifactory.internal.mx:443)"
    echo "  -f                - force delete existing folder"
    echo ""
    exit 1
    ;;
  esac
done

echo "Checking prerequisites..."
echo ""
if ! command -v javac &> /dev/null
then
    echo -e "${RED}JDK not installed. Please install a distribution of JDK 17. Visit: https://github.com/shyiko/jabba${NC}"
    exit 1
fi

echo -e "${GREEN}JDK installed.${NC}"
echo ""
if ! command -v gradle &> /dev/null
then
  echo -e "${RED}gradle not installed. Please visit: https://gradle.org/install/${NC}"
  while true; do
    read -p "Continue anyway? (y)es, (n)o  " yn
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

if [[ -z ${PROJECT_TYPE} ]]; then
  while true; do
    echo "Project types:"
    echo "  a - accessor"
    echo "  c - connector"
    read -p "Enter the type  " PROJECT_TYPE
    case $PROJECT_TYPE in
      [a]* ) break;;
      [c]* ) break;;
      * ) echo -e "${RED}Invalid type $PROJECT_TYPE${NC}";;
    esac
  done
fi

if [ "$PROJECT_TYPE" = "a" ]; then
  if [[ -z ${NAME} ]]; then
    read -p "Enter name of system to integrate (pascal-case. example: CheckFree)  " systemName
  else
    systemName="$NAME"
  fi

  systemNameLc="$(echo "$systemName" | tr [:upper:] [:lower:])" ## lowercase the project name
  projectFolder="path-accessor-$systemNameLc"

  echo -e "${GREEN}Setting up accessor project in folder $projectFolder...${NC}"

  if [ -d "$projectFolder" ]; then
    while true; do
      if [ $FORCE ]; then
        dca="d"
      else
        read -p "$projectFolder already exists. (d)elete, (c)ontinue, (a)bort ?  " dca
      fi

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
  ./gradlew initAccessorProject --name=$systemName --language=JAVA --javaVersion=VERSION_17
  ./gradlew assemble

  echo ""
  echo -e "${GREEN}-----------------------------------------------${NC}"
  echo -e "${GREEN}- Accessor setup in $projectFolder${NC}"
  echo -e "${GREEN}-----------------------------------------------${NC}"
  echo ""
  exit 0
fi

if [ "$PROJECT_TYPE" = "c" ]; then
  if [[ -z ${NAME} ]]; then
    read -p "Enter name client (pascal-case. example: AmericaFirst)  " clientName
  else
    clientName="$NAME"
  fi

  clientNameLc="$(echo "$clientName" | tr [:upper:] [:lower:])" ## lowercase the project name
  projectFolder="path-connector-$clientNameLc"

  if [[ -z ${ACCESSOR} ]]; then
    read -p "Accessor coordinates (example: com.mx.path.service.accessor:qolo)  " ACCESSOR
  fi

  echo -e "${GREEN}Setting up connector project in folder $projectFolder...${NC}"

  if [ -d "$projectFolder" ]; then
    while true; do
      if [ $FORCE ]; then
        dca="d"
      else
        read -p "$projectFolder already exists. (d)elete, (c)ontinue, (a)bort ?  " dca
      fi

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
  ./gradlew --stacktrace initConnectorProject --name=$clientName --clientId=$clientNameLc --language=JAVA --javaVersion=VERSION_17 --accessor=$ACCESSOR --repository=$REPOSITORY
  ./gradlew assemble

  echo ""
  echo -e "${GREEN}-----------------------------------------------${NC}"
  echo -e "${GREEN}- Connector setup in $projectFolder${NC}"
  echo -e "${GREEN}-----------------------------------------------${NC}"
  echo ""
  exit 0
fi

echo ""
echo -e "${YELLOW}¯\_(ツ)_/¯${NC}"
echo ""
exit 1
