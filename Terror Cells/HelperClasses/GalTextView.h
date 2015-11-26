//
//  GalTextView.h
//  helpy
//
//  Created by Gal Blank on 9/23/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface GalTextView : UITextView<UITextViewDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{

    BOOL bPlacehodler;
    UITextBorderStyle _borderStyle;
    UIColor *__backgroundColor;
    UITextField *bgField;
    id<UITextViewDelegate> delegate;
    ///doubletapspeed=delay in seconds or milliseconds ( depends on whatever you set it for ) between first "Return" tap and second to hids the keyboard.
    //default is 1.5 seconds
    CGFloat doubleTapSpeed;

    UIView * paretnView;
    
    CGFloat animatedDistance;
}
@property(nonatomic,retain)id<UITextViewDelegate> delegate;
@property(nonatomic,retain)UIView * paretnView;
@property(nonatomic)BOOL bPlacehodler;
@property(nonatomic)UITextBorderStyle _borderStyle;
@property(nonatomic)CGFloat doubleTapSpeed;

-(void)setPlaceholder:(NSString*)placeholder;
-(void)setGalBackgroundColor:(UIColor *)_backgroundColor;
- (CGRect)textRectForBounds:(CGRect)bounds;
- (CGRect)editingRectForBounds:(CGRect)bounds;

/*
 UITextBorderStyleNone,
 UITextBorderStyleLine,
 UITextBorderStyleBezel,
 UITextBorderStyleRoundedRect
 */
-(void)setBorderstyle:(UITextBorderStyle)borderStyle;

@end
