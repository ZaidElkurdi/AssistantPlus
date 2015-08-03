//
//  APSpotifyAuthManager.m
//  spotifyPlugin
//
//  Created by Zaid Elkurdi on 8/1/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "APSpotifyAuthManager.h"

#define kTokenRefreshURL @"192.241.230.231:8000/refresh"

#define kSpotifyClientId @"613bb410650d48f1a52b8fd07bf1d57e"
#define kSpotifyClientSecret @"34ebe83ce74347f1934eae9994cc121d"

#define kPreferencePath "/var/mobile/Library/Preferences/com.assistantplus.app.plist"

@implementation APSpotifyAuthManager

#pragma mark - Public

+ (instancetype)sharedManager {
  static APSpotifyAuthManager *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [[self alloc] init];
  });
  return sharedManager;
}

- (instancetype)init {
  if (self = [super init]) {
    [self _initSpotifyAuth];
  }
  return self;
}

- (void)currSession:(APSessionRetrievalBlock)callback {
  if ([[[SPTAuth defaultInstance] session] isValid]) {
    NSLog(@"Returning current one!");
    callback([[SPTAuth defaultInstance] session]);
  } else {
    [self _refreshSessionIfNecessary:^(SPTSession *newSession) {
      callback(newSession);
    }];
  }
}

#pragma mark - Helpers

- (void)_initSpotifyAuth {
  [[SPTAuth defaultInstance] setClientID:kSpotifyClientId];
  [[SPTAuth defaultInstance] setRequestedScopes:@[SPTAuthPlaylistModifyPrivateScope,
                                                  SPTAuthPlaylistModifyPublicScope,
                                                  SPTAuthStreamingScope,
                                                  SPTAuthPlaylistReadPrivateScope,
                                                  SPTAuthPlaylistModifyPublicScope,
                                                  SPTAuthUserLibraryModifyScope,
                                                  SPTAuthUserLibraryReadScope]];
  [[SPTAuth defaultInstance] setSessionUserDefaultsKey:@"spotifySession"];
  [[SPTAuth defaultInstance] setTokenRefreshURL:[NSURL URLWithString:kTokenRefreshURL]];
  
  [self _refreshSessionIfNecessary:^(SPTSession *newSession) {
    NSLog(@"New Session: %@", newSession);
  }];
}

- (void)_refreshSessionIfNecessary:(APSessionRetrievalBlock)callback {
  SPTSession *defaultSession = [[SPTAuth defaultInstance] session];
  NSLog(@"Refresh Token: %@", defaultSession.encryptedRefreshToken);
  if (![defaultSession isValid] && defaultSession.encryptedRefreshToken) {
    //Refresh the session if possible
    NSLog(@"Refresh session!");
    [self _refreshSession:defaultSession callback:callback];
  } else {
    NSLog(@"Getting the one from the app!");
    //Get the session from the first auth (in the app)
    SPTSession *appSession = [self _sessionFromApp];
    if ([appSession isValid]) {
      NSLog(@"App is valid!");
      callback(appSession);
    } else {
      NSLog(@"Refreshing app session!");
      [self _refreshSession:appSession callback:callback];
    }
  }
}

- (void)_refreshSession:(SPTSession *)session callback:(APSessionRetrievalBlock)callback {
  SPTAuth *defaultAuth = [SPTAuth defaultInstance];
  [defaultAuth renewSession:session callback:^(NSError *error, SPTSession *refreshedSession) {
    NSLog(@"Refreshed session: %@", refreshedSession);
    NSLog(@"Error: %@", error);
    defaultAuth.session = refreshedSession;
    callback(refreshedSession);
  }];
}

- (SPTSession *)_sessionFromApp {
  NSUserDefaults *appDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.assistantplus.app"];
  NSData *sessionData = [appDefaults objectForKey:@"spotifySession"];
  if (sessionData) {
    [NSKeyedUnarchiver setClass:[SPTSession class] forClassName:@"SPTSession"];
    SPTSession *appSession = [NSKeyedUnarchiver unarchiveObjectWithData:sessionData];
    [[SPTAuth defaultInstance] setSession:appSession];
    return appSession;
  }
  return nil;
}

@end
