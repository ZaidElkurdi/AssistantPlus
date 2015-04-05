//
//  PluginsViewController.h
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 4/1/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PluginsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *pluginsTable;
- (id)initWithInstalledPlugins:(NSArray*)plugins;
@end
