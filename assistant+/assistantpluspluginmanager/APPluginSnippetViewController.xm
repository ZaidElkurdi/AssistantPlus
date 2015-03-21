#import "AssistantHeaders.h"
#import "AssistantPlusHeaders.h"

@interface APPluginSnippetObject : SAUISnippet
- (id)encodedClassName;
- (id)groupIdentifier;
@end

@implementation APPluginSnippetObject

-(id)init {
  NSLog(@">> APPluginSnippetObject init");
  if ( (self = [super init]) ){
    
  }
  return self;
}

- (id)encodedClassName
{
  return @"SnippetObject";
}
- (id)groupIdentifier
{
  return @"zaid.assistantplus.plugin";
}
@end

static UIViewController *_view;

%subclass APPluginSnippetViewController : SiriUISnippetViewController <SiriUISnippetPlugin, SiriUIViewController>

//- (void)viewDidLoad {
//  //  [(SiriUISnippetViewController*)super viewDidLoad];
//  //  NSLog(@"Super is: %@", [(SiriUISnippetViewController*)super class]);
//  NSLog(@"Hello snippet view did load!");
//  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
//  label.text = @"HELLO SNIPPET!";
//  
//  UIViewController *vc = (UIViewController*)self;
//  [vc.view addSubview:label];
//}


%new
-(void)setCustomView:(UIViewController*)newVC {
  NSLog(@"Setting custom view to: %@", newVC);
  _view = newVC;
  [self addChildViewController:newVC];
  [newVC didMoveToParentViewController:self];
  self.view.frame = newVC.view.frame;
  [self.view addSubview:newVC.view];
}

%new
-(id)viewControllerForSnippet:(id)arg1 error:(id)arg2 {
  NSLog(@"VC FOR Snippet: %@" ,arg1);
  return _view;
}

%new
-(id)viewControllerForAceObject:(id)arg1 {
    NSLog(@"VC FOR ACE: %@" ,arg1);
  return _view;
}

%new
-(void)viewDidPresent {
  NSLog(@"View is presenting!");
}

//-(double)desiredHeightForWidth:(double)arg1 {
//  return 200;
//}

-(double)desiredHeight {
  return _view.view.frame.size.height;
}

%new
-(id)speakableNamespaceProviderForAceObject:(id)arg1 {
  return nil;
}

-(id)navigationTitle {
  return @"yoyoyo";
}

%new
-(void)transcriptViewControllerTappedOutsideEditingView {
  NSLog(@"tapped outside editing view!");
}


- (void)didMoveToParentViewController:(UIViewController *)parent  {
  NSLog(@"Hello moved to %@", parent);
}

%end
