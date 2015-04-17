//
//  AssistantPlusHeaders.h
//  
//
//  Created by Zaid Elkurdi on 3/12/15.
//
//

#import "AssistantHeaders.h"

#define PLUGIN_PATH "/Library/AssistantPlusPlugins/"

@protocol APSiriSession <NSObject>
- (void)sendTextSnippet:(NSString*)text temporary:(BOOL)temporary scrollToTop:(BOOL)toTop dialogPhase:(NSString*)phase;
- (void)sendAddViews:(NSArray*)views;
- (void)sendAddViews:(NSArray*)views dialogPhase:(NSString*)dialogPhase scrollToTop:(BOOL)toTop temporary:(BOOL)temporary;
-(NSMutableDictionary*)createSnippet:(NSString*)snippetClass properties:(NSDictionary*)props;
-(NSMutableDictionary*)createTextSnippet:(NSString*)text;
- (void)sendCustomSnippet:(NSString*)snippetClass withProperties:(NSDictionary*)props;
- (void)sendRequestCompleted;
- (void)getCurrentLocationWithCompletion:(void (^)(NSDictionary *info))completion;
@end

@protocol APSharedUtils <NSObject>
+ (id)sharedAPUtils;
- (void)getCurrentLocationWithCompletion:(void (^)(NSDictionary *info))completion;
- (void)runCommand:(NSString*)msg withInfo:(NSDictionary*)info;
@end

@protocol APPluginSystem <NSObject>
@required
+(id)sharedManager;
- (void)reloadCustomRepliesPlugin:(NSDictionary*)replies;
- (void)reloadActivatorListeners:(NSDictionary*)listeners;
@end

@protocol APPluginManager <NSObject>
@required
/// Register a command class
-(BOOL)registerCommand:(Class)cls;
/// Register a snippet class
-(BOOL)registerSnippet:(Class)cls;
@end

@protocol APPluginSnippet <NSObject>
@optional
-(id)initWithProperties:(NSDictionary*)props;
@end

@interface APPluginSnippetViewController : UIViewController <APPluginSnippet>
-(void)setCustomView:(UIViewController*)newVC;
@end


@protocol APPluginCommand <NSObject>
@optional
-(BOOL)handleSpeech:(NSString*)text withTokens:(NSSet*)tokens withSession:(id<APSiriSession>)session;
@end

@protocol APPlugin <NSObject>
@required
-(id)initWithPluginManager:(id<APPluginManager>)system;
@end
