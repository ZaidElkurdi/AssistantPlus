//
//  APLocationManager.h
//
//
//  Created by Zaid Elkurdi on 3/15/15.
//
//
#import <CoreLocation/CoreLocation.h>
#import "CPDistributedMessagingCenter.h"

@interface APLocationManager : NSObject <CLLocationManagerDelegate>
- (void)startMonitoringLocation;
- (void)stopMonitoringLocation;

@end
