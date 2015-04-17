//
//  CaptureGroupCommandDetailViewController.h
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 4/14/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCaptureGroupCommand.h"

@protocol CommandDetailDelegate <NSObject>
- (void)commandDidChange:(APCaptureGroupCommand*)command;
@end

@interface CaptureGroupCommandDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UITextFieldDelegate>
@property (assign) id<CommandDetailDelegate> delegate;
- (id)initWithCommand:(APCaptureGroupCommand*)command;
@end
