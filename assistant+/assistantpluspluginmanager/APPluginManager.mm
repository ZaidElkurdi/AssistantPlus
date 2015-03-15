//
//  AssistantPluginManager.m
//  
//
//  Created by Zaid Elkurdi on 3/12/15.
//
//

#import "APPluginManager.h"
#include "APPlugin.h"

#define PLUGIN_PATH "/Library/AssistantPlusPlugins/"

@implementation APPluginManager

+ (id)sharedManager {
  static APPluginManager *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [[self alloc] init];
    NSLog(@"Creating plugin manager again!");
    if ([sharedManager loadPlugins]) {
      NSLog(@"Successfully loaded plugins!");
    } else {
      NSLog(@"Failed to load plugins!");
    }
  });
  return sharedManager;
}

- (BOOL)loadPlugins {
  plugins = [[NSMutableArray alloc] init];
  
  NSURL *directoryPath = [NSURL URLWithString:@PLUGIN_PATH];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *contents = [fileManager contentsOfDirectoryAtURL:directoryPath
                                 includingPropertiesForKeys:@[]
                                                    options:NSDirectoryEnumerationSkipsHiddenFiles
                                                      error:nil];
  
//  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'assistantPlugin'"];
  
  NSLog(@"Loading Plugins:");
  for (NSURL *fileURL in contents) {//[contents filteredArrayUsingPredicate:predicate]) {
    NSString *name = [[[fileURL absoluteString] lastPathComponent] stringByDeletingPathExtension];
    
    NSLog(@"Loading %@ at %@", name, fileURL);
    APPlugin *currPlugin = [[APPlugin alloc] initWithFilePath:fileURL andName:name];
    
    if (currPlugin != nil) {
      [plugins addObject:currPlugin];
      //Need to release currPlugin?
    }
  }
  
  return TRUE;
}

- (BOOL)handleCommand:(NSString*)command withSession:(APSession*)currSession {
  NSLog(@"Looking for command to handle: %@", command);
  NSLog(@"There are currently %lu plugins registered: %@", (unsigned long)plugins.count, plugins);
  for (APPlugin *currPlugin in plugins) {
    NSLog(@"Currently on: %@:%@", currPlugin, [currPlugin displayName]);
    if ([currPlugin handleSpeech:command forSession:currSession]) {
      NSLog(@"%@ is handling command: %@", [currPlugin displayName], command);
      return YES;
    }
  }
  return NO;
}

- (id<APPluginSnippet>)viewControllerForClass:(NSString*)snippetClass {
  NSLog(@"Begin search for: %@ with %d plugins", snippetClass, (int)plugins.count);
  for (APPlugin *currPlugin in plugins) {
    NSLog(@"Current (%@) contains: %@", [currPlugin displayName], [currPlugin getRegisteredSnippets]);
    if ([[currPlugin getRegisteredSnippets] containsObject:snippetClass]) {
      NSObject<APPluginSnippet>* snip = [NSClassFromString(snippetClass) alloc];
      
      id initRes = nil;
      
      if ([snip respondsToSelector:@selector(initWithProperties:)])
        initRes = [snip initWithProperties:@{@"labelText" : @"fuck you"}];
      
      if (!initRes)
        initRes = [snip init];
      
      if (!initRes) {
        NSLog(@"ERROR: Snippet class %@ failed to initialize!", snippetClass);
        return nil;
      }
      return snip;
    }
  }
  NSLog(@"APPluginManager: Found no VC for %@", snippetClass);
  return nil;
}

-(NSString*)localizedString:(NSString*)text {
  return text;
}

-(NSString*)systemVersion {
  return @"1.0";
}

@end
