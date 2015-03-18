#import "AssistantPlusHeaders.h"

@interface APHelloSnippetCommands : NSObject<APPluginCommand>

-(BOOL)handleSpeech:(NSString*)text withTokens:(NSSet*)tokens withSession:(id<APSiriSession>)session;

@end
// vim:ft=objc
