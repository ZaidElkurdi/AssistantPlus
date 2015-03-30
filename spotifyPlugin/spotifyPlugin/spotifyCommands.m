//
//  spotifyCommands.m
//  spotifyPlugin
//
//  Created by Zaid Elkurdi on 3/28/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "spotifyCommands.h"
#import "AFNetworking/AFNetworking.h"

@implementation spotifyCommands

- (BOOL)handleSpeech:(NSString *)text withTokens:(NSSet *)tokens withSession:(id<APSiriSession>)session {
  if ([tokens containsObject:@"play"] && [tokens containsObject:@"on"] && [tokens containsObject:@"spotify"]) {
    
    NSRegularExpression *justSongRegex = [NSRegularExpression regularExpressionWithPattern:@"Play(.*)on Spotify" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *arrayOfAllMatches = [justSongRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    
    NSString *songName = nil;
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
      if (match.numberOfRanges > 1) {
       songName = [text substringWithRange:[match rangeAtIndex:1]];
      }
    }
    
    if (!songName || songName.length == 0) {
      return NO;
    }
    
    NSLog(@"<spotifySiri> Extracted Song: %@",songName);
    [session sendTextSnippet:@"Here's what I found..." temporary:NO scrollToTop:NO dialogPhase:@"Completion"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://ws.spotify.com/search/1/track.json" parameters:@{@"q" : songName} success:^(AFHTTPRequestOperation *operation, id responseObject) {
      NSLog(@"JSON: %@", responseObject);
      [session sendCustomSnippet:@"spotifySongListViewController" withProperties:@{@"songs" : responseObject[@"tracks"]}];
      [session sendRequestCompleted];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      [session sendTextSnippet:@"Sorry, I couldn't find that song" temporary:NO scrollToTop:YES dialogPhase:@"Completion"];
      [session sendRequestCompleted];
    }];
  }
  
  return YES;
}

@end
