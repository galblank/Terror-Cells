//
//  CustomMapAnnotationView.h
//  iLibRu
//
//  Created by Gal Blank on 7/11/11.
//  Copyright 2011 Mobixie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MyMapAnnotation.h"

@interface CustomMapAnnotationView : MKAnnotationView
{ 
    id * parent;
    MyMapAnnotation *weatherItem;
}

@property(nonatomic)id * parent;

@end