//
//  SlidingView.h
//  iTrophy
//
//  Created by Natalie Blank on 15/07/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlidingView : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource> {
	UIPickerView *agesScroll;
    NSMutableArray *agesArray;
    UITextField *searchField;
}


- (id)initWithTitle:(NSString *)title message:(NSString *)msg;

@end
