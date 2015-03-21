//
//  APSpringboardUtils.h
//
//
//  Created by Zaid Elkurdi on 3/18/15.
//
//

#import <Foundation/Foundation.h>

@interface APSpringboardUtils : NSObject
@property (copy, nonatomic) void (^completionHandler) (NSDictionary*) ;

+ (id)sharedUtils;
- (id)getPluginManager;
- (void)getCurrentLocationWithCompletion:(void (^)(NSDictionary *info))completion;
- (void)loadPlugins;
- (void)gotCurrentLocation:(NSString*)msg withInfo:(NSDictionary*)info;
@end
