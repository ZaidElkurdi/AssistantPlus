#import "AssistantPlusHeaders.h"

@interface APHelloSnippetCommands : NSObject<APPluginCommand>

-(BOOL)handleSpeech:(NSString*)text session:(id<APSiriSession>)session;

@end
// vim:ft=objc
