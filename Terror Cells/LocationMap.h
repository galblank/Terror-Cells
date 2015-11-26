//
//  MainViewController.h
//  iLimo
//
//  Created by Gal Blank on 5/3/12.
//  Copyright (c) 2012 Vivat Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKReverseGeocoder.h>
#import "GetLocationViewController.h"
#import "MyMapAnnotation.h"
#import "DDAnnotation.h"
#import "TripModel.h"
#import "PaintingView.h"
#import "SoundEffect.h"
#import "ASIHTTPRequest.h"
@class WEPopoverController;

@interface LocationMap : UIViewController<UIGestureRecognizerDelegate,UIScrollViewDelegate,MKMapViewDelegate,UIGestureRecognizerDelegate>
{
    NSMutableArray *locations;
    CLLocationCoordinate2D location;
    MKMapView *mapView;
    NSString *centerMapPoint;
    NSString *destinationPoint;
    NSMutableDictionary *project;
    GetLocationViewController *mylocationManager;
    UITextField *inputAddress;
    UITextField *destinationAddress;
    UITextField *tripnickName;
    CGFloat animatedDistance;
    DDAnnotation *currentAnnotation;
    CLLocationCoordinate2D prevlocation;
    UIView *centerPin;
    UILabel *pinBubbleLabel;
    
    UIActivityIndicatorView *activityWheel;
    UIActivityIndicatorView *activityWheelDest;
    
    UIView *destinationPin;
    UILabel *destinationPinLabel;
    
    BOOL bInit;
    int choosingPickupOrDestination;
    
    CGFloat dragHorizontal;
    CGFloat dragVertical;
    
    BOOL bDraggingMap;
    UIButton *destpinButton;
    UIButton *pinButton;
    UIBarButtonItem *viewPathButton;
    
    ////DRAW ROUTE
    UIImageView* routeView;
	
	NSMutableArray* routes;
	
	UIColor* lineColor;
    
    UIButton *bookForNowButton;
    UIButton *bookForLaterButton;
    
    UIView *slidingView;
    UILabel * infoLabel;
    
    BOOL bShowingSlidingView;
    
    CLLocationCoordinate2D pickUpCoordinate;
    CLLocationCoordinate2D destCoordinate;
    
    int centerOn;
    
    WEPopoverController *popoverController;
    Class popoverClass;
    
    BOOL bKeyboardOn;
    
    UITextField *resignResponder;
    
    NSTimer *myTimer;
    int nHelpIndex;
    
    int nInitMap;
    
    id * parent;
    
    UITableView *acView;
    NSMutableArray *autocompleteResults;
    
    TripModel *myTrip;
    
	PaintingView		*drawingView;
    
	SoundEffect			*erasingSound;
	SoundEffect			*selectSound;
	CFTimeInterval		lastTime;
    
    UIButton *loadPaintButton;
    
    UIImage *snapShot;
    NSData *imagedata;
    UITextField *address;
    UIView *searchViewBG;
}
@property(nonatomic)id * parent;
@property (nonatomic, retain) WEPopoverController *popoverController;
@property(nonatomic,retain)NSString *centerMapPoint;
@property(nonatomic,retain)NSMutableDictionary *project;
@property(nonatomic,retain)UIColor* lineColor;
@property(retain)UIImage *snapShot;
@property(retain)NSData *imagedata;

-(void)setLocation:(CLPlacemark*)location;
-(NSString*)getAdrressFromLatLong:(CGFloat)lat lon:(CGFloat)lon;
-(void)callback_loadBooking:(NSString*)destination;
- (void)sendAsyncNowNewIsFinished:(ASIHTTPRequest*)theRequest;
@end
