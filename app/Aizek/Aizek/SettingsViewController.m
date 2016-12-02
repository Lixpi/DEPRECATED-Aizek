//
//  SettingsViewController.m
//  Aizek
//
//  Created by Elchibek Konurbaev on 11/10/14.
//  Copyright (c) 2014 Linum. All rights reserved.
//
#import "AppDelegate.h"
#import "SettingsViewController.h"

@implementation SettingsViewController

@synthesize saveSettings_btn, pickerView, datePicker;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    
    isManual = NO;
    custom_fire_interval = 0;
    currentIndex = 0;
    savedIndex = 0;
    calendarUnit = NSDayCalendarUnit;
    
    [datePicker addTarget:self
               action:@selector(datePickerValueChanged:)
     forControlEvents:UIControlEventValueChanged];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
    static NSDateFormatter *formatter;
    if(!formatter){
        formatter = [[NSDateFormatter alloc]init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    }
    NSDate *now = [NSDate date];
    
    [formatter setDateFormat:@"h:mm"];
    timeLabel.text = [formatter stringFromDate:now];
    
    [formatter setDateFormat:@"EEEE, dd MMM"];
    dateLabel.text = [formatter stringFromDate:now];
    
    [formatter setDateFormat:@"a"];
    amLabel.text = [formatter stringFromDate:now];

}



- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 7;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch(row) {
        case 0: return @"Each day";
        case 1: return @"Twice a week";
        case 2: return @"Each week";
        case 3: return @"Twice a month";
        case 4: return @"Each month";
        case 5: return @"Once in 3 months";
        case 6: return @"Manually";
        default: return nil;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    isManual = NO;
    custom_fire_interval = 0;
    self.datePicker.userInteractionEnabled = YES;
    [datePicker setAlpha:1];
    
    switch(row) {
        case 0:
            NSLog(@"Each day");
            calendarUnit = NSDayCalendarUnit;
            break;
        case 1:
            NSLog(@"Twice a week");
            calendarUnit = NSWeekdayCalendarUnit;
            custom_fire_interval = 60*60*24*3;
            break;
        case 2:
            NSLog(@"Each week");
            calendarUnit = NSWeekCalendarUnit;
            break;
        case 3:
            NSLog(@"Twice a month");
            calendarUnit = NSWeekOfMonthCalendarUnit;
            custom_fire_interval = 60*60*24*14;
            break;
        case 4:
            NSLog(@"Each month");
            calendarUnit = NSMonthCalendarUnit;
            custom_fire_interval = 60*60*24*30;
            break;
        case 5:
            NSLog(@"Once in 3 months");
            calendarUnit = NSQuarterCalendarUnit;
            custom_fire_interval = 60*60*24*90;
            break;
        case 6:
            NSLog(@"Manually");
            isManual = YES;
            self.datePicker.userInteractionEnabled = NO;
            [datePicker setAlpha:0.6];
            break;
        default:
            break;
    }
    
    if(savedDate) {
        [self checkSaveWithDate:[datePicker date] andTime:(int)row];
    }
    currentIndex = (int)row;
}



- (void)datePickerValueChanged:(id)sender{
    [self checkSaveWithDate:[datePicker date] andTime:savedIndex];
    
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

-(void)checkSaveWithDate:(NSDate *)date andTime:(int)timeInterval {
    if([[self.datePicker date] isEqualToDate:savedDate] && savedIndex == timeInterval) {
        [saveSettings_btn setTitle:@"Saved" forState:UIControlStateNormal];
        [saveSettings_btn setBackgroundImage:[UIImage imageNamed:@"Rectangle 14"] forState:UIControlStateNormal];
    }
    else {
        [saveSettings_btn setTitle:@"Save" forState:UIControlStateNormal];
        [saveSettings_btn setBackgroundImage:[UIImage imageNamed:@"red button"] forState:UIControlStateNormal];
    }
}

- (IBAction) saveSettings:(id)sender
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    
    if(isManual) {
        custom_fire_interval = 0;
        localNotification.repeatInterval = NSYearCalendarUnit;
        localNotification.fireDate = [self.datePicker date];
        [self scheduleNotification:localNotification];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        return;
    } else if(custom_fire_interval > 0) {
        localNotification.repeatInterval = 0;
        NSDate *selectedDate = [self.datePicker date];
        NSDate *remindDate = [selectedDate dateByAddingTimeInterval:(NSTimeInterval)custom_fire_interval];
        localNotification.fireDate = remindDate;
        //localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:8];
        localNotification.userInfo = @{@"period": [NSNumber numberWithInteger:custom_fire_interval]};
    } else {
        localNotification.repeatInterval = calendarUnit;
        localNotification.fireDate = [self.datePicker date];
        //localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
    }
    savedDate = [self.datePicker date];
    savedIndex = currentIndex;
    [saveSettings_btn setTitle:@"Saved" forState:UIControlStateNormal];
    [saveSettings_btn setBackgroundImage:[UIImage imageNamed:@"Rectangle 14"] forState:UIControlStateNormal];
    [self scheduleNotification:localNotification];
}

