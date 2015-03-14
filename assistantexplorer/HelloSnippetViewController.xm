//
//  HelloSnippetViewController.m
//  
//
//  Created by Zaid Elkurdi on 3/11/15.
//
//

#import "HelloSnippetViewController.h"
#import "InspCWrapper.m"

@class AceObject;

//static AceObject *_aceObject;
//@implementation HelloSnippetViewController
%subclass HelloSnippetViewController : SiriUISnippetViewController <SiriUISnippetPlugin>
///@synthesize aceObject = _aceObject;


- (void)viewDidLoad {
//  [(SiriUISnippetViewController*)super viewDidLoad];
//  NSLog(@"Super is: %@", [(SiriUISnippetViewController*)super class]);
  NSLog(@"Hello snippet view did load!");
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
  label.text = @"HELLO SNIPPET!";
  
  UIViewController *vc = (UIViewController*)self;
  [vc.view addSubview:label];
}


%new
-(id)viewControllerForSnippet:(id)arg1 error:(id)arg2 {
  return self;
}

%new
-(id)speakableNamespaceProviderForAceObject:(id)arg1 {
  return nil;
}

%new
-(id)initWithAceObject:(id)aceObj {
  NSLog(@"Init with: %@", aceObj);
  [self setAceObject:aceObj];
  return self;
}

%new
-(id)viewControllerForSnippet:(id)arg1 {
  NSLog(@"hello snippet: %@", arg1);
  return self;
}

%new
-(id)viewControllerForAceObject:(id)arg1 {
  NSLog(@"hello ace: %@", arg1);
  return self;
}

//- (void)wasAddedToTranscript {
//  NSLog(@"Hello Snipped added to a transcript!");
//}

- (double)desiredHeight {
  return 200;
}

//-(void)siriWillActivateFromSource:(long long)arg1 {
//  NSLog(@"Siri is activating!");
//}


%new
-(void)viewDidPresent {
  NSLog(@"View is presenting!");
}


//-(AceObject*)aceObject {
//  return _aceObject;
//}
//
//-(void)setAceObject:(AceObject*)arg1 {
//  _aceObject = arg1;
//}

//-(void)siriDidDeactivate {
//  
//}

-(double)desiredHeightForWidth:(double)arg1 {
  return 200;
}

-(id)navigationTitle {
  return @"yoyoyo";
}

%new
-(void)transcriptViewControllerTappedOutsideEditingView {
  
}


- (void)didMoveToParentViewController:(UIViewController *)parent  {
  NSLog(@"Hello moved to %@", parent);
  setMaximumRelativeLoggingDepth(10);
  watchObject(parent);
}

%end
