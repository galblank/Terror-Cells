//
//  MainViewController.m
//  VivatProjectStatus
//
//  Created by Natalie Blank on 25/03/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NewsViewController.h"
#import "Globals.h"
#import "CommManager.h"
#import "Parser.h"
#import "DataHandler.h"
#import "Encryption.h"
#import "NSString+HTML.h"
#import <QuartzCore/QuartzCore.h>
@implementation NewsViewController

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

@synthesize displayedObjects,previousString;


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
	   
    searchitems = [[NSMutableArray alloc] init];
    NSString* path = [[NSBundle mainBundle] pathForResource:@"newssearchwords"
                                                     ofType:@"txt"];
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    self.searchitems = [content componentsSeparatedByString:@"\n"];

    
	newsCounter = [[UIBarButtonItem alloc] initWithCustomView:lblNewsCounter];

	[self setTitle:@"New on Terror"];
	self.tableView.backgroundColor = [UIColor clearColor];
    //self.tableView.backgroundView = nil;
	self.tableView.rowHeight = 50;

	[self.view setBackgroundColor:[UIColor clearColor]];
    index = 0;
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(35, 5, 250, 400)];
    scrollingTo = 402;
    //NSArray * paths = [NSBundle pathsForResourcesOfType: @"png" inDirectory: [[NSBundle mainBundle] bundlePath]];
    NSMutableArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:@".png" inDirectory:@"attacks"];
    int i = 0;
    lastHeight = 0;
    scrollingDown = YES;
    for ( NSString * path in paths )
    {
        NSString *imagename = [NSString stringWithFormat:@"%@",[path lastPathComponent]];
        UIImageView *specopImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, lastHeight, 250, 250)];
        UIImage *specOpImage = [UIImage imageNamed:imagename];
        [specopImageView setImage:specOpImage];
        [scrollView addSubview:specopImageView];
        lastHeight += 255;
        i++;
    }
    
    [scrollView setContentSize:CGSizeMake(250, lastHeight)];
    [self.tableView.backgroundView addSubview:scrollView];

    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(scroll) userInfo:nil repeats:YES];
   // [self loadnewsthreaded:[feeds objectAtIndex:index]];
}

