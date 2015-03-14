#import "AssistantPlusHeaders.h"

@interface APHelloSnippetCommands : NSObject<APPluginCommand>

-(BOOL)handleSpeech:(NSString*)text session:(APSession*)session;

@end
// vim:ft=objc