- (void) createLocalNotificationOn:(NSTimeInterval) repeatInterval
{
    custom_fire_interval = repeatInterval;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.repeatInterval = 0;
    NSDate *remindDate = [[NSDate date] dateByAddingTimeInterval:(NSTimeInterval)custom_fire_interval];
    localNotification.fireDate = remindDate;
    localNotification.userInfo = @{@"period": [NSNumber numberWithInteger:custom_fire_interval]};
    
    [self scheduleNotification:localNotification];
}

- (void) scheduleNotification:(UILocalNotification*) localNotification
{
    localNotification.alertBody = @"Capture new photo now?";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.alertAction = @"Aizek";
    localNotification.applicationIconBadgeNumber = 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    NSArray *pathForDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [[pathForDirectories objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"];
    //NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:documentsDir];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"YES" forKey:@"isNotificationMissed"];
    [dict setValue:localNotification.fireDate forKey:@"fireDate"];
    [dict setValue:[NSNumber numberWithInteger:custom_fire_interval] forKey:@"repeatInterval"];
    //NSLog(@"plist=%@", plist);
    NSString *error;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:dict format:NSPropertyListBinaryFormat_v1_0 errorDescription:&error];
    if(plistData) {
        [plistData writeToFile:documentsDir atomically:YES];
    }
}

- (void) showReminderView:(NSString*) msg
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Aizek"];
    [alert setMessage:msg];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Dismiss"];
    [alert addButtonWithTitle:@"Yes"];
    [alert show];
    
    NSArray *pathForDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [[pathForDirectories objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"];
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:documentsDir];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"NO" forKey:@"isNotificationMissed"];
    [dict setValue:[plist objectForKey:@"fireDate"] forKey:@"fireDate"];
    [dict setValue:[plist objectForKey:@"repeatInterval"] forKey:@"repeatInterval"];
    
    NSString *error;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:dict format:NSPropertyListBinaryFormat_v1_0 errorDescription:&error];
    if(plistData) {
        [plistData writeToFile:documentsDir atomically:YES];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != 0 ) {
        ((UITabBarController *)[[[AppDelegate delegate] window]rootViewController]).selectedIndex = 0;
        //[self presentViewController:tabBarController animated:YES completion:nil];
    }
    else {
        alertView.hidden = YES;
    }
}

- (void) checkThePlistFile
{
    NSArray *pathForDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [[pathForDirectories objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"];
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:documentsDir];
    
    /*float ratingValue = [[plist objectForKey:@"appearance"] floatValue];
    CaptureViewController *cp = (CaptureViewController*) [self.tabBarController.viewControllers objectAtIndex:0];
    if(ratingValue > 0) {
        cp.rateAppearanceView.rating = ratingValue;
    } else {
        cp.rateAppearanceView = 0;
    }*/
    BOOL isNotificationMissed = [plist objectForKey:@"isNotificationMissed"];
    NSInteger repeatInterval = [[plist objectForKey:@"repeatInterval"] floatValue];
    if(isNotificationMissed && repeatInterval > 0) {
        [self createLocalNotificationOn:(NSTimeInterval)repeatInterval];
    }
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
