//
//  AssistantPluginManager.m
//  
//
//  Created by Zaid Elkurdi on 3/12/15.
//
//

#import "APPluginSystem.h"
#include "APPlugin.h"

static NSString *PREFERENCE_PATH = @"/var/mobile/Library/Preferences/com.assistantplus.app.plist";
static NSString *EVENT_PREFIX = @"APListener";

@implementation APPluginSystem

+ (id)sharedManager {
  static APPluginSystem *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [[self alloc] init];
    NSLog(@"Creating plugin manager again!");
    if ([sharedManager loadPlugins]) {
      NSLog(@"Successfully loaded plugins!");
    } else {
      NSLog(@"Failed to load plugins!");
    }
    
    [sharedManager reloadActivatorListeners];
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
    }
  }
  
  return TRUE;
}

- (BOOL)handleCommand:(NSString*)command withTokens:(NSSet*)tokens withSession:(APSession*)currSession {
  NSLog(@"Looking for command to handle: %@", command);
  NSLog(@"There are currently %lu plugins registered: %@", (unsigned long)plugins.count, plugins);
  
  //First check activator listeners
  NSString *lowercase = [command lowercaseString];
  lowercase = [lowercase stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  NSLog(@"Listeners: %@ Query: %@", activatorListenersDict, lowercase);
  if ([activatorListenersDict objectForKey:lowercase]) {
    NSLog(@"Handling with activator!");
    [LASharedActivator sendEventToListener:[LAEvent eventWithName:[activatorListenersDict objectForKey:lowercase] mode:LASharedActivator.currentEventMode]];
    return YES;
  }
  
  for (APPlugin *currPlugin in plugins) {
    NSLog(@"Currently on: %@:%@", currPlugin, [currPlugin displayName]);
    if ([currPlugin handleSpeech:command withTokens:tokens withSession:currSession]) {
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

#pragma mark - Custom replies 
- (void)reloadCustomRepliesPlugin:(NSDictionary*)replies {
  NSLog(@"Updating replies with %@", replies);
  for (APPlugin *currPlugin in plugins) {
    if ([[currPlugin identifier] isEqualToString:@"com.assistantplus.customreplyidentifier"]) {
      id customCmd = [[currPlugin getRegisteredCommands] lastObject];
      [customCmd performSelector:@selector(createPhraseDictionary:) withObject:replies];
      break;
    }
  }
}

#pragma mark - Activator Methods

- (void)reloadActivatorListeners {
  NSLog(@"Reloading listeners!");
  
  if (!activatorListenersDict) {
    activatorListenersDict = [[NSMutableDictionary alloc] init];
  }
  
  if (!activatorListenersArray) {
    activatorListenersArray = [[NSMutableArray alloc] init];
  }
  
  for (NSString *currKey in activatorListenersDict.allKeys) {
    NSString *identifier = activatorListenersDict[currKey];
    NSString *eventName = [NSString stringWithFormat:@"%@%@", EVENT_PREFIX, identifier];
    NSLog(@"removed eventName = %@", eventName);
    [LASharedActivator unregisterEventDataSourceWithEventName:eventName];
  }
  
  [activatorListenersDict removeAllObjects];
  [activatorListenersArray removeAllObjects];
  
  NSDictionary *pref = [NSDictionary dictionaryWithContentsOfFile:PREFERENCE_PATH];
  if ([pref objectForKey:@"activatorListeners"]) {
    for (NSDictionary *currListener in [pref objectForKey:@"activatorListeners"]) {
      NSString *trigger = currListener[@"trigger"];
      BOOL isEnabled = [currListener[@"enabled"] boolValue];
      if (trigger.length > 0 && isEnabled) {
        NSString *eventName = [NSString stringWithFormat:@"%@%@", EVENT_PREFIX, currListener[@"identifier"]];
        NSLog(@"Registered %@ for %@", eventName, trigger);
        [activatorListenersDict setObject:eventName forKey:[trigger lowercaseString]];
        [activatorListenersArray addObject:currListener];
        [LASharedActivator registerEventDataSource:self forEventName:eventName];
      }
    }
  }
}

- (NSString *)localizedTitleForEventName:(NSString *)eventName {
  for (NSDictionary *currListener in activatorListenersArray) {
    NSString *comp = [NSString stringWithFormat:@"%@%@", EVENT_PREFIX, currListener[@"identifier"]];
    if ([comp isEqualToString:eventName]) {
      return currListener[@"name"];
    }
  }
  
  return @"Untitled Assistant+ Listener";
}

- (NSString *)localizedGroupForEventName:(NSString *)eventName {
  return @"Assistant+";
}

- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
  for (NSDictionary *currListener in activatorListenersArray) {
    NSString *comp = [NSString stringWithFormat:@"%@%@", EVENT_PREFIX, currListener[@"identifier"]];
    if ([comp isEqualToString:eventName]) {
      return [NSString stringWithFormat:@"Siri Query - \"%@\"", currListener[@"trigger"]];
    }
  }
  
  return @"Invalid Listener";
}

@end
