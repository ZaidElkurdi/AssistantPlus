#import "AssistantPlusHeaders.h"
#import "APPluginManager.h"
#import "APSpringboardUtils.h"
#import "CPDistributedMessagingCenter.h"

static APPluginManager *pluginManager;
static APSpringboardUtils *sharedUtils;
static NSDictionary *currLocation;

static inline __attribute__((constructor)) void init() {
  NSLog(@"Creating AssistantPlusSBPluginManager!");
  NSLog(@"FUCK IS: %@", sharedUtils);
  sharedUtils = [APSpringboardUtils sharedUtils];
}

%subclass APSpringboardCenter : NSObject
%new
+ (id)sharedUtils {
  NSLog(@"Returning: %@", sharedUtils);
  return sharedUtils;
}
%end