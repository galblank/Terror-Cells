//
//  NewsView.m
//  iLibRu
//
//  Created by Gal Blank on 7/11/11.
//  Copyright 2011 Mobixie. All rights reserved.
//

#import "MapView.h"
#import "CommManager.h"
#import "Globals.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "CustomMapAnnotationView.h"
#import "MapItem.h"
#import "DataHandler.h"
#import "UIView+Animation.h"
#import <QuartzCore/QuartzCore.h>
#import "SendMailViewController.h"

@implementation MapView

@synthesize itemsArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Terror Cells Map"];
  
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(sendMail)];
    mymapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    mymapView.delegate=self;
    [self.view addSubview:mymapView];
    itemsArray = [[NSMutableArray alloc] init];
    
    NSString *result = [[WapConnector sharedInstance] getlocalFullUrl:@"https://docs.google.com/uc?export=download&id=0ByIwWqtIPPIXUzVsb2FjQ1I0Zms"];

    
    NSMutableArray * locationsArray = [result componentsSeparatedByString:@"\n"];
    for(NSString *oneloc in locationsArray)
    {
        NSMutableArray *splitted = [oneloc componentsSeparatedByString:@">"];
        MapItem *item = [[MapItem alloc] init];
        item.title = [splitted objectAtIndex:0];
        NSMutableArray *latlong = [[splitted objectAtIndex:1] componentsSeparatedByString:@","];
        item.latitude = [[latlong objectAtIndex:0] doubleValue];
        item.longitude = [[latlong objectAtIndex:1] doubleValue];
        [itemsArray addObject:item];
    }
    [self loadnewsthreaded];

}

-(void)addCell
{
    [[Globals sharedInstance] SendContributionMail:self];
}


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    /*if(countryList.bChangesMade == YES){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Изменения Сохранены" message:@"Вы увидите ваши изменения в следующий раз когда вы зайдёте в раздел Новостей." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        countryList.bChangesMade = NO;
    }*/
    
    /*
    int prevNumberofActiveCountries = [mymapView.annotations count];
    NSMutableDictionary *activecountries = [[DataHandler sharedInstance] readCountryList];
    for(int i=0;i<[mymapView.annotations count];i++){
        MyMapAnnotation *annot = [mymapView.annotations objectAtIndex:i];
        if([[activecountries objectForKey:annot.title] isEqualToString:@"0"] == YES){
            //remove this annotation from the map
            [mymapView removeAnnotation:annot];
        }
    }
    if(prevNumberofActiveCountries < [[[Globals sharedInstance] countryList] count]){
        //add countries
        [self loadnewsthreaded];
    }*/
 
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(mymapView != NULL && [mymapView.annotations count] > 0){
        NSArray *selectedAnnotations = mymapView.selectedAnnotations;
        for(id annotationView in selectedAnnotations) {
            [mymapView deselectAnnotation:annotationView animated:NO];
        }
    }
}


-(void)loadnewsthreaded
{
    if(annotationsArray == nil){
        annotationsArray = [[NSMutableArray alloc] init];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        for (MapItem *item in self.itemsArray){
            MyMapAnnotation *oneAnnotation = [[MyMapAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(item.latitude,item.longitude) title:item.title];
            //[oneAnnotation setSubtitle:item.description];
            [oneAnnotation setMapItem:item];
            [annotationsArray addObject:oneAnnotation];
        }
        
        [mymapView addAnnotations:annotationsArray];
        MKCoordinateRegion region;
        region.center = [[[mymapView annotations] lastObject] coordinate];
        MKCoordinateSpan span;
        span.latitudeDelta=60;
        span.longitudeDelta=60;
        region.span=span;
        [mymapView setRegion:region animated:TRUE];
    });
}


- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    //for (CustomMapAnnotationView *anAnnotationView in views) {
		/*[anAnnotationView setCanShowCallout:YES];
		[anAnnotationView addObserver:self
                           forKeyPath:@"selected"
                              options:NSKeyValueObservingOptionNew
						      context:ANNOTATION_SELECTED_DESELECTED];*/
        //UIButton *disclosureButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
        //[disclosureButton setFrame:CGRectMake(217, 62, disclosureButton.frame.size.width, disclosureButton.frame.size.height)];
        //[disclosureButton addTarget:anAnnotationView action:@selector(showMoreNews) forControlEvents:UIControlEventTouchUpInside];
        //[anAnnotationView addSubview:disclosureButton];
        //[anAnnotationView setSelected:NO];
	//}
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MyMapAnnotation *myann = (MyMapAnnotation*)annotation;  
     
    static NSString *AnnotationViewID = @"annotationViewID";
    
    CustomMapAnnotationView *annotationView = (CustomMapAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    if (annotationView == nil)
    {
        annotationView = [[[CustomMapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID] autorelease];
    }
    [annotationView setParent:self];
    //annotationView.canShowCallout = YES;    
    //annotationView.rightCalloutAccessoryView = disclosureButton;
    annotationView.annotation = annotation;
    
    return annotationView;
	
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"tapped");
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    MyMapAnnotation *annotation = view.annotation;
    NSString *temp = annotation.title;
    NSLog(@"selected %@",temp);
    [self.view addSubviewWithZoomInAnimation:[self buildZoominView:annotation.mapItem] duration:0.55 option:UIViewAnimationOptionCurveEaseOut];
}

-(UIView *)buildZoominView:(MapItem*)item
{

    UIView *zoomInView = [[UIView alloc] initWithFrame:CGRectMake(10,70,self.view.frame.size.width - 20,self.view.frame.size.height - 150)];
    [zoomInView setBackgroundColor:[UIColor blackColor]];
    [zoomInView setAlpha:0.7];
    zoomInView.layer.cornerRadius = 8;
    
    UIImageView * imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
    [imgView setImage:[UIImage imageNamed:@"muslim.png"]];
    [zoomInView addSubview:imgView];
    
    UITextView *title = [[UITextView alloc] initWithFrame:CGRectMake(45, 5,230, 40)];
    title.tag = 1;
    [title setBackgroundColor:[UIColor clearColor]];
    [title setFont:[UIFont fontWithName:@"Optima-Bold" size:14.0]];
    [title setTextColor:[UIColor whiteColor]];
    [title setEditable:NO];
    [title setAlpha:0.8];
    title.layer.cornerRadius = 10;
    title.text = item.title;
    [zoomInView addSubview:title];
    
    UIImageView *iDivider = [[UIImageView alloc] initWithFrame:CGRectMake(5, 65, 295, 5)];
    [iDivider setImage:[UIImage imageNamed:@"divider.png"]];
    [zoomInView addSubview:iDivider];
    
    UITextView *desc = [[UITextView alloc] initWithFrame:CGRectMake(5, 85,290, 295)];
    desc.tag = 1;
    [desc setBackgroundColor:[UIColor clearColor]];
    [desc setFont:[UIFont fontWithName:@"Optima-Bold" size:14.0]];
    [desc setTextColor:[UIColor whiteColor]];
    [desc setEditable:NO];
    [desc setAlpha:0.8];
    desc.layer.cornerRadius = 10;
    desc.text = item.title;
    [zoomInView addSubview:desc];
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake(280, 2, 20, 20)];
    [closeButton setImage:[UIImage imageNamed:@"hide.png"] forState:UIControlStateNormal];
    
    [closeButton addTarget:self action:@selector(hidePopupView) forControlEvents:UIControlEventTouchUpInside];
    [zoomInView addSubview:closeButton];
    tempZoomView = zoomInView;
    return zoomInView;
}

-(void)hidePopupView
{
    
    [tempZoomView removeWithZoomOutAnimation:0.5 option:UIViewAnimationOptionCurveEaseInOut];
}



-(void)sendMail
{
    SendMailViewController *mail = [[SendMailViewController alloc] init];
    [self.navigationController pushViewController:mail animated:YES];
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

@end
