//
//  AssistantPluginManager.h
//  
//
//  Created by Zaid Elkurdi on 3/12/15.
//
//

#import "APSession.h"
#import "AssistantPlusHeaders.h"

@interface APPluginManager : NSObject<APPluginSystem> {
  NSMutableArray *plugins;
}
+ (id)sharedManager;
- (BOOL)loadPlugins;
- (BOOL)handleCommand:(NSString*)command withTokens:(NSSet*)tokens withSession:(APSession*)currSession;
- (id<APPluginSnippet>)viewControllerForClass:(NSString*)snippetClass;
@end
