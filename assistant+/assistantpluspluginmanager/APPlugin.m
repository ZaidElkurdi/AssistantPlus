//
//  AssistantPlugin.m
//
//
//  Created by Zaid Elkurdi on 3/12/15.
//
//

#import "APPlugin.h"

@implementation APPlugin

- (id)initWithFilePath:(NSURL*)filePath andName:(NSString*)fileName {
  if ((self = [super init])) {
    
    commands = [[NSMutableArray alloc] init];
    snippets = [[NSMutableSet alloc] init];
    
    bundle = [NSBundle bundleWithURL:filePath];
    if (!bundle) {
      NSLog(@"Failed to open plugin bundle %@!", filePath);
      return nil;
    }
    
    if (![bundle load]) {
      NSLog(@"Failed to load plugin bundle %@!", name);
      return nil;
    }
    
    //load principal class
    Class principal = [bundle principalClass];
    if (!principal) {
      NSLog(@"AP: Plugin %@ doesn't provide a NSPrincipalClass!", fileName);
      return nil;
    }
    
    NSLog(@"AP: Principal Class is %@", principal);
    
    pluginClass = [[principal alloc] initWithPluginManager:self];
    if (!pluginClass) {
      NSLog(@"AP: Failed to initialize NSPrincipalClass from plugin %@!", fileName);
      return nil;
    }
    
    //Get the plugin's display name
    displayName = [[bundle infoDictionary] objectForKey:@"APPluginName"];
    if (!displayName) {
      displayName = name;
    }
    
    author = [bundle objectForInfoDictionaryKey:@"APPluginAuthor"];
    identifier = [bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    pluginName = fileName;
    
    bundleName = fileName;
  }
  
  return self;
}

-(NSString*)displayName {
  return displayName;
}

-(NSString*)author {
  return author;
}

- (NSString*)identifier {
  return identifier;
}

- (NSArray*)getRegisteredCommands {
  return commands;
}

- (NSSet*)getRegisteredSnippets {
  return snippets;
}

- (BOOL)handleSpeech:(NSString*)text withTokens:(NSSet*)tokens withSession:(id<APSiriSession>)currSession {
  for (NSObject<APPluginCommand>* cmd in commands) {
    if ([cmd respondsToSelector:@selector(handleSpeech:withTokens:withSession:)]) {
      if ([cmd handleSpeech:text withTokens:tokens withSession:currSession]) {
        return YES;
      }
    } else {
      NSLog(@"Command does not respond to handleSpeech:session:!");
      return NO;
    }
  }
  return NO;
}

- (void)handleReply:(NSString*)text withTokens:(NSSet*)tokens withSession:(id<APSiriSession>)session {
  for (NSObject<APPluginCommand>* cmd in commands) {
    if ([cmd respondsToSelector:@selector(handleReply:withTokens:withSession:)]) {
      [cmd handleReply:text withTokens:tokens withSession:session];
    }
  }
}

#pragma mark - Notifications

- (void)assistantWasDismissed {
  for (NSObject<APPluginCommand>* cmd in commands) {
    if ([cmd respondsToSelector:@selector(assistantWasDismissed)]) {
      [cmd assistantWasDismissed];
    }
  }
}

#pragma mark - Snippet Presentation

-(NSObject<APPluginSnippet>*)allocSnippet:(NSString*)snippetClass properties:(NSDictionary *)props {
  if ([snippets containsObject:snippetClass]) {
    NSObject<APPluginSnippet>* snip = [NSClassFromString(snippetClass) alloc];
    
    id initRes = nil;
    
    if (!initRes && [snip respondsToSelector:@selector(initWithProperties:)]) {
      initRes = [snip initWithProperties:props];
    }
    
    if (!initRes) {
      initRes = [snip init];
    }
    
    if (!initRes) {
      NSLog(@"APPluginSnippet class %@ failed to initialize!", snippetClass);
      return nil;
    }
    return snip;
  }
  return nil;
}

#pragma mark - Command and Snippet Registration

-(BOOL)registerCommand:(Class)cls {
  NSString *className = NSStringFromClass([cls class]);
  
  if (![cls conformsToProtocol:@protocol(APPluginCommand)]) {
    NSLog(@"Command %@ does not conform to protocol APPluginCommand!", className);
    return NO;
  }
  
  id inst = [cls alloc];
  inst = [inst init];
  
  if (!inst) {
    NSLog(@"Command %@ failed to initialize!", className);
    return NO;
  }
  
  [commands addObject:inst];
  
  NSLog(@"Registered Command %@, commands is now: %@", className, commands);
  
  return YES;
}

-(BOOL)registerSnippet:(Class)cls {
  NSString *className = NSStringFromClass([cls class]);
  
  if (![cls conformsToProtocol:@protocol(APPluginSnippet)]) {
    NSLog(@"Snippet %@ does not conform to protocol APPluginSnippet!", className);
    return NO;
  }
  
  [snippets addObject:className];
  return YES;
}

@end
