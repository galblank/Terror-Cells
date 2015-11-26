//
//  MainViewController.m
//  iLimo
//
//  Created by Gal Blank on 5/3/12.
//  Copyright (c) 2012 Vivat Inc. All rights reserved.
//

#import "LocationMap.h"
#import "MyMapAnnotation.h"
#import "CustomMapAnnotationView.h"
#import "DDAnnotation.h"
#import "DDAnnotationView.h"
#import "Globals.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "CommManager.h"
#import "AutoCompleteResult.h"
#import "PaintingView.h"
#import "SoundEffect.h"


#define PICKUPBUTTON_ON  0
#define PICKUPBUTTON_OFF 1
#define DESTINATIONBUTTON_ON 2
#define DESTINATIONBUTTON_OFF 3

//CONSTANTS:

#define kPaletteHeight			30
#define kPaletteSize			5
#define kMinEraseInterval		0.5

// Padding for margins
#define kLeftMargin				10.0
#define kTopMargin				10.0
#define kRightMargin			10.0

//FUNCTIONS:
/*
 HSL2RGB Converts hue, saturation, luminance values to the equivalent red, green and blue values.
 For details on this conversion, see Fundamentals of Interactive Computer Graphics by Foley and van Dam (1982, Addison and Wesley)
 You can also find HSL to RGB conversion algorithms by searching the Internet.
 See also http://en.wikipedia.org/wiki/HSV_color_space for a theoretical explanation
 */
static void HSL2RGB(float h, float s, float l, float* outR, float* outG, float* outB)
{
	float			temp1,
    temp2;
	float			temp[3];
	int				i;
	
	// Check for saturation. If there isn't any just return the luminance value for each, which results in gray.
	if(s == 0.0) {
		if(outR)
			*outR = l;
		if(outG)
			*outG = l;
		if(outB)
			*outB = l;
		return;
	}
	
	// Test for luminance and compute temporary values based on luminance and saturation
	if(l < 0.5)
		temp2 = l * (1.0 + s);
	else
		temp2 = l + s - l * s;
    temp1 = 2.0 * l - temp2;
	
	// Compute intermediate values based on hue
	temp[0] = h + 1.0 / 3.0;
	temp[1] = h;
	temp[2] = h - 1.0 / 3.0;
    
	for(i = 0; i < 3; ++i) {
		
		// Adjust the range
		if(temp[i] < 0.0)
			temp[i] += 1.0;
		if(temp[i] > 1.0)
			temp[i] -= 1.0;
		
		
		if(6.0 * temp[i] < 1.0)
			temp[i] = temp1 + (temp2 - temp1) * 6.0 * temp[i];
		else {
			if(2.0 * temp[i] < 1.0)
				temp[i] = temp2;
			else {
				if(3.0 * temp[i] < 2.0)
					temp[i] = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - temp[i]) * 6.0;
				else
					temp[i] = temp1;
			}
		}
	}
	
	// Assign temporary values to R, G, B
	if(outR)
		*outR = temp[0];
	if(outG)
		*outG = temp[1];
	if(outB)
		*outB = temp[2];
}

@interface LocationMap ()
- (void)coordinateChanged_:(NSNotification *)notification;
@end


@implementation LocationMap

@synthesize centerMapPoint,project,lineColor,popoverController,parent,snapShot;


- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"motionBegan");
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"motionEnded");
	if (motion == UIEventSubtypeMotionShake )
	{
		// User was shaking the device. Post a notification named "shake".
		[[NSNotificationCenter defaultCenter] postNotificationName:@"shake" object:self];
	}
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"motionCancelled");
}

- (BOOL)canBecomeFirstResponder {
    NSLog(@"canBecomeFirstResponder");
    return YES;
}

// Called when receiving the "shake" notification; plays the erase sound and redraws the view
-(void) eraseView
{
	if(CFAbsoluteTimeGetCurrent() > lastTime + kMinEraseInterval) {
		[erasingSound play];
		[drawingView erase];
		lastTime = CFAbsoluteTimeGetCurrent();
	}
}

