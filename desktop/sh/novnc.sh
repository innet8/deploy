#!/bin/bash

echo "running novnc.sh: ${NO_VNC_HOME} ${VNC_PORT}"
${NO_VNC_HOME}/utils/launch.sh --vnc localhost:${VNC_PORT} --listen ${NO_VNC_PORT}

