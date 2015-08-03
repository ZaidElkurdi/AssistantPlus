//
//  spotifyPlaylistCommands.h
//  spotifyPlugin
//
//  Created by Zaid Elkurdi on 7/15/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssistantPlusHeaders.h"

@interface spotifyPlaylistCommands : NSObject <APPluginCommand>

- (BOOL)handleSpeech:(NSString *)text withTokens:(NSSet *)tokens withSession:(id<APSiriSession>)session;

@end
