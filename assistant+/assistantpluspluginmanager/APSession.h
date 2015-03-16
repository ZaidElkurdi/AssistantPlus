//
//  AssistantAceCommandBuilder.h
//  
//
//  Created by Zaid Elkurdi on 3/7/15.
//
//

#import "AssistantHeaders.h"

@protocol APSiriSession <NSObject>
- (void)sendTextSnippet:(NSString*)text;
- (void)sendAddViews:(NSArray*)views;
-(SOObject*)createSnippet:(NSString*)snippetClass properties:(NSDictionary*)props;
- (void)sendCustomSnippet:(NSString*)snippetClass withProperties:(NSDictionary*)props;
- (void)sendRequestCompleted;
-(SOObject*)createAssistantUtteranceView:(NSString*)text;
@end


@interface APSession : NSObject <APSiriSession>

+(APSession*)sessionWithRefId:(NSString*)refId andConnection:(AFConnection*)connection;

- (void)sendTextSnippet:(NSString*)text;
- (void)sendAddViews:(NSArray*)views;
-(SOObject*)createSnippet:(NSString*)snippetClass properties:(NSDictionary*)props;
- (void)sendCustomSnippet:(NSString*)snippetClass withProperties:(NSDictionary*)props;
- (void)sendRequestCompleted;
-(SOObject*)createAssistantUtteranceView:(NSString*)text;

@end
