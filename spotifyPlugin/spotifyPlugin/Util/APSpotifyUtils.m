//
//  APSpotifyUtils.m
//  spotifyPlugin
//
//  Created by Zaid Elkurdi on 8/1/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "APSpotifyUtils.h"

#import "APSpotifyAuthManager.h"
#import "NSString+Score.h"

#define kPreferencePath "/var/mobile/Library/Preferences/com.assistantplus.app.plist"
#define kSpotifyClientId @"613bb410650d48f1a52b8fd07bf1d57e"

@interface APSpotifyUtils ()
@property (copy, nonatomic) NSDictionary *playlists;
@end

@implementation APSpotifyUtils

+ (instancetype)sharedUtils {
  static APSpotifyUtils *sharedUtils = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedUtils = [[self alloc] init];
  });
  return sharedUtils;
}

- (void)synchronizeUserPlaylistData {
  
}

- (void)addCurrentSongToPlaylist:(NSString *)playlistName completion:(SPTPlaylistOperationCallback)callback {
  [[APSpotifyAuthManager sharedManager] currSession:^(SPTSession *currSession) {
    currSession = [[SPTSession alloc] initWithUserName:currSession.canonicalUsername accessToken:currSession.accessToken encryptedRefreshToken:currSession.encryptedRefreshToken expirationDate:currSession.expirationDate];
    NSLog(@"Got Session: %@", currSession);
    NSLog(@"Valid: %ld", (long)[currSession isValid]);
    //  NSArray *songToAdd = @[];
    SPTAudioStreamingController *audioController = [[SPTAudioStreamingController alloc] initWithClientId:kSpotifyClientId];
    NSLog(@"Audio controller: %@", audioController);
    [audioController loginWithSession:currSession callback:^(NSError *error) {
      NSLog(@"Error: %@", error);
      if (error) {
        callback(error, NO);
      } else {
        NSLog(@"Current Song: %@", audioController.currentTrackURI);
      }
    }];
    
    
    //  APPlaylistMatch *bestMatch = [self bestMatchForPlaylistName:playlistName];
    //  [SPTPlaylistSnapshot playlistWithURI:[NSURL URLWithString:bestMatch.uri] session:currSession callback:^(NSError *error, SPTPlaylistSnapshot *response) {
    //    [response addTracksToPlaylist:songToAdd withSession:currSession callback:<#^(NSError *error)block#>]
    //  }];
  }];
}

- (APPlaylistMatch *)bestMatchForPlaylistName:(NSString *)name {
  if (!_playlists) {
    [self _createPlaylistDictionary];
  }
  
  CGFloat highestScore = CGFLOAT_MIN;
  NSString *bestGuess = nil;
  for (NSString *playlistName in _playlists.allKeys) {
    CGFloat closeness = [playlistName scoreAgainst:name fuzziness:[NSNumber numberWithFloat:0.8]];
    if (closeness > highestScore) {
      bestGuess = playlistName;
      highestScore = closeness;
    }
  }
  
  if (bestGuess) {
    return [[APPlaylistMatch alloc] initWithName:bestGuess uri:_playlists[bestGuess] matchPercentage:highestScore];
  }
  
  return nil;
}

#pragma mark - Helpers

- (void)_createPlaylistDictionary {
  NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionary];
  NSDictionary *pref = [NSDictionary dictionaryWithContentsOfFile:@kPreferencePath];
  if (pref[@"spotifyPlaylists"]) {
    NSArray *rawPlaylists = pref[@"spotifyPlaylists"];
    for (NSDictionary *currPlaylist in rawPlaylists) {
      NSString *name = currPlaylist[@"name"];
      NSString *uri = currPlaylist[@"uri"];
      tempDictionary[name] = uri;
    }
  }

  _playlists = tempDictionary;
}

@end
