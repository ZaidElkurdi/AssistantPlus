//
//  APPlaylistMatch.h
//  spotifyPlugin
//
//  Created by Zaid Elkurdi on 8/1/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface APPlaylistMatch : NSObject
@property (strong, nonatomic) NSString *playlistName;
@property (strong, nonatomic) NSString *uri;
@property (assign, nonatomic) CGFloat matchPercentage;

- (instancetype)initWithName:(NSString *)playlistName uri:(NSString *)uri matchPercentage:(CGFloat)matchPercentage;
@end
