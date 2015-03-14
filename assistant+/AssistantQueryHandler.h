//
//  AssistantQueryHandler.h
//  
//
//  Created by Zaid Elkurdi on 3/7/15.
//
//

#import "AssistantAceCommandBuilder.h"

typedef enum {
  AssistantMusicPauseAction = 0,
  AssistantMusicPlayAction  = 1,
  AssistantChatAction       = 2,
  AssistantDefaultAction    = 3
} AssistantAction;

@interface AssistantQueryHandler : NSObject

- (AssistantAction)handleQuery:(NSString*)query;

@end
