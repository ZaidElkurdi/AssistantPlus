//
//  spotifySongListViewController.m
//  spotifyPlugin
//
//  Created by Zaid Elkurdi on 3/28/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "spotifySongListViewController.h"
#import "spotifySongTableViewCell.h"

@implementation spotifySongListViewController {
  NSArray *songsToDisplay;
}

-(id)initWithProperties:(NSDictionary*)props {
  if (self = [super init]) {
    songsToDisplay = [props objectForKey:@"songs"];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, (77*MIN(songsToDisplay.count, 10))+40);
  self.songsTable = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
  self.songsTable.delegate = self;
  self.songsTable.dataSource = self;
  self.songsTable.backgroundColor = [UIColor clearColor];
  self.songsTable.layoutMargins = UIEdgeInsetsZero;
  [self.view addSubview:self.songsTable];
}

-(double)desiredHeightForWidth:(double)height {
  return self.view.frame.size.height;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *selectedSong = [songsToDisplay objectAtIndex:indexPath.row];
  NSString *href = selectedSong[@"href"];
  [[UIApplication sharedApplication]openURL:[NSURL URLWithString:href]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 77;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  SpotifySongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"songCell"];
  
  if (!cell) {
    NSBundle *pluginBundle = [NSBundle bundleWithPath:@"/Library/AssistantPlusPlugins/spotifySiri.assistantPlugin"];
    [tableView registerNib:[UINib nibWithNibName:@"SpotifySongTableViewCell" bundle:pluginBundle] forCellReuseIdentifier:@"songCell"];
    cell = [tableView dequeueReusableCellWithIdentifier:@"songCell"];
  }
  cell.backgroundColor = [UIColor clearColor];
  NSDictionary *currSong = [songsToDisplay objectAtIndex:indexPath.row];
  NSLog(@"Curr song: %@", currSong);
  cell.songTitleLabel.text = currSong[@"name"];
  cell.songDetailLabel.text = [NSString stringWithFormat:@"%@ - %@", currSong[@"artists"][0][@"name"], currSong[@"album"][@"name"]];
  cell.layoutMargins = UIEdgeInsetsZero;
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return MIN(10, songsToDisplay.count);
}

@end
