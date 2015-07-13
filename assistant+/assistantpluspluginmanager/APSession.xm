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
#import "CPDistributedMessagingCenter.h"

static NSString* s_ver = nil;
static NSMutableDictionary *sessionDict;

@implementation APSession

-(APSession*)initWithRefId:(NSString*)referenceId andConnection:(AFConnection*)connection {
  if ((self = [super init])) {
    self.refId = [referenceId copy];
    if (!self.refId) self.refId = [@"00000000-0000-0000-0000-000000000000" copy];
    self.connection = connection;
    self.listenAfterSpeaking = NO;
  }
  return self;
}

+(APSession*)sessionWithConnection:(AFConnection*)connection {
  NSString *refId = [APSession generateRandomUUID];
  APSession *currSession = [[APSession alloc] initWithRefId:refId andConnection:connection];
  if (!currSession) {
    return nil;
  }
  
  if (!sessionDict) {
    sessionDict = [[NSMutableDictionary alloc] init];
  }
  
  [sessionDict setObject:currSession forKey:currSession.refId];
  return currSession;
}

- (BOOL)isListeningAfterSpeaking {
  return _listenAfterSpeaking;
}

#pragma mark - Public Methods

-(SOObject*)createTextSnippet:(NSString*)text {
  return [self createAssistantUtteranceView:text];
}

- (void)sendTextSnippet:(NSString*)text temporary:(BOOL)temporary scrollToTop:(BOOL)toTop dialogPhase:(NSString*)phase {
  [self sendTextSnippet:text temporary:temporary scrollToTop:toTop dialogPhase:phase listenAfterSpeaking:NO];
}

- (void)sendTextSnippet:(NSString*)text temporary:(BOOL)temporary scrollToTop:(BOOL)toTop dialogPhase:(NSString*)phase listenAfterSpeaking:(BOOL)listen {
  NSMutableArray* views = [NSMutableArray arrayWithCapacity:1];
  [views addObject:[self createAssistantUtteranceView:text speakableText:text identifier:@"Misc" listenAfterSpeaking:listen]];
  [self sendAddViews:views dialogPhase:phase scrollToTop:toTop temporary:temporary];
}

- (void)sendCustomSnippet:(NSString*)snippetClass withProperties:(NSDictionary*)props {
  [self sendAddViewsSnippet:snippetClass properties:props dialogPhase:@"Completion" scrollToTop:NO temporary:NO];
}

- (void)sendRequestCompleted {
  self.listenAfterSpeaking = NO;
  NSMutableDictionary* dict = [self createAceRequestCompleted];
  [self sendCommandToConnection:dict];
  [sessionDict removeObjectForKey:self.refId];
}

- (void)getCurrentLocationWithCompletion:(void (^)(NSDictionary *info))completion {
  id<APSharedUtils> x = [%c(APSpringboardUtils) sharedAPUtils];
  [x getCurrentLocationWithCompletion:completion];
}

- (void)sendAddViews:(NSArray*)views {
  [self sendAddViews:views dialogPhase:@"Completion" scrollToTop:NO temporary:NO];
}

- (void)sendAddViews:(NSArray*)views dialogPhase:(NSString*)dialogPhase scrollToTop:(BOOL)toTop temporary:(BOOL)temporary {
  self.listenAfterSpeaking = NO;
  for (NSDictionary *currView in views) {
    if ([currView[@"listenAfterSpeaking"] boolValue]) {
      dialogPhase = @"Clarification";
      self.listenAfterSpeaking = YES;
    }
  }
  NSMutableDictionary* dict = [self createAceAddViews:views forPhase:dialogPhase scrollToTop:toTop temporary:temporary];
  [self sendCommandToConnection:dict];
}

#pragma mark - APLocationDaemon Communication

- (void)handleMessage:(NSString*)name withInfo:(NSDictionary*)locationData {
  if (self.completionHandler) {
    self.completionHandler(locationData);
  }
}

#pragma mark - AFConnection Communication

- (void)sendCommandToConnection:(NSDictionary*) dict {
  id ctx = nil;
  
  id AceObject = objc_getClass("AceObject");
  id BasicAceContext = objc_getClass("BasicAceContext");
  
  if (!AceObject) NSLog(@"No AceObject class");
  if (!BasicAceContext) NSLog(@"No BasicAceContext class");
  
  if (!dict) {
    return;
  }
  
  // create context
  if (ctx == nil) {
    ctx = [[BasicAceContext alloc] init]; // ... is not needed normally, but just in case...
  }
  
  if (!ctx) {
    NSLog(@"Error getting BasicAceContext!");
  }
  
  
  if ([dict objectForKey:@"v"] && !s_ver) {
    s_ver = [[dict objectForKey:@"v"] copy];
  } else if (s_ver && ![dict objectForKey:@"v"]) {
    dict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [(NSMutableDictionary*)dict setObject:s_ver forKey:@"v"];
  }
  
  // create real AceObject
  id obj = [AceObject aceObjectWithDictionary:dict context:ctx];
  if (obj == nil) {
    return;
  }
  
  // call the original method to handle our new object
  if (self.connection == nil) { NSLog(@"AP: AFConnection is nil"); return; }

  if ([dict[@"$class"] isEqualToString:@"CommandSucceeded"]) {
    [self.connection sendReplyCommand:obj];
  } else {
    [self.connection _doCommand:obj reply:nil];
  }
}

