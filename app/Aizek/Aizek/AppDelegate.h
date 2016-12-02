//
//  AppDelegate.h
//  Aizek
//
//  Created by Elchibek Konurbaev on 11/6/14.
//  Copyright (c) 2014 Linum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property(strong, nonatomic) UIWindow *window;
@property(strong, nonatomic) AizekImage *lastImage;

- (void) createCopyOfFile:(NSString*) file;
+(instancetype)delegate;
-(void)switchToTab:(int)tabIndex ;
@end

