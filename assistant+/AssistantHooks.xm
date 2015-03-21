#import <Foundation/Foundation.h>
#import "assistantpluspluginmanager/AssistantPlusHeaders.h"
#import "assistantpluspluginmanager/AssistantHeaders.h"
#import "assistantpluspluginmanager/APPluginManager.h"
#import "assistantpluspluginmanager/APSession.h"
#import "assistantpluspluginmanager/APSpringboardUtils.h"
#import <libobjcipc/objcipc.h>

@protocol SAAceSerializable <NSObject>
@end

@interface SBUIPluginController : NSObject
@end

@interface SAUIAppPunchOut : NSObject
@end

@interface SAUIConfirmationOptions : NSObject
@end

static BOOL defaultHandling = YES;
static AFConnection *currConnection;
static APPluginManager *pluginManager;

BOOL shouldHandleRequest(NSString *text, APSession *currSession) {
  pluginManager = [[%c(APSpringboardUtils) sharedUtils] getPluginManager];
  NSLog(@"Manager: %@", pluginManager);
  NSSet *tokens = [NSSet setWithArray:[text componentsSeparatedByString: @" "]];
  return [pluginManager handleCommand:text withTokens:tokens withSession:currSession];
}

%hook BasicAceContext
- (Class)classWithClassName:(NSString*)name group:(NSString*)group {
  id r;
  if ([name isEqualToString:@"SnippetObject"] && [group isEqualToString:@"zaid.assistantplus.plugin"]) {
    r = NSClassFromString(@"SAUISnippet");
  } else {
    r = %orig;
  }
  return r;
}

%end

%hook SiriUISnippetViewController
-(void)setSnippet:(id)arg1 {
  %log;
  %orig;
}
%end

%hook SiriUIPluginManager

- (id)transcriptItemForObject:(AceObject*)arg1 {
  NSDictionary *properties = [arg1 properties];
  if (properties) {
    NSString *className = properties[@"snippetClass"];
    if (className) {
      NSLog(@"AP: Looking for custom snippet: %@", className);
      id<APPluginSnippet> customClass = [[NSClassFromString(className) alloc] initWithProperties:properties[@"snippetProps"]];
      if ([customClass respondsToSelector:@selector(view)]) {
        UIViewController *customVC = (UIViewController*)customClass;
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
  NSLog(@"Doing: %@", arg1);
  if ([arg1 respondsToSelector:@selector(views)]) {
    NSLog(@"Views: %@", arg1.views);
  }
  %log;
  %orig;
}

- (void)clearContext { %log; %orig; }

- (void)sendReplyCommand:(id)arg1 {
  %log;
}

- (void)startRequestWithCorrectedText:(NSString*)text forSpeechIdentifier:(id)arg2 {
  NSLog(@"AP: Starting request with corrected text: %@", text);
  APSession *currSession = [APSession sessionWithRefId:nil andConnection:self];
  if (shouldHandleRequest(text, currSession)) {
    NSLog(@"Handling!");
  } else {
    %orig;
  }
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

%hook AFUISiriSession
- (void)_requestContextWithCompletion:(id)arg1 {
  NSLog(@"%@", arg1);
  %log;
  %orig;
}
- (void)_requestDidFinishWithError:(id)arg1 {
  NSLog(@"%@", arg1);
  %log;
  %orig;
}
- (void)assistantConnectionRequestFinished:(id)arg1 {
  NSLog(@"%@", arg1);
  %log;
  %orig;
}
- (void)end {
  %log;
  %orig;
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
  
  NSLog(@"AP Starting Speech Query: %@", phraseBuilder);
  
  AFConnection *connection = MSHookIvar<AFConnection*>(self, "_connection");
  
  APSession *currSession = [APSession sessionWithRefId:nil andConnection:connection];
  if (shouldHandleRequest(phraseBuilder, currSession)) {
    defaultHandling = NO;
    NSLog(@"Handling with plugin!");
  } else {
    defaultHandling = YES;
    NSLog(@"Going to default!");
    %orig;
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