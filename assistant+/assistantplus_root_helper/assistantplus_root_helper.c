#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <spawn.h>

#include "paths.h"

void startLocationDaemon() {
  system("/bin/launchctl load /Library/LaunchDaemons/com.zaid.aplocationdaemon.plist");
}


void stopLocationDaemon() {
  system("/bin/launchctl unload /Library/LaunchDaemons/com.zaid.aplocationdaemon.plist");
}

int main(int argc, const char *argv[]) {
  // Run as root.
  if (setuid(0) != 0) {
    fprintf(stderr, "setuid failed. Error: %d.\n", errno);
    return EXIT_FAILURE;
  }
  
  if (strcmp(argv[1], "start") == 0) {
    startLocationDaemon();
  } else if (strcmp(argv[1], "stop") == 0) {
    stopLocationDaemon();
  }
  return EXIT_SUCCESS;
}