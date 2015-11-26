//
//  Parser.m
//  First App
//
//  Created by Natalie Blank on 23/08/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Parser.h"
#import "RegexKitLite.h"
#import "Globals.h"
#import "SBJson4.h"
#import "DataHandler.h"
#import "RegexKitLite.h"
#import "MapItem.h"
#import "NSString+HTML.h"
#import "AutoCompleteResult.h"

static Parser *sharedSampleSingletonDelegate = nil;

@implementation Parser


+ (Parser *)sharedInstance {
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

-(NSMutableDictionary*)parseProfileInfo:(NSString*)data
{
    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    NSString * mainDesc = [data stringByMatching:@"<meta name=\"description\" content=\"(?s)(.*?)/>" capture:1];
    [retDic setObject:mainDesc forKey:@"mainDesc"];
    
    NSString * name = [data stringByMatching:@"<title>FBI &mdash; (?s)(.*?)</title>" capture:1];
    if(name != nil){
        [retDic setObject:name forKey:@"name"];
    }
    
    NSString * caution = [data stringByMatching:@"CAUTION</h2>(?s)(.*?)</span>" capture:1];
    if(caution != nil){
        [retDic setObject:caution forKey:@"caution"];
    }

    NSString * reward = [data stringByMatching:@"REWARD</h2>(?s)(.*?)</span>" capture:1];
    if(reward != nil){
        [retDic setObject:reward forKey:@"reward"];
    }

    return retDic;
}


-(NSMutableArray *)parseLanguages:(NSString*)data
{
    /*    isoLangs = {
    "ab":{
        "name":"Abkhaz",
        "nativeName":"аҧсуа"
    },*/

	NSMutableArray *langsNames = [data componentsMatchedByRegex:@"\"name\":\"(?s)(.*?)\"" capture:1];
    for(NSString *lang in langsNames){
        NSLog(@"%@",lang);
    }
    NSMutableArray *langsNatives = [data componentsMatchedByRegex:@"\"nativeName\":\"(?s)(.*?)\"" capture:1];
    for(NSString *native in langsNatives){
        NSLog(@"%@",native);
    }
	return langsNames;
}

-(NSMutableDictionary*)parseInit:(NSString*)data
{
    NSMutableArray *retVals = [data componentsSeparatedByString:@";"];
    NSMutableArray *admob = [[retVals objectAtIndex:0] componentsSeparatedByString:@":"];
    NSMutableArray *sh = [[retVals objectAtIndex:1] componentsSeparatedByString:@":"];
    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    [retDic setObject:[admob objectAtIndex:1] forKey:@"admob"];
    [retDic setObject:[sh objectAtIndex:1] forKey:@"sh"];
    return retDic;
}


-(NSMutableArray*)getCountriesStates:(NSString*)data
{
    data = [data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //NSLog(data);
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    
    NSRange range = [data rangeOfString:@"<div id=\"geoListings\">"];
    NSRange end = [data rangeOfString:@"<!-- #geoListings -->"];
    data = [data substringWithRange:NSMakeRange(range.location, end.location - range.location)];
    retArray = [data componentsMatchedByRegex:@"\/\">(.*?)<\/a>" capture:1];
    NSLog(@"%@",retArray);
    return retArray; 
}

-(NSMutableDictionary*)parseAd:(NSString*)data
{
    //<p class="metaInfoDisplay">Contact: 951-398-4586<br></p>
    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    //EnlargeImage
    NSString *title = [data stringByMatching:@"<title>(.*?)<\/title>" capture:1];
    NSLog(@"%@",title);
    [retDic setObject:title forKey:@"title"];
    
    NSString *contact = [data stringByMatching:@"Contact:(.*?)<br>" capture:0];
    if(contact != nil){
        NSLog(@"%@",contact);
        contact = [contact stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
        [retDic setObject:contact forKey:@"contact"];
    }
    
    NSString *mailto = [data stringByMatching:@"mailto:(.*?)\"" capture:1];
    if(mailto != nil){
        NSLog(@"%@",mailto);
        [retDic setObject:mailto forKey:@"mailto"];
    }
    
    NSString *body = [data stringByMatching:@"<h1>(.*?)<\/h1>" capture:1];
    if(body != nil){
        body = [self stripSpecials:body];
        NSLog(@"%@",body);
        [retDic setObject:body forKey:@"body"];
    }
    
    NSString *adInfo = [data stringByMatching:@"Posted:(?s)(.*?)<\/div>" capture:1];
    if(adInfo != nil){
        NSLog(@"%@",adInfo);
        [retDic setObject:adInfo forKey:@"adInfo"];
    }
    
    NSString *postingBody = [data stringByMatching:@"postingBody\">(?s)(.*?)<\/div>" capture:1];
    if(adInfo != nil){
        //postingBody = [self stripSpecials:postingBody];
        NSLog(@"postingBody: %@",postingBody);
        NSString *str = [NSString stringWithFormat:@"<html><body>%@</body></html>",postingBody];
        [retDic setObject:str forKey:@"postingBody"];
    }
    
    //replyDisplay
    NSString *reply = [data stringByMatching:@"<b>Reply<\/b>(.*?)>" capture:1];
    if(reply != nil){
        reply = [self stripSpecials:reply];
        reply = [reply stringByReplacingOccurrencesOfString:@": a href=" withString:@""];
        NSLog(@"%@",reply);
        [retDic setObject:reply forKey:@"reply"];
    }
    
    
    NSMutableArray *images = [self getAdImages:data];
    if(images != nil && images.count > 0){
       [retDic setObject:images forKey:@"images"]; 
    }
    return retDic;
}

-(NSMutableArray*)getAdImages:(NSString*)data
{
    //viewAdPhotoLayout
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    NSString *imgs = [data stringByMatching:@"<ul id=\"viewAdPhotoLayout\" class=\"\">(?s)(.*?)<!-- #viewAdPhotoLayout -->" capture:1];
    if(imgs != nil){
        retArray = [imgs componentsMatchedByRegex:@"<img src=\"(.*?)\"" capture:1];
    }
    return retArray;
}

-(NSMutableArray*)parseOnePage:(NSString*)data
{
    data = [data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"%@",data);
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    //<div class="cat">
    NSMutableArray *itemlist = [data componentsMatchedByRegex:@"<a href(.*?)\"Picture\">" capture:1];
    if(itemlist == nil || itemlist.count == 0){
        itemlist = [data componentsMatchedByRegex:@"<div class=\"cat\">(?s)(.*?)<\/div>" capture:1];
    }
    for(int k=0;k<itemlist.count;k++){
        NSString *eachitem = [itemlist objectAtIndex:k];
        NSString * adurl = [eachitem stringByMatching:@"=(.*?)\">" capture:1];
        NSString *adtext = [eachitem stringByMatching:@">(.*?)<\/a>" capture:1];
        NSString *adimg = [eachitem stringByMatching:@"<img src=\"(.*?)\"" capture:1];
        NSMutableDictionary * dicEntry = [[NSMutableDictionary alloc] init];
        adurl = [self stripSpecials:adurl];
        adtext = [self stripSpecials:adtext];
        adimg = [self stripSpecials:adimg];
        if(adurl != nil){
            [dicEntry setObject:adurl forKey:@"adurl"];
        }
        if(adtext != nil){
            [dicEntry setObject:adtext forKey:@"adtext"];
        }
        if(adimg != nil){
            [dicEntry setObject:adimg forKey:@"adimg"];
        }
        [retArray addObject:dicEntry];
    }
    return retArray;
}

-(NSMutableArray*)getSections:(NSString*)data :(NSString*)prefix
{
    data = [data lowercaseString];
    //<a href="http://allentown.backpage.com/AppliancesForSale/">appliances</a>
    
    data = [data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    NSString *regex = [NSString stringWithFormat:@"%@\/(.*?)<\/a>",prefix];
    NSMutableArray * tempArray = [data componentsMatchedByRegex:regex capture:1];
    //NSLog(@"%@",retArray);
    for(int i=0;i<[tempArray count];i++){
        NSString *oneSection = [tempArray objectAtIndex:i];
        NSString *sectionSuffix = [oneSection stringByMatching:@"(.*?)\/" capture:1];
        if(sectionSuffix == nil || [sectionSuffix isEqualToString:@"classifieds"] || [sectionSuffix isEqualToString:@"online"]) continue;
        NSRange range = [oneSection rangeOfString:@">"];
        if(range.location == NSNotFound) continue;
        NSString *sectionName = [oneSection substringFromIndex:range.location + 1];
        if(sectionName == nil)continue;
        sectionName = [self stripSpecials:sectionName];
        NSLog(@"%@:%@",sectionName,sectionSuffix);
        NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
        [retDic setObject:sectionName forKey:@"name"];
        [retDic setObject:sectionSuffix forKey:@"suffix"];
        [retArray addObject:retDic];
    }
    NSLog(@"%@",retArray);
    return retArray; 
}


-(NSMutableDictionary*)parseGroup:(NSString*)data :(NSString*)groupname
{
   
    data = [data stringByReplacingOccurrencesOfString:@"<Strong>" withString:@"<strong>"];
    data = [data stringByReplacingOccurrencesOfString:@"<STRONG" withString:@"<strong"];
    data = [data stringByReplacingOccurrencesOfString:@"<BR>" withString:@"<br>"];
     NSLog(@"%@",data);
    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    NSString *desc = [data stringByMatching:@"Description(?s)(.*?)<br><br>" capture:1];
    desc = [desc stringByReplacingOccurrencesOfString:@"</strong>" withString:@""];
    [retDic setObject:desc forKey:@"desc"];
    NSString *exp = [data stringByMatching:@"<strong>Explanation(?s)(.*?)<br><br>" capture:1];
    exp = [exp stringByReplacingOccurrencesOfString:@"</strong>" withString:@""];
    [retDic setObject:exp forKey:@"exp"];
    NSString *over = [data stringByMatching:@"<strong>Overview(?s)(.*?)<br><br>" capture:1];
    if(over == nil){
        //<A name="3">
        over = [data stringByMatching:@"<strong>Overview(?s)(.*?)<A name" capture:1];
    }
    over = [over stringByReplacingOccurrencesOfString:@"</strong>" withString:@""];
    [retDic setObject:over forKey:@"over"];
    NSMutableArray *attacks = [data componentsMatchedByRegex:@"<li  class=\"bk10\"><em>(?s)(.*?)</li>" capture:1];
    if(attacks == nil || attacks.count == 0){
        attacks = [data componentsMatchedByRegex:@"<li>(?s)<em>(?s)(.*?)<br>" capture:1];
    }
    if(attacks == nil || attacks.count == 0){
        attacks = [data componentsMatchedByRegex:@"<LI class=\"bk10\"><em>(?s)(.*?)<LI" capture:1];
    }
    if(attacks == nil || attacks.count == 0){
        attacks = [data componentsMatchedByRegex:@"<li class=bk10>(?s)<em>(?s)(.*?)</li>" capture:1];
    }
    if(attacks == nil || attacks.count == 0){
        attacks = [data componentsMatchedByRegex:@"<li>(?s)(.*?)</li>" capture:1];
    }
    //<li class=bk10>
    NSMutableArray *itemAttacks = [[NSMutableArray alloc] init];
    for(NSString *attack in attacks){
        MapItem *_oneItem = [[MapItem alloc] init];
        //June 20, 2009</em>: Truck bombing of a Shi’i mosque near Kirkuk blamed on Al Qaeda in Iraq: at least 75 killed, 163 wounded.
        NSString *date = [attack stringByMatching:@"(?s)(.*?)</em>" capture:1];
        if(date == nil)continue;
        NSRange range = [attack rangeOfString:@"</em>"];
        NSString *descrip = [attack substringFromIndex:range.location + range.length + 1];
        _oneItem.date = date;
        _oneItem.description = [descrip stringByConvertingHTMLToPlainText];
        [itemAttacks addObject:_oneItem];
    }
    [retDic setObject:itemAttacks forKey:@"attacks"];
    NSString *methods = [data stringByMatching:@"<strong>Methods<\/strong>(?s)(.*?)<br><br>" capture:1];
    if(methods == nil){
        //<A name="3">
        methods = [data stringByMatching:@"<strong>Methods(?s)(.*?)<A name" capture:1];
    }
    methods = [methods stringByReplacingOccurrencesOfString:@"</strong>" withString:@""];
    [retDic setObject:methods forKey:@"methods"];
    NSString *sponsors = [data stringByMatching:@"<strong>Sponsors<\/strong>(?s)(.*?)<br><br>" capture:1];
    if(sponsors == nil){
        //<A name="3">
        sponsors = [data stringByMatching:@"<strong>Sponsors(?s)(.*?)<A name" capture:1];
    }
    sponsors = [sponsors stringByReplacingOccurrencesOfString:@"</strong>" withString:@""];
    [retDic setObject:methods forKey:@"sponsors"];
    
    return retDic;
}

-(NSMutableArray*)parseProfiles:(NSString*)data
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    NSMutableArray *profiles = [data componentsMatchedByRegex:@"<table width=\"454\(?s)(.*?)</table>" capture:1];
    
    for(NSString *oneProfile in profiles){
        NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
        //CLASS="BK10B">Barry Walter Bujol Jr.</td>
        NSString *name = [oneProfile stringByMatching:@"CLASS=\"BK10B\">(?s)(.*?)</td>" capture:1];
        name = [name stringByConvertingHTMLToPlainText];
        [retDic setObject:name forKey:@"name"];
    
        NSString *img = [oneProfile stringByMatching:@"<img src=\"(?s)(.*?)\"" capture:1];
        NSString *imageSrc = @"http://www.adl.org/";
        imageSrc = [imageSrc stringByAppendingString:img];
        [retDic setObject:imageSrc forKey:@"img"];
    
        NSString *desc = [oneProfile stringByMatching:@"<strong>Profile:</strong>(?s)(.*?)<div" capture:1];
        desc = [desc stringByConvertingHTMLToPlainText];
        [retDic setObject:desc forKey:@"desc"];
        
        [retArray addObject:retDic];
    }
    return retArray;
}

-(NSMutableArray*)parseAutocompleteResults:(NSString*)data
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    NSMutableDictionary* theObject=[data JSONValue];
    NSMutableArray *results = [theObject objectForKey:@"results"];
    for(int i=0;i<results.count;i++){
        NSMutableDictionary *oneresult = [results objectAtIndex:i];
        AutoCompleteResult *autocompleteres = [[AutoCompleteResult alloc] init];
        [autocompleteres setAddress:[oneresult objectForKey:@"formatted_address"]];
        [autocompleteres setTripNickname:[oneresult objectForKey:@"name"]];
        [autocompleteres setIconUrl:[oneresult objectForKey:@"icon"]];
        NSMutableDictionary *geo = [oneresult objectForKey:@"geometry"];
        NSMutableDictionary *loc = [geo objectForKey:@"location"];
        [autocompleteres setCoordinates:CLLocationCoordinate2DMake([[loc objectForKey:@"lat"] doubleValue], [[loc objectForKey:@"lng"] doubleValue])];
        [retArray addObject:autocompleteres];
    }
    NSLog(@"%@",results);
    return retArray;
}

-(NSString*)stripSpecials:(NSString*)string
{
    string = [string stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"<" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@">" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"&pound;" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    return string;
}

@end
