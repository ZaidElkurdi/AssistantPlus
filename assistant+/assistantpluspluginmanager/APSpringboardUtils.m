//
//  APSpringboardUtils.m
//  
//
//  Created by Zaid Elkurdi on 3/18/15.
//
//

#import "APSpringboardUtils.h"
#import "AssistantPlusHeaders.h"
#import "CPDistributedMessagingCenter.h"
#include <spawn.h>
#include <signal.h>

@interface SpringBoard : UIApplication
- (void)_relaunchSpringBoardNow;
@end


@implementation APSpringboardUtils {
  APPluginSystem *pluginManager;
  NSDictionary *currLocation;
}

+ (id)sharedAPUtils {
  static APSpringboardUtils *sharedObj = nil;
  @synchronized(self) {
    if (sharedObj == nil) {
      sharedObj = [[self alloc] init];
      [sharedObj loadPlugins];
      CPDistributedMessagingCenter* center = [CPDistributedMessagingCenter centerNamed:@"com.zaid.applus.springboard"];
      [center runServerOnCurrentThread];
      [center registerForMessageName:@"RetrievedLocation" target:sharedObj selector:@selector(gotCurrentLocation:withInfo:)];
      [center registerForMessageName:@"UpdateActivatorListeners" target:sharedObj selector:@selector(updateActivatorListeners:withListeners:)];
      [center registerForMessageName:@"UpdateCustomReplies" target:sharedObj selector:@selector(updateCustomReplies:withReplies:)];
      [center registerForMessageName:@"respringForListeners" target:sharedObj selector:@selector(respring)];
      [center registerForMessageName:@"getInstalledPlugins" target:sharedObj selector:@selector(getInstalledPlugins:withInfo:)];
      [center registerForMessageName:@"siriSay" target:sharedObj selector:@selector(siriSay:withMessage:)];
    }
  }
  return sharedObj;
}

- (APPluginSystem*)getPluginManager {
  return pluginManager;
}

- (void)loadPlugins {
  pluginManager = [APPluginSystem sharedManager];
  NSLog(@"APSpringboardUtils: Loaded Plugin Manager: %@", pluginManager);
}

- (void)updateActivatorListeners:(NSString*)msg withListeners:(NSDictionary*)listeners {
  [pluginManager reloadActivatorListeners:listeners];
}

- (void)updateCustomReplies:(NSString*)msg withReplies:(NSDictionary*)dict {
  [pluginManager reloadCustomRepliesPlugin:dict];
}

- (void)respring {
  pid_t pid;
  int status;
  const char *argv[] = {"killall", "backboardd", NULL};
  posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char *const *)argv, NULL);
  waitpid(pid, &status, WEXITED);
}

- (void)siriSay:(NSString*)msg withMessage:(NSDictionary*)dict {
  [pluginManager siriSay:dict[@"message"]];
}

- (NSDictionary*)getInstalledPlugins:(NSString*)msg withInfo:(NSDictionary*)info {
  return [pluginManager getInstalledPlugins];
}

- (void)getCurrentLocationWithCompletion:(void (^)(NSDictionary *info))completion {
  [self startLocationDaemon];
  self.completionHandler = completion;
  CPDistributedMessagingCenter* center = [CPDistributedMessagingCenter centerNamed:@"com.zaid.applus.daemon"];
  [center sendMessageName:@"RetrieveLocation" userInfo:nil];
}

- (void)gotCurrentLocation:(NSString*)msg withInfo:(NSDictionary*)info {
  if (info) {
    NSDictionary *locInfo = info[@"Location"];
    if (locInfo && self.completionHandler) {
      self.completionHandler(locInfo);
      self.completionHandler = nil;
    }
  }
  [self stopLocationDaemon];
}

- (void)startLocationDaemon {
  system("/Applications/AssistantPlusApp.app/assistantplus_root_helper start");
}

- (void)stopLocationDaemon {
  system("/Applications/AssistantPlusApp.app/assistantplus_root_helper stop");
}
@end
