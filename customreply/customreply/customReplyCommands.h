//
//  customReplyCommands.h
//  customreply
//
//  Created by Zaid Elkurdi on 3/22/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssistantPlusHeaders.h"

@interface customReplyCommands : NSObject <APPluginCommand>
-(BOOL)handleSpeech:(NSString *)text withTokens:(NSSet *)tokens withSession:(id<APSiriSession>)session;
@end
