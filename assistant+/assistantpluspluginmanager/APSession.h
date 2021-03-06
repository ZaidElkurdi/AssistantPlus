//
//  AssistantAceCommandBuilder.h
//  
//
//  Created by Zaid Elkurdi on 3/7/15.
//
//

#import "AssistantPlusHeaders.h"
#import "AssistantHeaders.h"
#import <CoreLocation/CoreLocation.h>

@class APPlugin;

@interface APSession : NSObject <APSiriSession, CLLocationManagerDelegate>
@property (nonatomic, strong) NSString *refId;
@property (nonatomic, getter=isListeningAfterSpeaking) BOOL listenAfterSpeaking;
@property (nonatomic, strong) APPlugin *currentPlugin;
@property (nonatomic, strong) AFConnection *connection;
@property (nonatomic, copy) void (^completionHandler)(NSDictionary *locationData);

-(APSession*)initWithRefId:(NSString*)referenceId andConnection:(AFConnection*)connection;
+(APSession*)sessionWithConnection:(AFConnection*)connection;
    
- (void)sendTextSnippet:(NSString*)text temporary:(BOOL)temporary scrollToTop:(BOOL)toTop dialogPhase:(NSString*)phase;
- (void)sendTextSnippet:(NSString*)text temporary:(BOOL)temporary scrollToTop:(BOOL)toTop dialogPhase:(NSString*)phase listenAfterSpeaking:(BOOL)shouldListen;

-(SOObject*)createTextSnippet:(NSString*)text;

- (void)sendAddViews:(NSArray*)views;
- (void)sendAddViews:(NSArray*)views dialogPhase:(NSString*)dialogPhase scrollToTop:(BOOL)toTop temporary:(BOOL)temporary;

- (void)sendCustomSnippet:(NSString*)snippetClass withProperties:(NSDictionary*)props;
-(SOObject*)createSnippet:(NSString*)snippetClass properties:(NSDictionary*)props;
-(SOObject*)createAssistantUtteranceView:(NSString*)text;

- (void)sendRequestCompleted;
- (void)getCurrentLocationWithCompletion:(void (^)(NSDictionary *info))completion;

+(NSString*)generateRandomUUID;

@end
