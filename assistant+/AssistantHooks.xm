#import <Foundation/Foundation.h>
#import "assistantpluspluginmanager/AssistantPlusHeaders.h"
#import "assistantpluspluginmanager/AssistantHeaders.h"
#import "assistantpluspluginmanager/APPluginSystem.h"
#import "assistantpluspluginmanager/APSession.h"
#import "assistantpluspluginmanager/APSpringboardUtils.h"
#import <substrate.h>

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
static APPluginSystem *pluginManager;
static BOOL hasLoadedSnippets = NO;

BOOL shouldHandleRequest(NSString *text, APSession *currSession) {
  pluginManager = [[%c(APSpringboardUtils) sharedAPUtils] getPluginManager];
  NSArray *lowerCaseArr = [[text componentsSeparatedByString: @" "] valueForKey:@"lowercaseString"];
  NSSet *tokens = [NSSet setWithArray:lowerCaseArr];
  BOOL pluginWillHandle = [pluginManager handleCommand:text withTokens:tokens withSession:currSession];
  defaultHandling = !pluginWillHandle;
  return pluginWillHandle;
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

%hook SiriUIPluginManager

- (id)transcriptItemForObject:(AceObject*)arg1 {
  if (!hasLoadedSnippets) {
    [self loadAssistantPlusSnippets];
  }
  NSDictionary *properties = [arg1 properties];
  if (properties) {
    NSString *className = properties[@"snippetClass"];
    if (className) {
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
  id r = %orig(arg1);
  return r;
}

%new
- (void)loadAssistantPlusSnippets {
  hasLoadedSnippets = YES;
  
  NSURL *directoryPath = [NSURL URLWithString:@PLUGIN_PATH];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *contents = [fileManager contentsOfDirectoryAtURL:directoryPath
                                 includingPropertiesForKeys:@[]
                                                    options:NSDirectoryEnumerationSkipsHiddenFiles
                                                      error:nil];
  
  for (NSURL *fileURL in contents) {
    NSString *name = [[[fileURL absoluteString] lastPathComponent] stringByDeletingPathExtension];
    
    NSBundle *bundle = [NSBundle bundleWithURL:fileURL];
    
    if (!bundle) {
      NSLog(@"Failed to open plugin bundle %@ (%@)!", fileURL, fileURL);
      continue;
    }
    
    if (![bundle load]) {
      NSLog(@"Failed to load plugin bundle %@!", name);
      continue;
    } else {
      NSLog(@"Loaded bundle!");
    }
  }
}

%end

%hook AFConnection

- (void)startRequestWithCorrectedText:(NSString*)text forSpeechIdentifier:(id)arg2 {
  NSLog(@"AP: Starting request with corrected text: %@", text);
  APSession *currSession = [APSession sessionWithConnection:self];
  if (shouldHandleRequest(text, currSession)) {
    NSLog(@"Handling!");
  } else {
    %orig;
  }
}

- (void)startRequestWithText:(NSString*)text {
  NSLog(@"AP: Starting request with text: %@", text);
  APSession *currSession = [APSession sessionWithConnection:self];
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
        for (AFSpeechToken *currToken in currInterpretation.tokens) {
          [phraseBuilder appendString:[NSString stringWithFormat:@"%@ ", currToken.text]];
        }
      }
    }
  }
  
  NSLog(@"AP Starting Speech Query: %@", phraseBuilder);
  
  AFConnection *connection = MSHookIvar<AFConnection*>(self, "_connection");
  APSession *currSession = [APSession sessionWithConnection:connection];
  if (shouldHandleRequest(phraseBuilder, currSession)) {
    [connection cancelRequest];
    [self requestDidFinish];
  } else {
    %orig;
  }
}

- (void)requestDidReceiveCommand:(id)arg1 reply:(CDUnknownBlockType*)arg2 {
  if (defaultHandling) {
    NSLog(@"Allowing default!");
    %orig;
  } else {
    NSLog(@"Overriding!");
  }
}
%end