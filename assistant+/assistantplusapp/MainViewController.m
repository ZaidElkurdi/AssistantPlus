#import "MainViewController.h"
#import "ActivatorListenersViewController.h"
#import "CustomRepliesViewController.h"
#import "CPDistributedMessagingCenter.h"
#import "PluginsViewController.h"

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"Assistant+";
  
  self.optionsTable = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
  self.optionsTable.delegate = self;
  self.optionsTable.dataSource = self;
  
  UIView *copyrightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
  UILabel *copyrightLabel = [[UILabel alloc] initWithFrame:copyrightView.frame];
  copyrightLabel.text = @"© 2015 Zaid Elkurdi";
  copyrightLabel.textAlignment = NSTextAlignmentCenter;
  [copyrightView addSubview:copyrightLabel];
  self.optionsTable.tableFooterView = copyrightView;
  
  UIColor *backgroundColor = [UIColor colorWithWhite:.9f alpha:1.0];
  self.optionsTable.backgroundColor = backgroundColor;
  
  [self.view addSubview:self.optionsTable];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if ([self.optionsTable indexPathForSelectedRow]) {
    [self.optionsTable deselectRowAtIndexPath:[self.optionsTable indexPathForSelectedRow] animated:YES];
  }
}


#pragma mark - UITableViewDataSource

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"optionsCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"optionsCell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  NSString *cellTitle = @"";
  switch (indexPath.section) {
    case 0:
      cellTitle = @"Activator Listeners";
      break;
    case 1:
      cellTitle = @"Custom Replies";
      break;
    case 2:
      cellTitle = @"Installed Plugins";
    default:
      break;
  }
  
  cell.textLabel.text = cellTitle;
  return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 3;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return 6.0;
  }
  
  return 1.0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
  return 5.0;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
  return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section {
  return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.section) {
    case 0:
      [self goToNewVC:[[ActivatorListenersViewController alloc] init]];
      break;
    case 1:
      [self goToNewVC:[[CustomRepliesViewController alloc] init]];
      break;
    case 2: {
      CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"com.zaid.applus.springboard"];
      NSDictionary *installed = [center sendMessageAndReceiveReplyName:@"getInstalledPlugins" userInfo:nil];
      [self goToNewVC:[[PluginsViewController alloc] initWithInstalledPlugins:installed[@"plugins"]]];
      break; }
    default:
      break;
  }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 60.0f;
}

#pragma mark - Navigation

- (void)goToNewVC:(UIViewController*)vc {
  [self.navigationController pushViewController:vc animated:YES];
}


@end
