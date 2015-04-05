#import "AssistantHeaders.h"
#import "AssistantPlusHeaders.h"

static UIViewController *_view;

%subclass APPluginSnippetViewController : SiriUISnippetViewController <SiriUISnippetPlugin, SiriUIViewController>

%new
-(void)setCustomView:(UIViewController*)newVC {
  _view = newVC;
  [self addChildViewController:newVC];
  [newVC didMoveToParentViewController:self];
  self.view.frame = newVC.view.frame;
  [self.view addSubview:newVC.view];
}

%new
-(id)viewControllerForSnippet:(id)arg1 error:(id)arg2 {
  return _view;
}

%new
-(id)viewControllerForAceObject:(id)arg1 {
  return _view;
}

%new
-(void)viewDidPresent {
  NSLog(@"View is presenting!");
}

-(double)desiredHeight {
  return _view.view.frame.size.height;
}

%new
-(id)speakableNamespaceProviderForAceObject:(id)arg1 {
  return nil;
}

-(id)navigationTitle {
  return @"APPluginSnippet";
}

%new
-(void)transcriptViewControllerTappedOutsideEditingView {
  NSLog(@"Tapped outside editing view!");
}


%end
