#import "AppDelegate.h"

#if !(TARGET_IPHONE_SIMULATOR)
#import "Spotify.h" //Needs to be "Spotify.h" for theos, "<Spotify/Spotify.h>" for Xcode
#else
#import <Spotify/Spotify.h>
#endif

#define kTokenRefreshURL @"192.241.230.231:8000/refresh"

@interface AppDelegate ()
@property (nonatomic, strong) SPTSession *session;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];
  
  self.mainController = [[MainViewController alloc] init];
  
  self.navController = [[UINavigationController alloc] initWithRootViewController:self.mainController];
  self.navController.title = @"Assistant+";
  self.navController.view.backgroundColor = [UIColor whiteColor];
  [self.window setRootViewController:self.navController];
  [self.window makeKeyAndVisible];
  
  [[SPTAuth defaultInstance] setClientID:@"613bb410650d48f1a52b8fd07bf1d57e"];
  [[SPTAuth defaultInstance] setRedirectURL:[NSURL URLWithString:@"aplus://spotifyauth"]];
  [[SPTAuth defaultInstance] setRequestedScopes:@[SPTAuthPlaylistModifyPrivateScope,
                                                  SPTAuthPlaylistModifyPublicScope,
                                                  SPTAuthStreamingScope,
                                                  SPTAuthPlaylistReadPrivateScope,
                                                  SPTAuthPlaylistModifyPublicScope,
                                                  SPTAuthUserLibraryModifyScope,
                                                  SPTAuthUserLibraryReadScope]];
  [[SPTAuth defaultInstance] setSessionUserDefaultsKey:@"spotifySession"];
  [[SPTAuth defaultInstance] setTokenRefreshURL:[NSURL URLWithString:kTokenRefreshURL]];
  [self _updateSpotifyPlaylists];
  return YES;
}

// Handle auth callback
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  // Ask SPTAuth if the URL given is a Spotify authentication callback
  if ([[SPTAuth defaultInstance] canHandleURL:url]) {
    [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
      
      if (error != nil) {
        NSLog(@"*** Auth error: %@", error);
        return;
      }
      [self _updateSpotifyPlaylists];
    }];
    return YES;
  }
  
  return NO;
}

- (void)_updateSpotifyPlaylists {
  SPTSession *currSession = [[SPTAuth defaultInstance] session];
  if (!currSession) {
    return;
  }
  
  [SPTPlaylistList playlistsForUserWithSession:currSession callback:^(NSError *error, id obj) {
    SPTPlaylistList *playlists = (SPTPlaylistList *)obj;
    if (!playlists) {
      return;
    }
    
    NSMutableArray *allPlaylists = [NSMutableArray array];
    for (SPTPartialPlaylist *currPlaylist in playlists.items) {
      NSDictionary *playlistDict = @{@"name" : currPlaylist.name,
                                     @"uri" : [NSString stringWithFormat:@"%@", currPlaylist.playableUri]};
      [allPlaylists addObject:playlistDict];
    }
    [[NSUserDefaults standardUserDefaults] setObject:allPlaylists forKey:@"spotifyPlaylists"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }];
}

@end

// vim:ft=objc