//
//  SettingsViewController.h
//  Aizek
//
//  Created by Elchibek Konurbaev on 11/10/14.
//  Copyright (c) 2014 Linum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaptureViewController.h"

@interface SettingsViewController : UIViewController
<UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>
{
    BOOL isManual;
    NSUInteger calendarUnit;
    NSInteger custom_fire_interval;
    IBOutlet UILabel *timeLabel;
    IBOutlet UILabel *dateLabel;
    IBOutlet UILabel *amLabel;

    
    NSDate *savedDate;
    int savedIndex;
    int currentIndex;

}

@property (strong, nonatomic) IBOutlet UIButton *saveSettings_btn;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction) saveSettings:(id)sender;
- (void) createLocalNotificationOn:(NSTimeInterval) repeatInterval;
- (void) scheduleNotification:(UILocalNotification*) localNotification;
- (void) showReminderView:(NSString*) msg;
- (void) checkThePlistFile;

@end
