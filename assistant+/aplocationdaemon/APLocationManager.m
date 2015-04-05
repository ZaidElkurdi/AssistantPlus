//
//  APLocationManager.m
//
//
//  Created by Zaid Elkurdi on 3/15/15.
//
//

#import "APLocationManager.h"

@implementation APLocationManager {
  NSInteger count;
  CLLocationManager *locationManager;
  CLLocation *currLocation;
}

#pragma mark - Public Methods

- (id)init {
  if (self = [super init]) {
    count = 0;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  }
  return self;
}

- (void)startMonitoringLocation {
  [locationManager startUpdatingLocation];
}

- (void)stopMonitoringLocation {
  [locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  currLocation = locations.lastObject;
  NSLog(@"APLocationManager: %ld Retrieved location: %@", (long)++count, currLocation);
  [self stopMonitoringLocation];
  
  NSDictionary *dict = @{@"latitude" : @(currLocation.coordinate.latitude),
                         @"longitude" : @(currLocation.coordinate.longitude),
                         @"horizontalAccuracy" : @(currLocation.horizontalAccuracy),
                         @"verticalAccuracy" : @(currLocation.verticalAccuracy),
                         @"speed" : @(currLocation.speed),
                         @"course" : @(currLocation.course),
                         @"timestamp" : currLocation.timestamp};
  
  CPDistributedMessagingCenter* center = [CPDistributedMessagingCenter centerNamed:@"com.zaid.applus.springboard"];
  [center sendMessageName:@"RetrievedLocation" userInfo:@{@"Location" : dict}];
}

@end
