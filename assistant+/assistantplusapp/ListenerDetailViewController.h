//
//  ListenerDetailViewController.h
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 3/23/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APActivatorListener.h"

@protocol ListenerDetailDelegate <NSObject>
- (void)listenerDidChange:(APActivatorListener*)listener;
@end

@interface ListenerDetailViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate>
@property (assign) id<ListenerDetailDelegate> delegate;
- (id)initWithListener:(APActivatorListener*)listener;
@end
