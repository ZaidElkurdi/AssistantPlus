//
//  CustomReplyDetailViewController.h
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 3/25/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCustomReply.h"

@protocol CustomRepliesDelegate <NSObject>
- (void)customReplyDidChange:(APCustomReply*)reply;
@end

@interface CustomReplyDetailViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>
- (id)initWithCustomReply:(APCustomReply*)reply;
@property (weak) id<CustomRepliesDelegate> delegate;
@end
