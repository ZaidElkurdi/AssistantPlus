//
//  ListenerDetailViewController.m
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 3/23/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "ListenerDetailViewController.h"

@interface ListenerDetailViewController ()
@property (strong, nonatomic) APActivatorListener *currListener;
@property (strong, nonatomic) UISwitch *enabledSwitch;
@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) UITextView *triggerField;
@property (nonatomic) BOOL didChange;
@end

@implementation ListenerDetailViewController

- (id)initWithListener:(APActivatorListener*)listener {
  if (self = [super init]) {
    self.currListener = listener;
    self.didChange = NO;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  UIColor *backgroundColor = [UIColor colorWithWhite:.9f alpha:1.0];
  self.view.backgroundColor = backgroundColor;
  
  UIView *switchBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 90, self.view.frame.size.width, 50)];
  switchBackground.backgroundColor = [UIColor whiteColor];
  UILabel *switchLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 50)];
  switchLabel.text = @"Enabled:";
  self.enabledSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100, 9.5, 51, 31)];
  [self.enabledSwitch addTarget:self action:@selector(didToggleSwitch:) forControlEvents:UIControlEventValueChanged];
  self.enabledSwitch.on = self.currListener.enabled;
  [switchBackground addSubview:switchLabel];
  [switchBackground addSubview:self.enabledSwitch];
  [self.view addSubview:switchBackground];
  
  UIView *nameBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 170, self.view.frame.size.width, 50)];
  nameBackground.backgroundColor = [UIColor whiteColor];
  UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 50)];
  nameLabel.text = @"Name:";
  self.nameField = [[UITextField alloc] initWithFrame:CGRectMake(80, 2, self.view.frame.size.width-60, 50)];
  self.nameField.text = self.currListener.name;
  self.nameField.delegate = self;
  [nameBackground addSubview:nameLabel];
  [nameBackground addSubview:self.nameField];
  [self.view addSubview:nameBackground];
  
  
  UIView *triggerBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 230, self.view.frame.size.width, 100)];
  triggerBackground.backgroundColor = [UIColor whiteColor];
  UILabel *triggerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 70, 50)];
  triggerLabel.text = @"Trigger:";
  self.triggerField = [[UITextView alloc] initWithFrame:CGRectMake(80, 8, self.view.frame.size.width-80, 90)];
  self.triggerField.font = [UIFont systemFontOfSize:16];
  self.triggerField.text = self.currListener.trigger;
  self.triggerField.delegate = self;
  [triggerBackground addSubview:triggerLabel];
  [triggerBackground addSubview:self.triggerField];
  [self.view addSubview:triggerBackground];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  if (self.didChange) {
    self.currListener.trigger = self.triggerField.text;
    self.currListener.name = self.nameField.text;
    [self.delegate listenerDidChange:self.currListener];
  }
}

#pragma mark - UI Delegates

- (void)didToggleSwitch:(UISwitch*)theSwitch {
  self.didChange = YES;
  self.currListener.enabled = theSwitch.on;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  self.didChange = YES;
  return  YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  self.didChange = YES;
  return  YES;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
