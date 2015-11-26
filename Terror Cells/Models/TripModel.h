//
//  TripModel.h
//  iLimo
//
//  Created by Gal Blank on 5/26/12.
//  Copyright (c) 2012 Vivat Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKReverseGeocoder.h>

@interface TripModel : NSObject
{
    int nTripId;
    int nIsSpecial;
    NSString *tripNickname;
    NSString *strTripId;
    NSString *pickupLocation;
    NSString *destination;
    NSString *price;
    NSString *pickupDateTime;
    CLLocationCoordinate2D coordinates;
    CLLocationCoordinate2D coordinatesDestination;
    NSNumber *distance;
    NSString *distanceStr;
    NSString *duration;
    NSNumber *customerId;
    double timesince1970;
    double doublePrice;
    NSString *couponApplied;
}
@property(nonatomic)double timesince1970;
@property(nonatomic)double doublePrice;
@property(nonatomic)int nIsSpecial;
@property(nonatomic)int nTripId;
@property(nonatomic,retain)NSString *couponApplied;
@property(nonatomic,retain)NSString *tripNickname;
@property(nonatomic,retain)NSString *strTripId;
@property(nonatomic,retain)NSString *distanceStr;
@property(nonatomic,retain)NSString *duration;
@property(nonatomic,retain)NSString *pickupLocation;
@property(nonatomic,retain)NSString *destination;
@property(nonatomic,retain)NSString *price;
@property(nonatomic,retain)NSString *pickupDateTime;
@property(nonatomic,retain)NSNumber *distance;
@property(nonatomic,retain)NSNumber *customerId;
@property(nonatomic)CLLocationCoordinate2D coordinates;
@property(nonatomic)CLLocationCoordinate2D coordinatesDestination;
@end
