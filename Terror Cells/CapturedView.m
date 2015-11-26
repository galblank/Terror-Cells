//
//  ProfilesTilesView.m
//  Terror Cells
//
//  Created by Gal Blank on 11/9/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//

#import "CapturedView.h"
#import "CommManager.h"
#import "Parser.h"
#import "Globals.h"
#import "ImageManipulation.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Animation.h"
#import "SendTerroristIntel.h"
@interface CapturedView ()

@end

@implementation CapturedView


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

    NSString *result = [[WapConnector sharedInstance] getlocalFullUrl:@"https://docs.google.com/uc?export=download&id=0ByIwWqtIPPIXTlJGVDBPMVpDaUE"];
    NSLog(@"Captured: %@",result);
    displayedObjects = [[NSMutableArray alloc] init];
    
    NSMutableArray *linksArray = [result componentsSeparatedByString:@"\n"];
    
    
    for(NSString * link in linksArray){
        NSMutableDictionary *profile = [[NSMutableDictionary alloc] init];
        NSMutableArray * parsed = [link componentsSeparatedByString:@">"];
        NSString * name = [parsed objectAtIndex:0];
        NSString *aboutlink = [parsed objectAtIndex:1];
        NSString *imgLink = [parsed objectAtIndex:2];
        [profile setObject:name forKey:@"name"];
        [profile setObject:aboutlink forKey:@"aboutlink"];
        [profile setObject:imgLink forKey:@"imgLink"];
        [displayedObjects addObject:profile];
    }
    NSLog(@"%@",displayedObjects);
    
    [self loadimagesThreaded];
    [self.view setBackgroundColor:[UIColor clearColor]];
    //[self.view setAlpha:0.5];
	[self setTitle:@"Terminated Terrorists"];
    
    profilesTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
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
    int scrollViewsAmount = (displayedObjects.count / 5) + (displayedObjects.count % 5);
    for(int i=0;i<scrollViewsAmount;i++){
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
    dispatch_async(dispatch_get_main_queue(), ^{
        for(int i=0;i<displayedObjects.count;i++){
            NSMutableDictionary *profile = [displayedObjects objectAtIndex:i];
            NSURL *url=[NSURL URLWithString:[profile objectForKey:@"imgLink"]];
            NSLog(@"Loading image %@",[profile objectForKey:@"imgLink"]);
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *image = [[UIImage alloc] initWithData:data];
            image = [UIImage imageOfSize:CGSizeMake(80, 80) fromImage:image];
            image = [ImageManipulation makeRoundCornerImage:image :10 :10];
            
            UIImage *topimage = [UIImage imageNamed:@"terminatedred.png"];
            
            CGSize newSize = CGSizeMake(120, 120);
            UIGraphicsBeginImageContext( newSize );
            
            // Use existing opacity as is
            [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
            // Apply supplied opacity
            [topimage drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:0.8];
            
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            NSString *about = [[WapConnector sharedInstance] getlocalFullUrl:[profile objectForKey:@"aboutlink"]];
            NSMutableDictionary *newProf = [[NSMutableDictionary alloc] init];
            [newProf setObject:newImage forKey:@"image"];
            [newProf setObject:about forKey:@"about"];
            [newProf setObject:[profile objectForKey:@"name"] forKey:@"name"];
            [displayedObjects setObject:newProf atIndexedSubscript:i];
        }
        [self buildScrollViewsArray];
        
        
        int row = 0;
        int column = -125;
        int imageIndex = 1;
        int index = 0;
        for ( NSMutableDictionary * profile in displayedObjects )
        {
            NSMutableDictionary *profData = [[NSMutableDictionary alloc] init];
            if(imageIndex % 5 == 0){
                index += 1;
                column = 0;
            }
            else{
                column+=125;
            }
            
            UIButton *specopImageView = [UIButton buttonWithType:UIButtonTypeCustom];
            [specopImageView setFrame:CGRectMake(column,0, 120, 120)];
            [specopImageView setBackgroundImage:[profile objectForKey:@"image"] forState:UIControlStateNormal];
            [specopImageView setTag:imageIndex-1];
            [specopImageView addTarget:self action:@selector(showProfInfo:) forControlEvents:UIControlEventTouchUpInside];
            UILabel *txtLabelProfs = [[UILabel alloc] initWithFrame:CGRectMake(column, 90, 120, 30)];
            [txtLabelProfs setBackgroundColor:[UIColor blackColor]];
            [txtLabelProfs setAlpha:0.6];
            txtLabelProfs.tag = 100;
            txtLabelProfs.layer.cornerRadius = 10;
            [txtLabelProfs setTextAlignment:NSTextAlignmentCenter];
            [txtLabelProfs setFont:[UIFont fontWithName:@"Optima-Bold" size:12.0]];
            [txtLabelProfs setTextColor:[UIColor whiteColor]];
            [txtLabelProfs setText:[profile objectForKey:@"name"]];
            [self.view addSubview:txtLabelProfs];
            
            
            
            [profData setObject:specopImageView forKey:@"image"];
            [profData setObject:txtLabelProfs forKey:@"name"];
            [profData setObject:[profile objectForKey:@"about"] forKey:@"info"];
            [[scrollViewsArray objectAtIndex:index] addObject:profData];
            imageIndex++;
        }
        NSLog(@"Finished addin images to scroll views");
        [loadingWheel stopAnimating];
        [profilesTable reloadData];
    });
}

-(void)showProfInfo:(UIButton*)btn
{
    NSMutableDictionary *profile = [displayedObjects objectAtIndex:btn.tag];
    
    NSLog(@"showProfInfo : %@",profile);
    //http://en.wikipedia.org/w/api.php?action=query&format=xml&titles=cia&redirects&rvprop=content&prop=revisions
    currentProfile = [profile objectForKey:@"about"];
    
    UIView *zoomInView = [[UIView alloc] initWithFrame:CGRectMake(5,70,self.view.frame.size.width - 10,self.view.frame.size.height - 100)];
    [zoomInView setBackgroundColor:[UIColor blackColor]];
    //[zoomInView setAlpha:0.8];
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
    title.text = [profile objectForKey:@"name"];
    [zoomInView addSubview:title];

    
    UITextView *desc = [[UITextView alloc] initWithFrame:CGRectMake(5, imgView.frame.origin.y + imgView.frame.size.height,zoomInView.frame.size.width - 10, self.view.frame.size.height - 100 - 140)];
    desc.tag = 1;
    [desc setBackgroundColor:[UIColor blackColor]];
    [desc setFont:[UIFont fontWithName:@"Optima-Bold" size:14.0]];
    [desc setTextColor:[UIColor colorWithRed:214.0 / 255.0 green:179.0 / 255.0 blue:94.0 / 255.0 alpha:1.0]];
    [desc setEditable:NO];
    [desc setAlpha:0.8];
    [desc sizeThatFits:CGSizeMake(290, 255)];
    desc.layer.cornerRadius = 10;
    desc.text = [profile objectForKey:@"about"];
    [zoomInView addSubview:desc];
    

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake(zoomInView.frame.size.width - 30, 5, 20, 20)];
    [closeButton setImage:[UIImage imageNamed:@"hide.png"] forState:UIControlStateNormal];
    
    [closeButton addTarget:self action:@selector(hidePopupView) forControlEvents:UIControlEventTouchUpInside];
    [zoomInView addSubview:closeButton];
    
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
	int storyIndex = indexPath.row;
    UIScrollView *scrollView = nil;
	if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 300, 120)];
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
        NSLog(@"Adding : %@",lblName);
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
@end
