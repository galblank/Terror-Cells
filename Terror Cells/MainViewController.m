//
//  MainViewController.m
//  Backpage
//
//  Created by Gal Blank on 4/13/12.
//  Copyright (c) 2012 Vivat Inc. All rights reserved.
//

#import "MainViewController.h"
#import "CommManager.h"
#import "Globals.h"
#import "NewsViewController.h"
#import "ImageDemoViewController.h"
#import "CustomImagePicker.h"
#import "ProfilesView.h"
#import "UIImage+Resizing.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageManipulation.h"
#import "ProfilesTilesView.h"
#import "MapView.h"
#import "UIView+Animation.h"
#import "NSString+HTML.h"
#import "SettingsView.h"
#import "CapturedView.h"
#import "CommManager.h"
@implementation MainViewController

#define BUTTON_HEIGHT 70
#define LABEL_HEIGHT 20

#define TEXTVIEW_SET_HTML_TEXT(__textView__, __text__)\
do\
{\
if ([__textView__ respondsToSelector: NSSelectorFromString(@"setContentToHTMLString:")])\
[__textView__ performSelector: NSSelectorFromString(@"setContentToHTMLString:") withObject: __text__];\
else __textView__.text = __text__;\
}\
while (0)

#define TEXTVIEW_GET_HTML_TEXT(__textView__, __text__)\
do\
{\
if ([__textView__ respondsToSelector: NSSelectorFromString(@"contentAsHTMLString")])\
__text__ = [__textView__ performSelector: NSSelectorFromString(@"contentAsHTMLString") withObject: nil];\
else\
__text__ = __textView__.text;\
}\
while (0)


@synthesize sectionUrl;

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.navigationItem.titleView = [[Globals sharedInstance] setTitleBar:@"The Base"];
    
    //[[Globals sharedInstance] setBackground:self.view];

    [self setTitle:@"The Base"];

    mainViewMenuTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStylePlain];
    mainViewMenuTable.tag = 1;
	mainViewMenuTable.delegate        = self;
	mainViewMenuTable.dataSource      = self;
    mainViewMenuTable.scrollEnabled   = YES;
	mainViewMenuTable.separatorStyle  = UITableViewCellSeparatorStyleSingleLine;
    mainViewMenuTable.separatorColor  = [UIColor grayColor];
    
    // NOTE: These next two lines are required to fix the issue of the
    // background view not updating it's color properly for a grouped table view.
    [mainViewMenuTable setBackgroundView:nil];
    [mainViewMenuTable setBackgroundView:[[UIView alloc] init]];
    mainViewMenuTable.backgroundColor = [UIColor clearColor];
	
	// Setup our list view to autoresizing in case we decide to support autorotation along the other UViewControllers
	mainViewMenuTable.autoresizesSubviews = YES;
	mainViewMenuTable.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    mainViewMenuTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
	[self.view addSubview:mainViewMenuTable];
    
    //mylocationManager = [[GetLocationViewController alloc] init];
    //[mylocationManager setParent:self];
    
    //[self loadTilesView];
    
    UIButton *settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsBtn setFrame:CGRectMake(0, 0, 35, 35)];
    [settingsBtn setImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
    [settingsBtn addTarget:self action:@selector(loadsettings) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:settingsBtn];
    self.navigationItem.rightBarButtonItem = settingsButton;

    [self loadTilesView];
}


-(void)loadsettings
{
    SettingsView *settng = [[SettingsView alloc] init];
    [self.navigationController pushViewController:settng animated:YES];
}


