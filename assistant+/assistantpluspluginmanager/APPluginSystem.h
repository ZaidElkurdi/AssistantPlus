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
  NSMutableArray *activatorListenersArray;
}
+ (id)sharedManager;
- (BOOL)loadPlugins;
- (BOOL)handleCommand:(NSString*)command withTokens:(NSSet*)tokens withSession:(APSession*)currSession;
- (void)reloadCustomRepliesPlugin:(NSDictionary*)replies;
- (void)reloadActivatorListeners:(NSDictionary*)listeners;
- (NSDictionary*)getInstalledPlugins;
@end
