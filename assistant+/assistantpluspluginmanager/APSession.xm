//
//  AssistantAceCommandBuilder.m
//  
//
//  Created by Zaid Elkurdi on 3/7/15.
//
//

#import "AssistantHeaders.h"
#import "APSession.h"
#import "substrate.h"

static NSString *referenceId = @"00000000-0000-0000-0000-000000000000";
static NSString* s_ver = nil;
static AFConnection *currConnection = nil;

@implementation APSession

-(APSession*)initWithRefId:(NSString*)refId {
  if ( (self = [super init]) )
  {
    referenceId = [refId copy];
    if (!referenceId) referenceId = [@"00000000-0000-0000-0000-000000000000" copy];
    
    NSLog(@"Created a new session for request %@.", refId);
  }
  return self;
}

+(APSession*)sessionWithRefId:(NSString*)refId andConnection:(AFConnection*)connection {
  if (!refId) refId = @"00000000-0000-0000-0000-000000000000";
  
  currConnection = connection;
  APSession *currSession = [[[APSession alloc] initWithRefId:refId] autorelease];
  if (!currSession) return nil;
  
  return currSession;
}

#pragma mark - Public Methods 

- (void)sendTextSnippet:(NSString*)text {
  NSMutableArray* views = [NSMutableArray arrayWithCapacity:1];
  [views addObject:[self createAssistantUtteranceView:text]];
  sendAddViews(views);
}

- (void)sendCustomSnippet:(NSString*)snippetClass withProperties:(NSDictionary*)props {
  NSLog(@"Sending snippet: %@", snippetClass);
  [self sendAddViewsSnippet:snippetClass properties:props dialogPhase:@"Completion" scrollToTop:NO temporary:NO];
}

- (void)sendRequestCompleted {
  NSMutableDictionary* dict = SOCreateAceRequestCompleted(referenceId);
  SessionSendToClient(dict);
}

- (void)sendAddViews:(NSArray*)views {
  return sendAddViews(views);
}

#pragma mark - Communication

id SessionSendToClient(NSDictionary* dict) {
  NSLog(@"Sending %@ to client", dict);
  id ctx = nil;
  
  static Class AceObject = objc_getClass("AceObject");
  static Class BasicAceContext = objc_getClass("BasicAceContext");
  
  if (!AceObject) NSLog(@"No AceObject class");
  if (!BasicAceContext) NSLog(@"AE ERROR: No BasicAceContext class");
  
  if (!dict) {
    NSLog(@"AE ERROR: SessionSendToClient: nil dict as an argument!");
    return nil;
  }
  
  // create context
  if (ctx == nil) ctx = [[[BasicAceContext alloc] init] autorelease]; // ... is not needed normally, but just in case...
  if (!ctx) NSLog(@"AE ERROR: No context");
  
  
  if ([dict objectForKey:@"v"] && !s_ver) {
    s_ver = [[dict objectForKey:@"v"] copy];
  } else if (s_ver && ![dict objectForKey:@"v"]) {
    dict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [(NSMutableDictionary*)dict setObject:s_ver forKey:@"v"];
  }
  
  NSLog(@"AE: ###### ===> Sending Ace Object to Client: %@", dict);
  
  // create real AceObject
  id obj = [AceObject aceObjectWithDictionary:dict context:ctx];
  if (obj == nil) {
    NSLog(@"AE ERROR: SessionSendToClient: NIL ACE OBJECT RETURNED FOR DICT: %@", dict);
    return nil;
  }
  
  // call the original method to handle our new object
  if (currConnection == nil) { NSLog(@"AE: AFConnection is nil"); return nil; }
  
  NSLog(@"Sending this: %@", obj);
  if ([dict[@"$class"] isEqualToString:@"CommandSucceeded"]) {
    [currConnection sendReplyCommand:obj];
  } else {
   [currConnection _doCommand:obj reply:nil];
  }
  
  return obj;
}

-(void)sendAddViewsSnippet:(NSString*)snippetClass properties:(NSDictionary*)props dialogPhase:(NSString*)dialogPhase scrollToTop:(BOOL)scrollToTop temporary:(BOOL)temporary {
  if (!props) props = [NSDictionary dictionary];
  NSArray* views = [NSArray arrayWithObject:[self createSnippet:snippetClass properties:props]];
//  NSLog(@"About to send: %@", views);
  sendAddViews(views);
}

void sendAddViews(NSArray* views, NSString *dialogPhase, BOOL scrollToTop, BOOL temporary) {
  NSMutableDictionary* dict = SOCreateAceAddViews(referenceId, views, dialogPhase, scrollToTop, temporary);
  
  // listenAfterSpeaking hack!
  //  for (NSDictionary* view in views)
  //  {
  //    NSDictionary* props = [view objectForKey:@"properties"];
  //    if ([[props objectForKey:@"listenAfterSpeaking"] boolValue])
  //    {
  //      _listenAfterSpeaking = YES;
  //      break;
  //    }
  //  }
  
  // send
  SessionSendToClient(dict);
}

void sendAddViews(NSArray* views) {
  sendAddViews(views, @"Completion", NO, NO);
}

#pragma mark - Object Creation