-(void)buildZoominView:(UIButton*)item
{
    NSMutableDictionary *oneSpecial = [specialOpsArray objectAtIndex:item.tag];

    NSString * wikiSearch = [oneSpecial objectForKey:@"imagename"];
    if([wikiSearch rangeOfString:@"Military Intelligence, Section 5"].location != NSNotFound){
        wikiSearch = @"mi5";
    }
    else if([wikiSearch rangeOfString:@"Military Intelligence, Section 6"].location != NSNotFound){
        wikiSearch = @"mi6";
    }
    else if([wikiSearch rangeOfString:@"Federal Security Service"].location != NSNotFound){
        wikiSearch = @"Federal_Security_Service_(Russia)";
    }
    else if([wikiSearch rangeOfString:@"dst"].location != NSNotFound){
        wikiSearch = @"Direction_de_la_surveillance_du_territoire";
    }
    wikiSearch = [[WapConnector sharedInstance] urlencode:wikiSearch];
    NSString *wikiStr = [NSString stringWithFormat:@"http://en.m.wikipedia.org/w/index.php?title=%@&mobileaction=render",wikiSearch];
    
    
    UIView *zoomInView = [[UIView alloc] initWithFrame:CGRectMake(5,70,self.view.frame.size.width - 10,self.view.frame.size.height - 150)];
    [zoomInView setBackgroundColor:[UIColor blackColor]];
    [zoomInView setAlpha:0.8];
    zoomInView.layer.cornerRadius = 8;
    
    UIImageView * imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 90, 90)];
    [imgView setImage:[oneSpecial objectForKey:@"image"]];
    [zoomInView addSubview:imgView];
    
    UITextView *title = [[UITextView alloc] initWithFrame:CGRectMake(100,40,175, 70)];
    title.tag = 1;
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[UIFont fontWithName:@"Optima-Bold" size:16.0]];
    [title setTextColor:[UIColor whiteColor]];
    [title setEditable:NO];
    [title setAlpha:0.8];
    title.layer.cornerRadius = 10;
    title.text = wikiSearch;
    [zoomInView addSubview:title];
    
    
    UIWebView *wikiview = [[UIWebView alloc] initWithFrame:CGRectMake(5, 140,300, 255)];
    [wikiview setBackgroundColor:[UIColor clearColor]];
    [wikiview sizeThatFits:CGSizeMake(300, 255)];
    [wikiview loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:wikiStr]]];
    [zoomInView addSubview:wikiview];
    
    UITextView *desc = [[UITextView alloc] initWithFrame:CGRectMake(5, 140,300, 255)];
    desc.tag = 1;
    [desc setBackgroundColor:[UIColor whiteColor]];
    [desc setFont:[UIFont fontWithName:@"Optima-Bold" size:14.0]];
    [desc setTextColor:[UIColor blackColor]];
    [desc setEditable:NO];
    [desc setAlpha:0.8];
    [desc sizeThatFits:CGSizeMake(290, 255)];
    desc.layer.cornerRadius = 10;

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake(280, 2, 20, 20)];
    [closeButton setImage:[UIImage imageNamed:@"hide.png"] forState:UIControlStateNormal];
    
    [closeButton addTarget:self action:@selector(hidePopupView) forControlEvents:UIControlEventTouchUpInside];
    [zoomInView addSubview:closeButton];
    tempZoomView = zoomInView;
    [self.view addSubviewWithZoomInAnimation:zoomInView duration:0.55 option:UIViewAnimationOptionCurveEaseOut];
}

-(void)hidePopupView
{
    
    [tempZoomView removeWithZoomOutAnimation:0.5 option:UIViewAnimationOptionCurveEaseInOut];
}

-(void)loadTilesView
{
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5, self.view.frame.size.height - 70, self.view.frame.size.width - 10, 70)];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    //NSArray * paths = [NSBundle pathsForResourcesOfType: @"png" inDirectory: [[NSBundle mainBundle] bundlePath]];
    NSMutableArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:@".png" inDirectory:@"specialforces"].mutableCopy;
    int i = 0;
    int lastLen = 0;
    specialOpsArray = [[NSMutableArray alloc] init];
    for ( NSString * path in paths )
    {
        NSMutableDictionary *oneSpecial = [[NSMutableDictionary alloc] init];
        NSString *imagename = [NSString stringWithFormat:@"%@",[path lastPathComponent]];
        [oneSpecial setObject:[[Globals sharedInstance] speciaoOrgFromImageName:imagename] forKey:@"imagename"];
        UIButton *specopImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        [specopImageView setFrame:CGRectMake(lastLen, 0, 60, 60)];
        [specopImageView setTag:i];
        [specopImageView addTarget:self action:@selector(buildZoominView:) forControlEvents:UIControlEventTouchUpInside];
        lastLen += 60 + 5;
        UIImage *specOpImage = [UIImage imageNamed:imagename];
        specOpImage = [ImageManipulation makeRoundCornerImage:specOpImage :10 :10];
        [oneSpecial setObject:specOpImage forKey:@"image"];
        [specopImageView setImage:specOpImage forState:UIControlStateNormal];
        [scrollView addSubview:specopImageView];
        [specialOpsArray addObject:oneSpecial];
        i++;
    }
    
    [scrollView setContentSize:CGSizeMake(lastLen, 60)];
    [self.view addSubview:scrollView];
    scrollingTo = 201;
    scrollingRight = YES;
    lastHeight = lastLen;
    //[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(scroll) userInfo:nil repeats:YES];
    
}

