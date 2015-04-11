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
@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *mutableTriggers;
@property (nonatomic) BOOL didChange;
@end

@implementation ListenerDetailViewController

- (id)initWithListener:(APActivatorListener*)listener {
  if (self = [super init]) {
    self.currListener = listener;
    self.didChange = NO;
    self.mutableTriggers = listener.triggers.count > 0 ? [listener.triggers mutableCopy] : [NSMutableArray arrayWithObject:@""];
    NSLog(@"Triggers: %@", self.mutableTriggers);
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  UIColor *backgroundColor = [UIColor colorWithWhite:.9f alpha:1.0];
  self.view.backgroundColor = backgroundColor;
  
  self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
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
  
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewTrigger:)];
  [self.navigationItem setRightBarButtonItem:addButton];
  
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
    self.currListener.triggers = self.mutableTriggers;
    self.currListener.name = self.nameField.text;
    [self.delegate listenerDidChange:self.currListener];
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 1) {
    if (self.mutableTriggers.count == 0) {
    NSLog(@"Returing: 2!");
      return 2;
    } else {
      NSLog(@"Returing: %ld", 1 + (long)self.mutableTriggers.count);
      return 1 + self.mutableTriggers.count;
    }
  }
  return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
   return [self createSwitchCell];
  }
  
  if (indexPath.row == 0) {
    return [self createNameCell];
  } else {
    return [self createTriggerCellForIndex:indexPath.row-1];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 50;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return @"";
}

#pragma mark - Cell Helpers

- (UITableViewCell*)createSwitchCell {
  UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  UISwitch *enabledSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(85, 9.5, 51, 31)];
  [enabledSwitch addTarget:self action:@selector(didToggleSwitch:) forControlEvents:UIControlEventValueChanged];
  enabledSwitch.tag = 117;
  enabledSwitch.on = self.currListener.enabled;
  
  UILabel *enabledSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 50)];
  enabledSwitchLabel.text = @"Enabled:";
  
  CGFloat viewWidth = self.view.frame.size.width;
  
  UISwitch *passthroughSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(viewWidth-61, 9.5, 51, 31)];
  [passthroughSwitch addTarget:self action:@selector(didToggleSwitch:) forControlEvents:UIControlEventValueChanged];
  passthroughSwitch.on = self.currListener.willPassthrough;
  
  CGFloat passthroughSwitchXOrigin = passthroughSwitch.frame.origin.x;
  
  UILabel *passthroughSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(passthroughSwitchXOrigin-110, 0, 110, 50)];
  passthroughSwitchLabel.text = @"Passthrough:";
  
  [cell.contentView addSubview:enabledSwitchLabel];
  [cell.contentView  addSubview:passthroughSwitchLabel];
  [cell.contentView  addSubview:enabledSwitch];
  [cell.contentView  addSubview:passthroughSwitch];
  return cell;
}

- (UITableViewCell*)createNameCell {
  UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 50)];
  nameLabel.text = @"Name:";
  UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectMake(80, 2, self.view.frame.size.width-60, 50)];
  nameField.text = self.currListener.name;
  nameField.delegate = self;
  nameField.tag = -1;
  nameField.returnKeyType = UIReturnKeyDone;
  
  self.nameField = nameField;
  
  [cell.contentView addSubview:nameLabel];
  [cell.contentView  addSubview:nameField];
  return cell;
}

- (UITableViewCell*)createTriggerCellForIndex:(NSInteger)index {
  NSLog(@"Getting cell for index: %ld", (long)index);
  UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  UIView *triggerBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 230, self.view.frame.size.width, 100)];
  triggerBackground.backgroundColor = [UIColor whiteColor];
  UILabel *triggerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 70, 50)];
  triggerLabel.text = @"Trigger:";
  UITextField *triggerField = [[UITextField alloc] initWithFrame:CGRectMake(80, 8, self.view.frame.size.width-80, 35)];
  triggerField.returnKeyType = UIReturnKeyDone;
  triggerField.font = [UIFont systemFontOfSize:16];
  if (index < self.currListener.triggers.count) {
    triggerField.text = self.currListener.triggers[index];
  }
  
  triggerField.delegate = self;
  triggerField.tag = index;
  [cell.contentView addSubview:triggerLabel];
  [cell.contentView  addSubview:triggerField];
  return cell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 1)) {
    return NO;
  }
  return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    [self.mutableTriggers removeObjectAtIndex:indexPath.row-1];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    self.didChange = YES;
  }
}

#pragma mark - UI Delegates

- (void)addNewTrigger:(id)sender {
  [self.mutableTriggers addObject:@""];
  NSLog(@"Mutable triggers: %@", self.mutableTriggers);
  NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:self.mutableTriggers.count inSection:1];
  
  [self.tableView beginUpdates];
  [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

- (void)didToggleSwitch:(UISwitch*)theSwitch {
  self.didChange = YES;
  
  if (theSwitch.tag == 117) {
    self.currListener.enabled = theSwitch.on;
  } else {
    self.currListener.willPassthrough = theSwitch.on;
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  self.didChange = YES;
  if (textField.tag >= 0) {
    [self.mutableTriggers setObject:[textField.text stringByReplacingCharactersInRange:range withString:string] atIndexedSubscript:textField.tag];
  }
  return  YES;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - Helpers

- (NSString*)getHelpMessage {
  return @"Enabled: For a listener to appear in Activator it must be enabled\n"
          "\nPassthrough: If enabled, Assistant+ will continue searching for another Activator listener, custom reply, or plugin to handle the command. If it doesn't find anything to handle the command, Siri will go to its default action. You can add a voice confirmation for your Activator listener if you create a custom reply for the same trigger and then enable passthrough for your listener\n"
          "\nName: A name to describe your listener. This can be anything and is purely for informational purposes\n"
          "\nTrigger: The command that will trigger the Activator listener, you must have at least one for the listener to appear in Activator. You may use wildcards in the trigger by using (.*). For example, '(.*)turn on the lights' will trigger on \"Turn on the lights\", \"Siri turn on the lights\", \"Hey Siri please turn on the lights\", etc.\n"
          "\nOnce you create an Activator listener here you must go to Activator and assign it to an event.";
}

@end
