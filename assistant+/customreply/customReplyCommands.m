//
//  customReplyCommands.m
//  customreply
//
//  Created by Zaid Elkurdi on 3/22/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "customReplyCommands.h"
#define kPreferencesPath "/var/mobile/Library/Preferences/com.assistantplus.app.plist"

@implementation customReplyCommands {
  NSDictionary *phrases;
}

- (void)createPhraseDictionary:(NSDictionary*)repliesDict {
  NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
  NSArray *customReplies = repliesDict[@"customReplies"];
  if (customReplies) {
    for (NSDictionary *currReply in customReplies) {
      NSString *currTrigger = currReply[@"trigger"];
      NSString *currResponse = currReply[@"response"];
      if ([dict objectForKey:[currTrigger lowercaseString]]) {
          NSMutableArray *mutableCmds = [[dict objectForKey:[currTrigger lowercaseString]] mutableCopy];
          [mutableCmds addObject:currResponse];
          [dict setObject:mutableCmds forKey:[currTrigger lowercaseString]];
      } else {
        [dict setObject:@[currResponse] forKey:[currTrigger lowercaseString]];
      }
    }
  }
  phrases = dict;
}

-(BOOL)handleSpeech:(NSString *)text withTokens:(NSSet *)tokens withSession:(id<APSiriSession>)session {
  if (!phrases) {
    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:@kPreferencesPath];
    [self createPhraseDictionary:preferences];
  }
  
  text = [[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
  
  if ([phrases objectForKey:text]) {
    NSArray *customReplies = [phrases objectForKey:text];
    for (NSString *currReply in customReplies) {
      [session sendTextSnippet:currReply temporary:NO scrollToTop:YES dialogPhase:@"Completion"];
    }
    [session sendRequestCompleted];
    return YES;
  }
  
  return NO;
}

@end
