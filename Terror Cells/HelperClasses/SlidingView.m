//
//  SlidingView.m
//  iTrophy
//
//  Created by Natalie Blank on 15/07/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SlidingView.h"
#import "Globals.h"

@implementation SlidingView



- (id)initWithTitle:(NSString *)title message:(NSString *)msg
{
	if (self = [super init]) 
	{
		// Notice the view y coordinate is offscreen (480)
		// This hides the view
		self.view = [[UIView alloc] initWithFrame:CGRectMake(0, -30, 320, 30)];
		[self.view setBackgroundColor:[UIColor blackColor]];
		[self.view setAlpha:.87];
		
				
		
		
		UIImage *mailpic = [UIImage imageNamed:@"close.png"];
		// set the image for the button
		UIButton * button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[button1 setImage:mailpic forState:UIControlStateNormal];
		[button1 setFrame:CGRectMake(277, 5, 24, 24)];
		[button1 setTitle:@"Submit" forState:UIControlStateNormal]; 
		[button1 addTarget:self action:@selector(hideMsg) forControlEvents:UIControlEventTouchUpInside];
		//[self.view addSubview:button1];
		
		
		
	}
	
	return self;
}

-(void) loadData
{
	[super viewDidLoad];
	float red = 247.0/255.0;
	float green = 148.0/255.0;
	float blue = 30.0/255.0;
	
	UIColor *mycolor=[UIColor colorWithRed:(red) green:(green) blue:(blue) alpha:1];
	UIFont *myFont = [UIFont fontWithName:@"Georgia-Bold" size:15];
	
    searchField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [searchField setBorderStyle:UITextBorderStyleBezel];
    [searchField setBackgroundColor:[UIColor whiteColor]];
    [searchField setPlaceholder:@"Внесите имя автора"];
    [searchField setDelegate:self];
    [searchField setFont:myFont];
    [searchField setTextColor:mycolor];
    [self.view addSubview:searchField];
	
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)hideMsg;
{
	// Slide the view down off screen
	CGRect frame = self.view.frame;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.75];
	
	frame.origin.y = -30;
	self.view.frame = frame;
	
	// To autorelease the Msg, define stop selector
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	[UIView commitAnimations];
}

- (void)animationDidStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context 
{
	// Release
	//[self release];
}

- (void)showMsgWithDelay:(int)delay
{
	//  UIView *view = self.view;
	CGRect frame = self.view.frame;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.75];
	
	// Slide up based on y axis
	// A better solution over a hard-coded value would be to
	// determine the size of the title and msg labels and 
	// set this value accordingly
	frame.origin.y = 30;
	self.view.frame = frame;
	
	[UIView commitAnimations];
	
	// Hide the view after the requested delay
	//[self performSelector:@selector(hideMsg) withObject:nil afterDelay:delay];
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    //[super dealloc];
}

//PickerViewController.m
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

//PickerViewController.m
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [agesArray count];
}

//PickerViewController.m
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [agesArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    
    [self hideMsg];
    NSLog(@"Selected Color: %@. Index of selected color: %i", [agesArray objectAtIndex:row], row);
}

-(BOOL)textFieldShouldReturn:(UITextField *)txtObject {
	[txtObject resignFirstResponder];
    return YES;
}


@end