- (void) scroll
{
    [scrollView scrollRectToVisible:CGRectMake(35, 5, 250, scrollingTo) animated:YES];
    if(scrollingTo >= lastHeight){
        scrollingDown = NO;
    }
    else if(scrollingTo <= 0){
        scrollingDown = YES;
    }
    
    if(scrollingDown){
        scrollingTo += 1;
    }
    else{
        scrollingTo -= 1;
    }
}
/*
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return GAD_SIZE_320x50.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[Globals sharedInstance] bannerView_];
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return GAD_SIZE_320x50.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[Globals sharedInstance] bannerView_];
}
*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadnewsthreaded];
	//cellSize = CGSizeMake([newsTable bounds].size.width, 60);
}

-(void)loadnewsthreaded
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *result = [[WapConnector sharedInstance] getlocalFullUrl:@"https://docs.google.com/uc?export=download&id=0ByIwWqtIPPIXcHFmeUExWElUdEU"];
        feeds = [result componentsSeparatedByString:@"\n"];
        for(NSString *feed in feeds){
            [self parseXMLFileAtURL:feed];
        }
        
    });
}

- (void)parseXMLFileAtURL:(NSString *)URL
{
    if(stories == nil || [stories count] == 0){
        stories = [[NSMutableArray alloc] init];
    }
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
		item = [[NSMutableDictionary alloc] init]; 
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
		// save values to an item, then store that item into the array...
        BOOL bFound = NO;
        NSLog(@"%@",self.searchitems);
        for(NSString *searchword in self.searchitems){
            NSString * title = [currentTitle lowercaseString];
       
            if([title rangeOfString:searchword].location != NSNotFound)
            {
                bFound = YES;
                break;
            }
        }
        if(bFound == NO){
            NSLog(@"Filtering out item : %@",currentTitle);
            return;
        }
 		[item setObject:currentTitle forKey:@"title"];
		[item setObject:currentLink forKey:@"link"];
        currentSummary = [[NSMutableString alloc] initWithString:[currentSummary stringByConvertingHTMLToPlainText]];
		[item setObject:currentSummary forKey:@"summary"]; 
		[item setObject:currentDate forKey:@"date"]; 
		[stories addObject:[item copy]]; 
		NSLog(@"adding story: %@", currentTitle);
        
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
    [lblNewsCounter setText:[NSString stringWithFormat:@"%d Stories",[stories count]]];
    [rssParser release];
    rssParser = nil;
    [self.tableView reloadData];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    return [stories count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 150.0;
    NSString * title =[[stories objectAtIndex: indexPath.row] objectForKey: @"title"];
    NSString * desc = [[stories objectAtIndex: indexPath.row] objectForKey: @"summary"];

    NSString *total = [NSString stringWithFormat:@"%@\r\%@:",title,desc];
    
    CGSize maximumLabelSize = CGSizeMake(tableView.frame.size.width,9999);
    CGSize expectedLabelSize = [total sizeWithFont:[UIFont fontWithName:@"Arial-BoldMT" size:14.0] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
    
    
    return expectedLabelSize.height + 10;
}

-(CGFloat)calcHeight:(int)index
{
    NSString * title =[[stories objectAtIndex:index] objectForKey: @"title"];
    NSString * desc = [[stories objectAtIndex:index] objectForKey: @"summary"];
    
    NSString *total = [NSString stringWithFormat:@"%@\r\%@:",title,desc];
    
    CGSize maximumLabelSize = CGSizeMake(self.tableView.frame.size.width,9999);
    CGSize expectedLabelSize = [total sizeWithFont:[UIFont fontWithName:@"Optima-Bold" size:14.0] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
    
    
    return expectedLabelSize.height + 10;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"MyIdentifier"; 
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier]; 
	int storyIndex = indexPath.row;//[indexPath indexAtPosition: [indexPath length] - 1];
    UITextView * desc;
	if (cell == nil) 
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
        desc = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, tableView.frame.size.width - 10, 140)];
        desc.tag = 1;
        [desc setBackgroundColor:[UIColor blackColor]];
        [desc setFont:[UIFont fontWithName:@"Optima-Bold" size:12.0]];
        [desc setTextColor:[UIColor whiteColor]];
        [desc setEditable:NO];
        [desc setAlpha:0.8];
        desc.layer.cornerRadius = 1;
        [cell.contentView addSubview:desc];
        [cell setBackgroundColor:[UIColor clearColor]];
	}
    else{
        desc = (UITextView *)[[cell.contentView viewWithTag:0] viewWithTag:1];
    }
    
    
    NSString *title = [NSString stringWithFormat:@"%@\r\n%@\r\n%@",[[stories objectAtIndex: storyIndex] objectForKey: @"date"],[[stories objectAtIndex: storyIndex] objectForKey: @"title"],[[stories objectAtIndex: storyIndex] objectForKey: @"summary"]];
    desc.text = title;

	return cell;
}

-(void)rateproject
{
	
}
 
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	// Navigation logic 
	int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1]; 
	NSString * storyLink = [[stories objectAtIndex: storyIndex] objectForKey: @"link"]; 
	NSString * desc = [[stories objectAtIndex: storyIndex] objectForKey: @"summary"]; 
	NSLog(desc);
	// clean up the link - get rid of spaces, returns, and tabs... 
	storyLink = [storyLink stringByReplacingOccurrencesOfString:@" " withString:@""]; 
	storyLink = [storyLink stringByReplacingOccurrencesOfString:@"\n" withString:@""]; 
	storyLink = [storyLink stringByReplacingOccurrencesOfString:@"	" withString:@""]; 
	NSLog(@"link: %@", storyLink); // open in Safari 
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:storyLink]];
	
	/*NewsItemViewController *newItem = [[NewsItemViewController alloc] init];
	[newItem setItem:[stories objectAtIndex: storyIndex]];
	[self.navigationController pushViewController:newItem animated:YES];*/
	
	
	/*
	NSString *newLink = [NSString stringWithFormat:@"http://reader.mac.com/mobile/v1/%@",storyLink];
	NSLog(newLink);
	WebViewController *cntrlView = [[WebViewController alloc] init];
	[cntrlView setItem:[stories objectAtIndex: storyIndex]];
	//[cntrlView setTitle:[oneStore storeName]];
	[self.navigationController pushViewController:cntrlView animated:YES];	
	[cntrlView loadHtml:desc];*/
	
	
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setVars:(NSString*)html
{
	displayedObjects = [[NSMutableArray alloc] init];
	displayedObjects = [[Globals sharedInstance] storesArray];	
}


- (void)dealloc {
    [super dealloc];
}


@end

