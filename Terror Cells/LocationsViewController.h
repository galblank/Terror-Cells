//
//  LocationsViewController.h
//  helpy
//
//  Created by Gal Blank on 9/24/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationsViewController : UITableViewController<UITableViewDelegate,UISearchBarDelegate>
{
    UIViewController *parent;
    NSMutableArray *sortedArray;
    NSMutableArray *originalDicsArray;
    NSMutableArray *dataSource; //will be storing all the data
    NSMutableArray *tableData;//will be storing data that will be displayed in table
    NSMutableArray *searchedData;//will be storing data matching with the search string
    UISearchBar *sBar;//search bar
    NSMutableDictionary *selectedPlaces;
    
}

@property(nonatomic,retain)UIViewController *parent;

@end
