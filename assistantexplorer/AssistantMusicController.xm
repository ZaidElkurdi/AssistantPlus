//
//  AssistantMusicController.m
//  
//
//  Created by Zaid Elkurdi on 3/7/15.
//
//

#import "AssistantMusicController.h"

@interface SBApplication : NSObject
@end

@interface SBMediaController : NSObject
@property(readonly, nonatomic) SBApplication *nowPlayingApplication;
+ (id)sharedInstance;
- (BOOL)pause;
- (BOOL)play;
@end

@implementation AssistantMusicController

- (void)playSong {
  NSLog(@"Playing the song!");
  SBMediaController *controller = [%c(SBMediaController) sharedInstance];
  [controller play];
}

-(void)pauseSong {
  NSLog(@"Pausing the song!");
  SBMediaController *controller = [%c(SBMediaController) sharedInstance];
  [controller pause];
}

@end
