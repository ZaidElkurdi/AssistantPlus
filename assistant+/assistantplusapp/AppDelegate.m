#import "AppDelegate.h"

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
  return YES;
}

@end

// vim:ft=objc