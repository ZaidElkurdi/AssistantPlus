//
//  AssistantPluginManager.h
//  
//
//  Created by Zaid Elkurdi on 3/12/15.
//
//

#import "APSession.h"
#import "AssistantPlusHeaders.h"
#import "libactivator.h"

@interface APPluginSystem : NSObject<APPluginSystem, LAEventDataSource> {
  NSMutableArray *plugins;
  NSMutableDictionary *activatorListenersDict;
  NSMutableArray *activatorListenersArray;
}
+ (id)sharedManager;
- (BOOL)loadPlugins;
- (BOOL)handleCommand:(NSString*)command withTokens:(NSSet*)tokens withSession:(APSession*)currSession;
- (id<APPluginSnippet>)viewControllerForClass:(NSString*)snippetClass;
- (void)reloadCustomRepliesPlugin:(NSDictionary*)replies;
- (void)reloadActivatorListeners;
@end
