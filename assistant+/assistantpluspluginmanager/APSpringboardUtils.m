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

@implementation APSpringboardUtils {
  id<APPluginManager> pluginManager;
  NSDictionary *currLocation;
}

+ (id)sharedUtils {
  static APSpringboardUtils *sharedObj = nil;
  @synchronized(self) {
    if (sharedObj == nil) {
      NSLog(@"CREATED SHARED UTILS!");
      sharedObj = [[self alloc] init];
      [sharedObj loadPlugins];
      CPDistributedMessagingCenter* center = [CPDistributedMessagingCenter centerNamed:@"com.zaid.applus.springboard"];
      [center runServerOnCurrentThread];
      [center registerForMessageName:@"RetrievedLocation" target:sharedObj selector:@selector(gotCurrentLocation:withInfo:)];
    }
  }
  return sharedObj;
}

- (id)getPluginManager {
  return pluginManager;
}

- (void)loadPlugins {
  pluginManager = [NSClassFromString(@"APPluginManager") sharedManager];
  NSLog(@"APSpringboardUtils: Loaded Plugin Manager: %@", pluginManager);
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
