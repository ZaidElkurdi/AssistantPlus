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
      NSLog(@"CREATED SHARED UTILS!");
      sharedObj = [[self alloc] init];
      [sharedObj loadPlugins];
      CPDistributedMessagingCenter* center = [CPDistributedMessagingCenter centerNamed:@"com.zaid.applus.springboard"];
      [center runServerOnCurrentThread];
      [center registerForMessageName:@"RetrievedLocation" target:sharedObj selector:@selector(gotCurrentLocation:withInfo:)];
      [center registerForMessageName:@"UpdateActivatorListeners" target:sharedObj selector:@selector(updateActivatorListeners)];
      [center registerForMessageName:@"UpdateCustomReplies" target:sharedObj selector:@selector(updateCustomReplies:withReplies:)];
      [center registerForMessageName:@"respringForListeners" target:sharedObj selector:@selector(respring)];
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

- (void)updateActivatorListeners {
  NSLog(@"Calling1 on %@", pluginManager);
  [pluginManager reloadActivatorListeners];
}

- (void)updateCustomReplies:(NSString*)msg withReplies:(NSDictionary*)dict {
  NSLog(@"AP SB: Updating custom replies with %@", dict);
  [pluginManager reloadCustomRepliesPlugin:dict];
}

- (void)respring {
  NSLog(@"Respringing here!");
  pid_t pid;
  int status;
  const char *argv[] = {"killall", "backboardd", NULL};
  posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char *const *)argv, NULL);
  waitpid(pid, &status, WEXITED);
}

- (void)getCurrentLocationWithCompletion:(void (^)(NSDictionary *info))completion {
  self.completionHandler = completion;
  CPDistributedMessagingCenter* center = [CPDistributedMessagingCenter centerNamed:@"com.zaid.applus.daemon"];
  [center sendMessageName:@"RetrieveLocation" userInfo:nil];
}

- (void)gotCurrentLocation:(NSString*)msg withInfo:(NSDictionary*)info {
  NSLog(@"APSU got: %@", info);
  if (info) {
    NSDictionary *locInfo = info[@"Location"];
    if (locInfo && self.completionHandler) {
      NSLog(@"Sending: %@ to block!", locInfo);
      self.completionHandler(locInfo);
      self.completionHandler = nil;
    }
  }
}

@end
