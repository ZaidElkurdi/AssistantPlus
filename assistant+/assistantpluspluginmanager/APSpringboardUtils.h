//
//  APSpringboardUtils.h
//
//
//  Created by Zaid Elkurdi on 3/18/15.
//
//

#import <Foundation/Foundation.h>
#import "APPluginSystem.h"
#import "AssistantPlusHeaders.h"

@interface APSpringboardUtils : NSObject <APSharedUtils>
@property (copy, nonatomic) void (^completionHandler) (NSDictionary*) ;

+ (id)sharedAPUtils;
- (APPluginSystem*)getPluginManager;
- (void)getCurrentLocationWithCompletion:(void (^)(NSDictionary *info))completion;
- (void)loadPlugins;
- (void)gotCurrentLocation:(NSString*)msg withInfo:(NSDictionary*)info;
- (void)runCommand:(NSString*)msg withInfo:(NSDictionary*)info;
@end
