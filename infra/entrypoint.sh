#!/bin/bash                                                                                                                                     

Xvfb :1 -screen 0 800x600x16 &
/usr/bin/x11vnc -display :1.0 -usepw &
export DISPLAY=:1.0
export PATH=$HOME/bin:$PATH
service redis start
service postgresql start
echo "$@"
eval "$@"