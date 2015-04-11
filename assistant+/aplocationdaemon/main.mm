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
  APLocationManager *manager = [[APLocationManager alloc] init];
  [manager startMonitoringLocation];
  CPDistributedMessagingCenter* center = [CPDistributedMessagingCenter centerNamed:@"com.zaid.applus.daemon"];
  [center runServerOnCurrentThread];
  [center registerForMessageName:@"RetrieveLocation" target:manager selector:@selector(startMonitoringLocation)];
  
  @autoreleasepool {
    while([[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]]);
  }
  return 0;
}