- (void)loadPaint
{
    
    if(loadPaintButton.tag == 1){
        [loadPaintButton setTitle:@"Tap here when done" forState:UIControlStateNormal];
        [loadPaintButton setTag:2];
    }
    else{
        [self removePaint];
        return;
    }
    
    
    [self becomeFirstResponder];
	CGRect					rect = [[UIScreen mainScreen] applicationFrame];
	CGFloat					components[3];
	drawingView = [[PaintingView alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, self.view.frame.size.height - 60)];
	// Create a segmented control so that the user can choose the brush color.
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"Red.png"],
                                             [UIImage imageNamed:@"Yellow.png"],
                                             [UIImage imageNamed:@"Green.png"],
                                             [UIImage imageNamed:@"Blue.png"],
                                             [UIImage imageNamed:@"Purple.png"],
                                             nil]];
	[segmentedControl setFrame:CGRectMake(0, 400, 320, 40)];
	// Compute a rectangle that is positioned correctly for the segmented control you'll use as a brush color palette
	CGRect frame = CGRectMake(rect.origin.x + kLeftMargin, rect.size.height - kPaletteHeight - kTopMargin, rect.size.width - (kLeftMargin + kRightMargin), kPaletteHeight);
	segmentedControl.frame = frame;
	// When the user chooses a color, the method changeBrushColor: is called.
	[segmentedControl addTarget:self action:@selector(changeBrushColor:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	// Make sure the color of the color complements the black background
	segmentedControl.tintColor = [UIColor darkGrayColor];
	// Set the third color (index values start at 0)
	segmentedControl.selectedSegmentIndex = 2;
	 
	// Add the control to the window
	//[self.view addSubview:segmentedControl];
	// Now that the control is added, you can release it
	[segmentedControl release];
	
    // Define a starting color
	HSL2RGB((CGFloat) 2.0 / (CGFloat)kPaletteSize, kSaturation, kLuminosity, &components[0], &components[1], &components[2]);
	// Defer to the OpenGL view to set the brush color
    
	[drawingView setBrushColorWithRed:components[0] green:components[1] blue:components[2]];
	[drawingView setBackgroundColor:[UIColor clearColor]];
	// Load the sounds
	NSBundle *mainBundle = [NSBundle mainBundle];
	erasingSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Erase" ofType:@"caf"]];
	selectSound =  [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Select" ofType:@"caf"]];
    
	// Erase the view when recieving a notification named "shake" from the NSNotificationCenter object
	// The "shake" nofification is posted by the PaintingWindow object when user shakes the device
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eraseView) name:@"shake" object:nil];
    [self.view addSubview:drawingView];
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	nHelpIndex = 0;
	// NOTE: This is optional, DDAnnotationCoordinateDidChangeNotification only fired in iPhone OS 3, not in iOS 4.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coordinateChanged_:) name:@"DDAnnotationCoordinateDidChangeNotification" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	
	[super viewWillDisappear:animated];
    NSLog(@"Stopping location manager");
	[mylocationManager stopUpdatingLocation:NSLocalizedString(@"Acquired Location", @"Acquired Location")];
	// NOTE: This is optional, DDAnnotationCoordinateDidChangeNotification only fired in iPhone OS 3, not in iOS 4.
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"DDAnnotationCoordinateDidChangeNotification" object:nil];	
    [inputAddress resignFirstResponder];
    [self hideWaitingView];
}

- (void)removePaint {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self resignFirstResponder];
    [loadPaintButton setTitle:@"Tap to draw boundaries" forState:UIControlStateNormal];
    [loadPaintButton setTag:1];
    [drawingView erase];
    routes = [drawingView myShape];
    //[drawingView playbackFromPointsArray];
    [drawingView saveShape];
    [drawingView removeFromSuperview];
    [self updateRouteView];
}

