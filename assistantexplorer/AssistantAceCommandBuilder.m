#import "AssistantHeaders.h"
#import "AssistantAceCommandBuilder.h"

@implementation AssistantAceCommandBuilder

- (SAUIAddViews*)createUtteranceViewWithText:(NSString*)text {
  SAUIAddViews *cmd = [SAUIAddViews addViews];
  cmd.displayTarget = @"PrimaryDisplay";
  cmd.scrollToTop = NO;
  cmd.dialogPhase = @"Completion";
  cmd.temporary = NO;
  
  SAUIAssistantUtteranceView *utterView = [SAUIAssistantUtteranceView assistantUtteranceView];
  utterView.text = text;
  
  cmd.views = @[utterView];
  return cmd;
}


@end