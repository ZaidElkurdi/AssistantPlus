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

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.frame = CGRectMake(0,0,self.view.frame.size.width-50, 300);
  //UIView *contentView = [[UIView alloc] initWithFrame:self.view.frame];
  UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [button addTarget:self
             action:@selector(aMethod)
   forControlEvents:UIControlEventTouchUpInside];
  [button setTitle:@"Show View" forState:UIControlStateNormal];
  button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
  button.backgroundColor = [UIColor redColor];
  [self.view  addSubview:button];
  
  UITableView *tv = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
  tv.dataSource = self;
  tv.delegate = self;
  [tv setBackgroundView:nil];
  [tv setBackgroundColor:[UIColor clearColor]];
  [self.view  addSubview:tv];
//  [self.view addSubview:contentView];
  NSLog(@"Returing hello view: %@ ", self.view);
}

- (void)aMethod {
  NSLog(@"Tapped that!");
}

-(id)initWithAceObject:(id)aceObj {
  NSLog(@"Init with: %@", aceObj);
  [self setAceObject:aceObj];
  return self;
}

-(id)initWithProperties:(NSDictionary*)props {
  NSLog(@"Snippet init with: %@" ,props);
  if (self = [super init]) {
    NSDictionary *locInfo = props[@"Location"];
    NSLog(@"Loc Info: %@", locInfo);
    helloLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 200)] autorelease];
    helloLabel.text = [NSString stringWithFormat:@"%f", [locInfo[@"latitude"] floatValue]];
    [self.view addSubview:helloLabel];
  }
  
  return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"siriCell"];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"siriCell"];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
  }
  
  cell.textLabel.text = @"swag";
  return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSLog(@"Selected!");
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return 3;
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
