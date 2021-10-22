# Flutter docker image

[![BUILD AND PUBLISH BRANCHES](https://github.com/PlugFox/docker_flutter/actions/workflows/build_and_publish_branches.yml/badge.svg)](https://github.com/PlugFox/docker_flutter/actions/workflows/build_and_publish_branches.yml) [![GitHub](https://img.shields.io/badge/Git-Hub-purple.svg)](https://hub.docker.com/r/plugfox/flutter/tags) [![Docker](https://img.shields.io/badge/Docker-hub-2496ed.svg)](https://hub.docker.com/r/plugfox/flutter/tags) [![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://github.com/PlugFox/docker_flutter/blob/master/LICENSE)  

Alpine Linux images for Flutter & Dart with helpful utils and web build support.  
Symlinks to dart, flutter in the folder: `/opt/flutter`  
Rolling release update strategy at every monday.

### Env
+ FLUTTER_ROOT = "/opt/flutter"
+ PUB_CACHE    = "/var/tmp/.pub_cache"
+ ANDROID_HOME = "/opt/android"  
  
