//
//  APCustomReply.m
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 3/25/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "APCustomReply.h"

@implementation APCustomReply

- (id)initWithDictionary:(NSDictionary *)dict {
  if (self = [super init]) {
    NSString *response = dict[@"response"];
    NSString *trigger = dict[@"trigger"];
    NSString *uuid = dict[@"uuid"];
    
    self.trigger = trigger;
    self.response = response;
    self.uuid = uuid ? uuid : [NSString stringWithFormat:@"%@", [NSUUID UUID]];
  }
  return self;
}

- (NSDictionary*)dictionaryRepresentation {
  return @{@"response" : self.response ? self.response : @"",
           @"trigger" : self.trigger ? self.trigger : @"",
           @"uuid" : self.uuid ? self.uuid : [NSString stringWithFormat:@"%@", [NSUUID UUID]]};
}

@end
