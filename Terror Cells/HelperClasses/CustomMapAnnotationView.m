//
//  CustomMapAnnotationView.m
//  iLibRu
//
//  Created by Gal Blank on 7/11/11.
//  Copyright 2011 Mobixie. All rights reserved.
//

#import "CustomMapAnnotationView.h"


@implementation CustomMapAnnotationView

@synthesize parent;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        CGRect frame = self.frame;
        frame.size = CGSizeMake(260.0, 110.0);
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        self.centerOffset = CGPointMake(30.0, 42.0);
    }
    return self;
}

- (void)setAnnotation:(id <MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    
    // this annotation view has custom drawing code.  So when we reuse an annotation view
    // (through MapView's delegate "dequeueReusableAnnoationViewWithIdentifier" which returns non-nil)
    // we need to have it redraw the new annotation data.
    //
    // for any other custom annotation view which has just contains a simple image, this won't be needed
    //
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    weatherItem = (MyMapAnnotation *)self.annotation;
    if (weatherItem != nil)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 1);
        
        // draw the gray pointed shape:
        CGMutablePathRef path = CGPathCreateMutable();
        /*CGPathMoveToPoint(path, NULL, 14.0, 0.0);
        CGPathAddLineToPoint(path, NULL, 0.0, 0.0); 
        CGPathAddLineToPoint(path, NULL, 100.0, 50.0);
        CGContextAddPath(context, path);
        CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
        CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
        CGContextDrawPath(context, kCGPathFillStroke);
        CGPathRelease(path);
        
        // draw the cyan rounded box
        path = CGPathCreateMutable();*/
        CGPathMoveToPoint(path, NULL, 15.5, 0.5);
                                    ///   X1    Y1    X2    Y2
        CGPathAddArcToPoint(path, NULL, 100.5, 0.5, 100.5, 10.5, 5.0);
        CGPathAddArcToPoint(path, NULL, 100.5, 40.5, 90.5, 40.5, 5.0);
        CGPathAddArcToPoint(path, NULL, 15.5, 40.5, 15.5, 30.0, 5.0);
        CGPathAddArcToPoint(path, NULL, 15.5, 0.5, 25.0, 0.5, 5.0);
        CGContextAddPath(context, path);
        UIColor * bgColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        CGContextSetFillColorWithColor(context, bgColor.CGColor);
        CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
        CGContextDrawPath(context, kCGPathFillStroke);
        CGPathRelease(path);
               
        // draw the string and graphic
        NSString *title = weatherItem.title;
        [[UIColor whiteColor] set];
        //[title drawInRect:CGRectMake(30.0, 5.0, 85, 35.0) withFont:[UIFont fontWithName:@"Optima-Bold" size:12.0]];
        
        
        [weatherItem.mapItem.title drawInRect:CGRectMake(35.0, 5.0, 60.0, 40.0) withFont:[UIFont fontWithName:@"Optima-Bold" size:8.0]];
       
        NSString *imageName = @"muslim.png";
        [[UIImage imageNamed:imageName] drawInRect:CGRectMake(16.5, 5.0, 20.0, 20.0)];
    }
}

-(void)showMoreNews
{
    [parent showMoreNews:weatherItem.allitemsForCountry :weatherItem.title];
}

@end
