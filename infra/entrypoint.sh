#!/bin/bash                                                                                                                                     


ln -s /usr/bin/R /usr/bin/r
ln -s /usr/bin/python3 /usr/bin/python
service postgresql start
redis-server &
Xvfb :1 -screen 0 800x600x16 &
/usr/bin/x11vnc -display :1.0 -usepw &
export DISPLAY=:1.0
export PATH=$HOME/bin:$PATH
echo "$@"
eval "$@"