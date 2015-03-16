//
//  APLocationManager.h
//
//
//  Created by Zaid Elkurdi on 3/15/15.
//
//
#import <CoreLocation/CoreLocation.h>
#import "libobjcipc/objcipc.h"
#import "CPDistributedMessagingCenter.h"

@interface APLocationManager : NSObject <CLLocationManagerDelegate>
@property (nonatomic) BOOL shouldTerminate;
- (NSDictionary*)getCurrentLocation;
- (void)startMonitoringLocation;
- (void)stopMonitoringLocation;

@end
