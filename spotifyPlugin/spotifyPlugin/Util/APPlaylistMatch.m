//
//  APPlaylistMatch.m
//  spotifyPlugin
//
//  Created by Zaid Elkurdi on 8/1/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "APPlaylistMatch.h"

@implementation APPlaylistMatch

- (instancetype)initWithName:(NSString *)playlistName uri:(NSString *)uri matchPercentage:(CGFloat)matchPercentage {
  if (self = [super init]) {
    self.playlistName = playlistName;
    self.uri = uri;
    self.matchPercentage = matchPercentage;
  }
  return self;
}

@end
