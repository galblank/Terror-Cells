//
//  SendMailViewController.h
//  Terror Cells
//
//  Created by Gal Blank on 11/13/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalTextView.h"
@interface SendTerroristIntel : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    GalTextView * topicdesc;
    CGFloat animatedDistance;
    
    UITableView * inputTable;
    UILabel *txtlblPlaces;
    
    UILabel *languagesLbl;
    
    GalTextView * cellsize;
    UIImage *snapShot;
    NSData *imageData;
    
    UIActivityIndicatorView *loadingWheel;
    
    UIImagePickerController *imagePickerController;
    
    UIImage *attachedImage;
    
    NSString *terroristName;
}

@property(retain)UIImage *attachedImage;
@property(nonatomic,retain)NSString *terroristName;
@end
