//
//  StatisticsViewController.h
//  Aizek
//
//  Created by Elchibek Konurbaev on 11/6/14.
//  Copyright (c) 2014 Linum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "CaptureViewController.h"
#import "CKCalendarView.h"
#import "RangeSlider.h"
#import "MBProgressHUD.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
typedef enum {
    look,feel,aizek
}GraphType;


@interface StatisticsViewController : UIViewController <CKCalendarDelegate,UIAlertViewDelegate,MBProgressHUDDelegate>
{
    
    IBOutlet UIButton *mDateBg;
    IBOutlet UIView *botContainer;
    IBOutlet UIView *mCalendarContainer;
    IBOutlet UIScrollView *mScrollView;
    IBOutlet UIView *mGraphView;
    CGFloat axesMultiplier,ayesMultiplier;
    AizekImage *current;
    CKCalendarView *calendar;
    IBOutlet UIImageView *mStatistickHeader;
    IBOutlet UIView *mButtonsContainer;
    IBOutlet UIView *mCounterContainer;
    IBOutlet UILabel *mAziekValueLabel;
    IBOutlet UILabel *mLookValueLabel;
    IBOutlet UILabel *mFellValueLabel;
    NSArray *values;
    NSDate *minDate,*maxDate;
    BOOL isStatistickOpen,isSliderOpen;
    IBOutlet UIView *mSliderContainer;
    IBOutlet UILabel *minDateLabel;
    IBOutlet UILabel *maxDateLabel;
    IBOutlet UIView *dateRangeSlider;
    CGRect openLabelFrame,openButtonsFrame;
    NSMutableArray *datesArray;
    NSMutableArray *pickArray;
    NSMutableArray *points;
    UIVisualEffectView * effectView;
    int separator;
    MBProgressHUD *mHUD;
    RangeSlider *slider;
    CGFloat closeDimension;
    IBOutlet UIView *mEmptyView;
    IBOutlet UIButton *mHideSliderButton;
    CGFloat offset,botOffset;
    NSMutableArray *lineArray;
    CGRect botFrameOpen,botFrameClose;
    IBOutlet UIView *mGraphBgView;
    
}
@property (strong, nonatomic) IBOutlet UIImageView *pictureView;
@property (strong, nonatomic) NSArray *arrayOfRatings;


- (IBAction)deleteButtonPress:(UIButton *)sender;
- (IBAction)dateRangeButtonPress:(UIButton *)sender;
- (IBAction)calendarButtonPress:(UIButton *)sender;
- (IBAction)closeSliderView:(UIButton *)sender;

- (IBAction)pushTest:(UIButton *)sender;
@end

