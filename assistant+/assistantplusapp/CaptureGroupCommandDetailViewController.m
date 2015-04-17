//
//  CaptureGroupCommandDetailViewController.m
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 4/14/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "CaptureGroupCommandDetailViewController.h"

typedef enum {
  APNameCell    = 1,
  APTriggerCell = 2,
  APCommandCell = 3
} APTextCellType;

typedef enum {
  APWhenValue    = 1,
  APSetValue = 2,
} APConditionalEditingType;

@interface CaptureGroupCommandDetailViewController ()
@property (strong, nonatomic) APCaptureGroupCommand *currCommand;
@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) UITextField *triggerField;
@property (strong, nonatomic) UITextField *commandField;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *mutableVariables;
@property (strong, nonatomic) NSMutableArray *mutableConditionals;
@property (nonatomic) BOOL didChange;
@property (nonatomic) NSInteger conditionalToEdit;
@property (nonatomic) APConditionalEditingType editingType;
@end

@implementation CaptureGroupCommandDetailViewController

- (id)initWithCommand:(APCaptureGroupCommand*)command {
  if (self = [super init]) {
    self.currCommand = command;
    self.mutableVariables = command.variables ? [command.variables mutableCopy] : [NSMutableArray array];
    
    if (command.conditionals && command.conditionals.count > 0) {
      self.mutableConditionals = [[NSMutableArray alloc] init];
      for (NSArray *currConditional in command.conditionals) {
        [self.mutableConditionals addObject:[currConditional mutableCopy]];
      }
    } else {
      self.mutableConditionals = [NSMutableArray array];
    }
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  UIColor *backgroundColor = [UIColor colorWithWhite:.9f alpha:1.0];
  self.view.backgroundColor = backgroundColor;
  
  self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  
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
  
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPressed:)];
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
    self.currCommand.conditionals = self.mutableConditionals;
    self.currCommand.trigger = self.triggerField.text;
    self.currCommand.variables = self.mutableVariables;
    self.currCommand.name = self.nameField.text;
    self.currCommand.command = self.commandField.text;
    [self.delegate commandDidChange:self.currCommand];
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return 1;
  } else if (section == 1) {
    return 1;
  } else if (section == 2) {
    return self.mutableVariables.count;
  } else if (section == 3) {
    return self.mutableConditionals.count;
  } else {
    return 1;
  }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    return [self createTextCell:APNameCell];
  } else if (indexPath.section == 1) {
    return [self createTextCell:APTriggerCell];
  } else if (indexPath.section == 2) {
    return [self createVariableCellForIndex:indexPath.row];
  } else if (indexPath.section == 3) {
    return [self createConditionalCellForIndex:indexPath.row];
  } else if (indexPath.section == 4) {
    return [self createTextCell:APCommandCell];
  }
  
  return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 3) {
    return 200;
  }
  
  return 50;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  switch (section) {
    case 0:
      return @"";
      break;
    case 1:
      return @"";
    case 2:
      return @"Variables";
    case 3:
      return @"Conditionals";
    case 4:
      return @"Command";
    default:
      return @"";
  }
}

#pragma mark - Cell Helpers

- (UITableViewCell*)createTextCell:(APTextCellType)cellType {
  UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 50)];
  
  UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectMake(80, 2, self.view.frame.size.width-60, 50)];
  nameField.delegate = self;
  nameField.tag = -1;
  nameField.returnKeyType = UIReturnKeyDone;
  
  if (cellType == APNameCell) {
    nameLabel.text = @"Name:";
    nameField.text = self.currCommand.name;
    self.nameField = nameField;
    
    CGRect oldFrame = self.nameField.frame;
    oldFrame.origin.x = 70;
    oldFrame.size.width = self.view.frame.size.width - 70;
    nameField.frame = oldFrame;
    self.nameField.frame = oldFrame;
  } else if (cellType == APTriggerCell) {
    nameLabel.text = @"Trigger:";
    nameField.text = self.currCommand.trigger;
    self.triggerField = nameField;
  } else if (cellType == APCommandCell) {
    nameLabel.hidden = YES;
    nameField.text = self.currCommand.command;
    self.commandField = nameField;
    
    CGRect oldFrame = self.commandField.frame;
    oldFrame.origin.x = 5;
    oldFrame.size.width = self.view.frame.size.width - 5;
    self.commandField.frame = oldFrame;
  }
  
  [cell.contentView addSubview:nameLabel];
  [cell.contentView  addSubview:nameField];
  return cell;
}

