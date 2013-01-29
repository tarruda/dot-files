grm() {
  local deleted="`git ls-files --deleted`"
  if [ ! -z $deleted ]; then
    echo "Missing files:"
    echo "$deleted"
    echo "\nStage deletes?(Y/n)"
    local c
    read c
    case $c in
      n|N) return ;;
    esac
    git ls-files --deleted | xargs git rm
  else
    echo "No files are missing"
  fi
}
