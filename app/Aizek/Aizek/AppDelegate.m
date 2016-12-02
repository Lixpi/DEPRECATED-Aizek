//
//  AppDelegate.m
//  Aizek
//
//  Created by Elchibek Konurbaev on 11/6/14.
//  Copyright (c) 2014 Linum. All rights reserved.
//

#import "AppDelegate.h"
#import "DataBase.h"
#import "Base64.h"






@implementation AppDelegate

+(instancetype)delegate {
    return (AppDelegate*)[[UIApplication sharedApplication]delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self createCopyOfFile:@"data.plist"];
    [self createCopyOfFile:@"db.sqlite"];
    
    
    
    [DataBase setModelName:@"Aizek"];
    [DataBase setDBPath:@"Aizek.sqlite"];
    [DataBase sharedInstance];
    
    [Base64 initialize];
    

    if([[[UIDevice currentDevice] model]isEqualToString:@"iPad"]){
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"iPadStoryboard" bundle:nil];
        self.window.rootViewController = [sb instantiateViewControllerWithIdentifier:@"tabBar"];
    }
    if([[UIScreen mainScreen] bounds].size.height<568) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard4" bundle:nil];
        self.window.rootViewController = [sb instantiateViewControllerWithIdentifier:@"tabBar"];
    }

    
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:mySettings];
        [application registerForRemoteNotifications];
    } else {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if(locationNotification) {
        application.applicationIconBadgeNumber = 0;
    }
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UITabBar *tabBar = tabBarController.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];
    
    tabBarItem1.title = @"Capture";
    tabBarItem2.title = @"Statistics";
    tabBarItem3.title = @"Gallery";
    tabBarItem4.title = @"Settings";
    
    [tabBarItem1 setImage:[[UIImage imageNamed:@"tabbar_capture.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem1 setSelectedImage:[[UIImage imageNamed:@"tabbar_capture.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic]];
    [tabBarItem2 setImage:[[UIImage imageNamed:@"tabbar_statistics.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem2 setSelectedImage:[[UIImage imageNamed:@"tabbar_statistics.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic]];
    [tabBarItem3 setImage:[[UIImage imageNamed:@"tabbar_gallery.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem3 setSelectedImage:[[UIImage imageNamed:@"tabbar_gallery.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic]];
    [tabBarItem4 setImage:[[UIImage imageNamed:@"tabbar_settings.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem4 setSelectedImage:[[UIImage imageNamed:@"tabbar_settings.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic]];
    
 
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    
    UIColor *backgroundColor = [UIColor colorWithRed:44/255.0 green:44/255.0 blue:44/255.0 alpha:1];
    
    // set the bar background color
    [[UITabBar appearance] setBackgroundImage:[AppDelegate imageFromColor:backgroundColor forSize:CGSizeMake(320, 49) withCornerRadius:0]];
    
    // set the text color for selected state
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:backgroundColor, NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    // set the text color for unselected state
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    //[[UITabBar appearance] set
    // set the selected icon color
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setSelectedImageTintColor:backgroundColor];
    // remove the shadow
    [[UITabBar appearance] setShadowImage:nil];
    
    // Set the dark color to selected tab (the dimmed background)
    [[UITabBar appearance] setSelectionIndicatorImage:[AppDelegate imageFromColor:[UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1] forSize:CGSizeMake(64, 49) withCornerRadius:0]];
    
    _lastImage = [[AizekDB sharedInstance]getLastImage];
    [[AizekDB sharedInstance]getAllByDate];
    return YES;
}

-(void)switchToTab:(int)tabIndex {
    ((UITabBarController *)self.window.rootViewController).selectedIndex = tabIndex;
}

+ (UIImage *)imageFromColor:(UIColor *)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContext(size);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
    // Draw your image
    [image drawInRect:rect];
    
    // Get the image, here setting the UIImageView image
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return image;
}

- (void) createCopyOfFile:(NSString*) file
{
    BOOL success = NO;
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    NSArray *pathForDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir      = [pathForDirectories objectAtIndex:0];
    NSString *writableFilePath  = [documentsDir stringByAppendingPathComponent:file];
    success = [fileManager fileExistsAtPath:writableFilePath];
    if(success) { return; }
    NSError *error = nil;
    
    NSString *existingFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:file];
    success = [fileManager createFileAtPath:writableFilePath contents:[NSData dataWithContentsOfFile:existingFilePath] attributes:nil];
    if(!success) {
        NSLog(@"Error moving the file: %@", error.description);
    } else {
        NSLog(@"File was successfully moved");
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSInteger period = [[notification.userInfo objectForKey:@"period"] longValue];
    if(period > 0) {
        NSTimeInterval t = period;
        notification.fireDate =[[NSDate date] dateByAddingTimeInterval:t];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    SettingsViewController *sv = (SettingsViewController*) [self.window.rootViewController.childViewControllers objectAtIndex:3];
    [sv showReminderView:notification.alertBody];
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    SettingsViewController *sv = (SettingsViewController*) [self.window.rootViewController.childViewControllers objectAtIndex:3];
    [sv checkThePlistFile];
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
