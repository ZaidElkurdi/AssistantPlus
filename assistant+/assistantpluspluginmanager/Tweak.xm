#import "AssistantPlusHeaders.h"
#import "APPluginManager.h"
#import <libobjcipc/objcipc.h>

static APPluginManager *pluginManager;

static inline __attribute__((constructor)) void init() {
  NSLog(@"Creating AssistantPlusSBPluginManager!");
  
  NSLog(@"Initialized SPM: %@", [%c(SiriUIPluginManager) sharedInstance]);
  pluginManager = [APPluginManager sharedManager];
  objc_setAssociatedObject([%c(SiriUIPluginManager) sharedInstance], &kAPPluginAssociatedObjectKey, @"hey!", OBJC_ASSOCIATION_RETAIN);
  
  [[%c(BasicAceContext) sharedBasicAceContext] registerGroupAcronym:@"APPlugin" forGroupWithIdentifier:@"zaid.assistantplus.plugin"];
}

%subclass APSBPluginManager : NSObject
%new
+ (APPluginManager*)getSharedManager {
  return pluginManager;
}
%end