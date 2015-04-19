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
  
  UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectMake(80, 2, self.view.frame.size.width-80, 50)];
  nameField.delegate = self;
  nameField.tag = -1;
  nameField.returnKeyType = UIReturnKeyDone;
  nameField.adjustsFontSizeToFitWidth = YES;
  nameField.minimumFontSize = 3.0f;
  
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
    nameField.autocorrectionType = UITextAutocorrectionTypeNo;
    nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
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
  
  UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectMake(10, 2, self.view.frame.size.width-200, 50)];
  nameField.delegate = self;
  nameField.tag = 100+index;
  nameField.returnKeyType = UIReturnKeyDone;
  nameField.adjustsFontSizeToFitWidth = YES;
  nameField.minimumFontSize = 8.0f;
  nameField.placeholder = @"Unnamed Variable";
  
  
  
  NSString *variableName = self.mutableVariables[index][0];
  
  if (variableName.length > 0) {
    nameField.text = variableName;
  } else {
    nameField.text = @"";
  }
  
  CGFloat nameFieldEnd = nameField.frame.origin.x + nameField.frame.size.width;
  UILabel *escapeLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameFieldEnd+15, 1, 110, 50)];
  escapeLabel.text = @"URL Encode:";

  CGFloat escapeLabelEnd = escapeLabel.frame.origin.x + escapeLabel.frame.size.width;
  UISwitch *escapeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(escapeLabelEnd+5, 9.5, 51, 31)];
  [escapeSwitch addTarget:self action:@selector(didToggleSwitch:) forControlEvents:UIControlEventValueChanged];
  escapeSwitch.tag = index;
  
  BOOL enabled = [self.mutableVariables[index][1] boolValue];
  escapeSwitch.on = enabled;
  
  [cell.contentView addSubview:nameField];
  [cell.contentView addSubview:escapeLabel];
  [cell.contentView addSubview:escapeSwitch];
  
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

- (void)didToggleSwitch:(UISwitch*)theSwitch {
  self.didChange = YES;
  self.mutableVariables[theSwitch.tag] = @[self.mutableVariables[theSwitch.tag][0], [NSNumber numberWithBool:theSwitch.on]];
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
  for (NSArray *currVariable in self.mutableVariables) {
    NSString *name = currVariable[0];
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
    [self.mutableVariables addObject:@[@"", [NSNumber numberWithBool:NO]]];
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
  NSString *variableName = [self.mutableVariables objectAtIndex:buttonIndex-1][0];
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
    [self.mutableVariables setObject:@[newText, self.mutableVariables[textField.tag-100][1]] atIndexedSubscript:textField.tag-100];
  } else if (textField == self.nameField) {
    self.currCommand.name = newText;
  } else if (textField == self.triggerField) {
    self.currCommand.trigger = newText;
  } else if (textField == self.commandField) {
    self.currCommand.command = newText;
  }
  return  YES;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - Helpers

- (NSString*)getHelpMessage {
  return @"Name: A name to describe your capture group command. This can be anything and is purely for informational purposes\n"
  "\nTrigger: The command that will trigger the capture group command. In order to capture what the user says and assign it to a variable you must surround the variable's name in square brackets. For example, if 'Search for [query] on Yelp' were your trigger, then the command 'Search for Italian Restaurants on Yelp' would assign 'Italian Restaurants' to the 'query' variable. This field also supports NSRegularExpression syntax, with the only difference being the capture group syntax.\n"
  "\nVariables: The variables that are involved in your capture group command. In order to capture a variable in your trigger you must first create one with the same name.\n"
  "\nURL Encode: If you enable this option your variable will be percent encoded. This is useful if you intend to use your variable as an argument in a network call or with uiopen.\n"
  "\nConditionals: A conditional can be used to assign a value to a variable based on the value of another (or the same) variable. Conditionals are evaluated after your capture group command is triggered and the initial variable values have been captured. Remember that all values will be compared as strings, so \"5.0\" will not equal \"5\".\n"
  "\nCommand: The shell command that will be executed when your capture group command is triggered. In order to use variables in this command you must follow the same syntax as the trigger and surround the variable's name with square brackets. Following the example in the trigger description, 'uiopen yelp:///search?terms=[query]' will evaluate to 'uiopen yelp:///search?terms=italian%20restaurants'.";
}

@end
