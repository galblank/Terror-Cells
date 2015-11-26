//
//  WLSimpleMapAnnotation.h
//
//  Created by William LaFrance on 2/23/10.
//  Public Domain
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "MapItem.h"

@interface MyMapAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D _coordinate;
    NSString * _title;
    NSString * _subtitle;
    MapItem * _mapItem;
    NSMutableArray *allitemsForCountry;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, retain) MapItem *mapItem;
@property (nonatomic, retain)NSMutableArray *allitemsForCountry;
+ (MyMapAnnotation *)mapAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate;
+ (MyMapAnnotation *)mapAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title;
+ (MyMapAnnotation *)mapAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subtitle:(NSString *)subtitle;

- (MyMapAnnotation *)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (MyMapAnnotation *)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title;
- (MyMapAnnotation *)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subtitle:(NSString *)subtitle;

@end
