//
//  Globals.m
//  First App
//
//  Created by Gal Blank on 9/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Globals.h"
#import "UIImage+Resizing.h"
static Globals *sharedSingletonDelegate = nil;

@implementation Globals;
@synthesize globalDebugMode,globalCurrentStatus,m_bSaveLoginDetails,textColor,gAPNSKEY,myGpsLocation,userProfileData,myGpsHeading,userProfilePic;
@synthesize userRole,isLoggedOut,titleBarColor,lastKnownGoodData,gBackgroundColor,titleTextColor,reportData,userAutoLoginId,ticket,Viewclass,g_countryList,loggedInuser,bReadingSaved,biPad,admobId,sh,breadcrumbMenu;


+ (Globals *)sharedInstance {
	@synchronized(self) {
		if (sharedSingletonDelegate == nil) {
			[[self alloc] init]; // assignment not done here
		}
	}
	return sharedSingletonDelegate;
}


+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedSingletonDelegate == nil) {
			sharedSingletonDelegate = [super allocWithZone:zone];
			// assignment and return on first allocation
			return sharedSingletonDelegate;
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

-(float) labelHeight:(NSString*)text forFont:(UIFont*)font initialSize:(CGSize)size
{
	CGSize textSize = [text sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
	float height = textSize.height+textSize.height/3 ;
	return height;		
}

-(void)setuserImageThreaded
{
	[NSThread detachNewThreadSelector:@selector(setuserImage) toTarget:self withObject:nil];
}

-(void)setuserImage
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	
	NSString *_imageurl = [NSString stringWithFormat:@"%@GetUserImage?userId=%@",GLOBAL_SERVERSURL,[self.userProfileData objectForKey:@"UserId"]];
	NSURL *_url=[NSURL URLWithString:_imageurl];
	NSData *_data = [NSData dataWithContentsOfURL:_url];
	self.userProfilePic = [[UIImage alloc] initWithData:_data];
	
	
	[self performSelectorOnMainThread:@selector(finished) withObject:nil waitUntilDone:NO];
	
    //remove our pool and free the memory collected by it
    [pool release];
}

-(void)finished
{
	NSLog(@"FInished setting user profile pic");
}

-(void)setBackground:(UIView*)view
{
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
    if(biPad){
        [bg setFrame:CGRectMake(184,580, 400, 300)];
    }
    else{
        [bg setFrame:CGRectMake(0,0, 320, 480)];
    }
    [view addSubview:bg];
    [view sendSubviewToBack:bg]; 
}

-(UILabel*)setTitleBar:(NSString*)text
{
    if(self.breadcrumbMenu == nil){
        self.breadcrumbMenu = [[NSMutableArray alloc] init];
    }
    [self.breadcrumbMenu addObject:text];
    UILabel *topbarLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 150, 40)];
    [topbarLabel setUserInteractionEnabled:YES];
	[topbarLabel setBackgroundColor:[UIColor clearColor]];
    [topbarLabel setTextAlignment:UITextAlignmentCenter];
    
   /* NSString *_bcmenu = @"";
    int i=0;
    for(NSString *menu in self.breadcrumbMenu){
        if(i==0){
            _bcmenu = menu;
        }
        else{
            _bcmenu = [_bcmenu stringByAppendingFormat:@">%@",menu];
        }
        i++;
    }*/
    [topbarLabel setText:text];
    
    [topbarLabel setFont:[UIFont fontWithName:@"Arial" size:14.0]];
    [topbarLabel setTextColor:[UIColor whiteColor]];
	return topbarLabel;
}