- (void) scroll
{
    [scrollView scrollRectToVisible:CGRectMake(5, 320,scrollingTo, 100) animated:YES];
    if(scrollingTo >= lastHeight){
        scrollingRight = NO;
    }
    else if(scrollingTo <= 0){
        scrollingRight = YES;
    }
    
    if(scrollingRight){
        scrollingTo += 1;
    }
    else{
        scrollingTo -= 1;
    }
}

-(void)gotoProfilesKilled
{
    CapturedView * cap = [[CapturedView alloc] init];
    [self.navigationController pushViewController:cap animated:YES];
}

-(void)gotoViewMap
{
    MapView *map = [[MapView alloc] init];
    [self.navigationController pushViewController:map animated:YES];
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


/////////////TABLE///////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    [tableView setBackgroundColor:[UIColor clearColor]];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
        [cell.textLabel setTextColor:[UIColor grayColor]];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.textLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:17.0]];
    }

    if(indexPath.row == 0){
            [cell.textLabel setText:@"Terror Cells World Map"];
        cell.imageView.image = [UIImage imageNamed:@"compass.png"];
            }
    else if(indexPath.row == 1){
            [cell.textLabel setText:@"News on Terror"];
        cell.imageView.image = [UIImage imageNamed:@"newspaper.png"];
            }
    else if(indexPath.row == 2){
           [cell.textLabel setText:@"Wanted Terrorists"];
        cell.imageView.image = [UIImage imageNamed:@"terrorist.png"];
        
    }
    else if(indexPath.row == 3){
        cell.imageView.image = [UIImage imageNamed:@"jail.png"];
        UIImage *topimage = [UIImage imageNamed:@"terminatedred.png"];
        
        CGSize newSize = CGSizeMake(cell.imageView.image.size.width,cell.imageView.image.size.height);
        UIGraphicsBeginImageContext( newSize );
        
        // Use existing opacity as is
        [cell.imageView.image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        // Apply supplied opacity
        [topimage drawInRect:CGRectMake(0,0,cell.imageView.image.size.width,cell.imageView.image.size.height) blendMode:kCGBlendModeNormal alpha:0.8];
        
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        [cell.textLabel setText:@"Captured Terrorists"];
    }
    else if(indexPath.row == 4){
            [cell.textLabel setText:@"Terror Organizations"];
        cell.imageView.image = [UIImage imageNamed:@"terrororg.png"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return(10.0);
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 10)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return(0.01f);
}

-(UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 80.0;
}

-(void)gotoNews
{
    NewsViewController *news = [[NewsViewController alloc] init];
    [self.navigationController pushViewController:news animated:YES];
}

-(NSMutableArray*)readLocationTypes
{
        
}

-(void)gotoTerrorOrganizations
{
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"groupslinks"
                                                     ofType:@"txt"];
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSLog(@"%@,%@",path,content);
    
    NSMutableArray *retArr = [content componentsSeparatedByString:@"\n"];
    NSMutableArray *linksArray = [[NSMutableArray alloc] init];
    NSMutableArray *namesArray = [[NSMutableArray alloc] init];
    NSMutableArray *imageNamesArray = [[NSMutableArray alloc] init];
    for(NSString *link in retArr){
        NSMutableArray *splitted = [link componentsSeparatedByString:@">"];
        [namesArray addObject:[splitted objectAtIndex:0]];
        [linksArray addObject:[splitted objectAtIndex:1]];
        [imageNamesArray addObject:[splitted objectAtIndex:2]];
    }
    
    // Initialize image picker
	CustomImagePicker *_imagePicker = [[CustomImagePicker alloc] init];
	[_imagePicker setLinks:linksArray];

    for ( int i = 0;i<imageNamesArray.count;i++ )
    {
        
        NSString *name = [namesArray objectAtIndex:i];
        NSLog(@"%@",name);
        [_imagePicker addImage:[UIImage imageNamed:[imageNamesArray objectAtIndex:i]] :name];
    }
	    
    
    [self.navigationController pushViewController:_imagePicker animated:YES];
}

-(void)gotoProfiles
{
    ProfilesTilesView *view = [[ProfilesTilesView alloc] init];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch(indexPath.row){
        case 0:
            [self gotoViewMap];
            break;
        case 1:
            [self gotoNews];
            break;
        case 2:
            [self gotoProfiles];
            break;
        case 3:
            [self gotoProfilesKilled];
            break;
        case 4:
            [self gotoTerrorOrganizations];
            break;
    }
}

@end
