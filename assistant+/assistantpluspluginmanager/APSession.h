//
//  AssistantAceCommandBuilder.h
//  
//
//  Created by Zaid Elkurdi on 3/7/15.
//
//

#import "AssistantHeaders.h"
#import <CoreLocation/CoreLocation.h>

@protocol APSiriSession <NSObject>
- (void)sendTextSnippet:(NSString*)text;
- (void)sendAddViews:(NSArray*)views;
-(SOObject*)createSnippet:(NSString*)snippetClass properties:(NSDictionary*)props;
- (void)sendCustomSnippet:(NSString*)snippetClass withProperties:(NSDictionary*)props;
- (void)sendRequestCompleted;
-(SOObject*)createAssistantUtteranceView:(NSString*)text;
- (void)getCurrentLocationWithCompletion:(void (^)(NSDictionary *info))completion;
@end


@interface APSession : NSObject <APSiriSession, CLLocationManagerDelegate>

@property (nonatomic, copy) void (^completionHandler)(NSDictionary *locationData);

+(APSession*)sessionWithRefId:(NSString*)refId andConnection:(AFConnection*)connection;

- (void)sendTextSnippet:(NSString*)text;
- (void)sendAddViews:(NSArray*)views;
-(SOObject*)createSnippet:(NSString*)snippetClass properties:(NSDictionary*)props;
- (void)sendCustomSnippet:(NSString*)snippetClass withProperties:(NSDictionary*)props;
- (void)sendRequestCompleted;
-(SOObject*)createAssistantUtteranceView:(NSString*)text;
- (void)getCurrentLocationWithCompletion:(void (^)(NSDictionary *info))completion;

@end
