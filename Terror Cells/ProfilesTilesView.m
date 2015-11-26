//
//  ProfilesTilesView.m
//  Terror Cells
//
//  Created by Gal Blank on 11/9/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//

#import "ProfilesTilesView.h"
#import "CommManager.h"
#import "Parser.h"
#import "Globals.h"
#import "ImageManipulation.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Animation.h"
#import "SendTerroristIntel.h"
@interface ProfilesTilesView ()

@end

@implementation ProfilesTilesView


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


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //NSString *result = [[WapConnector sharedInstance] getlocalFullUrl:@"http://www.adl.org/terrorism/profiles/default.asp"];
    //displayedObjects = [[NSMutableArray alloc] initWithArray:[[Parser sharedInstance] parseProfiles:result]];
    
    displayedObjects = [[NSMutableArray alloc] init];
    [self parseXMLFileAtURL:@"http://www.fbi.gov/wanted/wanted_terrorists/wanted-feed.xml"];
    
    //http://www.fbi.gov/wanted/wanted_terrorists/wanted-feed.xml
    
    //[self loadimagesThreaded];
    [self.view setBackgroundColor:[UIColor clearColor]];
    //[self.view setAlpha:0.5];
	[self setTitle:@"Wanted Terrorists"];
    
    profilesTable = [[UITableView alloc] initWithFrame:CGRectMake(5, 0, self.view.frame.size.width - 10, self.view.frame.size.height) style:UITableViewStyleGrouped];
	profilesTable.delegate = self;
	profilesTable.dataSource = self;
    [profilesTable setBackgroundView:nil];
	[profilesTable setBackgroundColor:[UIColor clearColor]];
	profilesTable.scrollEnabled = YES;
	profilesTable.allowsSelection = NO;
	[self.view addSubview:profilesTable];
    
    scrollViewsArray = [[NSMutableArray alloc] init];
    
    loadingWheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingWheel];
    [loadingWheel startAnimating];
}

