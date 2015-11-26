//
//  Parser.h
//  First App
//
//  Created by Natalie Blank on 23/08/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Parser : NSObject {
	NSXMLParser * rssParser; 
	NSMutableArray * xmlresultsArray; 
	// a temporary item; added to the "stories" array one at a time, and cleared for the next one 
	NSMutableDictionary * item; 
	// it parses through the document, from top to bottom... // we collect and cache each sub-element value, and then save each item to our array. 
	// we use these to track each current item, until it's ready to be added to the "stories" array 
	NSString * currentElement; 
	NSMutableString * currentTitle, * currentDate, * currentSummary, * currentLink;
	NSString *previousString;

	BOOL bResultIsListOfObjects;
}


+ (Parser *)sharedInstance;
-(NSMutableDictionary*)parseInit:(NSString*)data;
-(NSMutableArray*)parsePoems:(NSString*)data;
-(NSString*)parseOnePoem:(NSString*)data;
-(NSMutableArray*)getCountriesStates:(NSString*)data;
-(NSMutableArray*)getSections:(NSString*)data :(NSString*)prefix;
-(NSString*)stripSpecials:(NSString*)string;
-(NSMutableArray*)parseOnePage:(NSString*)data;
-(NSMutableDictionary*)parseAd:(NSString*)data;
-(NSMutableArray *)parseLanguages:(NSString*)data;
-(NSMutableArray*)parseAutocompleteResults:(NSString*)data;
@end
