#import "AssistantPlusHeaders.h"
#import "APPluginSystem.h"
#import "APSpringboardUtils.h"
#import "CPDistributedMessagingCenter.h"

static APPluginSystem *pluginManager;
static APSpringboardUtils *sharedUtils;
static NSDictionary *currLocation;

static inline __attribute__((constructor)) void init() {
  NSLog(@"Creating AssistantPlusSBPluginManager!");
  sharedUtils = [APSpringboardUtils sharedAPUtils];
}