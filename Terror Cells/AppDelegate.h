//
//  gbAppDelegate.h
//  Stixi
//
//  Created by Gal Blank on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaitingScreenView.h"
#import "MainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    WaitingScreenView * mWaitingScreen;
    MainViewController *mainView;
    UINavigationController *rootController;
}
@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void)loadMainView;
-(void)showSplash;


@end
