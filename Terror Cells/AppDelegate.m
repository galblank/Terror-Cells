//
//  AppDelegate.m
//  Terror Cells
//
//  Created by Gal Blank on 11/4/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//

#import "AppDelegate.h"
#import "Globals.h"
#import "MainViewController.h"
#import "ImageDemoViewController.h"
@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    BOOL iPad = NO;
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        [[Globals sharedInstance] setBiPad:YES];
        NSLog(@"iPad");
    } else {
        NSLog(@"iPhone");
        [[Globals sharedInstance] setBiPad:NO];
    }
    /*
     [[Globals sharedInstance] setTitleBarColor:[UIColor colorWithRed:79.0/255.0 green:133.0/255.0 blue:219.0/255.0 alpha:1.0]];
     [[Globals sharedInstance] setGBackgroundColor:[UIColor colorWithRed:222.0 / 255.0 green:232.0 / 255.0 blue:234.0 / 255.0 alpha:1.0]];
     [[Globals sharedInstance] setTitleTextColor:[UIColor colorWithRed:89.0 / 255.0 green:93.0 / 255.0 blue:82.0 / 255.0 alpha:1.0]];
     */
    mainView = [[MainViewController alloc] init];
    
	rootController = [[UINavigationController alloc] initWithRootViewController:mainView];
	[rootController setTitle:@"MainView"];
    
    [self loadMainView];
    
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    [[UIBarButtonItem appearance] setTintColor:[UIColor lightGrayColor]];
    
    //[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

-(void)loadMainView
{
    [self.window addSubview:[rootController view]];
	[self.window makeKeyAndVisible];
    //[self showSplash];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void)showActivityViewer:(NSString*)caption :(CGRect)frame
{
    NSMutableDictionary *varsdic = [[NSMutableDictionary alloc] init];
    [varsdic setObject:caption forKey:@"caption"];
    NSValue *rectValue = [NSValue valueWithCGRect:frame];
    [varsdic setObject:rectValue forKey:@"frame"];
	[NSThread detachNewThreadSelector:@selector(localThread:) toTarget:self withObject:varsdic];
}

-(void)localThread:(NSMutableDictionary*)vars
{
	/*You need this for all threads you create or you will leak!*/
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	if([mWaitingScreen isCurrentlyActive] == YES){
		return;
	}
	
	if(mWaitingScreen != nil){
		[mWaitingScreen release];
	}
	
    NSValue *rectValue = [vars objectForKey:@"frame"];
    CGRect frame = [rectValue CGRectValue];
    
    NSString *caption = [vars objectForKey:@"caption"];
	mWaitingScreen = [[WaitingScreenView alloc] initWithFrame:frame];
	[mWaitingScreen setCaption:caption];
	[self.window addSubview: mWaitingScreen];
	//[mWaitingScreen release];
	[[[mWaitingScreen subviews] objectAtIndex:0] startAnimating];
	[mWaitingScreen setIsCurrentlyActive:YES];
	[self performSelectorOnMainThread:@selector(threadisFinished) withObject:nil waitUntilDone:NO];
    //remove our pool and free the memory collected by it
	[pool release];
}

-(void)threadisFinished
{
	
}

-(void)hideActivityViewer
{
	[mWaitingScreen setIsCurrentlyActive:NO];
	if(mWaitingScreen != nil){
		NSMutableArray *views = [mWaitingScreen subviews];
		for(int i=0;i<[views count];i++){
			id * oneView = [views objectAtIndex:i];
			if([oneView isKindOfClass:[UIActivityIndicatorView class]] == YES){
				[oneView stopAnimating];
			}
		}
		//[[[mWaitingScreen subviews] objectAtIndex:0] stopAnimating];
		[mWaitingScreen removeFromSuperview];
		mWaitingScreen = nil;
	}
}


@end
