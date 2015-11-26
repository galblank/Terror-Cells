//
//  SettingsView.h
//  helpy
//
//  Created by Gal Blank on 10/3/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SettingsView : UITableViewController
{
    UISwitch *showHelp;
    UISlider *distanceRange;
    UILabel *distanceLabel;
    UIViewController *parent;
}

@property(nonatomic,retain)UIViewController *parent;
@end
