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
    self.triggerString = dict[@"trigger"];
    self.trigger = [NSRegularExpression regularExpressionWithPattern:self.triggerString options:NSRegularExpressionCaseInsensitive error:nil];
    self.identifier = dict[@"identifier"];
    
    NSNumber *pass = dict[@"passthrough"];
    self.willPassthrough = pass ? [pass boolValue] : NO;
  }
  return self;
}
@end
