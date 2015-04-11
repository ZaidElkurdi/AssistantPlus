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
    NSString *identifier = dict[@"identifier"] ? dict[@"identifier"] : [NSString stringWithFormat:@"%@", [NSDate date]];
    
    BOOL enabled = false;
    if (dict[@"enabled"]) {
      enabled = [dict[@"enabled"] boolValue];
    }
    
    BOOL passthrough = false;
    if (dict[@"passthrough"]) {
      passthrough = [dict[@"passthrough"] boolValue];
    }
    
    //Migration from 1.0 - 1.01
    id trigger = dict[@"trigger"];
    if ([trigger isKindOfClass:[NSString class]]) {
      self.triggers = @[trigger];
    } else if ([trigger isKindOfClass:[NSArray class]]) {
      self.triggers = trigger;
    } else {
      self.triggers = [NSArray array];
    }
    
    self.name = name;
    self.enabled = enabled;
    self.willPassthrough = passthrough;
    self.uniqueId = identifier;
  }
  return self;
}

- (NSDictionary*)dictionaryRepresentation {
  return @{@"name" : self.name ? self.name : @"Untitled",
           @"trigger" : self.triggers ? self.triggers : [NSArray array],
           @"enabled" : self.enabled ? [NSNumber numberWithBool:self.enabled] : [NSNumber numberWithBool:NO],
           @"passthrough": self.willPassthrough ? [NSNumber numberWithBool:self.willPassthrough] : [NSNumber numberWithBool:NO],
           @"identifier" : self.uniqueId };
}

@end
