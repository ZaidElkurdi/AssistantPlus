//
//  AssistantPlugin.h
//  
//
//  Created by Zaid Elkurdi on 3/12/15.
//
//

#import "AssistantPlusHeaders.h"

@interface APPlugin : NSObject <APPluginManager>

@property (strong, nonatomic) NSString *pluginName;
@property (strong, nonatomic) NSString *pluginFilePath;
@property (strong, nonatomic) id<APPlugin> pluginClass;

- (id)initWithFilePath:(NSURL*)filePath andName:(NSString*)name;

- (BOOL)handleSpeech:(NSString*)text forSession:(APSession*)session;

/// Register a command class
-(BOOL)registerCommand:(Class)cls;
/// Register a snippet class
-(BOOL)registerSnippet:(Class)cls;

@end
