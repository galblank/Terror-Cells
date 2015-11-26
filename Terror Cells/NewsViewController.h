//
//  MainViewController.h
//  VivatProjectStatus
//
//  Created by Natalie Blank on 25/03/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsViewController : UITableViewController {
	NSMutableArray *displayedObjects;

	NSXMLParser * rssParser; 
	NSMutableArray * stories; 
	// a temporary item; added to the "stories" array one at a time, and cleared for the next one 
	NSMutableDictionary * item; 
	// it parses through the document, from top to bottom... // we collect and cache each sub-element value, and then save each item to our array. 
	// we use these to track each current item, until it's ready to be added to the "stories" array 
	NSString * currentElement; 
	NSMutableString * currentTitle, * currentDate, * currentSummary, * currentLink;
	NSString *previousString;
    
    UIBarButtonItem *newsCounter;
    UILabel *lblNewsCounter;
	
    NSMutableArray *searchitems;
    NSMutableArray *feeds;
    
    int index;
    
    UIScrollView *scrollView;
    int scrollingTo;
    int lastHeight;
    
    BOOL scrollingDown;
}

@property (nonatomic, retain) NSMutableArray *displayedObjects;
@property (nonatomic, retain) NSString *previousString;
@property(retain)NSMutableArray *searchitems;
-(void)setVars:(NSString*)html;
-(void)slidingviewout;
-(void)loadOrders;

@end
