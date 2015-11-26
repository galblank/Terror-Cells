//
//  WaitingScreenView.h
//  iTrophy
//
//  Created by Gal Blank on 8/1/10.
//  Copyright 2010 Mobixie. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WaitingScreenView : UIView {
	NSString *caption;
	BOOL isCurrentlyActive;
}
@property(nonatomic,retain)NSString *caption;
@property(nonatomic)BOOL isCurrentlyActive;

@end