-(void)setTitleView:(UIView*)topBar :(UIViewController*)parent
{
    [topBar setOpaque:false];
    
    
    UILabel *topbarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 47)];
    [topbarLabel setUserInteractionEnabled:YES];
    UIImage *topbarBgImg = [UIImage imageNamed:@"header_bg.png"];
    topbarBgImg = [UIImage imageOfSize:CGSizeMake(320, 47) fromImage:topbarBgImg];
    UIImageView *topLabelBgImg = [[UIImageView alloc] initWithImage:topbarBgImg];
    [topLabelBgImg setFrame:CGRectMake(0, 0, 320, 47)];
    [topbarLabel addSubview:topLabelBgImg];
    [topbarLabel setTextColor:[UIColor whiteColor]];
    [topbarLabel setText:@"Stixi.ru"];
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageOfSize:CGSizeMake(55, 38) fromImage:[UIImage imageNamed:@"logo.gif"]]];
    [logoView setFrame:CGRectMake(10, 4, 75, 38)];
   // [topbarLabel addSubview:logoView];
   
    /*
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setImage:[UIImage imageOfSize:CGSizeMake(45, 30) fromImage:[UIImage imageNamed:@"search_na.png"]] forState:UIControlStateNormal];
    [searchButton setFrame:CGRectMake(220, 7, 45, 30)];
    [searchButton addTarget:parent action:@selector(loadSettings) forControlEvents:UIControlEventTouchUpInside];
    [topbarLabel addSubview:searchButton];
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setImage:[UIImage imageOfSize:CGSizeMake(45, 30) fromImage:[UIImage imageNamed:@"settings_na.png"]] forState:UIControlStateNormal];
    [settingsButton setFrame:CGRectMake(265, 7, 45, 30)];
    [settingsButton addTarget:parent action:@selector(loadSettings) forControlEvents:UIControlEventTouchUpInside];
    [topbarLabel addSubview:settingsButton];
    */
    [topBar addSubview:topbarLabel];
}

