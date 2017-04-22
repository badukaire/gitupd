[ $# -lt 2 ] && { echo "$0 <branch> <mirror>" ; exit 1 ; }
MIRROR=$2
BRANCH=$1
REMOTE=refs/remotes/$MIRROR/$BRANCH
LOCAL=refs/heads/$BRANCH

echo "BRANCH:$BRANCH REMOTE:$MIRROR"
echo "remote REF:$REMOTE"
echo "local REF:$LOCAL"
git show-ref --quiet --verify $REMOTE || { echo "FATAL: ref $REMOTE NOT found" ; exit 1 ; }
git show-ref --quiet --verify $LOCAL  || { echo "FATAL: ref $REMOTE NOT found" ; exit 1 ; }
REMSHA=$( git show-ref -s $REMOTE )
SHA=$( git show-ref -s $LOCAL )
echo "remote SHA:" $REMSHA '('$MIRROR')'
echo "local  SHA:" $SHA
[ $SHA == $REMSHA ] && { echo "branch is in sync with remote branch, quitting ..." ; exit 0 ; }
git merge-base --is-ancestor $SHA $REMSHA
if [ $? -eq 0 ] ; then
  echo "local branch is ancestor of remote branch, fast-forward possible"
else
  echo "----"
  echo "local branch is NOT an ancestor of remote branch, NO fast-forward possible"
  git merge-base --is-ancestor $REMSHA $SHA
  if [ $? -eq 0 ] ; then
    echo "WARNING : but remote branch is ancestor of local branch ... you may need to push instead!"
  else
    echo "WARNING : no direct ancestry between remote and local branch, check the log and hierarchy ..."
  fi
  echo "----"
fi
echo "update branch $BRANCH to" $( echo $REMSHA | cut -c -7 )"... ? (ctrl-C to abort)"
read OK
git update-ref $LOCAL $REMSHA
