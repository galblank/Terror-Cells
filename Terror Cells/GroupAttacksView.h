//
//  MainViewController.h
//  VivatProjectStatus
//
//  Created by Natalie Blank on 25/03/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupAttacksView : UITableViewController {
	NSMutableArray *displayedObjects;
	
}

@property (nonatomic, retain) NSMutableArray *displayedObjects;

-(void)setVars:(NSString*)html;
-(void)slidingviewout;
-(void)loadOrders;

@end
