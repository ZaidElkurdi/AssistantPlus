//
//  APSpotifyAuthManager.h
//  spotifyPlugin
//
//  Created by Zaid Elkurdi on 8/1/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <Foundation/Foundation.h>
#if !(TARGET_IPHONE_SIMULATOR)
#import "Spotify.h" //Needs to be "Spotify.h" for theos, "<Spotify/Spotify.h>" for Xcode
#else
#import <Spotify/Spotify.h>
#endif

typedef void (^APSessionRetrievalBlock)(SPTSession *session);

@interface APSpotifyAuthManager : NSObject
+ (instancetype)sharedManager;
- (void)currSession:(APSessionRetrievalBlock)callback;
@end
