//
//  spotifySiri.m
//  spotifyPlugin
//
//  Created by Zaid Elkurdi on 3/28/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "spotifySiri.h"
#import "spotifyCommands.h"
#import "spotifySongListViewController.h"

@implementation spotifySiri

-(id)initWithSystem:(id<APPluginManager>)system {
  if (self = [super init]) {
    [system registerCommand:[spotifyCommands class]];
    [system registerSnippet:[spotifySongListViewController class]];
  }
  return self;
}

@end
