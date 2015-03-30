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

@interface APSession : NSObject <APSiriSession, CLLocationManagerDelegate>
@property (nonatomic, strong) NSString *refId;
@property (nonatomic, strong) AFConnection *connection;
@property (nonatomic, copy) void (^completionHandler)(NSDictionary *locationData);

-(APSession*)initWithRefId:(NSString*)referenceId andConnection:(AFConnection*)connection;
+(APSession*)sessionWithConnection:(AFConnection*)connection;
    
- (void)sendTextSnippet:(NSString*)text temporary:(BOOL)temporary scrollToTop:(BOOL)toTop dialogPhase:(NSString*)phase;
-(SOObject*)createTextSnippet:(NSString*)text;
- (void)sendAddViews:(NSArray*)views;
- (void)sendAddViews:(NSArray*)views dialogPhase:(NSString*)dialogPhase scrollToTop:(BOOL)toTop temporary:(BOOL)temporary;
-(SOObject*)createSnippet:(NSString*)snippetClass properties:(NSDictionary*)props;
- (void)sendCustomSnippet:(NSString*)snippetClass withProperties:(NSDictionary*)props;
- (void)sendRequestCompleted;
-(SOObject*)createAssistantUtteranceView:(NSString*)text;
- (void)getCurrentLocationWithCompletion:(void (^)(NSDictionary *info))completion;

+(NSString*)generateRandomUUID;

@end
