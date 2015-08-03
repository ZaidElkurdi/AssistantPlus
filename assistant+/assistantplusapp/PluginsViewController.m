//
//  PluginsViewController.m
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 4/1/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "PluginsViewController.h"

#import "SpotifyAuthenticationViewController.h"

@implementation PluginsViewController {
  NSArray *installedPlugins;
}

- (id)initWithInstalledPlugins:(NSArray *)plugins {
  if (self = [super init]) {
    installedPlugins = plugins;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.pluginsTable = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
  self.pluginsTable.delegate = self;
  self.pluginsTable.dataSource = self;
  self.pluginsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
  [self.view addSubview:self.pluginsTable];
  
  UIColor *backgroundColor = [UIColor colorWithWhite:.9f alpha:1.0];
  self.pluginsTable.backgroundColor = backgroundColor;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.pluginsTable deselectRowAtIndexPath:[self.pluginsTable indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *currPlugin = [installedPlugins objectAtIndex:indexPath.row];
  NSString *pluginName = currPlugin[@"name"];
  NSString *authorName = currPlugin[@"author"];
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pluginCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"pluginCell"];
    if ([pluginName isEqualToString:@"Spotify Control"]) {
      cell.selectionStyle = UITableViewCellSelectionStyleGray;
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      cell.userInteractionEnabled = YES;
    } else {
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.accessoryType = UITableViewCellAccessoryNone;
      cell.userInteractionEnabled = NO;
    }
  }

  cell.textLabel.text = pluginName;
  cell.detailTextLabel.text = authorName;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  SpotifyAuthenticationViewController *authVC = [[SpotifyAuthenticationViewController alloc] init];
 [self.navigationController pushViewController:authVC animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return installedPlugins.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 60.0f;
}

@end
