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
  NSMutableArray *phrases;
}


// @{ trigger : NSRegularExpression
//    response : NSString }

- (void)createPhraseDictionary:(NSDictionary*)repliesDict {
  phrases = [[NSMutableArray alloc] init];
  NSArray *customReplies = repliesDict[@"customReplies"];
  if (customReplies) {
    for (NSDictionary *currReply in customReplies) {
      NSString *currTrigger = currReply[@"trigger"];
      NSString *currResponse = currReply[@"response"];
      NSRegularExpression *regExpression = [NSRegularExpression regularExpressionWithPattern:currTrigger options:NSRegularExpressionCaseInsensitive error:nil];
      if (currTrigger && regExpression) {
        [phrases addObject:@{@"trigger" : regExpression,
                             @"response" : currResponse}];
      }
    }
  }
}

-(BOOL)handleSpeech:(NSString *)text withTokens:(NSSet *)tokens withSession:(id<APSiriSession>)session {
  if (!phrases) {
    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:@kPreferencesPath];
    [self createPhraseDictionary:preferences];
  }
  
  text = [[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
  
  BOOL didHandle = NO;
  for (NSDictionary *currDict in phrases) {
    NSRegularExpression *regExpression = currDict[@"trigger"];
    if (regExpression) {
      NSArray *arrayOfAllMatches = [regExpression matchesInString:text options:0 range:NSMakeRange(0, [text length])];
      for (NSTextCheckingResult *match in arrayOfAllMatches) {
        if (match.numberOfRanges > 0) {
          [session sendTextSnippet:currDict[@"response"] temporary:NO scrollToTop:YES dialogPhase:@"Completion"];
          didHandle = YES;
        }
      }
    }
  }
  
  if (didHandle) {
    [session sendRequestCompleted];
    return YES;
  }
  
  return NO;
}

@end