/*convert a CGPoint to a CLLocation according to a mapView*/
- (CLLocation*)pointToLocation:(MKMapView *)mapView fromPoint:(CGPoint)fromPoint
{
    CLLocationCoordinate2D coord = [mapView convertPoint:fromPoint toCoordinateFromView:drawingView];
    return [[[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude] autorelease];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    centerOn = 0;
    [super viewDidLoad];
    [self setTitle:@"Suspects location"];
    choosingPickupOrDestination=2;
    [self.view setBackgroundColor:[UIColor clearColor]];
    bShowingSlidingView = NO;
    
    bInit = YES;
    nInitMap = 0;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finish)];
    self.navigationItem.rightBarButtonItem = doneButton;
    CGFloat startYPos  = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
    
    searchViewBG = [[UIView alloc] initWithFrame:CGRectMake(0, startYPos, self.view.bounds.size.width, 40)];
    searchViewBG.backgroundColor = [UIColor clearColor];
    searchViewBG.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:searchViewBG];
    
    address = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, self.view.frame.size.width - 20,30)];
    address.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [address setBorderStyle:UITextBorderStyleRoundedRect];
    [address  setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0]];
    address.delegate = self;
    address.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [address setReturnKeyType:UIReturnKeyDone];
    [address setTextColor:[UIColor blackColor]];
    [address setBackgroundColor:[UIColor whiteColor]];
    address.keyboardAppearance = UIKeyboardAppearanceDark;
    [address setPlaceholder:NSLocalizedString(@"Type in Address or Location", nil)];
    address.layer.cornerRadius=8.0f;
    address.tag = 2;
    [searchViewBG  addSubview:address];
    [self.view addSubview:searchViewBG];
    
    locations = [[NSMutableArray alloc] init];
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, searchViewBG.frame.origin.y + searchViewBG.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (searchViewBG.frame.origin.y + searchViewBG.frame.size.height) - 30)];
    mapView.showsUserLocation=TRUE;
	mapView.mapType=MKMapTypeStandard;
	mapView.delegate=self;
    mapView.scrollEnabled = YES;
    bDraggingMap = NO;
	/*Region and Zoom*/
	[self.view addSubview:mapView];

    
    mylocationManager = [[GetLocationViewController alloc] init];
    [mylocationManager setParent:self];
    [mylocationManager setupViewController];
    
    [self buildOverlayView];
    
    dragHorizontal = 0;
    dragVertical = 0;


    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, self.view.frame.size.width, 40)];
	toolbar.tag = 2;
	toolbar.barStyle = UIBarStyleDefault;
    toolbar.tintColor = [UIColor blackColor];
    //toolbar.tintColor = [UIColor colorWithRed:97.0 / 255.0 green:97.0 / 255.0 blue:97.0 / 255.0 alpha:1.0];
	[toolbar sizeToFit];
	[toolbar setTranslucent:YES];
	//Add buttons
    
    

    /////////////MORE/////////////////
    UIImage *moreOnImg = [UIImage imageNamed:@"mapedit.png"];
    moreOnImg = [UIImage imageOfSize:CGSizeMake(35,35) fromImage:moreOnImg];
    UIImageView *imgMapView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, moreOnImg.size.width, moreOnImg.size.height)];
    imgMapView.image = moreOnImg;
    [toolbar addSubview:imgMapView];
    
   	loadPaintButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loadPaintButton setBackgroundColor:[UIColor clearColor]];
    [loadPaintButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [loadPaintButton.titleLabel setTextColor:[UIColor blackColor]];
    loadPaintButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [loadPaintButton setFrame:CGRectMake(moreOnImg.size.width + 5, 5, self.view.frame.size.width - 10 - moreOnImg.size.width, 30)];
    [loadPaintButton.titleLabel setFont:[UIFont fontWithName:@"Optima-Bold" size:14.0]];
    loadPaintButton.titleLabel.numberOfLines = 1;
    loadPaintButton.tag = 1;
    [loadPaintButton setTitle:@"Tap to draw boundaries" forState:UIControlStateNormal];
    [loadPaintButton addTarget:self action:@selector(loadPaint) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:loadPaintButton];
    
    [self.view addSubview:toolbar];
    [self buildAutoCompleteView];
    [self buildOverlayViewPoint];
    routes = [[NSMutableArray alloc] init];
}

-(void)showAutoComplete
{
    CGRect mainViewBounds = self.view.bounds;
    CGRect frame = acView.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.45];
    frame.origin.y = address.frame.size.height + 10 + self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
    frame.size.width = mainViewBounds.size.width;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            frame.size.height = mainViewBounds.size.height - frame.origin.y - 264;
        }
        else
        {
            frame.size.height = mainViewBounds.size.height - frame.origin.y - 362;
        }
    }
    else{
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            frame.size.height = 216;
        }
        else
        {
            frame.size.height = 162;
        }
    }
    acView.frame = frame;
    
    // Slide view
    [UIView commitAnimations];
}

-(void)hideAutoComplete
{
    // Get the frame of this view
    CGRect frame = acView.frame;
    // Set view to this offscreen location
    frame.size.width = 0;
    frame.size.height = 0;
    [UIView animateWithDuration:0.45
                     animations:^{
                         
                         acView.frame = frame;
                     }];
}

- (void)sendAsyncNowNewIsFinished:(ASIHTTPRequest*)theRequest
{
    NSData *myResponseData = [theRequest responseData];
    NSString *results = [[NSString alloc] initWithData:myResponseData encoding:NSUTF8StringEncoding];
    autocompleteResults = [[Parser sharedInstance] parseAutocompleteResults:results];
    [self showAutoComplete];
    [acView reloadData];
}

-(void)buildOverlayViewPoint
{
    UIImage *overlayImage = [UIImage imageNamed:@"mappin.png"];
    float x = mapView.frame.size.width / 2 - (overlayImage.size.width / 2);
    float y = mapView.frame.size.height  / 2 - overlayImage.size.height;
    UIImageView *  locationPointer = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, overlayImage.size.width,overlayImage.size.height)];
    [locationPointer setImage:overlayImage];
    [mapView addSubview:locationPointer];
}

-(void)buildAutoCompleteView
{
    acView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    acView.delegate = self;
    acView.dataSource = self;
    acView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    acView.separatorColor = [UIColor blackColor];
    [acView setBackgroundView:nil];
    [acView setBackgroundView:[[UIView alloc] init]];
    acView.backgroundColor = [UIColor clearColor];
	
	// Setup our list view to autoresizing in case we decide to support autorotation along the other UViewControllers
	acView.autoresizesSubviews = YES;
	acView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:acView];
}

