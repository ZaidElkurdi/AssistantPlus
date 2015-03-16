#import <Foundation/Foundation.h>
#import "assistantpluspluginmanager/AssistantPlusHeaders.h"
#import "assistantpluspluginmanager/AssistantHeaders.h"
#import "assistantpluspluginmanager/APPluginManager.h"
#import "assistantpluspluginmanager/APSession.h"
#import <libobjcipc/objcipc.h>

@interface APSBPluginManager : NSObject
+ (id)getSharedManager;
@end

@protocol SAAceSerializable <NSObject>
@end

@interface SBUIPluginController : NSObject
@end

@interface SAUIAppPunchOut : NSObject
@end

@interface SAUIConfirmationOptions : NSObject
@end

@interface SiriUIPluginManager : NSObject
+ (id)sharedInstance;
- (id)_bundleSearchPaths;
- (void)_loadBundleMapsIfNecessary;
@end

static BOOL defaultHandling = YES;
static AFConnection *currConnection;
static APPluginManager *pluginManager;

BOOL shouldHandleRequest(NSString *text, APSession *currSession) {
  pluginManager = [%c(APSBPluginManager) getSharedManager];
  return [pluginManager handleCommand:text withSession:currSession];
}

%hook BasicAceContext
- (Class)classWithClassName:(NSString*)name group:(NSString*)group {
  %log;
  id r = %orig;
  if ([name isEqualToString:@"SnippetObject"] && [group isEqualToString:@"zaid.assistantplus.plugin"]) {
    r = NSClassFromString(@"SAUISnippet");
  }
  NSLog(@"CWC: %@", r);
  return r;
}

%end

%hook SiriUIPluginManager

- (id)transcriptItemForObject:(AceObject*)arg1 {
  NSLog(@"new manager: %@ and self:%@", [%c(APPluginManager) sharedManager], self);
  NSDictionary *properties = [arg1 properties];
  if (properties) {
    NSString *className = properties[@"snippetClass"];
    if (className) {
      NSLog(@"AP: Looking for custom snippet: %@", className);
      id<APPluginSnippet> customClass = [[NSClassFromString(className) alloc] initWithProperties:@{@"Bitch" : @"Nigga"}];
      if ([customClass respondsToSelector:@selector(customView)]) {
        UIView *customVC = [customClass customView];
        SiriUISnippetViewController *vc = [[%c(SiriUISnippetViewController) alloc] init];
        object_setClass(vc, [%c(APPluginSnippetViewController) class]);
        [(APPluginSnippetViewController*)vc setCustomView:customVC];
        SiriUITranscriptItem *item = [%c(SiriUITranscriptItem) transcriptItemWithAceObject:arg1];
        item.viewController = vc;
        return item;
      } else {
        NSLog(@"AP ERROR: %@ did not respond to customView", className);
      }
    } else {
      NSLog(@"AP: No custom class for snippet, going to default!");
    }
  } else {
    NSLog(@"AP ERROR: No properties for snippet, this shouldn't hapepn...");
  }
  id r = %orig;
  return r;
}


%end

%hook AFConnection
- (void)_doCommand:(SAUIAddViews*)arg1 reply:(id)arg2 {
  
  id service;
  object_getInstanceVariable(self, "_delegate", (void **)&service);
  NSLog(@"Service: %@", service);
  
  NSLog(@"Doing: %@", arg1);
  if ([arg1 respondsToSelector:@selector(views)]) {
    NSLog(@"Views: %@", arg1.views);
  }
  %log;
  %orig;
}

- (void)clearContext { %log; %orig; }

- (void)sendReplyCommand:(id)arg1 { %log; %orig; }

- (void)startRequestWithCorrectedText:(NSString*)text forSpeechIdentifier:(id)arg2 {
  NSLog(@"AP: Starting request with corrected text: %@", text);
  APSession *currSession = [APSession sessionWithRefId:nil andConnection:self];
  if (shouldHandleRequest(text, currSession)) {
    NSLog(@"Handling!");
  } else {
    %orig;
  }
}

- (void)_requestWillBeginWithRequestClass:(id)arg1 isSpeechRequest:(BOOL)arg2 isBackgroundRequest:(BOOL)arg3 {
  NSLog(@"yoyoyyo");
  %log;
  %orig;
}

- (void)_requestWillBeginWithRequestClass:(id)arg1 isSpeechRequest:(BOOL)arg2 {
  NSLog(@"heyheyhey");
  %log;
  %orig;
}

- (void)requestWillBeginWithRequestClass:(id)arg1 isSpeechRequest:(BOOL)arg2 isBackgroundRequest:(BOOL)arg3 {
  NSLog(@"brobrobro");
  %log;
  %orig;
}

- (void)requestWillBeginWithRequestClass:(id)arg1 isSpeechRequest:(BOOL)arg2 {
  NSLog(@"zaidzaidzaid");
  %log;
  %orig;
}

- (void)startAcousticIDRequestWithOptions:(id)arg1 { %log; %orig; }
- (void)startSpeechPronunciationRequestWithOptions:(id)arg1 pronunciationContext:(id)arg2 { %log; %orig; }

- (void)startSpeechRequestWithOptions:(id)arg1 {
  NSLog(@"%@", arg1);
  %log;
  %orig;
}
- (void)startContinuationRequestWithUserInfo:(id)arg1 { %log; %orig; }
- (void)startDirectActionRequestWithString:(id)arg1 { %log; %orig; }

- (void)startRequestWithText:(NSString*)text {
  NSLog(@"AP: Starting request with text: %@", text);
  APSession *currSession = [APSession sessionWithRefId:nil andConnection:self];
  if (shouldHandleRequest(text, currSession)) {
    NSLog(@"Handling!");
  } else {
    NSLog(@"Default!");
    %orig;
  }
}

%end

%hook AFConnectionClientServiceDelegate

- (void)speechRecognized:(SASSpeechRecognized*)arg1 {
  NSMutableString *phraseBuilder = [NSMutableString string];
  for (AFSpeechPhrase *currPhrase in arg1.recognition.phrases) {
    if (currPhrase.interpretations.count > 0) {
      SASInterpretation *currInterpretation = currPhrase.interpretations[0];
      if (currInterpretation.tokens.count > 0) {
        AFSpeechToken *currToken = currInterpretation.tokens[0];
        [phraseBuilder appendString:[NSString stringWithFormat:@"%@ ", currToken.text]];
      }
    }
  }
  
  NSLog(@"Query: %@", phraseBuilder);
  
  AFConnection *connection;
  object_getInstanceVariable(self, "_connection", (void **)&connection);
  currConnection = connection;
  
  APSession *currSession = [APSession sessionWithRefId:nil andConnection:currConnection];
  
  pluginManager = [%c(APSBPluginManager) getSharedManager];
  if ([pluginManager handleCommand:phraseBuilder withSession:currSession]) {
    defaultHandling = NO;
    NSLog(@"Handling with plugin!");
  } else {
    defaultHandling = NO;
    NSLog(@"Going to default!");
  }
}

- (void)requestDidFinish{ %log; %orig; }
- (void)requestDidReceiveCommand:(id)arg1 reply:(CDUnknownBlockType*)arg2 {
  %log;
  if (defaultHandling) {
    %orig;
  }
}

%end
