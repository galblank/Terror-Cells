//
//  DataHandler.m
//  First App
//
//  Created by Gal Blank on 9/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DataHandler.h"
#import "Globals.h"

static DataHandler *sharedSampleSingletonDelegate = nil;

@implementation DataHandler

@synthesize readWritePath;

+ (DataHandler *)sharedInstance {
	@synchronized(self) {
		if (sharedSampleSingletonDelegate == nil) {
			[[self alloc] init]; // assignment not done here
		}
	}
	return sharedSampleSingletonDelegate;
}


+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedSampleSingletonDelegate == nil) {
			sharedSampleSingletonDelegate = [super allocWithZone:zone];
			// assignment and return on first allocation
			return sharedSampleSingletonDelegate;
		}
	}
	// on subsequent allocation attempts return nil
	return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain {
	return self;
}

- (unsigned)retainCount {
	return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
	//do nothing
}

- (id)autorelease {
	return self;
}



-(id)init
{
	if (self = [super init]) {
	}
	return self;
}

- (NSString*)getSerialNumber
{
	NSString *uniqueID = @"TERRORCELLS_UDID";
    return uniqueID;
}

-(void)saveShape:(NSMutableArray*)shape
{
    NSString *path=[readWritePath stringByAppendingString:@"/myshape.data"];
    NSMutableArray *nsnumbers = [[NSMutableArray alloc] init];
    for(int i=0;i<shape.count;i++){
        CGPoint point = [[shape objectAtIndex:i] CGPointValue];
        NSNumber *numX = [[NSNumber alloc] initWithFloat:point.x];
        NSNumber *numY = [[NSNumber alloc] initWithFloat:point.y];
        [nsnumbers addObject:numX];
        [nsnumbers addObject:numY];
    }
	BOOL bOk = [nsnumbers writeToFile:path atomically:TRUE];
    NSLog(@"saved Shaped to %@ with result %d",path,bOk);
}

-(NSMutableArray *)readShape
{
    NSString *path=[readWritePath stringByAppendingString:@"/myshape.data"];
	NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:path];
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for(int i=0;i<[array count];i+=2){
        NSNumber *numX = [array objectAtIndex:i];
        NSNumber *numY = [array objectAtIndex:i+1];
        CGPoint point = CGPointMake([numX floatValue], [numY floatValue]);
        [retArray addObject:[NSValue valueWithCGPoint:point]];
    }
	return retArray;
}

-(void)deleteCities{
    NSString *path=[NSTemporaryDirectory() stringByAppendingString:@"bpcities.txt"];
	NSMutableArray *dict = [[NSMutableArray alloc] initWithContentsOfFile:path];
    if(dict != nil) {
        [dict removeAllObjects];
        [dict writeToFile:path atomically:TRUE];
    }
}

-(void)saveCities:(NSMutableArray*)cities
{
	NSString *path=[NSTemporaryDirectory() stringByAppendingString:@"bpcities.txt"];	
	NSMutableArray *dict = [[NSMutableArray alloc]  initWithArray:cities];
	[dict writeToFile:path atomically:TRUE];
	
}

-(NSMutableArray*)getCities
{
	NSString *path=[NSTemporaryDirectory() stringByAppendingString:@"bpcities.txt"];
	NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:path];	
	return array;
}

-(void)saveSections:(NSMutableArray*)sections
{
    NSString *path=[NSTemporaryDirectory() stringByAppendingString:@"bpsections.txt"];	
	NSMutableArray *dict = [[NSMutableArray alloc]  initWithArray:sections];
	[dict writeToFile:path atomically:TRUE]; 
}

-(NSMutableArray*)getSections
{
    NSString *path=[NSTemporaryDirectory() stringByAppendingString:@"bpsections.txt"];
	NSMutableArray *dic = [[NSMutableArray alloc] initWithContentsOfFile:path];	
	return dic;
}

-(void)deleteAllSections
{
    NSString *path=[NSTemporaryDirectory() stringByAppendingString:@"bpsections.txt"];
	NSMutableArray *dict = [[NSMutableArray alloc] initWithContentsOfFile:path];
    if(dict != nil){
        [dict removeAllObjects];
        [dict writeToFile:path atomically:TRUE];
    }
}

