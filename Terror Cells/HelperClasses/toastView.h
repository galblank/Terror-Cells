//
//  splashView.h
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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


typedef enum {
	MySplashViewAnimationNone,
	MySplashViewAnimationSlideLeft,
	MySplashViewAnimationFade,
} MySplashViewAnimation;
	
@interface toastView : UIView {

    BOOL bshowActivity;
	UIImageView *splashImage;
	UIView *parentView;
	UIImage *image;
	NSTimeInterval delay;
	BOOL touchAllowed;
	MySplashViewAnimation animation;
	NSTimeInterval animationDelay;
	NSString *caption;
	BOOL isFinishing;
	UIActivityIndicatorView *activityWheel;
}
@property(nonatomic,retain)UIView *parentView;
@property(nonatomic,retain)NSString *caption;
@property (nonatomic)BOOL bshowActivity;
@property (retain) UIImage *image;
@property NSTimeInterval delay;
@property BOOL touchAllowed;
@property MySplashViewAnimation animation;
@property NSTimeInterval animationDelay;
@property BOOL isFinishing;

- (id)initWithImage:(UIImage *)screenImage;
- (void)showToast;

@end
