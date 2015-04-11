//
//  APActivatorListener.m
//  
//
//  Created by Zaid Elkurdi on 4/2/15.
//
//

#import "APActivatorListener.h"

@implementation APActivatorListener

- (id)initWithDictionary:(NSDictionary*)dict {
  if (self = [super init]) {
    self.name = dict[@"name"];
    
    //Migration 1.0 -> 1.01
    id triggerFromDict = dict[@"trigger"];
    
    if ([triggerFromDict isKindOfClass:[NSString class]]) {
      self.triggerStrings = @[triggerFromDict];
    } else if ([triggerFromDict isKindOfClass:[NSArray class]]) {
      self.triggerStrings = triggerFromDict;
    } else {
      self.triggerStrings = [NSArray array];
    }
    
    NSMutableArray *regexTriggers = [[NSMutableArray alloc] init];
    for (NSString *currTrigger in self.triggerStrings) {
      if (currTrigger.length > 0) {
        NSRegularExpression *newRegex = [NSRegularExpression regularExpressionWithPattern:currTrigger options:NSRegularExpressionCaseInsensitive error:nil];
        if (newRegex) {
          [regexTriggers addObject:newRegex];
        }
      }
    }
    
    self.triggers = regexTriggers;
    self.identifier = dict[@"identifier"];
    
    NSNumber *pass = dict[@"passthrough"];
    self.willPassthrough = pass ? [pass boolValue] : NO;
  }
  return self;
}
@end
