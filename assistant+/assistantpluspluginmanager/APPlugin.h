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
-(NSString*)author;
-(NSString*)identifier;

- (id)initWithFilePath:(NSURL*)filePath andName:(NSString*)name;
- (BOOL)handleSpeech:(NSString*)text withTokens:(NSSet*)tokens withSession:(id<APSiriSession>)session;
- (void)handleReply:(NSString*)text withTokens:(NSSet*)tokens withSession:(id<APSiriSession>)session;
/// Register a command class
-(BOOL)registerCommand:(Class)cls;
/// Register a snippet class
-(BOOL)registerSnippet:(Class)cls;

- (NSSet*)getRegisteredSnippets;
- (NSArray*)getRegisteredCommands;

- (void)assistantWasDismissed;

@end
