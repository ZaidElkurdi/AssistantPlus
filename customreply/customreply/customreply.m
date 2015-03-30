//
//  customreply.m
//  customreply
//
//  Created by Zaid Elkurdi on 3/21/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "customreply.h"
#import "customReplyCommands.h"

@implementation customreply

-(id)initWithSystem:(id<APPluginManager>)system {
  if (self = [super init]) {
    if (system) {
      [system registerCommand:[customReplyCommands class]];
    }
  }
  return self;
}

@end