-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)finish
{
    [self captureScreen];
    [parent setLocations:address.text :self.snapShot :self.imagedata];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)loadbothpoints
{
    choosingPickupOrDestination = 0;
    [mapView removeAnnotations:[mapView annotations]];
    [locations removeAllObjects];

    if(destinationPin.tag != -1){
        [destinationPin removeFromSuperview];
        destinationPin.tag = -1;
    }
    
    
    
    DDAnnotation *pointB = [[DDAnnotation alloc] initWithCoordinate:myTrip.coordinatesDestination addressDictionary:nil];
	pointB.title = @"Drop Off";
	pointB.subtitle = myTrip.destination;
    [locations addObject:pointB];
    [mapView addAnnotations:locations];
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in mapView.annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        if (MKMapRectIsNull(zoomRect)) {
            zoomRect = pointRect;
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    [mapView setVisibleMapRect:zoomRect animated:YES];
 //   self.lineColor = [[Globals sharedInstance] titleBarColor];
   // [self updateRouteView];
    [self showWaitingView];
}

-(void)focusOnPin:(UIButton*)button
{
    MKCoordinateRegion region;
	
	MKCoordinateSpan span;
	centerOn = button.tag;
	
	span.latitudeDelta=0.01;
	
	span.longitudeDelta=0.01; 
    
	region.span=span;
    [mapView removeOverlays:[mapView overlays]];
    [mapView removeAnnotations:[mapView annotations]];
    
    switch (button.tag) {
        case 1:
        {
            //CLLocationCoordinate2D center = [[Globals sharedInstance] getLocationFromAddressString:myTrip.pickupLocation];
            region.center=myTrip.coordinates;
            
            centerPin.tag = 1;
            pinButton.tag = PICKUPBUTTON_ON;
            if(destinationPin.tag != -1){
                [destinationPin removeFromSuperview];
                destinationPin.tag = -1;
            }
            [self.view addSubview:centerPin];
            [centerPin setFrame:CGRectMake(130, 190, 40, 40)];
            [pinBubbleLabel setText:@" Tap to Set "];
            choosingPickupOrDestination = 1;
            [inputAddress setBackgroundColor:[UIColor whiteColor]];
            [inputAddress setTextColor:[UIColor magentaColor]];
            inputAddress.enabled = YES;
            
            //destinationAddress.enabled = NO;
            [destinationAddress setBackgroundColor:[UIColor whiteColor]];
            [destinationAddress setTextColor:[UIColor blackColor]];
            //add circle with 5km radius where user touched down...
            //MKCircle *circle = [MKCircle circleWithCenterCoordinate:center radius:50];
            //[mapView addOverlay:circle];
        }
            break;
        case 2:
        {
            //CLLocationCoordinate2D center = [[Globals sharedInstance] getLocationFromAddressString:myTrip.destination];
            region.center=myTrip.coordinatesDestination;
            [centerPin removeFromSuperview];
            [destinationPin setFrame:CGRectMake(130, 190, 40, 40)];
            [self.view addSubview:destinationPin];
            centerPin.tag = -1;
            choosingPickupOrDestination = 2;
            destpinButton.tag = DESTINATIONBUTTON_ON;
            [destinationPinLabel setText:@" Tap to Set "];
            destinationAddress.text = myTrip.destination;
    
            destinationPin.tag = 2;
            
            [inputAddress setBackgroundColor:[UIColor whiteColor]];
            [inputAddress setTextColor:[UIColor redColor]];
            //inputAddress.enabled = NO;
            
            destinationAddress.enabled = YES;
            [destinationAddress setBackgroundColor:[UIColor whiteColor]];
            [destinationAddress setTextColor:[UIColor magentaColor]];
            //add circle with 5km radius where user touched down...
            //MKCircle *circle = [MKCircle circleWithCenterCoordinate:center radius:50];
            //[mapView addOverlay:circle];
        }
            break;
        default:
            break;
    }
    [mapView setRegion:region animated:TRUE];
    
	//[mapView regionThatFits:region];
}

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay 
{
    MKCircleView* circleView = [[[MKCircleView alloc] initWithOverlay:overlay] autorelease];
    circleView.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    return circleView;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer { 
        return YES;

}

-(void)buildOverlayView
{
    destCoordinate = [mapView convertPoint:CGPointMake(180, 178) toCoordinateFromView:self.view];
    
    /////ROUTE STUFF
    routeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 360)];
    routeView.userInteractionEnabled = NO;
    [mapView addSubview:routeView];
    self.lineColor = [UIColor redColor];
}

