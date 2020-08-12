# Flutter docker image  
  
## [plugfox/flutter](https://hub.docker.com/r/plugfox/flutter)  
  
Debian Linux image for Flutter & Dart with helpful utils and web build support.  
Symlinks to dart, flutter and pub cache are in the folder: `/opt`  
  
### Env  
 + DART_SDK     = "/usr/lib/dart"  
 + FLUTTER_ROOT = "/usr/lib/flutter"  
 + ANDROID_HOME = "/usr/lib/android_sdk"  
 + PUB_CACHE    = "/usr/lib/pub"  
  
### Linux utils 
 + git  
 + wget  
 + curl  
 + unzip  
 + lcov  
 + sqlite3  
 + chromium  
  
### Dart utils  
 + stagehand  
 + grinder  
 + cider  
  