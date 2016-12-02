#import <UIKit/UIKit.h>


@protocol CKCalendarDelegate;

@interface CKCalendarView : UIView
{
  int count_of_click;
  NSDate*lastdate;
  BOOL needspecial;
  NSDate*start;
  NSDate*finish;
}

enum {
    startSunday = 1,
    startMonday = 2,
};
typedef int startDay;

@property (nonatomic) startDay calendarStartDay;
@property (nonatomic, strong) NSLocale *locale;
@property (nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, strong) NSDate *maximumDate;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSArray *datesArray;
@property (nonatomic, strong) UIButton *showStatisticButton;
@property (nonatomic) BOOL shouldFillCalendar;
@property (nonatomic) BOOL adaptHeightToNumberOfWeeksInMonth;
@property (nonatomic, weak) id<CKCalendarDelegate> delegate;

- (id)initWithStartDay:(startDay)firstDay;
- (id)initWithStartDay:(startDay)firstDay frame:(CGRect)frame;

// Theming
- (void)setTitleFont:(UIFont *)font;
- (UIFont *)titleFont;

- (void)setTitleColor:(UIColor *)color;
- (UIColor *)titleColor;

- (void)setButtonColor:(UIColor *)color;

- (void)setInnerBorderColor:(UIColor *)color;

- (void)setDayOfWeekFont:(UIFont *)font;
- (UIFont *)dayOfWeekFont;

- (void)setDayOfWeekTextColor:(UIColor *)color;
- (UIColor *)dayOfWeekTextColor;

- (void)setDayOfWeekBackGroundColor:(UIColor *)color;
- (UIColor *)dayOfWeekBackGroundColor;

- (void)setDayOfWeekBottomColor:(UIColor *)bottomColor topColor:(UIColor *)topColor;

- (void)setDateFont:(UIFont *)font;
- (UIFont *)dateFont;

- (void)setDateBackgroundColor:(UIColor *)color;
- (UIColor *)dateBackgroundColor;

- (void)setDateBorderColor:(UIColor *)color;
- (UIColor *)dateBorderColor;

-(void)deselectall;
- (void)moveCalendarToNextMonth;
- (void)moveCalendarToPreviousMonth;
- (void)updateWithDates:(NSDate*)dateStart andOff:(NSDate*)dateFinish;
- (void)moveCalendarToDate:(NSDate*)d;
@property (nonatomic, strong) UIColor *dateTextColor;
@property (nonatomic, strong) UIColor *selectedDateTextColor;
@property (nonatomic, strong) UIColor *selectedDateBackgroundColor;
@property (nonatomic, strong) UIColor *currentDateTextColor;
@property (nonatomic, strong) UIColor *currentDateBackgroundColor;
@property (nonatomic, strong) UIColor *nonCurrentMonthDateTextColor;
@property (nonatomic, strong) UIColor *disabledDateTextColor;
@property (nonatomic, strong) UIColor *disabledDateBackgroundColor;
@property(nonatomic, assign) CGFloat cellWidth;
@end

@protocol CKCalendarDelegate <NSObject>

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date click:(int)click;

@optional
- (void)calendar:(CKCalendarView *)calendar didChangeMonth:(NSDate *)date;

@end