-(void)enableDestination
{
    if([destinationAddress.text isEqualToString:@"Type Destination or Move Pin on Map"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Please set destination before proceeding" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    destpinButton.tag = DESTINATIONBUTTON_OFF;
    [destinationPinLabel setText:@" Tap to Change "];
    destinationAddress.text = myTrip.destination;
    choosingPickupOrDestination = 0;
    [destinationAddress setBackgroundColor:[UIColor whiteColor]];
    [destinationAddress setTextColor:[UIColor blackColor]];
    [self loadbothpoints];
}

-(void) updateRouteView {
	CGContextRef context = 	CGBitmapContextCreate(nil,
												  routeView.frame.size.width,
												  routeView.frame.size.height, 
												  8, 
												  4 * routeView.frame.size.width,
												  CGColorSpaceCreateDeviceRGB(),
												  kCGImageAlphaPremultipliedLast);
	
	CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
	CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
	CGContextSetLineWidth(context, 3.0);
	
    for(int i = 0; i < routes.count; i++) {
		CGPoint point = [[routes objectAtIndex:i] CGPointValue];
		NSLog(@"X:%.2f Y:%.2f",point.x,point.y);
		if(i == 0) {
			CGContextMoveToPoint(context, point.x,point.y);
		} else {
			CGContextAddLineToPoint(context, point.x, point.y);
		}
	}
    
	CGContextStrokePath(context);
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	UIImage* img = [UIImage imageWithCGImage:image];
	
	routeView.image = img;
	CGContextRelease(context);

}


-(void)captureScreen
{
	UIGraphicsBeginImageContext(mapView.frame.size);
	[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	self.snapShot = viewImage;
    self.imagedata = UIImageJPEGRepresentation(viewImage, 1.0);
	UIGraphicsEndImageContext();
	//UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
}

-(void)centerMap:(NSString*)strLocation
{
    [locations removeAllObjects];
    MKCoordinateRegion region;
	
	MKCoordinateSpan span;
	
	
	span.latitudeDelta=0.02;
	
	span.longitudeDelta=0.02; 
    
	region.span=span;
    NSMutableArray *latlon = [[Globals sharedInstance] getLocationFromAddressString:strLocation];
	CLLocationCoordinate2D _location = CLLocationCoordinate2DMake([[latlon objectAtIndex:0] doubleValue],[[latlon objectAtIndex:1] doubleValue]);
	region.center=_location;
	DDAnnotation *annotation = [[DDAnnotation alloc] initWithCoordinate:_location addressDictionary:nil];
	annotation.title = @"Your location is:";
    CGFloat lat = annotation.coordinate.latitude;
    CGFloat lon = annotation.coordinate.longitude;
	annotation.subtitle = [self getAdrressFromLatLong:lat lon:lon];
    //[locations addObject:annotation];
	[mapView setRegion:region animated:TRUE];
	
	[mapView regionThatFits:region];
    NSString * labelStr = [NSString stringWithFormat:@"  Your Pickup location:\n   %@",strLocation];
    //[pinBubbleLabel setText:labelStr];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"calloutAccessoryControlTapped");
    DDAnnotationView *ddView = (DDAnnotationView*)view;

    [self centerMap:myTrip.destination];
    
}

-(void)buildLocaitonsArray
{
    locations = [[NSMutableArray alloc] init];
    NSMutableArray *templocations = [project objectForKey:@"locations"];
    for(int i=0;i<templocations.count;i++){
        NSMutableDictionary *oneProject = [templocations objectAtIndex:i];
        CLLocationCoordinate2D _location1;
        _location1.latitude = [[oneProject objectForKey:@"latitude"] doubleValue];
        _location1.longitude = [[oneProject objectForKey:@"longitude"] doubleValue];
        MyMapAnnotation *myLocation1 = [[MyMapAnnotation alloc] initWithCoordinate:_location1 title:[oneProject objectForKey:@"geoLocName"]];
        [locations addObject:myLocation1];
    }
    if(locations == nil || locations.count == 0){
        [self getLocationFromAddressString:self.centerMapPoint];
        DDAnnotation *myLocation1 = [[DDAnnotation alloc] initWithCoordinate:location addressDictionary:nil];
        //DDAnnotation *myLocation1 = [[DDAnnotation alloc] initWithCoordinate:location title:self.centerMapPoint];
        [locations addObject:myLocation1];
    }
}


- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (DDAnnotationView *anAnnotationView in views) {
		[anAnnotationView setCanShowCallout:YES];
        //[anAnnotationView addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:ANNOTATION_SELECTED_DESELECTED];
        UIButton * pickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [pickButton setBackgroundImage:[UIImage imageNamed:@"stretch_button.png"] forState:UIControlStateNormal];
        [pickButton setTitle:@"Pick" forState:UIControlStateNormal];
        [pickButton setFont:[UIFont fontWithName:@"Arial-BoldMT" size:12.0]];
        [pickButton addTarget:self action:@selector(bookNow) forControlEvents:UIControlEventTouchUpInside];
        [pickButton setFrame:CGRectMake(0, 0, 40, 35)];
        [anAnnotationView setSelected:NO];
        //[anAnnotationView setRightCalloutAccessoryView:pickButton];
        
	}

}

-(void)setpickUpLocation
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:[NSString stringWithFormat:@"Your current location is %@",self.centerMapPoint]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    return;
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"%f %f",scrollView.frame.origin.x,scrollView.frame.origin.y);
}



