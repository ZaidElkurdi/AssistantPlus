//
//  HelloSnippetSnippet.m
//  
//
//  Created by Zaid Elkurdi on 3/14/15.
//
//

#import "APHelloSnippetView.h"

@implementation APHelloSnippetView {
  UILabel *helloLabel;
}

@synthesize aceObject;

-(id)customView {
  UIView *shit = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 1000)];
  shit.backgroundColor = [UIColor redColor];
  NSLog(@"Returing hello view: %@ %@", shit, shit.backgroundColor);
  return shit;
}

-(id)initWithAceObject:(id)aceObj {
  NSLog(@"Init with: %@", aceObj);
  [self setAceObject:aceObj];
  return self;
}

-(id)initWithProperties:(NSDictionary*)props {
  NSLog(@"Init with: %@" ,props);
  if (self = [super init]) {
    NSString *newText = @"bitch nigga";
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

-(id)viewControllerForSnippet:(id)arg1 error:(id)arg2 {
  return self;
}

-(id)speakableNamespaceProviderForAceObject:(id)arg1 {
  return nil;
}

-(id)viewControllerForSnippet:(id)arg1 {
  NSLog(@"hello snippet: %@", arg1);
  return self;
}

-(id)viewControllerForAceObject:(id)arg1 {
  NSLog(@"hello ace: %@", arg1);
  return self;
}

-(id)navigationTitle {
  return @"yoyoyo";
}

-(void)transcriptViewControllerTappedOutsideEditingView {
  
}
@end