-(void)saveLocation:(NSString*)location
{
	NSString *path=[NSTemporaryDirectory() stringByAppendingString:@"bplocation.txt"];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc]  init];
    [dict setObject:location forKey:@"location"];
	[dict writeToFile:path atomically:TRUE];
	
}

-(NSString*)getLocation
{
    NSString *retval = @"";
	NSString *path=[NSTemporaryDirectory() stringByAppendingString:@"bplocation.txt"];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    if(dict != nil){
        retval = [dict objectForKey:@"location"];
    }
	return retval;
}

-(void)deleteLocation
{
    NSString *path=[NSTemporaryDirectory() stringByAppendingString:@"bplocation.txt"];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc]  init];
    if(dict != nil){
        [dict removeAllObjects];
        [dict writeToFile:path atomically:TRUE];
    }

	
}

-(void)saveSection:(NSMutableDictionary*)section
{
	NSString *path=[NSTemporaryDirectory() stringByAppendingString:@"bpsection.txt"];
    NSMutableDictionary *write = [[NSMutableDictionary alloc] initWithDictionary:section];
	BOOL bOk = [write writeToFile:path atomically:TRUE];
}

-(NSMutableDictionary*)getSection
{
	NSString *path=[NSTemporaryDirectory() stringByAppendingString:@"bpsection.txt"];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	return dict;
}

-(void)deleteSection{
    NSString *path=[NSTemporaryDirectory() stringByAppendingString:@"bpsection.txt"];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    if(dict != nil) {
        [dict removeAllObjects];
        [dict writeToFile:path atomically:TRUE];
    }
}


-(void)saveAd:(NSMutableDictionary*)ad
{
    NSString *path=[NSTemporaryDirectory() stringByAppendingString:@"bpsavedads.txt"];
    NSMutableArray *arrayOfAds = [[NSMutableArray alloc] initWithContentsOfFile:path];
    if(arrayOfAds == nil){
        arrayOfAds = [[NSMutableArray alloc] init];
    }
    [arrayOfAds addObject:ad];
	BOOL bOk = [arrayOfAds writeToFile:path atomically:TRUE];
}

-(NSMutableArray*)getAllSavedAds
{
    NSString *path=[NSTemporaryDirectory() stringByAppendingString:@"bpsavedads.txt"];
    NSMutableArray *arrayOfAds = [[NSMutableArray alloc] initWithContentsOfFile:path];
    return arrayOfAds;
}

-(void)deleteAds
{
    NSString *path=[NSTemporaryDirectory() stringByAppendingString:@"bpsavedads.txt"];
    NSMutableArray *arrayOfAds = [[NSMutableArray alloc] initWithContentsOfFile:path];
    if(arrayOfAds != nil && arrayOfAds.count > 0){
        [arrayOfAds removeAllObjects];
    }
	BOOL bOk = [arrayOfAds writeToFile:path atomically:TRUE];
}

-(BOOL)deleteSavedAd:(NSMutableDictionary*)ad
{
    NSString *path=[NSTemporaryDirectory() stringByAppendingString:@"bpsavedads.txt"];
    NSMutableArray *arrayOfAds = [[NSMutableArray alloc] initWithContentsOfFile:path];
    for(int i=0;i<arrayOfAds.count;i++){
        NSMutableDictionary *_ad = [arrayOfAds objectAtIndex:i];
        if([[_ad objectForKey:@"adInfo"] isEqualToString:[ad objectForKey:@"adInfo"]]){
            [arrayOfAds removeObjectAtIndex:i];
            break;
        }
    }
    BOOL bOk = YES;
    if(arrayOfAds != nil){
        bOk = [arrayOfAds writeToFile:path atomically:TRUE];
    }
    return bOk;
}


-(BOOL)readNotifications
{
    NSString *path=[NSTemporaryDirectory() stringByAppendingString:@"bpnotify.txt"];
	NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    if(dic == nil || dic.count == 0){
        return FALSE;
    }
    else{
        NSString *notify = [dic objectForKey:@"notify"];
        if([notify isEqualToString:@"YES"]){
            return YES;
        }
        else{
            return NO;
        }
    }
	return dic;
}

-(void)saveNotifications:(NSString*)notification
{
	NSString *path=[NSTemporaryDirectory() stringByAppendingString:@"bpnotify.txt"];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc]  init];
    [dict setObject:notification forKey:@"notify"];
	[dict writeToFile:path atomically:TRUE];
}

@end