-(void)buildScrollViewsArray
{
    int scrollViewsAmount = displayedObjects.count / 5;
    for(int i=0;i<=scrollViewsAmount;i++){
            NSMutableArray *scrollView = [[NSMutableArray alloc] init];
            [scrollViewsArray addObject:scrollView];
    }
    NSLog(@"Scroll Rows : %d",scrollViewsArray.count);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///////////////////////LOAD IMAGES/////////////////////
-(void)loadimagesThreaded
{
	[NSThread detachNewThreadSelector:@selector(loadiMages) toTarget:self withObject:nil];
}

-(void)loadiMages
{
	/*You need this for all threads you create or you will leak! */
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
   /* for(int i=0;i<displayedObjects.count;i++){
        NSMutableDictionary *profile = [displayedObjects objectAtIndex:i];
        NSLog(@"%@",[profile objectForKey:@"img"]);
        NSURL *url=[NSURL URLWithString:[profile objectForKey:@"img"]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [[UIImage alloc] initWithData:data];
        image = [UIImage imageOfSize:CGSizeMake(80, 80) fromImage:image];
        //image = [ImageManipulation makeRoundCornerImage:image :10 :10];
        [profile setObject:image forKey:@"image"];
        displayedObjects[i] = profile;
    }*/

    for(int i=0;i<stories.count;i++){
        NSMutableDictionary *profile = [stories objectAtIndex:i];
        NSLog(@"%@",[profile objectForKey:@"img"]);
        NSURL *url=[NSURL URLWithString:[profile objectForKey:@"img"]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [[UIImage alloc] initWithData:data];
        image = [UIImage imageOfSize:CGSizeMake(80, 80) fromImage:image];
        //image = [ImageManipulation makeRoundCornerImage:image :10 :10];
        NSMutableDictionary *newProf = [[NSMutableDictionary alloc] init];
        [newProf setObject:image forKey:@"image"];
        [newProf setObject:[profile objectForKey:@"name"] forKey:@"name"];
        [newProf setObject:[profile objectForKey:@"link"] forKey:@"info"];
       // [profile setObject:image forKey:@"image"];
        [displayedObjects addObject:newProf];
    }

    
    //Tell our callback what we've done
    [self performSelectorOnMainThread:@selector(finishedLoadingNews) withObject:nil waitUntilDone:NO];
	
    //remove our pool and free the memory collected by it
    [pool release];
	
}

-(void)finishedLoadingNews{
    [self buildScrollViewsArray];
    
    
    int row = 0;
    int column = 0;
    int imageIndex = 1;
    int index = 0;
    for (int i=0;i< displayedObjects.count;i++)
    {
        NSMutableDictionary * profile = [displayedObjects objectAtIndex:i];
        UIButton *specopImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        [specopImageView setFrame:CGRectMake(column,0, 120, 120)];
        [specopImageView setBackgroundImage:[profile objectForKey:@"image"] forState:UIControlStateNormal];
        [specopImageView setTag:imageIndex-1];
        [specopImageView addTarget:self action:@selector(showProfInfo:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *txtLabelProfs = [[UILabel alloc] initWithFrame:CGRectMake(column,100, 120, 20)];
        [txtLabelProfs setBackgroundColor:[UIColor blackColor]];
        [txtLabelProfs setAlpha:0.6];
        txtLabelProfs.tag = 100;
        txtLabelProfs.layer.cornerRadius = 10;
        [txtLabelProfs setTextAlignment:NSTextAlignmentCenter];
        [txtLabelProfs setFont:[UIFont fontWithName:@"Optima-Bold" size:10.0]];
        [txtLabelProfs setTextColor:[UIColor whiteColor]];
        [txtLabelProfs setText:[profile objectForKey:@"name"]];
        //[self.view addSubview:txtLabelProfs];
        
        
        NSMutableDictionary *profData = [[NSMutableDictionary alloc] init];
        if(imageIndex % 5 == 0 && imageIndex != 1){
            index += 1;
            column = 0;
        }
        else{
            column+=125;
        }
        [profData setObject:specopImageView forKey:@"image"];
        [profData setObject:txtLabelProfs forKey:@"name"];
        [profData setObject:[profile objectForKey:@"info"] forKey:@"info"];
        [[scrollViewsArray objectAtIndex:index] addObject:profData];
        imageIndex++;
    }
    NSLog(@"Finished addin images to scroll views");
    [profilesTable reloadData];
}

-(void)showProfInfo:(UIButton*)btn
{
    NSMutableDictionary *profile = [displayedObjects objectAtIndex:btn.tag];
    
    //NSLog(@"showProfInfo : %@",profile);
    //http://en.wikipedia.org/w/api.php?action=query&format=xml&titles=cia&redirects&rvprop=content&prop=revisions
    NSString * profilelink = [profile objectForKey:@"info"];
    NSString *result = [[WapConnector sharedInstance] getlocalFullUrl:profilelink];
    
    NSMutableDictionary *info = [[Parser sharedInstance] parseProfileInfo:result];
    currentProfile = info;
    
    UIView *zoomInView = [[UIView alloc] initWithFrame:CGRectMake(5,70,self.view.frame.size.width - 10,self.view.frame.size.height - 100)];
    [zoomInView setBackgroundColor:[UIColor blackColor]];
    zoomInView.layer.cornerRadius = 8;
    
    UIImageView * imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 90, 90)];
    [imgView setImage:[profile objectForKey:@"image"]];
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
    title.text = [info objectForKey:@"name"];
    [zoomInView addSubview:title];
    
    /*
     UIWebView *wikiview = [[UIWebView alloc] initWithFrame:CGRectMake(5, 140,300, 255)];
     [wikiview setBackgroundColor:[UIColor clearColor]];
     [wikiview sizeThatFits:CGSizeMake(300, 255)];
     [wikiview loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:wikiStr]]];
     //[wikiview loadHTMLString:result baseURL:nil];
     [zoomInView addSubview:wikiview];*/
    
    UITextView *desc = [[UITextView alloc] initWithFrame:CGRectMake(5, 140,self.view.frame.size.width - 10, 255)];
    desc.tag = 1;
    [desc setBackgroundColor:[UIColor clearColor]];
    [desc setFont:[UIFont fontWithName:@"Optima-Bold" size:14.0]];
    [desc setTextColor:[UIColor whiteColor]];
    [desc setEditable:NO];
    [desc setAlpha:0.8];
    [desc sizeThatFits:CGSizeMake(290, 255)];
    desc.layer.cornerRadius = 10;
    desc.text = [info objectForKey:@"mainDesc"];
    [zoomInView addSubview:desc];
    

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake(zoomInView.frame.size.width - 30, 5, 20, 20)];
    [closeButton setImage:[UIImage imageNamed:@"hide.png"] forState:UIControlStateNormal];
    
    [closeButton addTarget:self action:@selector(hidePopupView) forControlEvents:UIControlEventTouchUpInside];
    [zoomInView addSubview:closeButton];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitButton setFrame:CGRectMake(20,370, 280, 30)];
    [submitButton setBackgroundImage:[UIImage imageNamed:@"large-light-button.png"] forState:UIControlStateNormal];
    [submitButton.titleLabel setFont:[UIFont fontWithName:@"Optima-Bold" size:18.0]];
    [submitButton setTitle:@"Submit Intel" forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitIntel) forControlEvents:UIControlEventTouchUpInside];
    [zoomInView addSubview:submitButton];
    
    tempZoomView = zoomInView;
    
    [self.view addSubviewWithZoomInAnimation:zoomInView duration:0.55 option:UIViewAnimationOptionCurveEaseOut];
}

