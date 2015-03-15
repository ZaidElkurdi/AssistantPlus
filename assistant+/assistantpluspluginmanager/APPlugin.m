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
    
    NSLog(@"Commnds just created: %@", commands);
    
    bundle = [[NSBundle bundleWithURL:filePath] retain];
    if (!bundle) {
      NSLog(@"Failed to open extension bundle %@ (%@)!", fileName, filePath);
      [self release];
      return nil;
    }
    
    if (![bundle load]) {
      NSLog(@"Failed to load extension bundle %@ (wrong CFBundleExecutable? Missing? Not signed?)!", name);
      [self release];
      return nil;
    } else {
      NSLog(@"Loaded bundle!");
    }
    
    //load principal class
    Class principal = [bundle principalClass];
    if (!principal) {
      NSLog(@"Plugin %@ doesn't provide a NSPrincipalClass!", fileName);
      [self release];
      return nil;
    } else {
      NSLog(@"has principal!");
    }
    
    pluginClass = [[principal alloc] initWithSystem:self];
    if (!pluginClass) {
      NSLog(@"Failed to initialize NSPrincipalClass from plugin %@!", fileName);
      [self release];
      return nil;
    } else {
      NSLog(@"has pluginClass!");
    }
    
    // get extension info
    displayName = @"FuckerShit";
//    displayName = [[[_bundle infoDictionary] objectForKey:@"APPluginName"] copy];
//    if (!displayName) {
//      displayName = name;
//    }
    
    author = [[bundle objectForInfoDictionaryKey:@"PluginAuthor"] copy];
    pluginDescription = [[bundle objectForInfoDictionaryKey:@"PluginDescription"] copy];
    identifier = [[bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"] copy];
    pluginName = fileName;
    
    bundleName = [name copy];
    isInitialized = YES;
  }
  
  NSLog(@"Loaded Plugin: %@", self);
  return self;
}

-(NSString*)displayName {
  return displayName;
}

- (NSSet*)getRegisteredSnippets {
  NSLog(@"Registered Snippets: %@", snippets);
  return snippets;
}

- (BOOL)handleSpeech:(NSString*)text forSession:(APSession*)currSession {
  for (NSObject<APPluginCommand>* cmd in commands) {
    if ([cmd respondsToSelector:@selector(handleSpeech:session:)]) {
      if ([cmd handleSpeech:text session:currSession]) {
        return YES;
      }
    } else {
      NSLog(@"Command does not respond to handleSpeech:session:!");
      return NO;
    }
  }
  return NO;
}

#pragma mark - Snippet Presentation

-(NSObject<APPluginSnippet>*)allocSnippet:(NSString*)snippetClass properties:(NSDictionary *)props {
  if ([snippets containsObject:snippetClass]) {
    NSObject<APPluginSnippet>* snip = [NSClassFromString(snippetClass) alloc];
    
    id initRes = nil;
    if ([snip respondsToSelector:@selector(initWithProperties:system:)])
      initRes = [snip initWithProperties:props system:self];
    
    if (!initRes && [snip respondsToSelector:@selector(initWithProperties:)])
      initRes = [snip initWithProperties:props];
    
    if (!initRes)
      initRes = [snip init];
    
    if (!initRes)
    {
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
  
  // alloc
  id inst = [cls alloc];
  
  // init 1.0.2
  if ([inst respondsToSelector:@selector(initWithSystem:)]) {
    [inst initWithSystem:self];
  } else {
    NSLog(@"%@ did not respond to initWithSystem:. Using default init.", className);
    [inst init];
  }
  
  if (!inst) {
    NSLog(@"Command %@ failed to initialize!", className);
    return NO;
  }
  
  
  [commands addObject:inst];
  [inst release];
  
  NSLog(@"Registered Command %@, commands is now: %@", className, commands);
  
  return YES;
}

-(BOOL)registerSnippet:(Class)cls {
  NSString *className = NSStringFromClass([cls class]);
  
  if (![cls conformsToProtocol:@protocol(APPluginSnippet)]) {
    NSLog(@"Snippet %@ does not conform to protocol APPluginSnippet!", className);
    return NO;
  }
  
  id helloClass = [[NSClassFromString(className) alloc] init];
  NSLog(@"Snippet Initalized: %@", helloClass);
  
  [snippets addObject:className];
  NSLog(@"Registered snippet %@, snippets is now %@", className, snippets);
  return YES;
}

-(NSString*)systemVersion {
  return @"1.0";
}

-(NSString*)localizedString:(NSString*)text {
  return text;
}


@end