-(void)sendAddViewsSnippet:(NSString*)snippetClass properties:(NSDictionary*)props dialogPhase:(NSString*)dialogPhase scrollToTop:(BOOL)scrollToTop temporary:(BOOL)temporary {
  NSArray* views = [NSArray arrayWithObject:[self createSnippet:snippetClass properties:props]];
  [self sendAddViews:views];
}

#pragma mark - Object Creation

-(SOObject*)createSnippet:(NSString*)snippetClass properties:(NSDictionary*)props {
  if (!props) props = [NSDictionary dictionary];
  NSMutableDictionary* lowLevelProps = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        props,@"snippetProps", snippetClass,@"snippetClass", nil];
  
  return [self createObjectDictForGroup:@"zaid.assistantplus.plugin" class:@"SnippetObject" properties:lowLevelProps];
}

-(SOObject*)createObjectDict:(NSString*)className group:(NSString*)group properties:(NSDictionary*)props {
  return [self createObjectDictForGroup:group class:className properties:[props mutableCopy]];
}

#pragma mark - Object Dictionary Creation

-(NSMutableDictionary*)createObjectDictForGroup:(NSString*)group class:(NSString*)className properties:(NSMutableDictionary*)properties {
  NSMutableDictionary *objDict = [[NSMutableDictionary alloc] init];
  [objDict setObject:className forKey:@"$class"];
  [objDict setObject:group forKey:@"$group"];
  
  if (properties != nil) {
    //Only necessary for AceObjects
    [objDict setObject:@"4.3" forKey:@"$v"];
    
    for (NSString *currKey in properties.allKeys) {
      [objDict setObject:properties[currKey] forKey:currKey];
    }
  }
  return objDict;
}

- (NSMutableDictionary*)createAceObjectDictForGroup:(NSString*)group class:(NSString*)className properties:(NSMutableDictionary*) properties {
  NSString* aceId = [APSession generateRandomUUID];
  
  NSMutableDictionary *dict = [self createObjectDictForGroup:group class:className properties:properties];
  
  [dict setObject:[NSNumber numberWithBool:YES] forKey:@"local"];
  [dict setObject:aceId forKey:@"aceId"];
  [dict setObject:self.refId forKey:@"refId"];
  
  return dict;
}

-(NSMutableDictionary*)createBaseClientBoundCommandDictForGroup:(NSString*)group class:(NSString*)className {
  
  NSMutableDictionary *dict = [self createObjectDictForGroup:group class:className properties:nil];
  [dict setObject:self.refId forKey:@"refId"];
  
  return dict;
}

#pragma mark - AddViews Creation

- (NSMutableDictionary*)createAceAddViews:(NSArray*)views forPhase:(NSString*)dialogPhase scrollToTop:(BOOL)scrollToTop temporary:(BOOL)temporary {
  NSMutableDictionary* props = [NSMutableDictionary dictionary];
  [props setObject:[NSNumber numberWithBool:scrollToTop] forKey:@"scrollToTop"];
  [props setObject:[NSNumber numberWithBool:temporary] forKey:@"temporary"];
  [props setObject:views forKey:@"views"];
  [props setObject:dialogPhase forKey:@"dialogPhase"];
  [props setObject:@"PrimaryDisplay" forKey:@"displayTarget"];
  
  return [self createAceObjectDictForGroup:@"com.apple.ace.assistant" class:@"AddViews" properties:props];
}

#pragma mark - AssistantUtteranceView Creation

-(NSMutableDictionary*)createAssistantUtteranceView:(NSString*)text speakableText:(NSString*)speakableText identifier:(NSString*)dialogIdentifier listenAfterSpeaking:(BOOL)listen {
  if (speakableText == nil) speakableText = text;
  NSMutableDictionary* props = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                text,@"text", speakableText,@"speakableText", dialogIdentifier,@"dialogIdentifier", @(listen), @"listenAfterSpeaking", nil];
  return [self createObjectDictForGroup:@"com.apple.ace.assistant" class:@"AssistantUtteranceView" properties:props];
}

-(NSMutableDictionary*)createAssistantUtteranceView:(NSString*)text speakableText:(NSString*)speakableText identifier:(NSString*)dialogIdentifier {
  return [self createAssistantUtteranceView:text speakableText:speakableText identifier:dialogIdentifier listenAfterSpeaking:NO];
}

-(SOObject*)createAssistantUtteranceView:(NSString*)text {
  return [self createAssistantUtteranceView:text speakableText:text identifier:@"Misc#Ident"];
}

-(SOObject*)createAssistantUtteranceView:(NSString*)text speakableText:(NSString*)speakableText {
  return [self createAssistantUtteranceView:text speakableText:speakableText identifier:@"Misc#Ident"];
}

#pragma mark - RequestComplete Creation

-(NSMutableDictionary*)createAceRequestCompleted {
  return [self createBaseClientBoundCommandDictForGroup:@"com.apple.ace.system" class:@"CommandSucceeded"];
}

#pragma mark - Helper

+(NSString*)generateRandomUUID {
  return [NSString stringWithFormat:@"1%07x-%04x-%04x-%04x-%06x%06x", rand()%0xFFFFFFF, rand()%0xFFFF, rand()%0xFFFF, rand()%0xFFFF, rand()%0xFFFFFF, rand()%0xFFFFFF];
}


@end