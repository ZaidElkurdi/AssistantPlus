//
//  APCaptureGroupCommand.m
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 4/14/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "APCaptureGroupCommand.h"

@implementation APCaptureGroupCommand

-(id)initWithDictionary:(NSDictionary*)dict {
  if (self = [super init]) {
    NSString *name = dict[@"name"];
    NSArray *variables = dict[@"variables"];
    NSArray *conditionals = dict[@"conditionals"];
    NSString *command = dict[@"command"];
    NSString *trigger = dict[@"trigger"];
    NSString *uuid = dict[@"uuid"];
    
    self.name = name;
    self.variables = variables ? variables : [NSArray array];
    self.conditionals = conditionals ? conditionals : [NSArray array];
    self.command = command ? command : @"";
    self.trigger = trigger ? trigger : @"";
    self.uuid = uuid ? uuid : [NSString stringWithFormat:@"%@", [NSUUID UUID]];
  }
  return  self;
}

- (NSDictionary*)dictionaryRepresentation {
  return @{@"name" : self.name ? self.name : @"Untitled",
           @"variables" : self.variables ? self.variables : [NSArray array],
           @"conditionals" : self.conditionals ? self.conditionals : [NSArray array],
           @"command" : self.command ? self.command : @"",
           @"trigger" : self.trigger ? self.trigger : @"",
           @"uuid" : self.uuid ? self.uuid : [NSString stringWithFormat:@"%@", [NSUUID UUID]]};
}

@end
