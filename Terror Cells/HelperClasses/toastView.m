//
//  splashView.m
//  version 1.0
//
//  Created by Shannon Appelcline on 3/13/09.
//  Copyright 2009 Skotos Tech Inc.
//
//  Licensed Under Creative Commons Attribution 3.0:
//  http://creativecommons.org/licenses/by/3.0/
//  You may freely use this class, provided that you maintain these attribute comments
//
//  Visit our iPhone blog: http://iphoneinaction.manning.com
//

#import "toastView.h"

@implementation toastView
@synthesize image;
@synthesize delay;
@synthesize touchAllowed;
@synthesize animation;
@synthesize isFinishing;
@synthesize animationDelay;
@synthesize caption;
@synthesize parentView,bshowActivity;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor blackColor];
		self.alpha = 0.8;
        self.delay = 4;
		self.touchAllowed = NO;
		self.animation = MySplashViewAnimationFade;
		self.animationDelay = 1;
		self.isFinishing = NO;
        self.bshowActivity = NO;
        activityWheel = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(frame.size.width / 2 - 12, frame.size.height / 2 - 12, 24, 24)];
		activityWheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
		activityWheel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
										  UIViewAutoresizingFlexibleRightMargin |
										  UIViewAutoresizingFlexibleTopMargin |
										  UIViewAutoresizingFlexibleBottomMargin);
        
        
		
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    UILabel * labelCaption = nil;
	if(bshowActivity == NO){
	 labelCaption = [[UILabel alloc] initWithFrame:CGRectMake(5, 5 , self.frame.size.width - 5, self.frame.size.height - 5)];// /*CGRectMake(0, 500, 768,100)*/
    }
    else{
        labelCaption = [[UILabel alloc] initWithFrame:CGRectMake(5, self.frame.size.height / 2 , self.frame.size.width - 5, 60)]; 
    }
    
	labelCaption.text = caption;
	[labelCaption setTextColor:[UIColor whiteColor]];
	[labelCaption setFont:[UIFont systemFontOfSize:14]];
	[labelCaption setBackgroundColor:[UIColor blackColor]];
    [labelCaption setNumberOfLines:0];
	labelCaption.textAlignment = UITextAlignmentCenter;
	[self addSubview:labelCaption];
}

- (void)showToast {

	//splashImage = [[UIImageView alloc] initWithImage:self.image];
	//[self addSubview:splashImage];
    if(self.bshowActivity == YES)
    {
        [self addSubview:activityWheel];
        [activityWheel startAnimating];
    }
    CABasicAnimation *animSplash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animSplash.duration = self.animationDelay;
    animSplash.removedOnCompletion = NO;
    animSplash.fillMode = kCAFillModeForwards;
    animSplash.toValue = [NSNumber numberWithFloat:1];
    //animSplash.delegate = self;
    [self.layer addAnimation:animSplash forKey:@"animateOpacity"];
    [parentView addSubview:self];
    self.animation = MySplashViewAnimationFade;
	[self performSelector:@selector(dismissToast) withObject:self afterDelay:self.delay];
}

- (void)dismissToast {

	if (self.isFinishing || self.animation == MySplashViewAnimationNone) {
		[self dismissSplashFinish];
	} else if (self.animation == MySplashViewAnimationSlideLeft) {
		CABasicAnimation *animSplash = [CABasicAnimation animationWithKeyPath:@"transform"];
		animSplash.duration = self.animationDelay;
		animSplash.removedOnCompletion = NO;
		animSplash.fillMode = kCAFillModeForwards;
		animSplash.toValue = [NSValue valueWithCATransform3D:
							  CATransform3DMakeAffineTransform
							  (CGAffineTransformMakeTranslation(-320, 0))];
		animSplash.delegate = self;
		[self.layer addAnimation:animSplash forKey:@"animateTransform"];
	} else if (self.animation == MySplashViewAnimationFade) {
		CABasicAnimation *animSplash = [CABasicAnimation animationWithKeyPath:@"opacity"];
		animSplash.duration = self.animationDelay;
		animSplash.removedOnCompletion = NO;
		animSplash.fillMode = kCAFillModeForwards;
		animSplash.toValue = [NSNumber numberWithFloat:0];
		animSplash.delegate = self;
		[self.layer addAnimation:animSplash forKey:@"animateOpacity"];
	}
	self.isFinishing = YES;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {

	[self dismissSplashFinish];
}

- (void)dismissSplashFinish {

   [self removeFromSuperview];
		
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

	if (self.touchAllowed) {
		[self dismissSplash];
	}
}

- (void)dealloc {
   
}


@end
