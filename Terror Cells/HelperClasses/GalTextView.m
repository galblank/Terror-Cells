//
//  GalTextView.m
//  helpy
//
//  Created by Gal Blank on 9/23/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//

#import "GalTextView.h"

@implementation GalTextView

static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;

@synthesize _borderStyle,doubleTapSpeed,paretnView,bPlacehodler,delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.font = [UIFont fontWithName:@"Arial" size:15.0];
        __backgroundColor = [UIColor whiteColor];
        self.textColor = [UIColor blackColor];
        self.backgroundColor = [UIColor clearColor];
        bgField = [[UITextField alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width, self.frame.size.height)];
        bgField.borderStyle = UITextBorderStyleNone;
        bgField.backgroundColor = __backgroundColor;
        bgField.delegate = nil;
        bgField.enabled = NO;
        [self addSubview:bgField];
        [self sendSubviewToBack:bgField];
        doubleTapSpeed = 1.5;

        
      
        UIToolbar *doneBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, PORTRAIT_KEYBOARD_HEIGHT - 60, 320, 35)];
        doneBar.barStyle = UIBarStyleBlack;
        doneBar.translucent = YES;
        [doneBar setAlpha:0.5];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(hidekeyboard)];
        UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        //Add buttons to the array
        NSArray *items = [NSArray arrayWithObjects:flexItem,doneBtn,nil];
        [doneBar setItems:items animated:NO];
        self.inputAccessoryView = doneBar;
        
        
    }
    
    return self;
}

-(void)hidekeyboard
{
    [self resignFirstResponder];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

/*
- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect inset = CGRectMake(bounds.origin.x + 10, bounds.origin.y, bounds.size.width - 10, bounds.size.height);
    return inset;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect inset = CGRectMake(bounds.origin.x + 10, bounds.origin.y, bounds.size.width - 10, bounds.size.height);
    return inset;
}
*/

-(void)setBorderstyle:(UITextBorderStyle)borderStyle
{
    self._borderStyle = borderStyle;
    bgField.borderStyle = borderStyle;
}



-(void)setGalBackgroundColor:(UIColor *)_backgroundColor
{
    __backgroundColor = _backgroundColor;
    if(self._borderStyle == UITextBorderStyleRoundedRect){
        [bgField setBackgroundColor:_backgroundColor];
        self.backgroundColor = [UIColor clearColor];
    }
}

-(void)setPlaceholder:(NSString*)placeholder
{
    bPlacehodler = YES;
    self.text = placeholder;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)txtObject {
	[txtObject resignFirstResponder];
	
	return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if(bPlacehodler){
        bPlacehodler = NO;
        self.text = @"";
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if(bPlacehodler){
        bPlacehodler = NO;
        self.text = @"";
    }

}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
    static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
    static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
    static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
    static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
    
    CGRect textFieldRect = [paretnView convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [paretnView convertRect:paretnView.bounds fromView:paretnView];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = paretnView.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [paretnView setFrame:viewFrame];
    
    [UIView commitAnimations];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
    
    CGRect viewFrame = paretnView.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [paretnView setFrame:viewFrame];
    
    [UIView commitAnimations];
    
}


@end