-(void)addToolbar:(id*)Viewclass :(UIView*)viewToAdd :(int)ItemOn
{
    UIToolbar *toolbar = [UIToolbar new];
	toolbar.tag = 2;
	toolbar.barStyle = UIBarStyleDefault;
    toolbar.tintColor = [UIColor blackColor];
    //toolbar.tintColor = [UIColor colorWithRed:97.0 / 255.0 green:97.0 / 255.0 blue:97.0 / 255.0 alpha:1.0];
	[toolbar sizeToFit];
	//[toolbar setTranslucent:YES];
	toolbar.frame = CGRectMake(0,372, 320, 45.0);
	//Add buttons
    
    
    ///////////////EVENTS///////////////
    UIButton * buttonevents = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonevents.frame = CGRectMake(0,0,60,40);
    UIImage *eventsOn = [UIImage imageNamed:@"events_active.png"];
    eventsOn = [UIImage imageOfSize:CGSizeMake(60, 40) fromImage:eventsOn];
    UIImage *eventsOff = [UIImage imageNamed:@"events_not_active.png"];
    eventsOff = [UIImage imageOfSize:CGSizeMake(60, 40) fromImage:eventsOff];
    [buttonevents setImage:eventsOff forState:UIControlStateNormal];
    [buttonevents setImage:eventsOn forState:UIControlStateHighlighted];
    [buttonevents addTarget:self action:@selector(gohome) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemButtonEvents = [[UIBarButtonItem alloc] initWithCustomView:buttonevents];
   
    //////////////ATHELTS///////////////
    UIButton * buttonAthlets = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonAthlets.frame = CGRectMake(0,0,60,40);
    UIImage *athketsOnImg = [UIImage imageNamed:@"athlets_active.png"];
    UIImage *athletsOffImg = [UIImage imageNamed:@"athlets_not_active.png"];
    athketsOnImg = [UIImage imageOfSize:CGSizeMake(60,40) fromImage:athketsOnImg];
    athletsOffImg = [UIImage imageOfSize:CGSizeMake(60,40) fromImage:athletsOffImg];
    if(ItemOn == 1){
        athletsOffImg = athketsOnImg;
    }
    [buttonAthlets setImage:athletsOffImg forState:UIControlStateNormal];
    [buttonAthlets setImage:athketsOnImg forState:UIControlStateHighlighted];
    UIBarButtonItem *itemAthlets = [[UIBarButtonItem alloc] initWithCustomView:buttonAthlets];
    
    
    /////////////TEAMS/////////////////
    UIButton * buttonTeams= [UIButton buttonWithType:UIButtonTypeCustom];
    buttonTeams.frame = CGRectMake(0,0,60,40);
    UIImage *teamsOnImg = [UIImage imageNamed:@"teams_active.png"];
    UIImage *teamsOffImg = [UIImage imageNamed:@"teams_not_active.png"];
    teamsOnImg = [UIImage imageOfSize:CGSizeMake(60,40) fromImage:teamsOnImg];
    teamsOffImg = [UIImage imageOfSize:CGSizeMake(60,40) fromImage:teamsOffImg];
    if(ItemOn == 2){
        teamsOffImg = teamsOnImg;
    }
    [buttonTeams setImage:teamsOffImg forState:UIControlStateNormal];
    [buttonTeams setImage:teamsOnImg forState:UIControlStateHighlighted];
    UIBarButtonItem *itemTeams = [[UIBarButtonItem alloc] initWithCustomView:buttonTeams];
    
    //////////////COACHES//////////////
    UIButton * buttonCoaches = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonCoaches.frame = CGRectMake(0,0,60,40);
    UIImage *coachesOnImg = [UIImage imageNamed:@"coaches_active.png"];
    UIImage *coachesOffImg = [UIImage imageNamed:@"coaches_not_active.png"];
    coachesOnImg = [UIImage imageOfSize:CGSizeMake(60,40) fromImage:coachesOnImg];
    coachesOffImg = [UIImage imageOfSize:CGSizeMake(60,40) fromImage:coachesOffImg];
    if(ItemOn == 3){
        coachesOffImg = coachesOnImg;
    }
    [buttonCoaches setImage:coachesOffImg forState:UIControlStateNormal];
    [buttonCoaches setImage:coachesOnImg forState:UIControlStateHighlighted];
    UIBarButtonItem *itemCoaches = [[UIBarButtonItem alloc] initWithCustomView:buttonCoaches];
    
    
    /////////////MORE/////////////////
    UIButton * buttonMore = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonMore.frame = CGRectMake(0,0,60,40);
    UIImage *moreOnImg = [UIImage imageNamed:@"more_active.png"];
    UIImage *moreOffImg = [UIImage imageNamed:@"more_not_active.png"];
    moreOnImg = [UIImage imageOfSize:CGSizeMake(60,40) fromImage:moreOnImg];
    moreOffImg = [UIImage imageOfSize:CGSizeMake(60,40) fromImage:moreOffImg];
    if(ItemOn == 4){
        moreOffImg = moreOnImg;
    }
    [buttonMore setImage:moreOffImg forState:UIControlStateNormal];
    [buttonMore setImage:moreOnImg forState:UIControlStateHighlighted];
    UIBarButtonItem *itemMore = [[UIBarButtonItem alloc] initWithCustomView:buttonMore];
    
  
	
	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	//Add buttons to the array
	NSArray *items = [NSArray arrayWithObjects:flexItem,itemButtonEvents,flexItem,itemAthlets,flexItem,itemTeams,flexItem,itemCoaches,flexItem,itemMore,flexItem,nil];
	
	
	//add array of buttons to toolbar
	[toolbar setItems:items animated:NO];
    [viewToAdd addSubview:toolbar]; 
}

-(void)gohome
{
    [Viewclass.navigationController popToRootViewControllerAnimated:YES];
}



/*
 Try the link bellow(it's not finished yet): 
 
 POST http://75.146.218.13:8111/alfresco/service/integrity/submit
 
 Tested with :
 
 <html>
 <body>
 <form action="${url.service}" method="post" enctype="multipart/form-data">
 File: <input type="file" name="file"><br>
 udid: <input name="udid" value="udid"><br>
 id: <input name="id" value="id"><br>
 country: <input name="country" value="country"><br>
 topic: <input name="topic" value="topic"><br>
 activity: <input name="activity" value="activity"><br>
 description: <input name="description" value="description"><br>
 firstName: <input name="firstName" value="firstName"><br>
 lastName: <input name="lastName" value="lastName"><br>
 age: <input name="age" value="4"><br>
 gender: <input name="gender" value="Male"><br>
 email: <input name="email" value="email"><br>
 <input type="submit" name="submit" value="Upload">
 </form>
 </body>
 </html>
 
 where  ${url.service} =  http://75.146.218.13:8111/alfresco/service/integrity/submit
 */

-(NSString*)buildSubmitForm
{
        NSString *retStr = @"";
    
}

-(NSString*)speciaoOrgFromImageName:(NSString*)image
{
    NSString *retName = image;
    if([image isEqualToString:@"cia.png"]){
        retName = @"Central Intelligence Agency";
    }
    else if([image isEqualToString:@"mossad.png"]){
        retName = @"Mossad";
    }
    else if([image isEqualToString:@"dst.png"]){
        retName = @"dst";
    }
    else if([image isEqualToString:@"dhs.png"]){
        retName = @"United States Department of Homeland Security";
    }
    else if([image isEqualToString:@"fsb.png"]){
        retName = @"Federal Security Service";
    }
    else if([image isEqualToString:@"mi5.png"]){
        retName = @"Directorate of Military Intelligence, Section 5";
    }
    else if([image isEqualToString:@"mi6.png"]){
        retName = @"Directorate of Military Intelligence, Section 6";
    }
    else if([image isEqualToString:@"nsa.png"]){
        retName = @"National Security Agency";
    }
    
    return retName;
}

-(NSString *)getCountryImage:(NSString*)country
{
    NSString *flagImg = @"";
    country = [country stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    country = [country lowercaseString];
    country = [country stringByReplacingOccurrencesOfString:@" " withString:@""];
    country = [country stringByReplacingOccurrencesOfString:@"," withString:@""];
    country = [country stringByReplacingOccurrencesOfString:@"-" withString:@""];
    country = [country stringByReplacingOccurrencesOfString:@"'" withString:@""];
    country = [country stringByReplacingOccurrencesOfString:@"(" withString:@""];
    country = [country stringByReplacingOccurrencesOfString:@")" withString:@""];
    country = [country stringByReplacingOccurrencesOfString:@",the" withString:@""];
    country = [country stringByReplacingOccurrencesOfString:@",rep" withString:@""];
    country = [country stringByReplacingOccurrencesOfString:@",rb" withString:@""];
    if([country rangeOfString:@"congo"].location != NSNotFound){
        flagImg = @"congo.png";
    }
    else if([country rangeOfString:@"egypt"].location != NSNotFound){
        flagImg = @"egypt.png";
    }
    else if([country rangeOfString:@"bahamas"].location != NSNotFound){
        flagImg = @"bahamas.png";
    }
    else if([country rangeOfString:@"gambia"].location != NSNotFound){
        flagImg = @"gambia.png";
    }
    else if([country rangeOfString:@"euroarea"].location != NSNotFound){
        flagImg = @"europeanunion.png";
    }
    else if([country rangeOfString:@"korea"].location != NSNotFound){
        flagImg = @"korea.png";
    }
    else if([country rangeOfString:@"hongkong"].location != NSNotFound){
        flagImg = @"hongkong.png";
    }
    else if([country rangeOfString:@"iran"].location != NSNotFound){
        flagImg = @"iran.png";
    }
    else if([country rangeOfString:@"korea"].location != NSNotFound){
        flagImg = @"korea.png";
    }
    else if([country rangeOfString:@"yemen"].location != NSNotFound){
        flagImg = @"yemen.png";
    }
    else if([country rangeOfString:@"syrian"].location != NSNotFound){
        flagImg = @"syria.png";
    }
    else if([country rangeOfString:@"macedonia"].location != NSNotFound){
        flagImg = @"macedonia.png";
    }
    else if([country rangeOfString:@"venezuela"].location != NSNotFound){
        flagImg = @"venezuela.png";
    }
    else{
        flagImg = [NSString  stringWithFormat:@"%@.png",country];
    }
    NSLog(flagImg);
    return flagImg;
}



-(void)SendContributionMail:(UIViewController*)controller
{
	mailViewController = controller;
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self; // &lt;- very important step if you want feedbacks on what the user did with your email sheet
	NSMutableArray *toarray = [[NSMutableArray alloc] init];
    [toarray addObject:@"terrorcells@gmail.com"];
    [picker setToRecipients:toarray];
	[picker setSubject:@"Add new terror cell intel"];
	// Fill out the email body text
	NSString *emailBody = [NSString stringWithFormat:@"Please add as much information as you can!!<p><b><br />Cell Location:<br />Cell Size(How many people involved):<br />Spoken language:<br />Any other detail that you might think is relevant:</p>"];
	
	[picker setMessageBody:emailBody isHTML:YES]; // depends. Mostly YES, unless you want to send it as plain text (boring)
	
	picker.navigationBar.barStyle = UIBarStyleBlack; // choose your style, unfortunately, Translucent colors behave quirky.
	
	[controller presentModalViewController:picker animated:YES];
	[picker release];
}

-(void)loadInvitationForm:(UIViewController*)controller :(NSString*)mailto :(NSString*)subject
{
	mailViewController = controller;
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self; // &lt;- very important step if you want feedbacks on what the user did with your email sheet
	NSMutableArray *toarray = [[NSMutableArray alloc] init];
    [toarray addObject:mailto];
    [picker setToRecipients:toarray];
	[picker setSubject:subject];
	// Fill out the email body text
	NSString *emailBody = [NSString stringWithFormat:@"<p>Sent via Terror Cells App</p>"];
	
	[picker setMessageBody:emailBody isHTML:YES]; // depends. Mostly YES, unless you want to send it as plain text (boring)
	
	picker.navigationBar.barStyle = UIBarStyleBlack; // choose your style, unfortunately, Translucent colors behave quirky.
	
	[controller presentModalViewController:picker animated:YES];
	[picker release];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{ 
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
		{
			/*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank you!" message:@"Your request has been sent, someone from Inteltrain.com will contact you as soon as possible."delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alert show];
             [alert release];*/
		}
			break;
		case MFMailComposeResultFailed:
			break;
			
		default:
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Sending Failed, please try again later."
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];
			[alert release];
		}
			
			break;
	}
	[mailViewController dismissModalViewControllerAnimated:YES];
}


