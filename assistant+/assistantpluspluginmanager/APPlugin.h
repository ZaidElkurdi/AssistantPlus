//
//  AssistantPlugin.h
//  
//
//  Created by Zaid Elkurdi on 3/12/15.
//
//

#import "AssistantPlusHeaders.h"

@interface APPlugin : NSObject <APPluginManager> {
  NSBundle *bundle;
  BOOL isInitialized;
  
  NSString *name;
  NSString *displayName;
  NSString *bundleName;
  NSString *pluginDescription;
  NSString *author;
  NSString *identifier;
  NSMutableArray *commands;
  NSMutableSet *snippets;
  NSString *pluginName;
  NSString *pluginFilePath;
  id<APPlugin> pluginClass;
}
-(NSString*)displayName;
- (id)initWithFilePath:(NSURL*)filePath andName:(NSString*)name;
- (NSSet*)getRegisteredSnippets;
- (BOOL)handleSpeech:(NSString*)text forSession:(APSession*)session;

/// Register a command class
-(BOOL)registerCommand:(Class)cls;
/// Register a snippet class
-(BOOL)registerSnippet:(Class)cls;

@end
