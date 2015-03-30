//
//  CustomRepliesViewController.m
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 3/25/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "CustomRepliesViewController.h"
#import "APCustomReply.h"
#import "CPDistributedMessagingCenter.h"

@interface CustomRepliesViewController ()

@end

@implementation CustomRepliesViewController {
  NSMutableArray *savedReplies;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewReply:)];

  [self.navigationItem setRightBarButtonItem:addButton];
  
  self.repliesTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
  self.repliesTableView.delegate = self;
  self.repliesTableView.dataSource = self;
  self.repliesTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
  
  UIColor *backgroundColor = [UIColor colorWithWhite:.9f alpha:1.0];
  self.repliesTableView.backgroundColor = backgroundColor;
  
  [self.view addSubview:self.repliesTableView];
  
  [self loadRepliesFromFile];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if ([self.repliesTableView indexPathForSelectedRow]) {
    [self.repliesTableView deselectRowAtIndexPath:[self.repliesTableView indexPathForSelectedRow] animated:YES];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)loadRepliesFromFile {
  savedReplies = [[NSMutableArray alloc] init];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if ([defaults objectForKey:@"customReplies"]) {
    NSArray *replies = [defaults objectForKey:@"customReplies"];
    NSLog(@"Serialized replies: %@", replies);
    for (NSDictionary *currReply in replies) {
      APCustomReply *reply = [[APCustomReply alloc] initWithDictionary:currReply];
      [savedReplies addObject:reply];
    }
  }
}

- (void)saveRepliesToFile {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if (savedReplies) {
    NSMutableArray *toSave = [[NSMutableArray alloc] init];
    for (APCustomReply *currReply in savedReplies) {
      NSLog(@"Saving: %@ %@", currReply.trigger, currReply.response);
      [toSave addObject:[currReply dictionaryRepresentation]];
    }
    
    [defaults setObject:toSave forKey:@"customReplies"];
    [defaults synchronize];
    
    CPDistributedMessagingCenter* center = [CPDistributedMessagingCenter centerNamed:@"com.zaid.applus.springboard"];
    [center sendMessageName:@"UpdateCustomReplies" userInfo:@{@"customReplies" : toSave}];
  }
  
  NSLog(@"Saved replies is: %@", savedReplies);
}

#pragma mark - Reply Creation

- (void)addNewReply:(id)sender {
  APCustomReply *newReply = [[APCustomReply alloc] init];
  [savedReplies addObject:newReply];
  NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:savedReplies.count-1 inSection:0];
  
  [CATransaction begin];
  [self.repliesTableView beginUpdates];
  [CATransaction setCompletionBlock: ^{
    [self tableView:self.repliesTableView didSelectRowAtIndexPath:newIndexPath];
  }];
  [self.repliesTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.repliesTableView endUpdates];
  [CATransaction commit];
  
}

#pragma mark - UITableViewDataSource

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listenerCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"optionsCell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  APCustomReply *currReply = [savedReplies objectAtIndex:indexPath.row];
  cell.textLabel.text = currReply.trigger.length > 0 ? currReply.trigger : @"No Trigger Yet";
  cell.detailTextLabel.text = currReply.response.length > 0 ? currReply.response : @"No Response Yet";
  return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  APCustomReply *selectedReply = [savedReplies objectAtIndex:indexPath.row];
  CustomReplyDetailViewController *detailVC = [[CustomReplyDetailViewController alloc] initWithCustomReply:selectedReply];
  detailVC.delegate = self;
  [self.navigationController pushViewController:detailVC animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return savedReplies.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 60;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    APCustomReply *toDelete = [savedReplies objectAtIndex:indexPath.row];
    [savedReplies removeObject:toDelete];
    [self saveRepliesToFile];
    [self.repliesTableView reloadData];
  }
}

#pragma mark - CustomReplyDelegate

- (void)customReplyDidChange:(APCustomReply *)reply {
  for (NSInteger currIndex = 0; currIndex < savedReplies.count; currIndex++) {
    APCustomReply *currReply = [savedReplies objectAtIndex:currIndex];
    if ([currReply.uuid isEqualToString:reply.uuid]) {
      [savedReplies replaceObjectAtIndex:currIndex withObject:currReply];
      break;
    }
  }
  
  [self saveRepliesToFile];
  [self.repliesTableView reloadData];
}

@end
