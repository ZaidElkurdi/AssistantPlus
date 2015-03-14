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

@implementation APPluginManager {
  NSMutableArray *plugins;
}

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
  plugins = [[[[NSMutableArray alloc] init] retain] autorelease];
  
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
    APPlugin *currPlugin = [[[APPlugin alloc] initWithFilePath:fileURL andName:name] autorelease];
    
    if (currPlugin != nil) {
      [plugins addObject:currPlugin];
    }
  }
  
  return TRUE;
}

- (BOOL)handleCommand:(NSString*)command withSession:(APSession*)currSession {
  NSLog(@"Looking for command to handle: %@", command);
  NSLog(@"There are currently %lu plugins registered: %@", (unsigned long)plugins.count, plugins);
  for (APPlugin *currPlugin in plugins) {
    if ([currPlugin handleSpeech:command forSession:currSession]) {
      NSLog(@"%@ is handling command: %@", currPlugin.pluginName, command);
    }
  }
  return NO;
}

-(NSString*)localizedString:(NSString*)text {
  return text;
}

-(NSString*)systemVersion {
  return @"1.0";
}

@end
