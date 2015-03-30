//
//  ListenerDetailViewController.h
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 3/23/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APActivatorListener.h"

@interface ListenerDetailViewController : UIViewController <UITextFieldDelegate>
- (id)initWithListener:(APActivatorListener*)listener;
@end
