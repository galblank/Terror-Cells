//
//  SettingsViewController.m
//  Terror Cells
//
//  Created by Gal Blank on 11/14/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//

#import "SettingsViewController.h"
#import "Globals.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [[Globals sharedInstance] setTitleBar:@"Info Page"];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
