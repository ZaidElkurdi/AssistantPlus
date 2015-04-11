//
//  ActivatorListenersViewController.m
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 3/22/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "ActivatorListenersViewController.h"
#import "APActivatorListener.h"
#import "CPDistributedMessagingCenter.h"

@interface ActivatorListenersViewController ()

@end

@implementation ActivatorListenersViewController {
  NSMutableArray *savedListeners;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.title = @"Listeners";
  
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewListener:)];
  [self.navigationItem setRightBarButtonItem:addButton];
  
  self.listenersTable = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
  self.listenersTable.delegate = self;
  self.listenersTable.dataSource = self;
  
  UIView *msgView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 130)];
  UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 60)];
  msgLabel.lineBreakMode = NSLineBreakByWordWrapping;
  msgLabel.numberOfLines = 0;
  msgLabel.text = @"You must respring your device before listeners you delete here will be removed from Activator";
  msgLabel.textAlignment = NSTextAlignmentCenter;
  msgLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
  msgLabel.textColor = [UIColor darkGrayColor];
  [msgView addSubview:msgLabel];
  
  UIButton *respringButton = [UIButton buttonWithType:UIButtonTypeSystem];
  respringButton.frame = CGRectMake(0, 70, self.view.frame.size.width, 40);
  [respringButton addTarget:self action:@selector(respringPressed:) forControlEvents:UIControlEventTouchUpInside];
  [respringButton setTitle:@"Respring" forState:UIControlStateNormal];
  respringButton.titleLabel.font = [UIFont systemFontOfSize:18];
  
  [msgView addSubview:respringButton];
  self.listenersTable.tableFooterView = msgView;
  
  UIColor *backgroundColor = [UIColor colorWithWhite:.9f alpha:1.0];
  self.listenersTable.backgroundColor = backgroundColor;
  
  [self.view addSubview:self.listenersTable];
  
  [self loadListenersFromFile];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if ([self.listenersTable indexPathForSelectedRow]) {
    [self.listenersTable deselectRowAtIndexPath:[self.listenersTable indexPathForSelectedRow] animated:YES];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)loadListenersFromFile {
  savedListeners = [[NSMutableArray alloc] init];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ([defaults objectForKey:@"activatorListeners"]) {
    NSArray *listeners = [defaults objectForKey:@"activatorListeners"];
    for (NSDictionary *currListener in listeners) {
      APActivatorListener *listener = [[APActivatorListener alloc] initWithDictionary:currListener];
      [savedListeners addObject:listener];
    }
  }
  
}

- (void)saveListenersToFile {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *toSave = [[NSMutableArray alloc] init];
  if (savedListeners) {
    for (APActivatorListener *currListener in savedListeners) {
      [toSave addObject:[currListener dictionaryRepresentation]];
    }
    [defaults setObject:toSave forKey:@"activatorListeners"];
    [defaults synchronize];
  }
  
#if !(TARGET_IPHONE_SIMULATOR)
  CPDistributedMessagingCenter* center = [CPDistributedMessagingCenter centerNamed:@"com.zaid.applus.springboard"];
  [center sendMessageName:@"UpdateActivatorListeners" userInfo:@{@"activatorListeners" : toSave}];
#endif
}

#pragma mark - Button Handlers

- (void)addNewListener:(id)sender {
  APActivatorListener *newListener = [[APActivatorListener alloc] init];
  newListener.uniqueId = [NSString stringWithFormat:@"%@", [NSDate date]];
  [savedListeners addObject:newListener];
  NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:savedListeners.count-1 inSection:0];
  
  [CATransaction begin];
  [self.listenersTable beginUpdates];
  [CATransaction setCompletionBlock: ^{
      [self tableView:self.listenersTable didSelectRowAtIndexPath:newIndexPath];
  }];
  [self.listenersTable insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.listenersTable endUpdates];
  [CATransaction commit];
  
}

- (void)respringPressed:(UIButton*)button {
#if !(TARGET_IPHONE_SIMULATOR)
  CPDistributedMessagingCenter* center = [CPDistributedMessagingCenter centerNamed:@"com.zaid.applus.springboard"];
  [center sendMessageName:@"respringForListeners" userInfo:nil];
#endif
}

#pragma mark - UITableViewDataSource

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listenerCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"optionsCell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  APActivatorListener *currListener = [savedListeners objectAtIndex:indexPath.row];
  cell.textLabel.text = currListener.name.length > 0 ? currListener.name : @"Untitled Listener";
  
  NSMutableString *detailString = [NSMutableString string];
  for (NSInteger currIndex = 0; currIndex < currListener.triggers.count; currIndex++) {
    NSString *currTrigger = currListener.triggers[currIndex];
    NSString *format = currIndex == currListener.triggers.count-1 ? @"%@" : @"%@, ";
    [detailString appendString:[NSString stringWithFormat:format, currTrigger.length > 0 ? currTrigger : @"Empty Trigger"]];
  }
  cell.detailTextLabel.text = detailString.length > 0 ? detailString : @"No Trigger Yet";
  
  return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  APActivatorListener *selectedListener = [savedListeners objectAtIndex:indexPath.row];
  ListenerDetailViewController *detailVC = [[ListenerDetailViewController alloc] initWithListener:selectedListener];
  detailVC.delegate = self;
  [self.navigationController pushViewController:detailVC animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return savedListeners.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    APActivatorListener *toDelete = [savedListeners objectAtIndex:indexPath.row];
    [savedListeners removeObject:toDelete];
    [self saveListenersToFile];
    [self.listenersTable reloadData];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 60;
}

#pragma mark - ListenerDelegate

- (void)listenerDidChange:(APActivatorListener *)listener {
  for (NSInteger currIndex = 0; currIndex < savedListeners.count; currIndex++) {
    APActivatorListener *currListener = [savedListeners objectAtIndex:currIndex];
    if ([currListener.uniqueId isEqualToString:currListener.uniqueId]) {
      [savedListeners replaceObjectAtIndex:currIndex withObject:currListener];
      break;
    }
  }
  
  [self saveListenersToFile];
  [self.listenersTable reloadData];
}


@end
