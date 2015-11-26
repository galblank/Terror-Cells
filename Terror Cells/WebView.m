//
//  WebView.m
//  Terror Cells
//
//  Created by Gal Blank on 11/7/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//

#import "WebView.h"
#import "Globals.h"
#import "CommManager.h"
#import "Parser.h"
#import "MapView.h"
#import "GroupAttacksView.h"
#import "ImageManipulation.h"
@interface WebView ()

@end

@implementation WebView

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

@synthesize link,title,image;

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
    
    NSString *result = [[WapConnector sharedInstance] getlocalFullUrl:link];
    NSMutableDictionary *parsed = [[Parser sharedInstance] parseGroup:result :title];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    NSLog(@"%@",parsed);
    
    [self setTitle:title];
    
    CGFloat yPos = 70;
  
    UIImageView *iView = [[UIImageView alloc] initWithFrame:CGRectMake(5, yPos, 75, 75)];
    iView.layer.cornerRadius = 10;
    [iView setImage:image];
    [self.view addSubview:iView];
    
    UITextView * desc = [[UITextView alloc] initWithFrame:CGRectMake(85, yPos, 230, 80)];
    [desc setBackgroundColor:[UIColor clearColor]];
    [desc setFont:[UIFont fontWithName:@"Optima-Bold" size:12.0]];
    TEXTVIEW_SET_HTML_TEXT(desc,[parsed objectForKey:@"desc"]);
    [desc setEditable:NO];
    [desc setTextColor:[UIColor blackColor]];
    [self.view addSubview:desc];
    
    UIImageView *iDivider = [[UIImageView alloc] initWithFrame:CGRectMake(5, desc.frame.origin.y + desc.frame.size.height, self.view.frame.size.width - 10, 8)];
    [iDivider setImage:[UIImage imageNamed:@"divider.png"]];
    [self.view addSubview:iDivider];
    
    UITextView * exp = [[UITextView alloc] initWithFrame:CGRectMake(5, iDivider.frame.origin.y + iDivider.frame.size.height, self.view.frame.size.width - 10, 100)];
    [exp setBackgroundColor:[UIColor clearColor]];
    [exp setFont:[UIFont fontWithName:@"Optima-Bold" size:12.0]];
    TEXTVIEW_SET_HTML_TEXT(exp,[parsed objectForKey:@"exp"]);
    [exp setEditable:NO];
    [exp setTextColor:[UIColor blackColor]];
    [self.view addSubview:exp];
    
    UIImageView *iDivider2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, exp.frame.origin.y + exp.frame.size.height, self.view.frame.size.width - 10, 8)];
    [iDivider2 setImage:[UIImage imageNamed:@"divider.png"]];
    [self.view addSubview:iDivider2];
    
    UITextView * over = [[UITextView alloc] initWithFrame:CGRectMake(5, iDivider2.frame.origin.y + iDivider2.frame.size.height, self.view.frame.size.width - 10, 150)];
    [over setBackgroundColor:[UIColor clearColor]];
    [over setEditable:NO];
    [over setFont:[UIFont fontWithName:@"Optima-Bold" size:12.0]];
    TEXTVIEW_SET_HTML_TEXT(over,[parsed objectForKey:@"over"]);
    [over setTextColor:[UIColor blackColor]];
    [self.view addSubview:over];
    
    UIImageView *iDivider3 = [[UIImageView alloc] initWithFrame:CGRectMake(5,  over.frame.origin.y + over.frame.size.height, self.view.frame.size.width - 10, 8)];
    [iDivider3 setImage:[UIImage imageNamed:@"divider.png"]];
    [self.view addSubview:iDivider3];
    
    itemsArray = [parsed objectForKey:@"attacks"];
    
    [self addToolbar];

}

-(void)addToolbar
{
    UIToolbar *toolbar = [UIToolbar new];
	toolbar.tag = 2;
	toolbar.barStyle = UIBarStyleDefault;
    toolbar.tintColor = [UIColor lightGrayColor];
    //toolbar.tintColor = [UIColor colorWithRed:97.0 / 255.0 green:97.0 / 255.0 blue:97.0 / 255.0 alpha:1.0];
	[toolbar sizeToFit];
	//[toolbar setTranslucent:YES];
	toolbar.frame = CGRectMake(0,372, 320, 45.0);

    UIButton * showAttacks = [UIButton buttonWithType:UIButtonTypeCustom];
    showAttacks.frame = CGRectMake(0,0,60,40);
    UIImage *attacksOn = [UIImage imageNamed:@"attack.png"];
    attacksOn = [UIImage imageOfSize:CGSizeMake(60, 40) fromImage:attacksOn];
    [showAttacks setImage:attacksOn forState:UIControlStateNormal];
    [showAttacks setImage:attacksOn forState:UIControlStateHighlighted];
    [showAttacks addTarget:self action:@selector(viewAttacks) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemButtonAttacks = [[UIBarButtonItem alloc] initWithCustomView:showAttacks];

    UIButton * showLeaders = [UIButton buttonWithType:UIButtonTypeCustom];
    showLeaders.frame = CGRectMake(0,0,60,40);
    UIImage *LeadersOn = [UIImage imageNamed:@"leader.png"];
    LeadersOn = [UIImage imageOfSize:CGSizeMake(60, 40) fromImage:LeadersOn];
    [showLeaders setImage:LeadersOn forState:UIControlStateNormal];
    [showLeaders setImage:LeadersOn forState:UIControlStateHighlighted];
    [showLeaders addTarget:self action:@selector(viewAttacks) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemButtonLeaders = [[UIBarButtonItem alloc] initWithCustomView:showLeaders];
    
    
    	
	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	//Add buttons to the array
	NSArray *items = [NSArray arrayWithObjects:flexItem,itemButtonAttacks,flexItem,nil];
	
	
	//add array of buttons to toolbar
	[toolbar setItems:items animated:NO];
    [self.view addSubview:toolbar];
}

-(void)viewAttacks
{
    
    GroupAttacksView *map = [[GroupAttacksView alloc] init];
    [map setDisplayedObjects:itemsArray];
    [self.navigationController pushViewController:map animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"Finished");
    //[self zoomToFit];
}

-(void)zoomToFit
{
    
    if ([loadView respondsToSelector:@selector(scrollView)])
    {
        UIScrollView *scroll=[loadView scrollView];
        
        float zoom=loadView.bounds.size.width/scroll.contentSize.width;
        [scroll setZoomScale:zoom animated:YES];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
     NSLog(@"Started : %@",link);
}

@end
