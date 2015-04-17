//
//  CaptureGroupCommandsViewController.m
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 4/14/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "CaptureGroupCommandsViewController.h"
#import "APCaptureGroupCommand.h"
#import "CPDistributedMessagingCenter.h"

@interface CaptureGroupCommandsViewController ()
@property (strong, nonatomic) UITableView *commandsTable;
@end

@implementation CaptureGroupCommandsViewController {
  NSMutableArray *savedCommands;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.title = @"Commands";
  
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewCommand:)];
  [self.navigationItem setRightBarButtonItem:addButton];
  
  self.commandsTable = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
  self.commandsTable.delegate = self;
  self.commandsTable.dataSource = self;
  self.commandsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

  UIColor *backgroundColor = [UIColor colorWithWhite:.9f alpha:1.0];
  self.commandsTable.backgroundColor = backgroundColor;
  
  [self.view addSubview:self.commandsTable];
  
  [self loadCommandsFromFile];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if ([self.commandsTable indexPathForSelectedRow]) {
    [self.commandsTable deselectRowAtIndexPath:[self.commandsTable indexPathForSelectedRow] animated:YES];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)loadCommandsFromFile {
  savedCommands = [[NSMutableArray alloc] init];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ([defaults objectForKey:@"captureGroupCommands"]) {
    NSArray *commands = [defaults objectForKey:@"captureGroupCommands"];
    for (NSDictionary *currCommand in commands) {
      APCaptureGroupCommand *command = [[APCaptureGroupCommand alloc] initWithDictionary:currCommand];
      [savedCommands addObject:command];
    }
  }
}

- (void)saveCommandsToFile {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *toSave = [[NSMutableArray alloc] init];
  if (savedCommands) {
    for (APCaptureGroupCommand *currCommand in savedCommands) {
      [toSave addObject:[currCommand dictionaryRepresentation]];
    }
    [defaults setObject:toSave forKey:@"captureGroupCommands"];
    [defaults synchronize];
  }
  
#if !(TARGET_IPHONE_SIMULATOR)
  NSLog(@"Sending back to springobard!");
  CPDistributedMessagingCenter* center = [CPDistributedMessagingCenter centerNamed:@"com.zaid.applus.springboard"];
  [center sendMessageName:@"UpdateCaptureGroupCommands" userInfo:@{@"captureGroupCommands" : toSave}];
#endif
}

#pragma mark - Button Handlers

- (void)addNewCommand:(id)sender {
  APCaptureGroupCommand *newCommand = [[APCaptureGroupCommand alloc] init];
  [savedCommands addObject:newCommand];
  
  NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:savedCommands.count-1 inSection:0];
  
  [CATransaction begin];
  [self.commandsTable beginUpdates];
  [CATransaction setCompletionBlock: ^{
    [self tableView:self.commandsTable didSelectRowAtIndexPath:newIndexPath];
  }];
  [self.commandsTable insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.commandsTable endUpdates];
  [CATransaction commit];
  
}

#pragma mark - UITableViewDataSource

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commandCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"commandCell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  APCaptureGroupCommand *currCommand = [savedCommands objectAtIndex:indexPath.row];
  cell.textLabel.text = currCommand.name.length > 0 ? currCommand.name : @"Untitled Command";
  cell.detailTextLabel.text = currCommand.trigger.length > 0 ? currCommand.trigger : @"No Trigger Yet";
  
  return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  APCaptureGroupCommand *selectedCommand = [savedCommands objectAtIndex:indexPath.row];
  CaptureGroupCommandDetailViewController *detailVC = [[CaptureGroupCommandDetailViewController alloc] initWithCommand:selectedCommand];
  detailVC.delegate = self;
  [self.navigationController pushViewController:detailVC animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return savedCommands.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    APCaptureGroupCommand *toDelete = [savedCommands objectAtIndex:indexPath.row];
    [savedCommands removeObject:toDelete];
    [self saveCommandsToFile];
    
    [self.commandsTable beginUpdates];
    [self.commandsTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.commandsTable endUpdates];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 60;
}

#pragma mark - CommandDelegate

- (void)commandDidChange:(APCaptureGroupCommand *)command{
  for (NSInteger currIndex = 0; currIndex < savedCommands.count; currIndex++) {
    APCaptureGroupCommand *currCommand = [savedCommands objectAtIndex:currIndex];
    if ([currCommand.uuid isEqualToString:command.uuid]) {
      NSLog(@"Replacing %@", currCommand);
      [savedCommands replaceObjectAtIndex:currIndex withObject:currCommand];
      break;
    }
  }
  
  [self saveCommandsToFile];
  [self.commandsTable reloadData];
}

@end
