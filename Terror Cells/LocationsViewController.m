//
//  LocationsViewController.m
//  helpy
//
//  Created by Gal Blank on 9/24/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//

#import "LocationsViewController.h"
#import "DataHandler.h"
#import "Globals.h"
#import "CommManager.h"
#import "Parser.h"
#import "UIImage+Resizing.h"

@interface LocationsViewController ()

@end

@implementation LocationsViewController

@synthesize parent;

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
    
    [self setTitle:@"Languages"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];

    originalDicsArray = [[NSMutableArray alloc] init];
    
    dataSource = [[NSMutableArray alloc] init];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"languageslist"
                                                     ofType:@"txt"];
    
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    

    [originalDicsArray addObjectsFromArray:[[Parser sharedInstance] parseLanguages:content]];
    
    
    
    originalDicsArray = [originalDicsArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [dataSource addObjectsFromArray:originalDicsArray];
    
    
    
    sBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    sBar.delegate = self;
    sBar.placeholder = @"Tap here to search";
    
    //remove the background of the searchbox
    [[sBar.subviews objectAtIndex:0] removeFromSuperview];
    [self.view addSubview:sBar];
    
    //initialize the two arrays; dataSource will be initialized and populated by appDelegate
    searchedData = [[NSMutableArray alloc]init];
    tableData = [[NSMutableArray alloc]init];
    [tableData addObjectsFromArray:dataSource];//on launch it should display all the records
    
    selectedPlaces = [[NSMutableDictionary alloc] init];
    
    
    
    //[self downloadImages];
}

-(void)done
{
    NSMutableArray *places = [[NSMutableArray alloc] init];
    for(NSIndexPath *key  in selectedPlaces){
        NSString *value = [selectedPlaces objectForKey:key];
        [places addObject:value];
    }
    [parent setLangs:places];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)downloadImages
{
   /* for(int i=0;i<originalDicsArray.count;i++){
        PoiModel *onePoi = [originalDicsArray objectAtIndex:i];
        if(onePoi.imgUrl != nil && onePoi.imgUrl.length > 0){
            [self getImageThreaded:onePoi];
        }
    }
    */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source
/*
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 40.0;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setFrame:CGRectMake(20,0, 100, 40)];
    [addButton setBackgroundImage:[UIImage imageNamed:@"large-light-button.png"] forState:UIControlStateNormal];
    [addButton setTintColor:[UIColor whiteColor]];
    [addButton setTitle:@"Add New Place+" forState:UIControlStateNormal];
    [addButton setFont:[UIFont fontWithName:@"Arial-Bold" size:20.0]];
    return addButton;
}
 
 */
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}
 



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
    return [tableData count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    //if(cell.isSelected){
   //     cell.accessoryView = disclosureButton;
   // }
    //else{
    //    cell.accessoryView = nil;
   // }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [disclosureButton setFont:[UIFont fontWithName:@"Optima-Bold" size:12.0]];
    [disclosureButton setBackgroundImage:[UIImage imageNamed:@"checkboxoff.png"] forState:UIControlStateNormal];
    disclosureButton.tag = 0;
    [disclosureButton setFrame:CGRectMake(0,0, 30,30)];
    [disclosureButton addTarget:self action:@selector(select:event:) forControlEvents:UIControlEventTouchUpInside];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		[cell.textLabel setUserInteractionEnabled:YES];
       // [cell setImage:[UIImage imageNamed:@"bluemappointer.png"]];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setAccessoryView:disclosureButton];
	}
    else{
        int n = indexPath.row;
        if([selectedPlaces objectForKey:indexPath] != nil){
            disclosureButton.tag = 1;
            [disclosureButton setBackgroundImage:[UIImage imageNamed:@"checkboxon.png"] forState:UIControlStateNormal];
            [cell setAccessoryView:disclosureButton];
        }
        else{
            [disclosureButton setBackgroundImage:[UIImage imageNamed:@"checkboxoff.png"] forState:UIControlStateNormal];
            disclosureButton.tag = 0;
            [cell setAccessoryView:disclosureButton];
        }
    }
    
    NSString *name = [tableData objectAtIndex:indexPath.row];
    [cell.textLabel setText:name];
    
    return cell;
}

- (void)select:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    
    if (indexPath != nil)
    {
        [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

/*
- (void)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"accessory tapped");
    UIButton *disclosureButton = [[tableView cellForRowAtIndexPath:indexPath] accessoryView];
    if(disclosureButton.tag == 1){
        disclosureButton.tag = 0;
        [disclosureButton setBackgroundImage:[UIImage imageNamed:@"checkboxoff.png"] forState:UIControlStateNormal];
    }
    else{
        disclosureButton.tag = 1;
        [disclosureButton setBackgroundImage:[UIImage imageNamed:@"checkboxon.png"] forState:UIControlStateNormal];
    }
}
*/


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"accessory tapped at index %d",indexPath.row);
    UIButton *disclosureButton = (UIButton*)[[tableView cellForRowAtIndexPath:indexPath] accessoryView];
    if(disclosureButton.tag == 1){
        disclosureButton.tag = 0;
        [selectedPlaces removeObjectForKey:indexPath];
        [disclosureButton setBackgroundImage:[UIImage imageNamed:@"checkboxoff.png"] forState:UIControlStateNormal];
    }
    else{
        disclosureButton.tag = 1;
        [selectedPlaces setObject:[tableData objectAtIndex:indexPath.row] forKey:indexPath];
        [disclosureButton setBackgroundImage:[UIImage imageNamed:@"checkboxon.png"] forState:UIControlStateNormal];
    }
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




///////////////////////////////////////////////////////////////////

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}


#pragma mark UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // only show the status bar’s cancel button while in edit mode
    sBar.showsCancelButton = YES;
    sBar.autocorrectionType = UITextAutocorrectionTypeNo;
    // flush the previous search content
    //[tableData removeAllObjects];
    //initialize the two arrays; dataSource will be initialized and populated by appDelegate
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    sBar.showsCancelButton = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [tableData removeAllObjects];// remove all data that belongs to previous search
    
    
    if([searchText isEqualToString:@""] || searchText==nil){
        [tableData addObjectsFromArray:dataSource];
        [self.tableView reloadData];
        return;
    }
    
    
    
    NSInteger counter = 0;
    for(NSString *prod in dataSource)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        NSComparisonResult result = [prod compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        if (result == NSOrderedSame)
        {
            [tableData addObject:prod];
        }    
        counter++;
    }
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // if a valid search was entered but the user wanted to cancel, bring back the main list content
    [tableData removeAllObjects];
    [tableData addObjectsFromArray:dataSource];
    @try{
        [self.tableView reloadData];
    }
    @catch(NSException *e){
    }
    [sBar resignFirstResponder];
    sBar.text = @"";
}
// called when Search (in our case “Done”) button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}


@end
