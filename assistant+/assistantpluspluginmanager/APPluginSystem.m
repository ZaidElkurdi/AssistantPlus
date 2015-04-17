//
//  AssistantPluginManager.m
//  
//
//  Created by Zaid Elkurdi on 3/12/15.
//
//

#import "APPluginSystem.h"
#import "APPlugin.h"
#import "APActivatorListener.h"
#import "APCaptureGroupCommand.h"
#import "CPDistributedMessagingCenter.h"

static NSString *PREFERENCE_PATH = @"/var/mobile/Library/Preferences/com.assistantplus.app.plist";
static NSString *EVENT_PREFIX = @"APListener";

@implementation APPluginSystem

+ (id)sharedManager {
  static APPluginSystem *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [[self alloc] init];
    if ([sharedManager loadPlugins]) {
      NSLog(@"Successfully loaded plugins!");
    } else {
      NSLog(@"Failed to load plugins!");
    }
    
    NSDictionary *pref = [NSDictionary dictionaryWithContentsOfFile:PREFERENCE_PATH];
    [sharedManager reloadActivatorListeners:pref];
    [sharedManager reloadCaptureGroupCommands:pref];
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
  
  for (NSURL *fileURL in contents) {
    NSString *name = [[[fileURL absoluteString] lastPathComponent] stringByDeletingPathExtension];
    
    APPlugin *currPlugin = [[APPlugin alloc] initWithFilePath:fileURL andName:name];
    
    if (currPlugin != nil) {
      [plugins addObject:currPlugin];
    }
  }
  
  return TRUE;
}

