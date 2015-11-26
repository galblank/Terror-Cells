//
//  MainViewController.m
//  VivatProjectStatus
//
//  Created by Natalie Blank on 25/03/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GroupAttacksView.h"
#import "Globals.h"
#import "CommManager.h"
#import "Parser.h"
#import "DataHandler.h"
#import "Encryption.h"
#import "MapItem.h"

@implementation GroupAttacksView

@synthesize displayedObjects;


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
	[self.view setBackgroundColor:[UIColor clearColor]];
	[self setTitle:@"Group Activity"];
	self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
	self.tableView.rowHeight = 50;
    
    [self.view setBackgroundColor:[UIColor clearColor]];
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
    return [displayedObjects count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MapItem *item = [displayedObjects objectAtIndex: indexPath.row];

    NSString *total = [NSString stringWithFormat:@"%@\r\n%@:",item.date,item.description];
    
    CGSize maximumLabelSize = CGSizeMake(tableView.frame.size.width,9999);
    CGSize expectedLabelSize = [total sizeWithFont:[UIFont fontWithName:@"Arial-BoldMT" size:13.0] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
    
    
    return expectedLabelSize.height + 20;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"MyIdentifier"; 
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier]; 
	int storyIndex = indexPath.row;//[indexPath indexAtPosition: [indexPath length] - 1];
	if (cell == nil) 
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];        
		UIImage *image = [UIImage imageNamed:@"israelflag.png"];
		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [cell.textLabel setFont:[UIFont fontWithName:@"Optima-Bold" size:13.0]];
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [cell.textLabel setNumberOfLines:0];
        [cell.textLabel setNumberOfLines:0];
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Optima-Bold" size:12.0]];
        [cell.detailTextLabel setTextColor:[UIColor blackColor]];
        [cell.detailTextLabel setNumberOfLines:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        //[cell setImage:image];
	}
    
    MapItem *item = [displayedObjects objectAtIndex: indexPath.row];
    NSString *title = [NSString stringWithFormat:@"%@\r\n%@",item.date,item.description];
	[cell.textLabel setText:title];
   
    if(indexPath.row % 2 == 0){
        [cell setBackgroundColor:[UIColor lightGrayColor]];
    }
    else{
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
	return cell;
}

-(void)rateproject
{
	
}
 
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

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

