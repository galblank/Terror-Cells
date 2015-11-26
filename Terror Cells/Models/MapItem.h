//
//  MapItem.h
//  Terror Cells
//
//  Created by Gal Blank on 11/8/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapItem : NSObject
{
    NSString *title;
    NSString *description;
    NSString *itemurl;
    NSString *date;
    double latitude;
    double longitude;
}

@property(nonatomic)double latitude;
@property(nonatomic)double longitude;
@property(nonatomic,retain)NSString *title;
@property(nonatomic,retain)NSString *description;
@property(nonatomic,retain)NSString *itemurl;
@property(nonatomic,retain)NSString *date;

@end
