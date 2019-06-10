
while true ; do
  if ! pgrep -l 'ioex' > /dev/null ; then
    sh ioex.sh start > /dev/null
  fi
  sleep 30
done

