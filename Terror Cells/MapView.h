//
//  NewsView.h
//  iLibRu
//
//  Created by Gal Blank on 7/11/11.
//  Copyright 2011 Mobixie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKReverseGeocoder.h>
#import "MyMapAnnotation.h"

@interface MapView : UIViewController<MKMapViewDelegate,UIPopoverControllerDelegate> {
    MKMapView *mymapView;
	MKReverseGeocoder *geoCoder;
	MKPlacemark *mPlacemark;
	NSMutableArray *annotationsArray;
	CGFloat animatedDistance;
	NSMutableArray *itemsArray;
    UIActivityIndicatorView * activityIndicator;
    NSMutableArray *selectedItemsArray;
    UIPopoverController *_myDocsPickerPopover;
    UIBarButtonItem *barButtonShowSettings;
    UIView *tempZoomView;
}

@property(nonatomic,retain)NSMutableArray *itemsArray;

@end