//////////////////////MAIN MAP CLASSES///////////////////////
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    bDraggingMap = YES;
    if(resignResponder){
        [resignResponder resignFirstResponder];
    }
    switch(choosingPickupOrDestination){
        case 1:
            //pickup
            pinBubbleLabel.text = @"";
            [activityWheel startAnimating];
            break;
        case 2:
            //destination
            destinationPinLabel.text = @"";
            [activityWheelDest startAnimating];
            break;
    }//switch
    
    
    
}


//////////////////////////////////////////////////////////////////
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"Did: %f %f",[mapView centerCoordinate].latitude,[mapView centerCoordinate].longitude);
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
    
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {
            NSString *addressTxt = [[Globals sharedInstance] buildAddressFromLocation:placemark];
            address.text = addressTxt;
        }
    }];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState 
{
    NSLog(@"DRaggin state");
	if (oldState == MKAnnotationViewDragStateDragging) {
		DDAnnotation *annotation = (DDAnnotation *)annotationView.annotation;
        
        CGFloat lat = annotation.coordinate.latitude;
        CGFloat lon = annotation.coordinate.longitude;
        NSString *address = [self getAdrressFromLatLong:lat lon:lon];
        [locations removeAllObjects];
        [locations addObject:annotation];
        [mapView selectAnnotation:[locations objectAtIndex:0] animated:YES];
        //NSLog(address);
        //[annotation setTitle:centerMapPoint];
		annotation.subtitle = address;
	}
}

-(NSString*)getAdrressFromLatLong:(CGFloat)lat lon:(CGFloat)lon{
	NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true",lat,lon];
    NSString *responseString = [[WapConnector sharedInstance] getlocalFullUrl:urlString];
    //NSLog(@"responseString %@ ",[[responseString JSONValue] valueForKey:@"results"]);
    
	if ([responseString length] > 0) {
        
		if ([[[responseString JSONValue] valueForKey:@"status"] isEqualToString:@"OK"] ) {
			//NSLog(@"responseString %@  %@",[[[responseString JSONValue] valueForKey:@"results"] objectAtIndex:0]);
			NSArray *resultsArray = [[responseString JSONValue] valueForKey:@"results"];
			NSString *address = nil;
            
			if ([resultsArray count]>0) {
				address = [[resultsArray objectAtIndex:0] valueForKey:@"formatted_address"];
                //centerMapPoint = address;
                //myTrip.coordinates = CLLocationCoordinate2DMake(lat, lon);
			}
            return address;
		} else {
            return @"Uknown";
		}
	}
}

-(void)handleTapped:(UIGestureRecognizer *)sender {
	//Code to respond to gesture here
    //CGPoint point = [sender locationInView:self.view];
    UIButton *btn = (UIButton *) sender.view;
    MKAnnotationView *av = (MKAnnotationView *)[btn superview];
    id<MKAnnotation> ann = av.annotation;
    NSLog(@"handlePinButtonTap: ann.title=%@", ann.title);
    if([ann.title isEqualToString:@"Pickup"]){
        choosingPickupOrDestination = 1;
        [self callbackFromPopup:0];
    }
    else{
        choosingPickupOrDestination = 2;
        [self callbackFromPopup:1];
    }
    [self lightTextField];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView 
            viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annView = (MKAnnotationView *)[mapView 
                                                     dequeueReusableAnnotationViewWithIdentifier: @"pin"];
    if (annView == nil)
    {
        annView = [[[MKAnnotationView alloc] initWithAnnotation:annotation 
                                                reuseIdentifier:@"pin"] autorelease];
        
        annView.frame = CGRectMake(0, 0, 40, 40);
        
        UIButton *pinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        pinButton.frame = CGRectMake(0, 0, 35, 40);
        
        if([annotation.title isEqualToString:@"Pickup"]){
            [pinButton setImage:[UIImage imageNamed:@"red-pointer.png"] forState:UIControlStateNormal];
        }
        else{
            [pinButton setImage:[UIImage imageNamed:@"green-pointer.png"] forState:UIControlStateNormal];
        }
        pinButton.tag = 10;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] 
                                       initWithTarget:self action:@selector(handleTapped:)];
        tap.numberOfTapsRequired = 1;
        tap.delegate = self;
        [pinButton addGestureRecognizer:tap];
        [tap release];
        
        [annView addSubview:pinButton]; 
    }
    
    annView.annotation = annotation;
    
    UIButton *pb = (UIButton *)[annView viewWithTag:10];
    [pb setTitle:annotation.title forState:UIControlStateNormal];
    
    return annView;
}