-(NSMutableArray*) getLocationFromAddressString:(NSString*) addressStr {
    
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
	
    NSString *urlStr = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv",[addressStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
    NSString *locationStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlStr]];
	
    NSArray *items = [locationStr componentsSeparatedByString:@","];
	
	
    double lat = 0.0;
	
    double longtitude = 0.0;
	
	
    if([items count] >= 4 && [[items objectAtIndex:0] isEqualToString:@"200"]) {
		
        lat = [[items objectAtIndex:2] doubleValue];
		
        longtitude = [[items objectAtIndex:3] doubleValue];
		
    }
	
    else {
		
        NSLog(@"Address, %@ not found: Error %@",addressStr, [items objectAtIndex:0]);
		
    }
    [retArray addObject:[NSNumber numberWithDouble:lat]];
    [retArray addObject:[NSNumber numberWithDouble:longtitude]];
    return retArray;
	
}

///////////////////ROUTE CALCULAIOTNS/////////////////////

-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded {
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
								options:NSLiteralSearch
								  range:NSMakeRange(0, [encoded length])];
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
	NSInteger lat=0;
	NSInteger lng=0;
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[[NSNumber alloc] initWithFloat:lat * 1e-5] autorelease];
		NSNumber *longitude = [[[NSNumber alloc] initWithFloat:lng * 1e-5] autorelease];
		//printf("[%f,", [latitude doubleValue]);
		//printf("%f]", [longitude doubleValue]);
		CLLocation *loc = [[[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]] autorelease];
		[array addObject:loc];
	}
	
	return array;
}

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t {
	NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
	NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
	
	NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
	NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
	NSLog(@"api url: %@", apiUrl);
	NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl];
    NSLog(@"apiResponse %@", apiResponse);
	NSString* encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
	NSLog(@"encodedPoints %@", encodedPoints);
	return [self decodePolyLine:[encodedPoints mutableCopy]];
}

