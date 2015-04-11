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

@property (strong, nonatomic) APSession *currSession;

+ (id)sharedManager;
- (BOOL)loadPlugins;
- (BOOL)handleCommand:(NSString*)command withTokens:(NSSet*)tokens withSession:(APSession*)currSession;
- (void)reloadCustomRepliesPlugin:(NSDictionary*)replies;
- (void)reloadActivatorListeners:(NSDictionary*)listeners;

//1.0.1
- (void)siriSay:(NSString*)message;

- (NSDictionary*)getInstalledPlugins;
@end
