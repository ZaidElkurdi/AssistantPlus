//
//  PluginsViewController.m
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 4/1/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "PluginsViewController.h"

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pluginCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"pluginCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }

  NSDictionary *currPlugin = [installedPlugins objectAtIndex:indexPath.row];
  cell.textLabel.text = currPlugin[@"name"];
  cell.detailTextLabel.text = currPlugin[@"author"];
  return cell;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return installedPlugins.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 60.0f;
}

@end
