
//
//  spotifyPlaylistCommands.m
//  spotifyPlugin
//
//  Created by Zaid Elkurdi on 7/15/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "spotifyPlaylistCommands.h"

#import <UIKit/UIKit.h>
#import "Util/APPlaylistMatch.h"
#import "Util/APSpotifyUtils.h"
#import "Util/APSpotifyAuthManager.h"

typedef enum {
  APShouldPlayQuestion = 0,
  APPlaylistNameQuestion = 1,
  APNoQuestion = 2,
} APPlaylistQuestion;

@interface spotifyPlaylistCommands ()
@property (strong, nonatomic) NSDictionary *playlists;
@property (strong, nonatomic) APPlaylistMatch *bestGuess;
@property (nonatomic) APPlaylistQuestion currentQuestion;
@end

@implementation spotifyPlaylistCommands

- (BOOL)handleSpeech:(NSString *)text withTokens:(NSSet *)tokens withSession:(id<APSiriSession>)session {
  if ([tokens containsObject:@"play"] && [tokens containsObject:@"playlist"] && [tokens containsObject:@"spotify"]) {
    
    NSRegularExpression *playlistRegex = [NSRegularExpression regularExpressionWithPattern:@"(?:.*)(?:Play|Start) (?:my )?(.*) playlist on Spotify" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *regexMatches = [playlistRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    NSString *playlistName = nil;
    
    if (regexMatches.count > 0) {
      NSTextCheckingResult *match = regexMatches[0];
      if (match.numberOfRanges > 1) {
        NSLog(@"Match: %@", [text substringWithRange:[match rangeAtIndex:1]]);
        playlistName = [text substringWithRange:[match rangeAtIndex:1]];
      }
    }
    
    [[APSpotifyUtils sharedUtils] addCurrentSongToPlaylist:@"Dope" completion:nil];
    
    if (playlistName) {
      if ([self _handlePlaylistName:playlistName session:session]) {
        return YES;
      }
    }
  }

  return NO;
}

- (void)handleReply:(NSString *)text withTokens:(NSSet *)tokens withSession:(id<APSiriSession>)session {
  if (_currentQuestion == APPlaylistNameQuestion) {
    [self _handlePlaylistName:text session:session];
  } else if (_currentQuestion == APShouldPlayQuestion) {
    if ([text containsString:@"cancel"]) {
      _bestGuess = nil;
      [session sendTextSnippet:@"Okay, I won't play anything" temporary:NO scrollToTop:YES dialogPhase:@"Completion"];
    } else if ([[text lowercaseString] characterAtIndex:0] == 'y' || [text containsString:@"ok"]) {
      [self _openURI:_bestGuess.uri];
    } else {
      _currentQuestion = APPlaylistNameQuestion;
      [session sendTextSnippet:@"Okay, what's the name?" temporary:NO scrollToTop:YES dialogPhase:@"Clarification" listenAfterSpeaking:YES];
    }
  }
}

- (void)assistantWasDismissed {
  _bestGuess = nil;
  _currentQuestion = APNoQuestion;
}

#pragma mark - Helpers

- (BOOL)_handlePlaylistName:(NSString *)playlistName session:(id<APSiriSession>)session {
  _bestGuess = [[APSpotifyUtils sharedUtils] bestMatchForPlaylistName:playlistName];
  if (_bestGuess) {
    if (_bestGuess.matchPercentage > 0.40f) {
      [self _openURI:_bestGuess.uri];
    } else {
      _currentQuestion = APShouldPlayQuestion;
      NSString *message = [NSString stringWithFormat:@"I found a playlist named '%@', is that the one you wanted?", _bestGuess.playlistName];
      [session sendTextSnippet:message temporary:NO scrollToTop:YES dialogPhase:@"Clarification" listenAfterSpeaking:YES];
    }
    return YES;
  }
  return NO;
}

- (void)_openURI:(NSString *)uri {
  if (uri) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:uri]];
    });
  }
}

@end
