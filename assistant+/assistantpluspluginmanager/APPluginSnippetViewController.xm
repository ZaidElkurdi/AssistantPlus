#import "AssistantHeaders.h"

%subclass APPluginSnippetViewController : SiriUISnippetViewController <SiriUISnippetPlugin>

- (void)viewDidLoad {
  //  [(SiriUISnippetViewController*)super viewDidLoad];
  //  NSLog(@"Super is: %@", [(SiriUISnippetViewController*)super class]);
  NSLog(@"Hello snippet view did load!");
}

-(void)initWithProperties:(NSDictionary*)props {
  NSString *newText = props[@"labelText"];
  UILabel *helloLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)] autorelease];
  helloLabel.text = newText;
  
  UIViewController *vc = (UIViewController*)self;
  [vc.view addSubview:helloLabel];
}

%new
-(id)viewControllerForSnippet:(id)arg1 error:(id)arg2 {
  return self;
}

%new
-(id)viewControllerForAceObject:(id)arg1 {
  return self;
}

%new
-(void)viewDidPresent {
  NSLog(@"View is presenting!");
}

-(double)desiredHeightForWidth:(double)arg1 {
  return 200;
}

//-(id)speakableNamespaceProviderForAceObject:(id)arg1;
%end
