//
//  ProfilesTilesView.h
//  Terror Cells
//
//  Created by Gal Blank on 11/9/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfilesTilesView : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UIScrollView *topScrollView;
    UIScrollView *middleScrollView;
    UIScrollView *bottomScrollView;
    
    NSMutableArray *displayedObjects;
    
    UITableView *profilesTable;
    NSMutableArray *scrollViewsArray;
    
    UIActivityIndicatorView *loadingWheel;
    
    
    ///RSS
    
	NSXMLParser * rssParser;
	NSMutableArray * stories;
	// a temporary item; added to the "stories" array one at a time, and cleared for the next one
	NSMutableDictionary * item;
	// it parses through the document, from top to bottom... // we collect and cache each sub-element value, and then save each item to our array.
	// we use these to track each current item, until it's ready to be added to the "stories" array
	NSString * currentElement;
	NSMutableString * currentTitle, * currentDate, * currentSummary, * currentLink;
	NSString *previousString;
    
    UIView *tempZoomView;
    NSMutableDictionary *currentProfile;

}

@property (nonatomic, retain) NSString *previousString;

@end
