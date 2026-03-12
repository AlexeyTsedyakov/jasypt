#!/bin/sh

SCRIPT_NAME=jasypt.sh

if [ -z "$1" ]
then
  echo "Usage: $SCRIPT_NAME <encrypt|decrypt|encrypt-file|decrypt-file> [arguments]"
  echo ""
  echo "Required arguments:"
  echo "<encrypt|decrypt> [input, password]"
  echo "<encrypt-file|decrypt-file> [filePath, password]"
  echo ""
  echo "Optional arguments:"
  echo "[verbose, algorithm, keyObtentionIterations, saltGeneratorClassName, providerName, providerClassName, stringOutputType, ivGeneratorClassName, fileCharset]"
  exit 1
fi

COMMAND=$1
shift

EXECUTABLE_CLASS=
case "$COMMAND" in
  encrypt)
    EXECUTABLE_CLASS=org.jasypt.intf.cli.JasyptPBEStringEncryptionCLI
    ;;
  decrypt)
    EXECUTABLE_CLASS=org.jasypt.intf.cli.JasyptPBEStringDecryptionCLI
    ;;
  encrypt-file)
    EXECUTABLE_CLASS=org.jasypt.intf.cli.JasyptPBEFileTokenEncryptionCLI
    ;;
  decrypt-file)
    EXECUTABLE_CLASS=org.jasypt.intf.cli.JasyptPBEFileTokenDecryptionCLI
    ;;
esac

if [ -z "$EXECUTABLE_CLASS" ]
then
  echo "Usage: $SCRIPT_NAME <encrypt|decrypt|encrypt-file|decrypt-file> [arguments]"
  echo ""
  echo "Required arguments:"
  echo "<encrypt|decrypt> [input, password]"
  echo "<encrypt-file|decrypt-file> [filePath, password]"
  echo ""
  echo "Optional arguments:"
  echo "[verbose, algorithm, keyObtentionIterations, saltGeneratorClassName, providerName, providerClassName, stringOutputType, ivGeneratorClassName]"
  exit 1
fi

EXEC_ARGS=""
while [ "$#" -gt 0 ]
do
  CURRENT_ARG="$1"
  case "$CURRENT_ARG" in
    *=*)
      EXEC_ARGS="$EXEC_ARGS $CURRENT_ARG"
      shift
      ;;
    *)
      if [ "$#" -gt 1 ]
      then
        EXEC_ARGS="$EXEC_ARGS $1=\"$2\""
        shift 2
      else
        EXEC_ARGS="$EXEC_ARGS $1"
        shift
      fi
      ;;
  esac
done

case "$EXEC_ARGS" in
  *algorithm=*) ;;
  *) EXEC_ARGS="$EXEC_ARGS algorithm=\"PBEWITHHMACSHA512ANDAES_256\"" ;;
esac

case "$EXEC_ARGS" in
  *keyObtentionIterations=*) ;;
  *) EXEC_ARGS="$EXEC_ARGS keyObtentionIterations=\"1000\"" ;;
esac

case "$EXEC_ARGS" in
  *saltGeneratorClassName=*) ;;
  *) EXEC_ARGS="$EXEC_ARGS saltGeneratorClassName=\"org.jasypt.salt.RandomSaltGenerator\"" ;;
esac

case "$EXEC_ARGS" in
  *ivGeneratorClassName=*) ;;
  *) EXEC_ARGS="$EXEC_ARGS ivGeneratorClassName=\"org.jasypt.iv.RandomIvGenerator\"" ;;
esac

BIN_DIR=`dirname "$0"`
DIST_DIR=$BIN_DIR/..
LIB_DIR=$DIST_DIR/lib
EXEC_CLASSPATH="."

if [ -n "$JASYPT_CLASSPATH" ]
then
  EXEC_CLASSPATH=$EXEC_CLASSPATH:$JASYPT_CLASSPATH
fi

for a in "$LIB_DIR"/*.jar
do
  if [ -f "$a" ]
  then
    EXEC_CLASSPATH=$EXEC_CLASSPATH:$a
  fi
done

for a in "$BIN_DIR"/*.jar
do
  if [ -f "$a" ]
  then
    EXEC_CLASSPATH=$EXEC_CLASSPATH:$a
  fi
done

JAVA_EXECUTABLE=java
if [ -n "$JAVA_HOME" ]
then
  JAVA_EXECUTABLE=$JAVA_HOME/bin/java
fi

if [ "$OSTYPE" = "cygwin" ]
then
  EXEC_CLASSPATH=`echo "$EXEC_CLASSPATH" | sed 's/:/;/g' | sed 's/\/cygdrive\/\([a-z]\)/\1:/g'`
  JAVA_EXECUTABLE=`cygpath --unix "$JAVA_EXECUTABLE"`
fi

eval "$JAVA_EXECUTABLE -classpath \"$EXEC_CLASSPATH\" \"$EXECUTABLE_CLASS\" \"$SCRIPT_NAME\"$EXEC_ARGS"
