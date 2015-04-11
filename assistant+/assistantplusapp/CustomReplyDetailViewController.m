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
@property (strong, nonatomic) UITableView *tableView;
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
}

- (void)viewDidLoad {
  [super viewDidLoad];
  UIColor *backgroundColor = [UIColor colorWithWhite:.9f alpha:1.0];
  self.view.backgroundColor = backgroundColor;
  
  self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  
  CGFloat expectedHeight = [[self getHelpMessage] boundingRectWithSize:CGSizeMake(self.view.frame.size.width-20, CGFLOAT_MAX)
                                                               options:NSStringDrawingUsesLineFragmentOrigin
                                                            attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:14]}
                                                               context:nil].size.height;
  
  UIView *msgView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, expectedHeight+30)];
  UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, self.view.frame.size.width-20, expectedHeight)];
  msgLabel.lineBreakMode = NSLineBreakByWordWrapping;
  msgLabel.numberOfLines = 0;
  msgLabel.text = [self getHelpMessage];
  msgLabel.textAlignment = NSTextAlignmentLeft;
  msgLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
  msgLabel.textColor = [UIColor darkGrayColor];
  [msgView addSubview:msgLabel];
  
  self.tableView.tableFooterView = msgView;
  
  [self.view addSubview:self.tableView];
 
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(saveChangesIfNecessary)
   name:UIApplicationWillResignActiveNotification
   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self saveChangesIfNecessary];
}

- (void)saveChangesIfNecessary {
  if (self.didChange) {
    [self.delegate customReplyDidChange:self.currReply];
  }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    return [self createTriggerCell];
  } else {
    return [self createResponseCell];
  }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    return 50;
  } else {
    return 100;
  }
}
#pragma mark - Cell Helpers

- (UITableViewCell*)createTriggerCell {
  UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  UILabel *triggerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 70, 50)];
  triggerLabel.text = @"Trigger:";
  UITextField *triggerField = [[UITextField alloc] initWithFrame:CGRectMake(80, 9, self.view.frame.size.width-80, 35)];
  triggerField.returnKeyType = UIReturnKeyDone;
  triggerField.font = [UIFont systemFontOfSize:16];
  triggerField.text = self.currReply.trigger;
  triggerField.delegate = self;
  
  [cell.contentView addSubview:triggerLabel];
  [cell.contentView  addSubview:triggerField];
  return cell;
}

- (UITableViewCell*)createResponseCell {
  UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  UILabel *responseLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 50)];
  responseLabel.text = @"Response:";
  UITextView *responseField = [[UITextView alloc] initWithFrame:CGRectMake(95, 8, self.view.frame.size.width-100, 80)];
  responseField.font = [UIFont systemFontOfSize:16];
  responseField.text = self.currReply.response;
  responseField.delegate = self;
  
  [cell.contentView addSubview:responseLabel];
  [cell.contentView  addSubview:responseField];
  return cell;
}

#pragma mark - UI Delegates

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  self.didChange = YES;
  NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
  self.currReply.trigger = newString;
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  self.didChange = YES;
  NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
  self.currReply.response = newString;
  return YES;
}

#pragma mark - Helpers

- (NSString*)getHelpMessage {
  return @"Trigger: The command that will trigger the custom reply. You may use wildcards in the trigger by using (.*). For example, '(.*)turn on the lights' will trigger on \"Turn on the lights\", \"Siri turn on the lights\", \"Hey Siri please turn on the lights\", etc.\n"
  "\nResponse: What Siri will say in reponse to the trigger.\n";
}

@end
