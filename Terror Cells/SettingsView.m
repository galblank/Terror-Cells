//
//  SettingsView.m
//  helpy
//
//  Created by Gal Blank on 10/3/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//

#import "SettingsView.h"
#import "Globals.h"
#import "DataHandler.h"
#import <QuartzCore/QuartzCore.h>

@interface SettingsView ()

@end

@implementation SettingsView

@synthesize parent;

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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Info Page"];
    [self.tableView setScrollEnabled:NO];
    self.tableView.backgroundView = nil;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		//[cell.textLabel setUserInteractionEnabled:YES];
        [cell setBackgroundColor:[UIColor clearColor]];
	}
    
    switch(indexPath.row)
    {
        case 0:
        {
            UITextView *desc = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, tableView.frame.size.width - 30, 240)];
            desc.tag = 1;
            //[desc setBackgroundColor:[UIColor blackColor]];
            [desc setFont:[UIFont fontWithName:@"Optima-Bold" size:12.0]];
            [desc setTextColor:[UIColor blackColor]];
            [desc setEditable:NO];
            [desc setAlpha:0.8];
            desc.layer.cornerRadius = 10;
            NSString *result = [[WapConnector sharedInstance] getlocalFullUrl:@"https://docs.google.com/uc?export=download&id=0ByIwWqtIPPIXUTNGSlVOdXgtSGc"];
            desc.text = result;
            [cell.contentView addSubview:desc];
            break;
        }
        case 1:
        {
            [cell.textLabel setFont:[UIFont fontWithName:@"Optima-Bold" size:22.0]];
            [cell.textLabel setText:@"Share this App"];
            [cell.textLabel setTextColor:[UIColor grayColor]];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            [cell setBackgroundColor:[UIColor whiteColor]];
            [cell setAlpha:0.7];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            break;
        }
        default:
        {
            break;
        }
    }
    return cell;
}


- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:indexPath];
    
    return rectInTableView;
}

-(void)shareApp
{
    [[Globals sharedInstance] loadInvitationForm:self];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0){
        return 250.0;
    }
    return 40.0;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 1){
        [[Globals sharedInstance] loadInvitationForm:self];
    }
}


@end
