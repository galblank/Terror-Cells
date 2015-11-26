//
//  SendMailViewController.h
//  Terror Cells
//
//  Created by Gal Blank on 11/13/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalTextView.h"
@interface SendMailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    GalTextView * topicdesc;
    CGFloat animatedDistance;
    
    UITableView * inputTable;
    UILabel *txtlblPlaces;
    
    UILabel *languagesLbl;
    
    GalTextView * cellsize;
    UIImage *snapShot;
    NSData *imageData;
    
    
    NSString *locationStr;
    
    NSString *languages;
    
    UIActivityIndicatorView *loadingWheel;
}

@property(nonatomic,strong)NSString *locationStr;
@property(nonatomic,strong)NSString *languages;
@end
