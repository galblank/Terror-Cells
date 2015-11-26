//
//  DataHandler.h
//  First App
//
//  Created by Gal Blank on 9/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DOCSFOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface DataHandler : NSObject {
    NSString *readWritePath;
}

@property(nonatomic,retain)NSString *readWritePath;

-(void)saveCities:(NSMutableArray*)cities;
-(NSMutableArray*)getCities;

-(void)saveSections:(NSMutableArray*)sections;
-(NSMutableArray*)getSections;

-(void)saveLocation:(NSString*)location;
-(NSString*)getLocation;

-(void)saveSection:(NSMutableDictionary*)section;
-(NSMutableDictionary*)getSection;
-(void)deleteSection;

-(void)saveAd:(NSMutableDictionary*)ad;
-(NSMutableArray*)getAllSavedAds;
-(void)deleteAds;
-(BOOL)deleteSavedAd:(NSMutableDictionary*)ad;

-(BOOL)readNotifications;
-(void)saveNotifications:(NSString*)notification;


-(void)saveShape:(NSMutableArray*)shape;
+ (DataHandler *)sharedInstance;

@end
