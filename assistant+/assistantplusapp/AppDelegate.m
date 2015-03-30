#import "MainViewController.h"
#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];
  
  MainViewController *mainVC = [[MainViewController alloc] init];
  
  self.navController = [[UINavigationController alloc] initWithRootViewController:mainVC];
  self.navController.title = @"Assistant+";
  self.navController.view.backgroundColor = [UIColor whiteColor];
  [self.window setRootViewController:self.navController];
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
   [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

@end

// vim:ft=objc