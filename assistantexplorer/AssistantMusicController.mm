#line 1 "AssistantMusicController.xm"








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
  SBMediaController *controller = [SBMediaController sharedInstance];
  [controller play];
}

-(void)pauseSong {
  SBMediaController *controller = [SBMediaController sharedInstance];
  [controller pause];
}

@end
