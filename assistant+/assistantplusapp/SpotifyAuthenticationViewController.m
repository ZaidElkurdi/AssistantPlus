//
//  SpotifyAuthenticationViewController.m
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 7/15/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "SpotifyAuthenticationViewController.h"

#import <QuartzCore/QuartzCore.h>
#if !(TARGET_IPHONE_SIMULATOR)
#import "Spotify.h" //Needs to be "Spotify.h" for theos, "<Spotify/Spotify.h>" for Xcode
#else
#import <Spotify/Spotify.h>
#endif

@interface SpotifyAuthenticationViewController ()
@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) UIButton *authButton;
@end

@implementation SpotifyAuthenticationViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor colorWithWhite:.9f alpha:1.0];
  
  _authButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [_authButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [_authButton setBackgroundColor:[UIColor colorWithRed:127.0f/255.0f green:183.0f/255.0f blue:24.0f/255.0f alpha:1.0]];
  [_authButton addTarget:self action:@selector(_authenticateButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  _authButton.titleLabel.font = [UIFont systemFontOfSize:20.f];
  _authButton.layer.cornerRadius = 10;
  _authButton.clipsToBounds = YES;
  [self.view addSubview:_authButton];
  
  [self _installConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self _setAuthButtonState];
}

- (void)_setAuthButtonState {
  if ([[[SPTAuth defaultInstance] session] isValid]) {
    [_authButton setTitle:@"Authenticated Successfully" forState:UIControlStateNormal];
    _authButton.enabled = NO;
  } else {
    [_authButton setTitle:@"Authenticate with Spotify" forState:UIControlStateNormal];
    _authButton.enabled = YES;
  }
}

- (void)_installConstraints {
  _authButton.translatesAutoresizingMaskIntoConstraints = NO;
  
  NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:_authButton
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.f constant:0.f];
  
  NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:_authButton
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.f constant:0.f];
  
  NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:_authButton
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.f constant:60.f];
  
  NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_authButton
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.f constant:300.f];
  
  
  [self.view addConstraints:@[centerX, centerY, height, width]];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - Button Actions

- (void)_authenticateButtonPressed {
  // Construct a login URL and open it
  NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
  [[UIApplication sharedApplication] openURL:loginURL];
}

@end
