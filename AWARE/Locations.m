//
//  Locations.m
//  AWARE
//
//  Created by Yuuki Nishiyama on 11/20/15.
//  Copyright © 2015 Yuuki NISHIYAMA. All rights reserved.
//

#import "Locations.h"

@implementation Locations{
    NSTimer *uploadTimer;
    CLLocationManager *locationManager;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithSensorName:(NSString *)sensorName{
    self = [super init];
    if (self) {
        [super setSensorName:sensorName];
    }
    return self;
}

- (BOOL)startSensor:(double)interval withUploadInterval:(double)upInterval{
    NSLog(@"Start Gyroscope!");
    uploadTimer = [NSTimer scheduledTimerWithTimeInterval:upInterval target:self selector:@selector(uploadSensorData) userInfo:nil repeats:YES];
    if (nil == locationManager){
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        //    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.pausesLocationUpdatesAutomatically = NO;
        locationManager.allowsBackgroundLocationUpdates = YES; //This variable is an important method for background sensing
        locationManager.activityType = CLActivityTypeFitness;
        if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [locationManager requestAlwaysAuthorization];
        }
        // Set a movement threshold for new events.
        locationManager.distanceFilter = 25; // meters
        [locationManager startUpdatingLocation];
        //    [_locationManager startMonitoringVisits]; // This method calls didVisit.
        [locationManager startUpdatingHeading];
        //    _location = [[CLLocation alloc] init];
        //    locationTimer = [NSTimer scheduledTimerWithTimeInterval:locationInterval
        //                                                     target:self
        //                                                   selector:@selector(getGpsData:)
        //                                                   userInfo:nil
        //                                                    repeats:YES];
    
    }
    return YES;
}


//
//- (void) getGpsData: (NSTimer *) theTimer
//{
//    [sdManager addLocation:[_locationManager location]];
//
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy < 0)
        return;
//    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
//                                       newHeading.trueHeading : newHeading.magneticHeading);
//    [sdManager addSensorDataMagx:newHeading.x magy:newHeading.y magz:newHeading.z];
//    [sdManager addHeading: theHeading];
}


- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    for (CLLocation* location in locations) {
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        NSNumber* unixtime = [NSNumber numberWithDouble:timeStamp];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:unixtime forKey:@"timestamp"];
        [dic setObject:[self getDeviceId] forKey:@"device_id"];
        [dic setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"double_latitude"];
        [dic setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"double_longitude"];
        [dic setObject:[NSNumber numberWithDouble:location.course] forKey:@"double_bearing"];
        [dic setObject:[NSNumber numberWithDouble:location.speed] forKey:@"double_speed"];
        [dic setObject:[NSNumber numberWithDouble:location.altitude] forKey:@"double_altitude"];
        [dic setObject:@"gps" forKey:@"provider"];
        [dic setObject:[NSNumber numberWithInt:location.verticalAccuracy] forKey:@"accuracy"];
        [dic setObject:@"" forKey:@"label"];
        [self setLatestValue:[NSString stringWithFormat:@"%f, %f, %f", location.coordinate.latitude, location.coordinate.longitude, location.speed]];
        [self saveData:dic toLocalFile:@"locations"];
    }
}


- (BOOL)stopSensor{
    [locationManager stopUpdatingHeading];
    [locationManager stopUpdatingLocation];
    [uploadTimer invalidate];
    return YES;
}

- (void)uploadSensorData{
    NSString * jsonStr = [self getData:@"locations" withJsonArrayFormat:YES];
    [self insertSensorData:jsonStr withDeviceId:[self getDeviceId] url:[self getInsertUrl:@"locations"]];
}

@end