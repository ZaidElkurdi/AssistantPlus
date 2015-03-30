//
//  CustomRepliesViewController.h
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 3/25/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCustomReply.h"
#import "CustomReplyDetailViewController.h"

@interface CustomRepliesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CustomRepliesDelegate>
@property (nonatomic, strong) UITableView *repliesTableView;
@end
