//
//  MainViewController.h
//  Backpage
//
//  Created by Gal Blank on 4/13/12.
//  Copyright (c) 2012 Vivat Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetLocationViewController.h"


@interface MainViewController : UIViewController<UITableViewDelegate>
{
    GetLocationViewController * mylocationManager;
    NSString *currentCity;
    NSString *currentSection;
    NSMutableArray *results;
    NSString *sectionUrl;
    UIButton *selectSection;
    UIButton *selectLocation;
    UIButton * searchAds;
    UITableView *bgTable;
    UIScrollView *scrollView;
    
    int scrollingTo;
    int lastHeight;
    BOOL scrollingRight;
    UIView *tempZoomView;
    NSMutableArray *specialOpsArray;
    
    UITableView *mainViewMenuTable;
}

@property(nonatomic,retain)NSString *sectionUrl;
@end