- (BOOL)handleCommand:(NSString*)command withTokens:(NSSet*)tokens withSession:(APSession*)currSession {
  self.currSession = currSession;
  
  //Clean up the command
  NSString *userCommand = [command lowercaseString];
  userCommand = [userCommand stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  
  //First check activator listeners
  for (APActivatorListener *currListener in activatorListenersArray) {
    for (NSRegularExpression *currExpression in currListener.triggers) {
      NSArray *arrayOfAllMatches = [currExpression matchesInString:userCommand options:0 range:NSMakeRange(0, [userCommand length])];
      for (NSTextCheckingResult *match in arrayOfAllMatches) {
        if (match.numberOfRanges > 0) {
          NSString *eventName = [NSString stringWithFormat:@"%@%@", EVENT_PREFIX, currListener.identifier];
          [LASharedActivator sendEventToListener:[LAEvent eventWithName:eventName mode:LASharedActivator.currentEventMode]];
          if (!currListener.willPassthrough) {
            [currSession sendRequestCompleted];
            return YES;
          }
        }
      }
    }
  }
  
  //Then check Capture Group Commands
  for (APCaptureGroupCommand *currCommand in captureGroupCommandsArray) {
    NSRegularExpression *currExpression = currCommand.trigger;
    NSArray *arrayOfAllMatches = [currExpression matchesInString:userCommand options:0 range:NSMakeRange(0, [userCommand length])];
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
      if (match.numberOfRanges > 0) {
        NSMutableArray *variableMatches = [[NSMutableArray alloc] init];
        for (NSInteger currIndex = 1; currIndex < match.numberOfRanges; currIndex++) {
          NSString *variableValue = [[userCommand substringWithRange:[match rangeAtIndex:currIndex]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
          NSLog(@"Match %ld: %@", (long)currIndex, variableValue);
          [variableMatches addObject:variableValue];
        }
        NSString *commandToExecute = [currCommand buildCommandWithValues:variableMatches];
        CPDistributedMessagingCenter* center = [CPDistributedMessagingCenter centerNamed:@"com.zaid.applus.springboard"];
        [center sendMessageName:@"runCommand" userInfo:@{@"command" : commandToExecute}];
        return YES;
      }
    }
  }
  
  //Go through the plugins
  NSLog(@"AP: Got Command \"%@\"", userCommand);
  for (APPlugin *currPlugin in plugins) {
    if ([currPlugin handleSpeech:userCommand withTokens:tokens withSession:currSession]) {
      return YES;
    }
  }
  return NO;
}

#pragma mark - Message Handlers

- (NSDictionary*)getInstalledPlugins {
  NSMutableArray *pluginArray = [[NSMutableArray alloc] init];
  for (APPlugin *currPlugin in plugins) {
    NSDictionary *currDict = @{@"name" : [currPlugin displayName],
                               @"author" :[currPlugin author]};
    [pluginArray addObject:currDict];
  }
  return @{@"plugins" : pluginArray};
}

- (void)reloadCustomRepliesPlugin:(NSDictionary*)replies {
  for (APPlugin *currPlugin in plugins) {
    if ([[currPlugin identifier] isEqualToString:@"com.assistantplus.customreplyidentifier"]) {
      id customCmd = [[currPlugin getRegisteredCommands] lastObject];
      [customCmd performSelector:@selector(createPhraseDictionary:) withObject:replies];
      break;
    }
  }
}

- (void)reloadCaptureGroupCommands:(NSDictionary*)commands {
  NSLog(@"Loading capture group commands!");
  captureGroupCommandsArray = [[NSMutableArray alloc] init];
  
  if ([commands objectForKey:@"captureGroupCommands"]) {
    for (NSDictionary *currCommand in [commands objectForKey:@"captureGroupCommands"]) {
      id triggerValue = currCommand[@"trigger"];
      id commandValue = currCommand[@"command"];
      if (triggerValue && commandValue) {
        APCaptureGroupCommand *command = [[APCaptureGroupCommand alloc] initWithDictionary:currCommand];
        [captureGroupCommandsArray addObject:command];
      }
    }
  }
}

- (void)siriSay:(NSString*)message {
  [self.currSession sendTextSnippet:message temporary:NO scrollToTop:YES dialogPhase:@"Completion"];
}

#pragma mark - Activator Methods

- (void)reloadActivatorListeners:(NSDictionary*)listeners {
  if (!activatorListenersArray) {
    activatorListenersArray = [[NSMutableArray alloc] init];
  }
  
  for (APActivatorListener *currListener in activatorListenersArray) {
    NSString *identifier = currListener.identifier;
    NSString *eventName = [NSString stringWithFormat:@"%@%@", EVENT_PREFIX, identifier];
    [LASharedActivator unregisterEventDataSourceWithEventName:eventName];
  }
  
  [activatorListenersArray removeAllObjects];
  
  if ([listeners objectForKey:@"activatorListeners"]) {
    for (NSDictionary *currListener in [listeners objectForKey:@"activatorListeners"]) {
      BOOL isEnabled = [currListener[@"enabled"] boolValue];
      BOOL isValid = NO;
      id triggerValue = currListener[@"trigger"];
      if ([triggerValue isKindOfClass:[NSArray class]]) {
        NSArray *triggers = (NSArray*)triggerValue;
        isValid = triggers.count > 0 && isEnabled;
        if (isValid) {
          NSString *firstTrigger = triggers[0];
          isValid = firstTrigger.length > 0;
        }
      } else {
        //Migration 1.0 -> 1.01
        NSString *trigger = (NSString*)triggerValue;
        isValid = trigger.length > 0 && isEnabled;
      }
      if (isValid) {
          APActivatorListener *newListener = [[APActivatorListener alloc] initWithDictionary:currListener];
          NSString *eventName = [NSString stringWithFormat:@"%@%@", EVENT_PREFIX, newListener.identifier];
          [activatorListenersArray addObject:newListener];
          [LASharedActivator registerEventDataSource:self forEventName:eventName];
        }
      }
    }
}

- (NSString *)localizedTitleForEventName:(NSString *)eventName {
  for (APActivatorListener *currListener in activatorListenersArray) {
    NSString *comp = [NSString stringWithFormat:@"%@%@", EVENT_PREFIX, currListener.identifier];
    if ([comp isEqualToString:eventName]) {
      return currListener.name;
    }
  }
  
  return @"Untitled Assistant+ Listener";
}

- (NSString *)localizedGroupForEventName:(NSString *)eventName {
  return @"Assistant+";
}

- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
  for (APActivatorListener *currListener in activatorListenersArray) {
    NSString *comp = [NSString stringWithFormat:@"%@%@", EVENT_PREFIX, currListener.identifier];
    
    if ([comp isEqualToString:eventName]) {
      NSMutableString *descriptionString = [NSMutableString string];
      for (NSInteger currIndex = 0; currIndex < currListener.triggerStrings.count; currIndex++) {
        NSString *currTrigger = currListener.triggerStrings[currIndex];
        NSString *format = currIndex == currListener.triggerStrings.count-1 ? @"\"%@\"" : @"\"%@\", ";
        [descriptionString appendString:[NSString stringWithFormat:format, currTrigger.length > 0 ? currTrigger : @"Empty Trigger"]];
      }
      return [NSString stringWithFormat:@"Siri Query - %@", descriptionString];
    }
  }
  
  return @"Invalid Listener";
}

@end
