//
//  HelloSnippetSnippet.m
//  
//
//  Created by Zaid Elkurdi on 3/14/15.
//
//

#import "APHelloSnippetViewController.h"

@implementation APHelloSnippetViewController {
  UILabel *helloLabel;
}

@synthesize aceObject;

- (void)viewDidLoad {
  [super viewDidLoad];
}

-(id)initWithProperties:(NSDictionary*)props {
  if (self = [super init]) {
    NSString *newText = props[@"labelText"];
    helloLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)] autorelease];
    helloLabel.text = newText;
  }
  
  return self;
}

-(double)desiredHeightForWidth:(double)arg1 {
  return 200.0;
}

-(void)siriWillActivateFromSource:(long long)arg1 {
  NSLog(@"Is activating from: %lld", arg1);
}

-(void)siriDidDeactivate {
  NSLog(@"Did deactivate!");
}

-(void)wasAddedToTranscript {
  NSLog(@"Was added!");
}

-(AceObject *)aceObject {
  return aceObject;
}

-(void)setAceObject:(AceObject*)aceObj {
  aceObject = aceObj;
}

@end