///callback
-(void)setLocation:(CLPlacemark*)location :(CLLocationCoordinate2D)coordinates
{
    CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:prevlocation.latitude longitude:prevlocation.longitude];
    CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:coordinates.latitude longitude:coordinates.longitude];
    CLLocationDistance distance = [loc1 distanceFromLocation:loc2];
    if(distance >= 300){
        prevlocation = coordinates;
    }
    else{
        return;
    }
    self.centerMapPoint = [NSString stringWithFormat:@"%@,%@,%@",[location name],[location locality],[location administrativeArea]];
    [self centerMap:self.centerMapPoint];
    [inputAddress setText:self.centerMapPoint];
    [myTrip setPickupLocation:self.centerMapPoint];
    [myTrip setCoordinates:coordinates];
    
    //[mapView selectAnnotation:[locations objectAtIndex:0] animated:YES];
}

#pragma mark -
#pragma mark DDAnnotationCoordinateDidChangeNotification

// NOTE: DDAnnotationCoordinateDidChangeNotification won't fire in iOS 4, use -mapView:annotationView:didChangeDragState:fromOldState: instead.
- (void)coordinateChanged_:(NSNotification *)notification {
	NSLog(@"%f %f",[mapView centerCoordinate].latitude,[mapView centerCoordinate].longitude);
	DDAnnotation *annotation = notification.object;
	annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
}

-(void)lightTextField
{
    bKeyboardOn = YES;
    switch (choosingPickupOrDestination) {
        case 1:
        {
            pinButton.tag = PICKUPBUTTON_ON;
            [pinBubbleLabel setText:@" Tap to Set "];
            [inputAddress setBackgroundColor:[UIColor whiteColor]];
            [inputAddress setTextColor:[UIColor magentaColor]];
            inputAddress.enabled = YES;
            [destinationAddress setBackgroundColor:[UIColor whiteColor]];
            [destinationAddress setTextColor:[UIColor blackColor]];
        }
            break;
        case 2:
        {
            destpinButton.tag = DESTINATIONBUTTON_ON;
            [destinationPinLabel setText:@" Tap to Set "];
            [inputAddress setBackgroundColor:[UIColor whiteColor]];
            [inputAddress setTextColor:[UIColor redColor]];
            destinationAddress.enabled = YES;
            [destinationAddress setBackgroundColor:[UIColor whiteColor]];
            [destinationAddress setTextColor:[UIColor magentaColor]];
        }
            break;
        default:
            break;
    }
    
    /*if(centerPin.tag != -1){
        [centerPin removeFromSuperview];
        [centerPin setTag:-1];
    }
    if(destinationPin.tag != -1){
        [destinationPin removeFromSuperview];
        [destinationPin setTag:-1];
    }*/
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if(textField.tag != 500){
        choosingPickupOrDestination = textField.tag;
    }
    
    if([textField.text isEqualToString:@"Type Destination or Move Pin on Map"]){
        textField.text = @"";
    }
    
    [self lightTextField];
    [self hideWaitingView];
    resignResponder = textField;
    
    static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
    static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
    static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
    static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
    static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
    
    CGRect textFieldRect =
    [self.view convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations]; 
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations]; 
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if([textField.text isEqualToString:@"Type Destination or Move Pin on Map"] || textField.tag == 500){
        return YES;
    }
    else if(textField.text.length == 0){
        textField.text = @"Type Destination or Move Pin on Map";
        return YES;
    }
   
    
    BOOL bSkipLoadingBothPoints = NO;
    
    if([textField.text isEqualToString:myTrip.destination]){
        bSkipLoadingBothPoints = YES;
    }
    else{
        NSMutableArray *latlon = [[Globals sharedInstance] getLocationFromAddressString:textField.text];
        CLLocationCoordinate2D _location = CLLocationCoordinate2DMake([[latlon objectAtIndex:0] doubleValue],[[latlon objectAtIndex:1] doubleValue]);
        [myTrip setCoordinatesDestination:_location];
        [myTrip setDestination:textField.text];
        NSLog(@"%@",myTrip.destination);
    }
    
    if(bSkipLoadingBothPoints == NO){
        [self loadbothpoints];
    }
    else{
        [textField setBackgroundColor:[UIColor whiteColor]];
        if(textField.tag == 1){
            [textField setTextColor:[UIColor redColor]];
        }
        else{
            [textField setTextColor:[UIColor blackColor]];
        }
    }
    if(centerPin.tag == -1 && choosingPickupOrDestination == 1){
        //switch pins
        [self callbackFromPopup:0];
    }
    else if(destinationPin.tag == -1 && choosingPickupOrDestination == 2){
        //switch pins
        [self callbackFromPopup:1];
    }
	return YES;
}



