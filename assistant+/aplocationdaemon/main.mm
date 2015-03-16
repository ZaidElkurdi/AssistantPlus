//
//  main.m
//  APLocationDaemon
//
//  Created by Zaid Elkurdi on 15.03.2015.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APLocationManager.h"

int main(int argc, char *argv[]) {
  NSLog(@"Starting this shit 2");
  
  APLocationManager *manager = [[APLocationManager alloc] init];
  CPDistributedMessagingCenter* center = [CPDistributedMessagingCenter centerNamed:@"com.zaid.applus.center"];
  [center runServerOnCurrentThread];
  [center registerForMessageName:@"GetLocation" target:manager selector:@selector(getCurrentLocation)];
  
  @autoreleasepool {
    [manager startMonitoringLocation];
    [NSTimer scheduledTimerWithTimeInterval:30 target:manager selector:@selector(startMonitoringLocation) userInfo:nil repeats:YES];
    while([[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]]);
  }
  return 0;
}
