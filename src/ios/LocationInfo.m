//
//  LocationInfo.m
//  泛艺术
//
//  Created by zsly on 16/2/2.
//
//

#import "LocationInfo.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationInfo()<CLLocationManagerDelegate>
@property (nonatomic,strong) CLLocationManager* locationManager;
@property (nonatomic,strong) NSString*callbackId;
@end


@implementation LocationInfo
-(void)get:(CDVInvokedUrlCommand*)command
{
    self.callbackId=command.callbackId;
    [self checkAuthority];
}

-(void)checkAuthority
{
    if([CLLocationManager locationServicesEnabled])
    {
        if (!self.locationManager)
        {
            self.locationManager = [[CLLocationManager alloc] init];
        }
        _locationManager.delegate           = self;
        _locationManager.distanceFilter     = 500;
        _locationManager.desiredAccuracy    = kCLLocationAccuracyBestForNavigation;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
        {
            [_locationManager requestWhenInUseAuthorization];
            // 开始时时定位
        }
        [_locationManager startUpdatingLocation];
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        [self handleFailedMsg:@"定位服务未开启"];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [_locationManager requestWhenInUseAuthorization];
            }
            break;
        case kCLAuthorizationStatusDenied:
        {
            
        }
        default:
            break;
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // NSLog(@"error:%@",error);
    [self handleFailedMsg:@"定位服务未开启"];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    // NSLog(@"%ld", (unsigned long)[locations count]);
    
    CLLocation *newLocation             = locations[0];
    //    CLLocationCoordinate2D coordinate   = newLocation.coordinate;
    //    NSLog(@"经度：%f,纬度：%f",coordinate.longitude,coordinate.latitude);
    
    [manager stopUpdatingLocation];
    
    //------------------位置反编码---5.0之后使用-----------------
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation
                   completionHandler:^(NSArray *placemarks, NSError *error){
                       if(error)
                       {
                           NSString *error_msg=[NSString stringWithFormat:@"定位解析失败:%@",error.description];
                           [self handleFailedMsg:error_msg];
                       }
                       else
                       {
                           for (CLPlacemark *place in placemarks) {
                               NSString* province      = place.administrativeArea;
                               NSString* city         = place.locality;
                               NSString* district         = place.subLocality;
                               CDVPluginResult*pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"province":province,@"city":city,@"district":district}];
                               [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
                           }
                       }
                   }];
}



-(void)handleFailedMsg:(NSString*)msg
{
     CDVPluginResult*pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:msg];
     [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

@end
