#import "AssistantPlusHeaders.h"
#import "APPluginManager.h"
#import <libobjcipc/objcipc.h>

static APPluginManager *pluginManager;

static inline __attribute__((constructor)) void init() {
  NSLog(@"Creating AssistantPlusSBPluginManager!");
  pluginManager = [APPluginManager sharedManager];
  
  NSLog(@"Registed for messages!");
  [OBJCIPC registerIncomingMessageFromAppHandlerForMessageName:@"AssistantPlus.Query"  handler:^NSDictionary *(NSDictionary *message) {
    NSLog(@"Message: %@", message);
    return @{@"Hello" : @"Sucker!"};
  }];
}

%subclass APSBPluginManager : NSObject
%new
+ (APPluginManager*)getSharedManager {
  return pluginManager;
}
%end