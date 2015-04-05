  //
  //  CustomReplyDetailViewController.m
  //  AssistantPlusApp
  //
  //  Created by Zaid Elkurdi on 3/25/15.
  //  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
  //

#import "CustomReplyDetailViewController.h"

@interface CustomReplyDetailViewController ()
@property (strong, nonatomic) APCustomReply *currReply;
@property (strong, nonatomic) UITextField *triggerField;
@property (strong, nonatomic) UITextView *responseField;
@property (nonatomic) BOOL didChange;
@end

@implementation CustomReplyDetailViewController

- (id)initWithCustomReply:(APCustomReply*)reply {
  if (self = [super init]) {
    self.currReply = reply;
    self.didChange = NO;
  }
  return self;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
  [super viewDidLoad];
  UIColor *backgroundColor = [UIColor colorWithWhite:.9f alpha:1.0];
  self.view.backgroundColor = backgroundColor;
  
  UIView *triggerBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
  triggerBackground.backgroundColor = [UIColor whiteColor];
  UILabel *triggerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 70, 50)];
  triggerLabel.text = @"Trigger:";
  self.triggerField = [[UITextField alloc] initWithFrame:CGRectMake(90, 2, self.view.frame.size.width-60, 50)];
  self.triggerField.text = self.currReply.trigger;
  self.triggerField.delegate = self;
  [triggerBackground addSubview:triggerLabel];
  [triggerBackground addSubview:self.triggerField];
  [self.view addSubview:triggerBackground];
  
  UIView *responseBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 190, self.view.frame.size.width, 100)];
  responseBackground.backgroundColor = [UIColor whiteColor];
  UILabel *responseLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 50)];
  responseLabel.text = @"Response:";
  self.responseField = [[UITextView alloc] initWithFrame:CGRectMake(110, 8, self.view.frame.size.width-110, 90)];
  self.responseField.text = self.currReply.response;
  self.responseField.font = [UIFont systemFontOfSize:16];
  self.responseField.delegate = self;
  [responseBackground addSubview:responseLabel];
  [responseBackground addSubview:self.responseField];
  [self.view addSubview:responseBackground];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  if (self.didChange) {
    self.currReply.trigger = self.triggerField.text;
    self.currReply.response = self.responseField.text;
    [self.delegate customReplyDidChange:self.currReply];
  }
}

#pragma mark - UI Delegates

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  self.didChange = YES;
  return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  self.didChange = YES;
  return YES;
}
@end
