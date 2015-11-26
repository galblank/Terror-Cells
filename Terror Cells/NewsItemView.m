//
//  NewsItemView.m
//  Terror Cells
//
//  Created by Gal Blank on 11/7/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//

#import "NewsItemView.h"
#import "Globals.h"
@interface NewsItemView ()

@end

@implementation NewsItemView

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
	// Do any additional setup after loading the view.
    [[Globals sharedInstance] setBackground:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