-(void)loadInvitationForm:(UIViewController*)controller
{
	mailViewController = controller;
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self; // &lt;- very important step if you want feedbacks on what the user did with your email sheet
	NSMutableArray *toarray = [[NSMutableArray alloc] init];
	[picker setSubject:@"Terror Cells - Know your enemy!"];
	// Fill out the email body text
    NSString *link = @"https://itunes.apple.com/us/artist/gal-blank/id335153129";
	NSString *emailBody = [NSString stringWithFormat:@"<p>Great app that lets you follow up on the latest development in the terrorism reality and lets you be a part of the teams that fights terror, domestic and foreign.<br />Tap <a href=\"%@\">HERE</a> to download Terror Cells to your device</p>",link];
	
	[picker setMessageBody:emailBody isHTML:YES]; // depends. Mostly YES, unless you want to send it as plain text (boring)
	
	picker.navigationBar.barStyle = UIBarStyleBlack; // choose your style, unfortunately, Translucent colors behave quirky.
	
	[controller presentModalViewController:picker animated:YES];
	[picker release];
}


-(NSString*)buildAddressFromLocation:(CLPlacemark *)location
{
    NSString * zipCode = [location postalCode];
    NSString *_country = [location country];
    NSString *state = [location administrativeArea];
    //NSString *_region = [location region];
    NSString *city = [location locality];
    NSString *streetname = [location thoroughfare];
    
    NSString *address = @"";
    
    if(streetname != nil && streetname.length > 0){
        address = [address stringByAppendingString:streetname];
    }
    if(city != nil && city.length > 0){
        address = [address stringByAppendingString:@","];
        address = [address stringByAppendingString:city];
    }
    if(state != nil && state.length > 0){
        address = [address stringByAppendingString:@","];
        address = [address stringByAppendingString:state];
    }
    if(_country != nil && _country.length > 0){
        address = [address stringByAppendingString:@","];
        address = [address stringByAppendingString:_country];
    }
    if(_country != nil  && [_country isEqualToString:@"Kyrgyzstan"]){
        return @"";
    }
    if(zipCode != nil && zipCode.length > 0){
        address = [address stringByAppendingString:@","];
        address = [address stringByAppendingString:zipCode];
    }
    
    return address;
}

@end