-(void)buildSlidingView
{
    slidingView = [[UIView alloc] initWithFrame:CGRectMake(0, 480, 320, 40)];
    [slidingView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    //slidingView.layer.cornerRadius = 6;
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.titleLabel.backgroundColor = [[Globals sharedInstance] titleBarColor];
    [closeBtn setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(hideWaitingView) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setFrame:CGRectMake(290,5, 24, 24)];
    [slidingView addSubview:closeBtn];
    
    infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 270, 30)];
    [infoLabel setBackgroundColor:[UIColor clearColor]];
    [infoLabel setNumberOfLines:0];
    [infoLabel setTextColor:[UIColor whiteColor]];
    [infoLabel setTextAlignment:UITextAlignmentLeft];
    [infoLabel setFont:[UIFont fontWithName:@"Arial" size:14.0]];
    [slidingView addSubview:infoLabel];
    
    
    UIButton *cancelTrip = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelTrip setBackgroundImage:[UIImage imageNamed:@"small-light-button.png"] forState:UIControlStateNormal];
    [cancelTrip setTitle:@"Finish" forState:UIControlStateNormal];
    [cancelTrip setFont:[UIFont fontWithName:@"Arial" size:18.0]];
    [cancelTrip setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelTrip addTarget:self action:@selector(cancelTrip) forControlEvents:UIControlEventTouchUpInside];
    [cancelTrip setFrame:CGRectMake(65, 50, 190, 40)];
    //[slidingView addSubview:cancelTrip];
    
    [self.view addSubview:slidingView];   
}

-(void)showWaitingView
{
    bShowingSlidingView = YES;
    NSString *trip=[NSString stringWithFormat:@"Address: %@",myTrip.destination];
    [infoLabel setText:trip];
    // Get the frame of this view
    CGRect frame = slidingView.frame;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.45];
    
    // Set view to this offscreen location
    frame.origin.y = 480 - 100;
    slidingView.frame = frame;
    
    // Slide view
    [UIView commitAnimations];
}

-(void)hideWaitingView
{
    bShowingSlidingView = NO;
    // Get the frame of this view
    CGRect frame = slidingView.frame;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.45];
    
    // Set view to this offscreen location
    frame.origin.y = 480;
    slidingView.frame = frame;
    
    // Slide view
    [UIView commitAnimations];
}

-(void)zoomInMap
{
    MKMapRect zoomRect = MKMapRectNull;
    for (int i = 0;i<2;i++)
    {
        MKMapPoint annotationPoint;
        if(i==0){
            annotationPoint = MKMapPointForCoordinate(myTrip.coordinates);
        }
        else{
            annotationPoint = MKMapPointForCoordinate(myTrip.coordinatesDestination);
        }
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.5, 0.5);
        if (MKMapRectIsNull(zoomRect)) {
            zoomRect = pointRect;
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    [mapView setVisibleMapRect:zoomRect animated:YES];
}


-(void)callbackFromPopup:(int)changeId
{
    changeId += 1;
    UIButton *butn = [UIButton buttonWithType:UIButtonTypeCustom];
    butn.tag = changeId;
    self.lineColor = [UIColor clearColor];
//    [self updateRouteView];
    [self focusOnPin:butn];
    [self hideWaitingView];
}
//////////////TABLE/////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    return autocompleteResults.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"MyIdentifier"; 
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier]; 
	if (cell == nil) 
	{ 
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier] autorelease];
		//cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		[cell.textLabel setUserInteractionEnabled:YES];
        [cell.textLabel setFont:[UIFont systemFontOfSize:13]];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12]];
        [cell.detailTextLabel setTextColor:[UIColor grayColor]];
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [cell setBackgroundColor:[UIColor whiteColor]];
	}
    AutoCompleteResult *oneResult = [autocompleteResults objectAtIndex:indexPath.row];
    [cell.detailTextLabel setText:oneResult.address];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 35.0;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AutoCompleteResult *oneResult = [autocompleteResults objectAtIndex:indexPath.row];
    [self hideAutoComplete];
    [self repositionMapForCenter:CLLocationCoordinate2DMake(oneResult.coordinates.latitude, oneResult.coordinates.longitude)];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField.text.length > 2 && textField.tag == 2){
        //https://maps.googleapis.com/maps/api/place/textsearch/json?query=jcc&sensor=true&key=AIzaSyDnubl66O4G0WbBJmi99BKh4JjS1MAahOE
        NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=%@&location=%f,%f&radius=150000&sensor=true&key=AIzaSyAcJNXhrxJVATF1lcHcEXwSEnmkhuRbyD4",[[WapConnector sharedInstance] urlencode:textField.text],myTrip.coordinates.latitude,myTrip.coordinates.longitude];
        [[WapConnector sharedInstance] sendAsyncGoogle:url withDelegate:self];
    }
    else{
        [self hideAutoComplete];
    }
    return YES;
}

-(void)repositionMapForCenter:(CLLocationCoordinate2D) _location
{
    MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta=0.02;
	span.longitudeDelta=0.02;
	region.span=span;
	region.center=_location;
    [mapView setRegion:region animated:TRUE];
	[mapView regionThatFits:region];
}

@end






