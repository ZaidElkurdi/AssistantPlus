//
//  ActivatorListenersViewController.h
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 3/22/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserve.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ListenerDetailViewController.h"

@interface ActivatorListenersViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ListenerDetailDelegate>
@property (strong, nonatomic) UITableView *listenersTable;
@end