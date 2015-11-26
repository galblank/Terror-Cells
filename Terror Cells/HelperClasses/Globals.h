//
//  Globals.h
//  First App
//
//  Created by Gal Blank on 9/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommManager.h"
#import "Parser.h"
#import <CoreLocation/CoreLocation.h>
#import "UIUnderlinedButton.h"
#import <MessageUI/MessageUI.h>


#define GLOBAL_VERSION @"0.0.1"

#define GLOBAL_INFOTEXT @"© 2014 All rights reserved."

#define GLOBAL_LOGINURL @"http://stixi.ru/"
#define GLOBAL_SERVERSURL @"http://stixi.ru/"

//#define GLOBAL_LOGINURL @"http://10.1.10.84:8080/alfresco/service/api/login?u=admin&pw=Must$Haven&format=json"
//#define GLOBAL_SERVERSURL @"http://10.1.10.84:8080/alfresco/service/integrity/"

#define GLOBAL_IMGSURL @"http://97.74.119.205/iscoopit/userimages/"

#define GLOBAL_LEVELIMGS @"http://97.74.119.205/iscoopit/levelimages/"

#define GLOBAL_NEWSIMGS @"http://97.74.119.205/iscoopit/newsitems/"

#define FACEBOOKAPIKEY @"eef912c908999a1e843f1e808c4203bf"

#define FACEBOOKAPPLICATIONID @"113221985405484"

#define FACEBOOKAPPSECRET @"0a8db3f6aecb9d27ae6e4f0294c1f0eb"


#define GLOBAL_TOU @"https://docs.google.com/document/pub?id=1E7kOcoxzk5U4Tsh0ZeeQD7RVsCbqzY_Ri7oXnhEQY_U"
#define GLOBAL_ABOUTUS @"https://docs.google.com/document/pub?id=1PgH6rxJOAtq2VXCQsl4dAtRSO0h3ztovGx5097NTHsw"

#define GLOBALS_NSH @"01100110011101010110001101101011011110010110111101110101"
#define GLOBALS_SH @"01100110011101010110001101101011011110010110111101110001"

//113221985405484|ac9b22d1eea161648555fa1a-100000021671840|AYyxFXR9B42jtryjq2YP_MgfTys
//113221985405484|ac9b22d1eea161648555fa1a-100000021671840|AYyxFXR9B42jtryjq2YP_MgfTys

@interface Globals : NSObject<MFMailComposeViewControllerDelegate> {
	BOOL globalDebugMode;
	BOOL bTrialMode;
	int globalCurrentStatus;
	BOOL m_bSaveLoginDetails;
	UIColor *textColor;

	//profile data
	NSString * gAPNSKEY;
	
	
	NSMutableDictionary *userProfileData;
	NSMutableDictionary *levelsData;
	NSMutableDictionary *globalData;
	int nudgesLeft;
	CLLocation *myGpsLocation;
	CLLocationDirection myGpsHeading;
	UIImage *userProfilePic;
    NSString * userAutoLoginId;
    NSString *userRole; 
    BOOL isLoggedOut;
    UIColor *titleBarColor;
    UIColor *titleTextColor;
    
    NSMutableDictionary *g_countryList;
    NSMutableDictionary *lastKnownGoodData;
    
    NSMutableDictionary *reportData;
    
    //id * currentUserLocation;
    
    UIColor *gBackgroundColor;
    
    NSString *ticket;
    
    UIViewController* Viewclass;
    NSMutableDictionary *loggedInuser;
    BOOL bReadingSaved;
    UIViewController *mailViewController;
    BOOL biPad;
    NSString *admobId;
    NSString *sh;
    
    NSMutableArray *breadcrumbMenu;
}
@property(nonatomic,retain)NSMutableArray *breadcrumbMenu;
@property(nonatomic,retain)NSString *sh;
@property(nonatomic)NSString *admobId;
@property(nonatomic)BOOL biPad;
@property(nonatomic)BOOL bReadingSaved;
@property(nonatomic)BOOL isLoggedOut;
@property(nonatomic)BOOL bTrialMode;
@property(nonatomic)BOOL globalDebugMode;
@property(nonatomic)int globalCurrentStatus;
@property(nonatomic)BOOL m_bSaveLoginDetails;
@property(nonatomic,retain)NSMutableDictionary *loggedInuser;
@property(nonatomic,retain)UIColor *textColor;
@property(nonatomic,retain)UIColor *titleBarColor;
@property(nonatomic,retain)NSMutableDictionary *g_countryList;
@property(nonatomic,retain)UIColor *gBackgroundColor;
@property(nonatomic,retain)NSString *userRole;
@property(nonatomic,retain)NSString *ticket;
@property(nonatomic,retain)NSString * userAutoLoginId;
@property(nonatomic,retain)NSString * gAPNSKEY;
@property(nonatomic,retain)NSMutableDictionary *userProfileData;
@property(nonatomic,retain)NSMutableDictionary *levelsData;
@property(nonatomic,retain)NSMutableDictionary *globalData;
@property(nonatomic,retain)CLLocation *myGpsLocation;
@property(nonatomic)CLLocationDirection myGpsHeading;
@property(nonatomic)int nudgesLeft;
@property(nonatomic,retain)UIImage *userProfilePic;
@property(nonatomic,retain)NSMutableDictionary *lastKnownGoodData;
@property(nonatomic,retain)NSMutableDictionary *reportData;
@property(nonatomic,retain)UIColor *titleTextColor;
@property(nonatomic)UIViewController * Viewclass;

+ (Globals *)sharedInstance;
-(float) labelHeight:(NSString*)text forFont:(UIFont*)font initialSize:(CGSize)size;
-(void)addToolbar:(id*)Viewclass :(UIView*)viewToAdd :(int)ItemOn;
-(void)setuserImageThreaded;
-(NSString *)getCountryImage:(NSString*)country;
-(void)setTitleView:(UIView*)topBar :(UIViewController*)parent;
-(void)setBackground:(UIView*)view;
-(void)loadInvitationForm:(UIViewController*)controller :(NSString*)mailto :(NSString*)subject;
-(void)addAdv:(UIView*)view :(BOOL)bOnTop;
-(NSString*)buildAddressFromLocation:(CLPlacemark *)location;
@end