-(SOObject*)createSnippet:(NSString*)snippetClass properties:(NSDictionary*)props {
  NSMutableDictionary* lowLevelProps = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        props,@"snippetProps", snippetClass,@"snippetClass", nil];

  NSLog(@"Creating snippet: %@ with properties: %@", snippetClass, lowLevelProps);
  return SOCreateObjectDict(@"zaid.assistantplus.plugin", @"SnippetObject", lowLevelProps);
}

-(SOObject*)createObjectDict:(NSString*)className group:(NSString*)group properties:(NSDictionary*)props {
  return SOCreateObjectDict(group, className, [[props mutableCopy] autorelease]);
}

#pragma mark - Object Dictionary Creation

NSMutableDictionary* SOCreateObjectDict(NSString* group, NSString* className, NSMutableDictionary* properties) {
  NSMutableDictionary *objDict = [[NSMutableDictionary alloc] init];
  [objDict setObject:className forKey:@"$class"];
  [objDict setObject:group forKey:@"$group"];
  
  if (properties != nil) {
    //Only necessary for AceObjects
    [objDict setObject:@"4.0" forKey:@"$v"];
    
    for (NSString *currKey in properties.allKeys) {
      [objDict setObject:properties[currKey] forKey:currKey];
    }
  }
  NSLog(@"Returning: %@", objDict);
  return objDict;
}

NSMutableDictionary* SOCreateAceObjectDict(NSString* refId, NSString* group, NSString* className, NSMutableDictionary* properties) {
  NSString* aceId = RandomUUID();
  
  NSMutableDictionary *dict = SOCreateObjectDict(group, className, properties);
  
  [dict setObject:[NSNumber numberWithBool:YES] forKey:@"local"];
  [dict setObject:aceId forKey:@"aceId"];
  [dict setObject:refId forKey:@"refId"];
  
  return dict;
}

NSMutableDictionary* BaseClientBoundCommandDict(NSString* refId, NSString* group, NSString* className) {
  
  NSMutableDictionary *dict = SOCreateObjectDict(group, className, nil);
  [dict setObject:refId forKey:@"refId"];
  
  return dict;
}

#pragma mark - AddViews Creation

NSMutableDictionary* SOCreateAceAddViews(NSString* refId, NSArray* views, NSString* dialogPhase, BOOL scrollToTop, BOOL temporary) {
  NSMutableDictionary* props = [NSMutableDictionary dictionary];
  [props setObject:[NSNumber numberWithBool:scrollToTop] forKey:@"scrollToTop"];
  [props setObject:[NSNumber numberWithBool:temporary] forKey:@"temporary"];
  [props setObject:views forKey:@"views"];
  [props setObject:dialogPhase forKey:@"dialogPhase"];
  [props setObject:@"PrimaryDisplay" forKey:@"displayTarget"];
  
  return SOCreateAceObjectDict(refId, @"com.apple.ace.assistant", @"AddViews", props);
}

NSMutableDictionary* SOCreateAceAddViewsUtteranceView(NSString* refId, NSString* text, NSString* speakableText, NSString* dialogPhase, BOOL scrollToTop, BOOL temporary) {
  NSMutableArray* views = [NSMutableArray arrayWithCapacity:1];
  [views addObject:SOCreateAssistantUtteranceView(text, speakableText, @"Misc#ident")];
  
  return SOCreateAceAddViews(refId, views, dialogPhase, scrollToTop, temporary);
}

#pragma mark - AssistantUtteranceView Creation

NSMutableDictionary* SOCreateAssistantUtteranceView(NSString* text, NSString* speakableText, NSString* dialogIdentifier) {
  if (speakableText == nil) speakableText = text;
  NSMutableDictionary* props = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                text,@"text", speakableText,@"speakableText", dialogIdentifier,@"dialogIdentifier", nil];
  return SOCreateObjectDict(@"com.apple.ace.assistant", @"AssistantUtteranceView", props);
}

-(SOObject*)createAssistantUtteranceView:(NSString*)text {
  return [self createAssistantUtteranceView:text speakableText:text dialogIdentifier:@"Misc#Ident"];
}

-(SOObject*)createAssistantUtteranceView:(NSString*)text speakableText:(NSString*)speakableText {
  return [self createAssistantUtteranceView:text speakableText:speakableText dialogIdentifier:@"Misc#Ident"];
}

-(SOObject*)createAssistantUtteranceView:(NSString*)text speakableText:(NSString*)speakableText dialogIdentifier:(NSString*)dialogIdentifier {
  return SOCreateAssistantUtteranceView(text, speakableText, dialogIdentifier);
}

#pragma mark - RequestComplete Creation

NSMutableDictionary* SOCreateAceRequestCompleted(NSString* refId) {
  return BaseClientBoundCommandDict(refId, @"com.apple.ace.system", @"CommandSucceeded");
}

#pragma mark - Helper

NSString* RandomUUID() {
  return [NSString stringWithFormat:@"1%07x-%04x-%04x-%04x-%06x%06x", rand()%0xFFFFFFF, rand()%0xFFFF, rand()%0xFFFF, rand()%0xFFFF, rand()%0xFFFFFF, rand()%0xFFFFFF];
}


@end