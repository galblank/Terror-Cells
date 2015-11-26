//
//  WLSimpleMapAnnotation.m
//
//  Created by William LaFrance on 2/23/10.
//  Public Domain
//

#import "MyMapAnnotation.h"

@implementation MyMapAnnotation

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize mapItem = _mapItem;
@synthesize allitemsForCountry;

#pragma mark -
#pragma mark Class Methods
#pragma mark -


+ (MyMapAnnotation *)mapAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate {
	return [self mapAnnotationWithCoordinate:coordinate title:nil subtitle:nil];
}


+ (MyMapAnnotation *)mapAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title {
	return [self mapAnnotationWithCoordinate:coordinate title:title subtitle:nil];
}


+ (MyMapAnnotation *)mapAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subtitle:(NSString *)subtitle {
	MyMapAnnotation *annotation = [[[self alloc] init] autorelease];
	annotation.coordinate = coordinate;
	annotation.title = title;
	annotation.subtitle = subtitle;
	return annotation;
}


#pragma mark -
#pragma mark NSObject
#pragma mark -

- (void)dealloc {
	[_title release];
	[_subtitle release];
	[super dealloc];
}


#pragma mark -
#pragma mark Initializers
#pragma mark -

- (MyMapAnnotation *)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
	return [self initWithCoordinate:coordinate title:nil subtitle:nil];
}


- (MyMapAnnotation *)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title {
	return [self initWithCoordinate:coordinate title:title subtitle:nil];
}


- (MyMapAnnotation *)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subtitle:(NSString *)subtitle {
	if (self = [super init]) {
		self.coordinate = coordinate;
		self.title = title;
		self.subtitle = subtitle;
        self.mapItem = [[MapItem alloc] init];
	}
	return self;
}

@end