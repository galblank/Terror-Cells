//
//  CustomImagePicker.m
//  CustomImagePicker
//
//  Created by Ray Wenderlich on 1/27/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "CustomImagePicker.h"
#import "UIImageExtras.h"
#import "Globals.h"
#import "WebView.h"
#import "ImageManipulation.h"

@implementation CustomImagePicker
@synthesize images = _images;
@synthesize thumbs = _thumbs;
@synthesize selectedImage = _selectedImage;
@synthesize links;

- (id) init {
	if ((self = [super init])) {
		_images =  [[NSMutableArray alloc] init];
		_thumbs =  [[NSMutableArray alloc] init];
        names = [[NSMutableArray alloc] init];
        links = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)addImage:(UIImage *)image :(NSString*)name {
	[_images addObject:image];
	[_thumbs addObject:[image imageByScalingAndCroppingForSize:CGSizeMake(64, 64)]];
    [names addObject:name];
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    [self setTitle:@"Terror Organizations"];
	// Create view
	UIScrollView *view = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	int row = 0;
	int column = 0;
	for(int i = 0; i < _thumbs.count; ++i) {
		UIImage *thumb = [_thumbs objectAtIndex:i];
		UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectMake(column*100+24, row*90+20, 70, 90);
		[button setImage:thumb forState:UIControlStateNormal];
		[button addTarget:self 
				   action:@selector(buttonClicked:) 
		 forControlEvents:UIControlEventTouchUpInside];
		button.tag = i;
        
        UILabel *btnTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 75, 70, 30)];
        [btnTitle setTextAlignment:NSTextAlignmentCenter];
        [btnTitle setTextColor:[UIColor whiteColor]];
        [btnTitle setNumberOfLines:0];
        [btnTitle setBackgroundColor:[UIColor clearColor]];
        [btnTitle setFont:[UIFont fontWithName:@"Optima-Bold" size:12.0]];
        [btnTitle setText:[names objectAtIndex:i]];
        NSLog(@"%@",[names objectAtIndex:i]);
        [button addSubview:btnTitle];
        
		[view addSubview:button];
		
		if (column == 2) {
			column = 0;
			row++;
		} else {
			column++;
		}
		
	}
	
    [view setBackgroundColor:[UIColor clearColor]];
    //view.alpha = 0.6;
	[view setContentSize:CGSizeMake(320, (row+1) * 90 + 20)];

	self.view = view;
	[view release];
	
	
}

- (IBAction)buttonClicked:(id)sender {
	UIButton *button = (UIButton *)sender;
	self.selectedImage = [_images objectAtIndex:button.tag];
    WebView *wView = [[WebView alloc] init];
    [wView setLink:[links objectAtIndex:button.tag]];
    [wView setTitle:[names objectAtIndex:button.tag]];
    [wView setImage:[_images objectAtIndex:button.tag]];
    [self.navigationController pushViewController:wView animated:YES];
	//CustomImagePickerAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	//[delegate.navController popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
	self.selectedImage = nil;
	//CustomImagePickerAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	//[delegate.navController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
	self.images = nil;
	self.thumbs = nil;
	self.selectedImage = nil;
	[super dealloc];
}

@end
