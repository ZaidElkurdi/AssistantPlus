//
//  AssistantQueryHandler.m
//  
//
//  Created by Zaid Elkurdi on 3/7/15.
//
//

#import "AssistantQueryHandler.h"

@implementation AssistantQueryHandler

- (AssistantAction)handleQuery:(NSString*)query {
  NSLog(@"Handling Query: %@", query);
  query = [query lowercaseString];
  
//  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"" options:NSRegularExpressionCaseInsensitive error:nil];
  if ([query rangeOfString:@"test"].location != NSNotFound) {
    return AssistantChatAction;
  } else if ([query rangeOfString:@"pause"].location != NSNotFound) {
    return AssistantMusicPauseAction;
  } else if ([query rangeOfString:@"play"].location != NSNotFound) {
    return AssistantMusicPlayAction;
  } else {
    return AssistantDefaultAction;
  }
}

@end
