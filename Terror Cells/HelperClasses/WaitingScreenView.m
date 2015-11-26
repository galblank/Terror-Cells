//
//  WaitingScreenView.m
//  iTrophy
//
//  Created by Gal Blank on 8/1/10.
//  Copyright 2010 Mobixie. All rights reserved.
//

#import "WaitingScreenView.h"


@implementation WaitingScreenView


@synthesize caption,isCurrentlyActive;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor blackColor];
		self.alpha = 0.7;
		
		UIActivityIndicatorView *activityWheel = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(frame.size.width / 2 - 12, frame.size.height / 2 - 12, 24, 24)];
		activityWheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
		activityWheel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
										  UIViewAutoresizingFlexibleRightMargin |
										  UIViewAutoresizingFlexibleTopMargin |
										  UIViewAutoresizingFlexibleBottomMargin);
        
       
		[self addSubview:activityWheel];
		[activityWheel release];
		
		
		
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	
	UILabel * labelCaption = [[UILabel alloc] initWithFrame:CGRectMake(5, self.frame.size.height / 2 , self.frame.size.width - 5, 60)];// /*CGRectMake(0, 500, 768,100)*/
	labelCaption.text = caption;
	[labelCaption setTextColor:[UIColor whiteColor]];
	[labelCaption setFont:[UIFont systemFontOfSize:14]];
	[labelCaption setBackgroundColor:[UIColor clearColor]];
    [labelCaption setNumberOfLines:0];
	labelCaption.textAlignment = UITextAlignmentCenter;
	[self addSubview:labelCaption];
}


- (void)dealloc {
    [super dealloc];
}


@end
