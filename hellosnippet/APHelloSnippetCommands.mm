#import "APHelloSnippetCommands.h"

@implementation APHelloSnippetCommands

-(id)init
{
	if ( (self = [super init]) )
	{
		// additional initialization
	}
	return self;
}

-(void)dealloc
{
	// additional cleaning
	[super dealloc];
}

-(BOOL)handleSpeech:(NSString*)text session:(APSession*)session {
	// logging useful during development
	NSLog(@">> APHelloSnippetCommands handleSpeech: %@", text);

	// react to recognized tokens (what happen or what happened)
  if ([[text lowercaseString] isEqualToString:@"hello"]) {
		// properties for the snippet (optional)
		//NSDictionary* snipProps = [NSDictionary dictionaryWithObject:@"It's working!" forKey:@"text"];

		// create an array of views
    [session sendSnippetWithText:@"Why hello there dude"];

		// alternatively, for utterance response, you can use this call only:
		//[ctx sendAddViewsUtteranceView:@"Hello Snippet!!"];
		// alternatively, for snippet response you can use this call only:
		//[ctx sendAddViewsSnippet:@"K3AHelloSnippet" properties:snipProps];

		// Inform the assistant that this is end of the request
		// For more complex extensions, you can spawn an additional thread and process request asynchronly,
		// ending with sending "request completed"
		//[ctx sendRequestCompleted];

		return YES; // the command has been handled by our extension (ignore the original one from the server)
	}

	return NO;
}

@end
// vim:ft=objc