- (UITableViewCell*)createVariableCellForIndex:(NSInteger)index {
  UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectMake(10, 2, self.view.frame.size.width-10, 50)];
  nameField.delegate = self;
  nameField.tag = 100+index;
  nameField.returnKeyType = UIReturnKeyDone;
  nameField.placeholder = @"Unnamed Variable";
  
  NSString *variableName = [self.mutableVariables objectAtIndex:index];
  if (variableName.length > 0) {
    nameField.text = variableName;
  } else {
    nameField.text = @"";
  }
  
  [cell.contentView addSubview:nameField];
  
  return cell;
}

- (UITableViewCell*)createConditionalCellForIndex:(NSInteger)index {
  UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  UILabel *whenlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 70, 50)];
  whenlabel.text = @"When:";
  
  UILabel *equalsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 70, 50)];
  equalsLabel.text = @"Equals:";

  UILabel *setLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 70, 50)];
  setLabel.text = @"Set:";

  UILabel *toLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, 70, 50)];
  toLabel.text = @"To:";
  
  UIButton *whenField = [UIButton buttonWithType:UIButtonTypeCustom];
  whenField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
  whenField.frame = CGRectMake(70, 2, self.view.frame.size.width-15, 50);
  whenField.tag = index;
  [whenField addTarget:self action:@selector(whenButtonPressedForIndex:) forControlEvents:UIControlEventTouchUpInside];
  
  NSString *whenVariableName = self.mutableConditionals[index][0];
  if (whenVariableName && whenVariableName.length > 0) {
    [whenField setTitle:whenVariableName forState:UIControlStateNormal];
    [whenField setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  } else {
    [whenField setTitle:@"Select Variable..." forState:UIControlStateNormal];
    [whenField setTitleColor:[UIColor colorWithWhite:0.7 alpha:1.0] forState:UIControlStateNormal];
  }
  
  UITextField *equalsField = [[UITextField alloc] initWithFrame:CGRectMake(80, 57, self.view.frame.size.width-80, 35)];
  equalsField.returnKeyType = UIReturnKeyDone;
  equalsField.font = [UIFont systemFontOfSize:17];
  equalsField.tag = 1000 + index;
  equalsField.placeholder = @"A Value";
  
  NSString *equalsValue = self.mutableConditionals[index][1];
  if (equalsValue.length > 0) {
    equalsField.text = equalsValue;
  } else {
    equalsField.text = @"";
  }
  equalsField.delegate = self;

  UIButton *setField = [UIButton buttonWithType:UIButtonTypeCustom];
  setField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
  setField.frame = CGRectMake(50, 100, self.view.frame.size.width-75, 50);
  setField.tag = index;
  [setField addTarget:self action:@selector(setButtonPressedForIndex:) forControlEvents:UIControlEventTouchUpInside];
  
  NSString *setVariableName = self.mutableConditionals[index][2];
  if (setVariableName && setVariableName.length > 0) {
    [setField setTitle:setVariableName forState:UIControlStateNormal];
    [setField setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  } else {
    [setField setTitle:@"Select Variable..." forState:UIControlStateNormal];
    [setField setTitleColor:[UIColor colorWithWhite:0.7 alpha:1.0] forState:UIControlStateNormal];
  }
  
  UITextField *toField = [[UITextField alloc] initWithFrame:CGRectMake(40, 158, self.view.frame.size.width-80, 35)];
  toField.returnKeyType = UIReturnKeyDone;
  toField.tag = 2000 + index;
  toField.font = [UIFont systemFontOfSize:17];
  toField.placeholder = @"A Value";
  
  NSString *toValue = self.mutableConditionals[index][3];
  if (toValue.length > 0) {
    toField.text = toValue;
  } else {
    toField.text = @"";
  }
  toField.delegate = self;
  
  [cell.contentView addSubview:whenlabel];
  [cell.contentView addSubview:equalsLabel];
  [cell.contentView addSubview:setLabel];
  [cell.contentView addSubview:toLabel];
  
  [cell.contentView  addSubview:equalsField];
  [cell.contentView  addSubview:toField];
  [cell.contentView  addSubview:whenField];
  [cell.contentView  addSubview:setField];
  
  return cell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 4) {
    return NO;
  }
  return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    
    if (indexPath.section == 2) {
      [self.mutableVariables removeObjectAtIndex:indexPath.row];
    } else if (indexPath.section == 3) {
      [self.mutableConditionals removeObjectAtIndex:indexPath.row];
    }
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    self.didChange = YES;
  }
}

