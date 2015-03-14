//
//  AssistantPlugin.m
//
//
//  Created by Zaid Elkurdi on 3/12/15.
//
//

#import "APPlugin.h"

@interface APPlugin()
@property (strong, nonatomic) NSBundle *bundle;
@property (nonatomic) BOOL isInitialized;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *bundleName;
@property (strong, nonatomic) NSString *pluginDescription;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSString *identifier;

@property (strong, nonatomic) NSMutableArray *commands;
@property (strong, nonatomic) NSMutableSet *snippets;

@end

@implementation APPlugin

- (id)initWithFilePath:(NSURL*)filePath andName:(NSString*)name {
  if ((self = [super init])) {
    self.bundle = [[NSBundle bundleWithURL:filePath] retain];
    if (!self.bundle) {
      NSLog(@"Failed to open extension bundle %@ (%@)!", name, filePath);
      [self release];
      return nil;
    }
    
    if (![self.bundle load]) {
      NSLog(@"Failed to load extension bundle %@ (wrong CFBundleExecutable? Missing? Not signed?)!", name);
      [self release];
      return nil;
    }
    
    //load principal class
    Class principal = [self.bundle principalClass];
    if (!principal) {
      NSLog(@"Plugin %@ doesn't provide a NSPrincipalClass!", name);
      [self release];
      return nil;
    }
    
    self.pluginClass = [[principal alloc] initWithSystem:self];
    if (!self.pluginClass) {
      NSLog(@"Failed to initialize NSPrincipalClass from plugin %@!", name);
      [self release];
      return nil;
    }
    
    self.commands = [[NSMutableArray alloc] init];
    self.snippets = [[NSMutableSet alloc] init];
    
    // get extension info
    self.displayName = [[[_bundle infoDictionary] objectForKey:@"APPluginName"] copy];
    if (!self.displayName) {
      self.displayName = name;
    }
    
    self.author = [[self.bundle objectForInfoDictionaryKey:@"PluginAuthor"] copy];
    self.pluginDescription = [[self.bundle objectForInfoDictionaryKey:@"PluginDescription"] copy];
    self.identifier = [[self.bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"] copy];
    
    self.bundleName = [name copy];
    self.isInitialized = YES;
  }
  
  return self;
}

- (BOOL)handleSpeech:(NSString*)text forSession:(APSession*)currSession {
  for (NSObject<APPluginCommand>* cmd in self.commands) {
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
  if ([self.snippets containsObject:snippetClass]) {
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
  
  [self.commands addObject:inst];
  [inst release];
  
  NSLog(@"Registered Command %@", className);
  
  return YES;
}

-(BOOL)registerSnippet:(Class)cls {
  NSString *className = NSStringFromClass([cls class]);
  
  if (![cls conformsToProtocol:@protocol(APPluginSnippet)]) {
    NSLog(@"Snippet %@ does not conform to protocol APPluginSnippet!", className);
    return NO;
  }
  
  NSLog(@"Registered snippet %@", className);
  [self.snippets addObject:className];
  
  return YES;
}

-(NSString*)systemVersion {
  return @"1.0";
}

-(NSString*)localizedString:(NSString*)text {
  return text;
}

@end