-(void)submitIntel
{
    SendTerroristIntel *submitIntel = [[SendTerroristIntel alloc] init];
    [submitIntel setTerroristName:[currentProfile objectForKey:@"name"]];
    [self.navigationController pushViewController:submitIntel animated:YES];
}

-(void)hidePopupView
{
    
    [tempZoomView removeWithZoomOutAnimation:0.5 option:UIViewAnimationOptionCurveEaseInOut];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	profilesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    NSLog(@"Table Rows :  %d",scrollViewsArray.count);
    return [scrollViewsArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130.0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"MyIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    UIScrollView *scrollView = nil;
	if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 120)];
        scrollView.tag =1;
        [cell.contentView addSubview:scrollView];
    }
    else{
        scrollView = (UIScrollView *)[[cell.contentView viewWithTag:0] viewWithTag:1];
    }
    
    for(UIView *subview in [scrollView subviews]) {
        if([subview isKindOfClass:[UIButton class]] || [subview isKindOfClass:[UILabel class]]) {
            [subview removeFromSuperview];
        }
    }
    
    NSMutableArray *imagesArray = [scrollViewsArray objectAtIndex:indexPath.row];
    NSLog(@"TableCell: scrollViewContentCount %d",imagesArray.count);
    for(NSMutableDictionary * profData in imagesArray){
        UIButton *imView = [profData objectForKey:@"image"];
        UILabel *lblName = [profData objectForKey:@"name"];
        [scrollView addSubview:imView];
        [scrollView addSubview:lblName];
    }
    [scrollView setContentSize:CGSizeMake(imagesArray.count * 125,120)];
    return cell;
}


- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


///////////////////////////////////////////////////////////////////////////XML//////////////////////////

- (void)parseXMLFileAtURL:(NSString *)URL
{
    stories = [[NSMutableArray alloc] init];
    
	//you must then convert the path to a proper NSURL or it won't work
	NSURL *xmlURL = [NSURL URLWithString:URL];
	// here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
	// this may be necessary only for the toolchain
    
    rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [rssParser setDelegate:self];
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [rssParser setShouldProcessNamespaces:NO];
    [rssParser setShouldReportNamespacePrefixes:NO];
    [rssParser setShouldResolveExternalEntities:NO];
    [rssParser parse];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	NSLog(@"found file and started parsing");
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
	NSLog(@"error parsing XML: %@", errorString);
    //	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]; [errorAlert show];
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	//NSLog(@"found this element: %@", elementName);
	currentElement = [elementName copy];
    //NSLog(@"Element %@",currentElement);
	if ([elementName isEqualToString:@"item"])
	{ // clear out our story item caches...
        NSLog(@"Starting element: %@", elementName);
		
		currentTitle = [[NSMutableString alloc] init];
		currentDate = [[NSMutableString alloc] init];
		currentSummary = [[NSMutableString alloc] init];
		currentLink = [[NSMutableString alloc] init];
		previousString = [[NSString alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	//NSLog(@"ended element: %@", elementName);
	if ([elementName isEqualToString:@"item"]) {
        NSMutableDictionary *profitem = [[NSMutableDictionary alloc] init];
		// save values to an item, then store that item into the array...
 		[profitem setObject:currentTitle forKey:@"name"];
        //currentLink = [currentLink stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        currentLink = [currentLink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[profitem setObject:currentLink forKey:@"link"];
        currentSummary = [currentSummary stringByMatching:@"src=\"(?s)(.*?)\"" capture:1];
        //currentSummary = [[NSMutableString alloc] initWithString:[currentSummary stringByConvertingHTMLToPlainText]];
		[profitem setObject:currentSummary forKey:@"img"];
		[profitem setObject:currentDate forKey:@"date"];
        //[displayedObjects addObject:[profitem copy]];
		[stories addObject:[profitem copy]];
	}
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	string = [string stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"ldquo;" withString:@"\""];
    
	// save the characters for the current item...
	if([string caseInsensitiveCompare:@"&"] == NSOrderedSame){
		self.previousString = string;
		return;
	}
	
	NSRange range = [string rangeOfString:@"#39;"];
	if(range.location != NSNotFound){
		string = [string stringByReplacingOccurrencesOfString:@"#39;" withString:@"'"];
		self.previousString = @"";
	}
	
	if ([currentElement isEqualToString:@"title"]) {
		[currentTitle appendString:string];
	}
	else if ([currentElement isEqualToString:@"link"]) {
		[currentLink appendString:string];
	}
	else if ([currentElement isEqualToString:@"description"]) {
		[currentSummary appendString:string];
	}
	else if ([currentElement isEqualToString:@"pubDate"]) {
		[currentDate appendString:string];
	}
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	//[activityIndicator stopAnimating];
	//[activityIndicator removeFromSuperview];
	NSLog(@"all done!");
	NSLog(@"stories array has %d items", [stories count]);
    [rssParser release];
    rssParser = nil;
    [self loadimagesThreaded];    
}

@end
