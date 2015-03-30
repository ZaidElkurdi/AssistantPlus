//
//  APActivatorListener.m
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 3/22/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "APActivatorListener.h"

@implementation APActivatorListener

- (id)initWithDictionary:(NSDictionary *)dict {
  if (self = [super init]) {
    NSString *name = dict[@"name"];
    NSString *trigger = dict[@"trigger"];
    NSString *identifier = dict[@"identifier"] ? dict[@"identifier"] : [NSString stringWithFormat:@"%@", [NSDate date]];
    BOOL enabled = false;
    if (dict[@"enabled"]) {
      enabled = [dict[@"enabled"] boolValue];
    }
    self.name = name;
    self.trigger = trigger;
    self.enabled = enabled;
    self.uniqueId = identifier;
  }
  return self;
}

- (NSDictionary*)dictionaryRepresentation {
  return @{@"name" : self.name ? self.name : @"Untitled",
           @"trigger" : self.trigger ? self.trigger : @"",
           @"enabled" : self.enabled ? [NSNumber numberWithBool:self.enabled] : [NSNumber numberWithBool:NO],
           @"identifier" : self.uniqueId };
}

@end
