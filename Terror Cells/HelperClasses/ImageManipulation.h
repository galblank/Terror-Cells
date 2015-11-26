//
//  ImageManipulation.h
//  First App
//
//  Created by Gal Blank on 10/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageManipulation : NSObject {

}

+(UIImage *)makeRoundCornerImage:(UIImage*)img :(int) cornerWidth :(int) cornerHeight;

@end