#pragma mark - UI Delegates

- (void)addPressed:(id)sender {
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add new..." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
  [actionSheet addButtonWithTitle:@"Variable"];
  [actionSheet addButtonWithTitle:@"Conditional"];
  actionSheet.cancelButtonIndex = 0;
  actionSheet.tag = 1;
  [actionSheet showInView:self.view];
}

- (void)whenButtonPressedForIndex:(UIButton*)button {
  self.conditionalToEdit = button.tag;
  self.editingType = APWhenValue;
  [self displayVariableSelection];
}

- (void)setButtonPressedForIndex:(UIButton*)button {
  self.conditionalToEdit = button.tag;
  self.editingType = APSetValue;
  [self displayVariableSelection];
}

- (void)displayVariableSelection {
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Variable..." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
  for (NSString *name in self.mutableVariables) {
    if (name.length > 0) {
      [actionSheet addButtonWithTitle:name];
    }
  }
  actionSheet.tag = 2;
  actionSheet.cancelButtonIndex = 0;
  [actionSheet showInView:self.view];
}

- (void)addOptionsSheetClickedButtonAtIndex:(NSInteger)buttonIndex {
  NSInteger section;
  NSInteger row;
  if (buttonIndex == 1) {
    //variable
    section = 2;
    [self.mutableVariables addObject:@""];
    row = self.mutableVariables.count-1;
    
  } else if (buttonIndex == 2) {
    //conditional
    section = 3;
    [self.mutableConditionals addObject:[NSMutableArray arrayWithObjects:@"", @"", @"", @"", nil]];
    row = self.mutableConditionals.count-1;
  } else {
    //Is cancel button
    return;
  }
  
  NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:row inSection:section];
  
  [self.tableView beginUpdates];
  [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

- (void)variableSelectionSheetClickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *variableName = [self.mutableVariables objectAtIndex:buttonIndex-1];
  if (self.editingType == APSetValue) {
    [[self.mutableConditionals objectAtIndex:self.conditionalToEdit] setObject:variableName atIndexedSubscript:2];
  } else if (self.editingType == APWhenValue) {
    [[self.mutableConditionals objectAtIndex:self.conditionalToEdit] setObject:variableName atIndexedSubscript:0];
  }
  
  [self.tableView beginUpdates];
  [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.conditionalToEdit inSection:3]] withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView endUpdates];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    return;
  }
  
  if (actionSheet.tag == 1) {
    [self addOptionsSheetClickedButtonAtIndex:buttonIndex];
  } else if (actionSheet.tag == 2) {
    [self variableSelectionSheetClickedButtonAtIndex:buttonIndex];
  }
  [self.view endEditing:YES];
  self.didChange = YES;
  
 }

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  if (textField == self.commandField) {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4] atScrollPosition:UITableViewScrollPositionTop animated:YES];
  } else if (textField == self.nameField) {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
  } else if (textField == self.triggerField) {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
  }
  return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  self.didChange = YES;
  NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
  if (textField.tag - 2000 >= 0) {
    [[self.mutableConditionals objectAtIndex:textField.tag-2000] setObject:newText atIndexedSubscript:3];
  } else if (textField.tag - 1000 >= 0) {
    [[self.mutableConditionals objectAtIndex:textField.tag-1000] setObject:newText atIndexedSubscript:1];
  } else if (textField.tag - 100 >= 0) {
    [self.mutableVariables setObject:newText atIndexedSubscript:textField.tag-100];
  } else if (textField == self.nameField) {
    self.currCommand.name = newText;
  } else if (textField == self.triggerField) {
    self.currCommand.trigger = newText;
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
