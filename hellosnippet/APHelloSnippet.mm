#import "APHelloSnippet.h"
#import "APHelloSnippetCommands.h"
#import "APHelloSnippetViewController.h"

@implementation APHelloSnippet

// required initialization
-(id)initWithSystem:(id<APPluginManager>)manager {
	if ((self = [super init])) {
		// register all extension classes provided
		[manager registerCommand:[APHelloSnippetCommands class]];
		[manager registerSnippet:[APHelloSnippetViewController class]];
	}
	return self;
}

@end
// vim:ft=objc
