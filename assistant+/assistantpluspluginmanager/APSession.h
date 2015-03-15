//
//  AssistantAceCommandBuilder.h
//  
//
//  Created by Zaid Elkurdi on 3/7/15.
//
//

#import "AssistantHeaders.h"

@interface APSession : NSObject

+(APSession*)sessionWithRefId:(NSString*)refId andConnection:(AFConnection*)connection;

- (void)sendSnippetWithText:(NSString*)text;
- (void)sendAddViews:(NSArray*)views;
-(SOObject*)createSnippet:(NSString*)snippetClass properties:(NSDictionary*)props;
- (void)sendSnippetForViewController:(NSString*)snippetClass withProperties:(NSDictionary*)props;
- (void)sendRequestCompleted;
-(SOObject*)createAssistantUtteranceView:(NSString*)text;

//-(SOObject*)createObjectDict:(NSString*)className group:(NSString*)group properties:(NSDictionary*)props;
//-(SOObject*)createAssistantUtteranceView:(NSString*)text;
//-(SOObject*)createAssistantUtteranceView:(NSString*)text speakableText:(NSString*)speakableText;
//-(SOObject*)createAssistantUtteranceView:(NSString*)text speakableText:(NSString*)speakableText dialogIdentifier:(NSString*)dialogIdentifier;
//
//NSMutableDictionary* SOCreateAssistantUtteranceView(NSString* text, NSString* speakableText, NSString* dialogIdentifier);
//
//NSMutableDictionary* SOCreateAceAddViews(NSString* refId, NSArray* views, NSString* dialogPhase, BOOL scrollToTop, BOOL temporary);
//
//NSMutableDictionary* SOCreateAceRequestCompleted(NSString* refId);

@end
