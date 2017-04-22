#!/bin/bash

[ $# -lt 1 ] && { echo "$0 <branch> [<mirror>]" ; exit 1 ; }
S_REF=$1
echo branch : $S_REF
[ $# -ge 2 ] && { S_MIRROR=$2 ; echo remote : $S_MIRROR "(other remotes will be ignored)" ; }

FOUNDHEAD=0
echo "--"
while read LINE
do
  #echo $LINE
  read HASH NAME <<< $LINE
  #echo HASH $HASH
  #echo $NAME | cut -d "/" -f 2
  GREPHEAD=`echo $NAME | cut -d "/" -f 2`
  [ $GREPHEAD = "heads" ] && ISHEAD=1 || ISHEAD=0
  if [ $ISHEAD -eq 0 ] ; then # remote
    if [ ! -z $S_MIRROR ] ; then
      GREPREMO=`echo $NAME | cut -d "/" -f 3`
      #echo GREPREMO $GREPREMO
      [ $GREPREMO != $S_MIRROR ] && continue
    fi
  fi
  if [ $ISHEAD -ne 0 ] ; then # remote
    echo $NAME "(local)"
    FOUNDHEAD=1
  else
    echo $NAME
  fi
  LOG1=$( git log -n 1 --pretty=format:"%h %ai" $HASH )
  RELT=$( git log -n 1 --pretty=format:"%ar" $HASH )
  echo $LOG1 '('$RELT')'
  echo "--"
done < <( git show-ref $S_REF ) # process substitution, not creating a subshell

if [ $FOUNDHEAD -eq 0 ] ; then
  echo "NO local branch found"
fi




#   python showBranch.py       | \
#   grep -v '\-\-'             | \
#   xargs -n 1 git log -n 1 --pretty=format:"%h %ar %d"
