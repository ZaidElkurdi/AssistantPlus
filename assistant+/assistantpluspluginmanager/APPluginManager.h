//
//  AssistantPluginManager.h
//  
//
//  Created by Zaid Elkurdi on 3/12/15.
//
//

#import "APSession.h"

@interface APPluginManager : NSObject {
  NSMutableArray *plugins;
}
+ (id)sharedManager;
- (BOOL)loadPlugins;
- (BOOL)handleCommand:(NSString*)command withSession:(APSession*)currSession;
@end
