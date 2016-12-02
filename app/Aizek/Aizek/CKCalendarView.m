

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "CKCalendarView.h"

#define BUTTON_MARGIN 0
#define CALENDAR_MARGIN 0
#define TOP_HEIGHT 30
#define DAYS_HEADER_HEIGHT 30
#define DEFAULT_CELL_WIDTH 46
#define CELL_BORDER_WIDTH 0

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@class CALayer;
@class CAGradientLayer;

@interface GradientView : UIView

@property(nonatomic, strong, readonly) CAGradientLayer *gradientLayer;
- (void)setColors:(NSArray *)colors;

@end

@implementation GradientView

- (id)init {
    return [self initWithFrame:CGRectZero];
}

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (CAGradientLayer *)gradientLayer {
    return (CAGradientLayer *)self.layer;
}

- (void)setColors:(NSArray *)colors {
    NSMutableArray *cgColors = [NSMutableArray array];
    for (UIColor *color in colors) {
        [cgColors addObject:(__bridge id)color.CGColor];
    }
    self.gradientLayer.colors = cgColors;
}



@end


@interface DateButton : UIButton

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSCalendar *calendar;

@end

@implementation DateButton

@synthesize date = _date;
@synthesize calendar = _calendar;

- (void)setDate:(NSDate *)date {
    _date = date;
    NSDateComponents *comps = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:date];
    [self setTitle:[NSString stringWithFormat:@"%d", (int)comps.day] forState:UIControlStateNormal];
}

@end


@interface CKCalendarView ()

@property(nonatomic, strong) UIView *highlight;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *titleYearLabel;
@property(nonatomic, strong) UIImageView *pc;
@property(nonatomic, strong) UIButton *prevButton;
@property(nonatomic, strong) UIButton *nextButton;
@property(nonatomic, strong) UIView *calendarContainer;
@property(nonatomic, strong) GradientView *daysHeader;
@property(nonatomic, strong) NSArray *dayOfWeekLabels;
@property(nonatomic, strong) NSMutableArray *dateButtons;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSDate *monthShowing;
@property (nonatomic, strong) NSCalendar *calendar;


@end

@implementation CKCalendarView

@synthesize highlight = _highlight;
@synthesize titleLabel = _titleLabel;
@synthesize prevButton = _prevButton;
@synthesize nextButton = _nextButton;
@synthesize calendarContainer = _calendarContainer;
@synthesize daysHeader = _daysHeader;
@synthesize dayOfWeekLabels = _dayOfWeekLabels;
@synthesize dateButtons = _dateButtons;

@synthesize monthShowing = _monthShowing;
@synthesize calendar = _calendar;
@synthesize dateFormatter = _dateFormatter;

@synthesize selectedDate = _selectedDate;
@synthesize delegate = _delegate;

@synthesize dateTextColor = _dateTextColor;
@synthesize selectedDateTextColor = _selectedDateTextColor;
@synthesize selectedDateBackgroundColor = _selectedDateBackgroundColor;
@synthesize currentDateTextColor = _currentDateTextColor;
@synthesize currentDateBackgroundColor = _currentDateBackgroundColor;
@synthesize nonCurrentMonthDateTextColor = _nonCurrentMonthDateTextColor;
@synthesize disabledDateTextColor = _disabledDateTextColor;
@synthesize disabledDateBackgroundColor = _disabledDateBackgroundColor;
@synthesize cellWidth = _cellWidth;

@synthesize calendarStartDay = _calendarStartDay;
@dynamic locale;
@synthesize minimumDate = _minimumDate;
@synthesize maximumDate = _maximumDate;
@synthesize shouldFillCalendar = _shouldFillCalendar;
@synthesize adaptHeightToNumberOfWeeksInMonth = _adaptHeightToNumberOfWeeksInMonth;


-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer { return NO; }

- (id)init {
    return [self initWithStartDay:startSunday];
}

- (id)initWithStartDay:(startDay)firstDay {
    return [self initWithStartDay:firstDay frame:CGRectMake(0, 0, 320, 308)];
}

- (void)internalInit:(startDay)firstDay {
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [self.calendar setLocale:[NSLocale currentLocale]];

    self.cellWidth = 25;

    self.pc = [[UIImageView alloc]init];
    self.pc.image = [UIImage imageNamed:@"sector"];
    [self addSubview:self.pc];
    
    // Show statistic/OK button on calendar
    self.showStatisticButton = [[UIButton alloc]init];
    [self addSubview:self.showStatisticButton];
    [self.showStatisticButton addTarget:self action:@selector(okButtonPress) forControlEvents:UIControlEventTouchUpInside];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    self.dateFormatter.dateFormat = @"LLLL";

    self.calendarStartDay = firstDay;
    self.shouldFillCalendar = NO;
    self.adaptHeightToNumberOfWeeksInMonth = YES;

    self.layer.cornerRadius = 1.0f;

    UIView *highlight = [[UIView alloc] initWithFrame:CGRectZero];
    highlight.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    highlight.layer.cornerRadius = 6.0f;
    [self addSubview:highlight];
    self.highlight = highlight;

    // SET UP THE HEADER
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.textColor = [UIColor darkGrayColor];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self addSubview:titleLabel];
    self.titleYearLabel = titleLabel;
    
    CGRect fr = self.titleLabel.frame;
    fr.origin.y-=1;
    self.titleLabel.frame = fr;
    
    UIButton *prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [prevButton setImage:[UIImage imageNamed:@"search_btn_month_prev"] forState:UIControlStateNormal];
    prevButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [prevButton addTarget:self action:@selector(moveCalendarToPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:prevButton];

    self.prevButton = prevButton;

    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setImage:[UIImage imageNamed:@"search_btn_month_next"] forState:UIControlStateNormal];
    nextButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [nextButton addTarget:self action:@selector(moveCalendarToNextMonth) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextButton];
    self.nextButton = nextButton;

    // THE CALENDAR ITSELF
    UIView *calendarContainer = [[UIView alloc] initWithFrame:CGRectZero];

    calendarContainer.layer.borderColor = [UIColor clearColor].CGColor;
    calendarContainer.backgroundColor = [UIColor clearColor];
    calendarContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    calendarContainer.layer.cornerRadius = 1.0f;
    calendarContainer.clipsToBounds = YES;
    [self addSubview:calendarContainer];
    self.calendarContainer = calendarContainer;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    pan.maximumNumberOfTouches=1;
    pan.minimumNumberOfTouches=1;
    [self.calendarContainer addGestureRecognizer:pan];
    

    GradientView *daysHeader = [[GradientView alloc] initWithFrame:CGRectZero];
    daysHeader.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self.calendarContainer addSubview:daysHeader];
    self.daysHeader = daysHeader;

    NSMutableArray *labels = [NSMutableArray array];
    for (int i = 0; i < 7; ++i) {
        UILabel *dayOfWeekLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        dayOfWeekLabel.textAlignment = NSTextAlignmentCenter;
        dayOfWeekLabel.textColor = [UIColor whiteColor];
        dayOfWeekLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"search_bg_date"]];
        [labels addObject:dayOfWeekLabel];
        [self.calendarContainer addSubview:dayOfWeekLabel];
    }
    self.dayOfWeekLabels = labels;
    [self updateDayOfWeekLabels];

    // at most we'll need 42 buttons, so let's just bite the bullet and make them now...
    NSMutableArray *dateButtons = [NSMutableArray array];
    for (NSInteger i = 1; i <= 42; i++) {
        DateButton *dateButton = [DateButton buttonWithType:UIButtonTypeCustom];
        dateButton.calendar = self.calendar;
        [dateButton addTarget:self action:@selector(dateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [dateButtons addObject:dateButton];
    }
    self.dateButtons = dateButtons;

    // initialize the thing
    self.monthShowing = [NSDate date];
    [self setDefaultStyle];
    
    [self layoutSubviews]; // TODO: this is a hack to get the first month to show properly
}


-(void)pan:(UIPanGestureRecognizer *)pan {
    
    CGPoint point = [pan locationInView:self.calendarContainer];
    DateButton *db = [self findButtonWithPoint:point];
    if(!db)return;
    
    
    if(pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged || pan.state == UIGestureRecognizerStateEnded||pan.state == UIGestureRecognizerStateFailed){
        if(!start){
            start = db.date;
            count_of_click = 0;
        }else if([[start laterDate:db.date]isEqualToDate:start]){
            if(finish ==nil)finish=start;
            if([[finish laterDate:start]isEqualToDate:start]){
                finish = start;
            }
            start = db.date;
            count_of_click = 1;
        }else if([[start laterDate:db.date]isEqualToDate:db.date]){
            finish = db.date;
            count_of_click = 1;
        }
    }
    [self.delegate calendar:self didSelectDate:db.date click:count_of_click];
    [self layoutSubviews];
}


-(DateButton*)findButtonWithPoint:(CGPoint)point{
       for(UIView*v in self.calendarContainer.subviews){
        if([v isKindOfClass:[DateButton class]]){
            if(CGRectContainsPoint(v.frame, point)){
                return (DateButton *)v;
            }
        }
    }
    return nil;
}





- (id)initWithStartDay:(startDay)firstDay frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        count_of_click=0;
      needspecial =NO;
        [self internalInit:firstDay];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithStartDay:startSunday frame:frame];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self internalInit:startSunday];
    }

    return self;
}



- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat containerWidth = self.bounds.size.width - (CALENDAR_MARGIN * 2);
    self.cellWidth = (containerWidth / 7.0) - CELL_BORDER_WIDTH;

    NSInteger numberOfWeeksToShow = 5;
    if (self.adaptHeightToNumberOfWeeksInMonth) {
        numberOfWeeksToShow = [self numberOfWeeksInMonthContainingDate:self.monthShowing];
    }


    self.showStatisticButton.frame = CGRectMake(self.frame.size.width - 40, 10, 30, 20);
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"date chosen"]];
    [self.showStatisticButton setTitle:@"OK" forState:UIControlStateNormal];
    
    self.pc.frame = CGRectMake(0, 0, self.frame.size.width, TOP_HEIGHT*1.5);
    
    self.titleLabel.textColor = [UIColor whiteColor];
    
    
    self.titleLabel.text = [self.dateFormatter stringFromDate:_monthShowing];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, TOP_HEIGHT);
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    self.titleYearLabel.textColor = UIColorFromRGB(0x7A7775);
    
    static NSDateFormatter *dateYaerFormatter;
    if(!dateYaerFormatter){
        dateYaerFormatter = [[NSDateFormatter alloc]init];
        [dateYaerFormatter setDateFormat:@"yyyy"];
    }
    
    self.titleYearLabel.text = [dateYaerFormatter stringFromDate:_monthShowing];
    self.titleYearLabel.font = [UIFont systemFontOfSize:12];
    self.titleYearLabel.frame = CGRectMake(0, 15, self.frame.size.width, TOP_HEIGHT);
    self.titleYearLabel.backgroundColor = [UIColor clearColor];

    self.prevButton.frame = CGRectMake(((self.frame.size.width)/3) - 44, BUTTON_MARGIN, 44, 59);
    self.nextButton.frame = CGRectMake(((self.frame.size.width)/3) * 2, BUTTON_MARGIN, 44, 59);
    self.calendarContainer.frame = CGRectMake(0, TOP_HEIGHT*1.5, self.frame.size.width, self.frame.size.height - (DAYS_HEADER_HEIGHT));
    self.daysHeader.frame = CGRectMake(0, 0, self.frame.size.width, DAYS_HEADER_HEIGHT);
    self.backgroundColor = [UIColor clearColor];
    int nn=0;
    self.daysHeader.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"sector"]];
    float sizeWidth = (self.frame.size.width/7 - BUTTON_MARGIN);
    self.backgroundColor = [UIColor clearColor];
    for (UILabel *dayLabel in self.dayOfWeekLabels)
    {
        dayLabel.frame = CGRectMake(nn * (sizeWidth)+ (BUTTON_MARGIN*nn +1),0, sizeWidth, 30);
        dayLabel.textColor = [UIColor whiteColor];
        dayLabel.backgroundColor = [UIColor clearColor];
        nn++;
    }

    for (DateButton *dateButton in self.dateButtons) {
        [dateButton removeFromSuperview];
    }

    NSDate *date = [self firstDayOfMonthContainingDate:self.monthShowing];
    if (self.shouldFillCalendar) {
        while ([self placeInWeekForDate:date] != 0) {
            date = [self previousDay:date];
        }
    }
    
    self.calendarContainer.backgroundColor = [UIColor clearColor];
    
    NSDate *endDate = [self firstDayOfNextMonthContainingDate:self.monthShowing];
    if (self.shouldFillCalendar) {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setWeekOfYear:numberOfWeeksToShow];
        endDate = [self.calendar dateByAddingComponents:comps toDate:date options:0];
    }

    NSUInteger dateButtonPosition = 0;
    while ([date laterDate:endDate] != date)
    {
      
        DateButton *dateButton = [self.dateButtons objectAtIndex:dateButtonPosition];
        dateButton.date = date;
        BOOL isSelected;

            if([dateButton.date  isEqualToDate:start]||[dateButton.date  isEqualToDate:finish]||[self.selectedDate isEqualToDate:dateButton.date])
            {
              [dateButton setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
              isSelected = YES;
            }
            else if([dateButton.date isEqualToDate:[dateButton.date laterDate:start]]&&[finish isEqualToDate:[finish laterDate:dateButton.date]])
            {
                  [dateButton setTitleColor:[UIColor lightGrayColor]  forState:UIControlStateNormal];
                  isSelected = YES;
            }
            else if (self.shouldFillCalendar && [self compareByMonth:date toDate:self.monthShowing] != NSOrderedSame) {
                [dateButton setTitleColor:self.nonCurrentMonthDateTextColor forState:UIControlStateNormal];
                   isSelected = NO;
            }
            else {
                    [dateButton setTitleColor:self.dateTextColor forState:UIControlStateNormal];
                   isSelected = NO;
            }
        
        

        dateButton.backgroundColor = [UIColor clearColor];
        dateButton.frame = [self calculateDayCellFrame:date];
        
        if ([self isDatePresentInArray:dateButton.date]) {
            [dateButton setBackgroundImage:[UIImage imageNamed:isSelected?@"Rectangle with Photo":@"datesector with photo"] forState:UIControlStateNormal];
        }else{
            [dateButton setBackgroundImage:[UIImage imageNamed:isSelected?@"Rectangle 25":@"datesector"] forState:UIControlStateNormal];
        }
        
        [self.calendarContainer addSubview:dateButton];

        date = [self nextDay:date];
        dateButtonPosition++;
    }
}


-(NSString *)localizedString:(NSString *)key{
   return  NSLocalizedString(key, @"");
}

- (void)updateDayOfWeekLabels {
  
    NSArray *weekdays =[[[NSDateFormatter alloc] init] shortWeekdaySymbols];
  
    
  
    // adjust array depending on which weekday should be first
    NSUInteger firstWeekdayIndex = [self.calendar firstWeekday] - 1;
    if (firstWeekdayIndex > 0) {
        weekdays = [[weekdays subarrayWithRange:NSMakeRange(firstWeekdayIndex, 7 - firstWeekdayIndex)]
                    arrayByAddingObjectsFromArray:[weekdays subarrayWithRange:NSMakeRange(0, firstWeekdayIndex)]];
    }

    NSUInteger i = 0;
    for (NSString *day in weekdays) {
        [[self.dayOfWeekLabels objectAtIndex:i] setText:[day uppercaseString]];
        [[self.dayOfWeekLabels objectAtIndex:i] setColor:[UIColor blackColor]];
        i++;
    }
}

- (void)setCalendarStartDay:(startDay)calendarStartDay {
    _calendarStartDay = calendarStartDay;
    [self.calendar setFirstWeekday:self.calendarStartDay];
    [self updateDayOfWeekLabels];
    [self setNeedsLayout];
}

- (void)setLocale:(NSLocale *)locale {
    [self.dateFormatter setLocale:locale];
    [self updateDayOfWeekLabels];
    [self setNeedsLayout];
}

- (NSLocale *)locale {
    return self.dateFormatter.locale;
}

- (void)setMonthShowing:(NSDate *)aMonthShowing {
    _monthShowing = [self firstDayOfMonthContainingDate:aMonthShowing];

    [self setNeedsLayout];
}

- (void)setSelectedDate:(NSDate *)selectedDate {
    _selectedDate = selectedDate;
    [self setNeedsLayout];
    self.monthShowing = selectedDate;
}

- (void)setShouldFillCalendar:(BOOL)shouldFillCalendar {
    _shouldFillCalendar = shouldFillCalendar;
    [self setNeedsLayout];
}

- (void)setAdaptHeightToNumberOfWeeksInMonth:(BOOL)adaptHeightToNumberOfWeeksInMonth {
    _adaptHeightToNumberOfWeeksInMonth = adaptHeightToNumberOfWeeksInMonth;
    [self setNeedsLayout];
}

- (void)setDefaultStyle {
    self.backgroundColor = UIColorFromRGB(0x393B40);

    [self setTitleColor:[UIColor whiteColor]];
    [self setTitleFont:[UIFont boldSystemFontOfSize:17.0]];

    [self setDayOfWeekFont:[UIFont boldSystemFontOfSize:12.0]];
    [self setDayOfWeekTextColor:UIColorFromRGB(0xFFFFFF)];
    [self setDayOfWeekBottomColor:[UIColor clearColor] topColor:[UIColor clearColor]];

    [self setDateFont:[UIFont boldSystemFontOfSize:16.0f]];
    [self setDateTextColor : [UIColor whiteColor]];
    [self setDateBackgroundColor:UIColorFromRGB(0xF2F2F2)];
    [self setDateBorderColor:UIColorFromRGB(0xDAE1E6)];


    [self setSelectedDateTextColor:UIColorFromRGB(0xF2F2F2)];
    [self setSelectedDateBackgroundColor:UIColorFromRGB(0x88B6DB)];

    [self setCurrentDateTextColor:UIColorFromRGB(0xF2F2F2)];
    [self setCurrentDateBackgroundColor:UIColorFromRGB(0x343B40)];

    self.nonCurrentMonthDateTextColor = UIColorFromRGB(0x7A7775);

    self.disabledDateTextColor = UIColorFromRGB(0xbcbcbc);
    
    self.disabledDateBackgroundColor = self.dateBackgroundColor;
}

- (CGRect)calculateDayCellFrame:(NSDate *)date {
    NSInteger numberOfDaysSinceBeginningOfThisMonth = [self numberOfDaysFromDate:self.monthShowing toDate:date];
    NSInteger row = (numberOfDaysSinceBeginningOfThisMonth + [self placeInWeekForDate:self.monthShowing]) / 7;
	
    NSInteger placeInWeek = [self placeInWeekForDate:date];

    float sizeWidth = self.frame.size.width/7 -BUTTON_MARGIN;
    float sizeHeight = (self.calendarContainer.frame.size.height -TOP_HEIGHT*2)/4 - BUTTON_MARGIN;
    
    return CGRectMake(placeInWeek * (sizeWidth)+ (BUTTON_MARGIN*placeInWeek +1), row * (sizeHeight)+30+ (BUTTON_MARGIN*row +1), sizeWidth, sizeHeight);
}

- (void)moveCalendarToNextMonth
{
    if([self.monthShowing isEqualToDate:[self.monthShowing laterDate:self.maximumDate]])
        return;
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    [comps setMonth:1];
    self.monthShowing = [self.calendar dateByAddingComponents:comps toDate:self.monthShowing options:0];
     if([self.monthShowing isEqualToDate:[self.maximumDate laterDate:self.monthShowing]])return;
    if ( [self.delegate respondsToSelector:@selector(calendar:didChangeMonth:)] ) {
        [self.delegate calendar:self didChangeMonth:self.monthShowing];
    }
}


-(void)moveCalendarToDate:(NSDate*)d
{
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    NSDateFormatter*dt = [[NSDateFormatter alloc]init];
    [dt setDateFormat:@"MM"];
    int c = d==[d laterDate:self.monthShowing]?1:-1;
    [comps setMonth:c];
        while (true)
        {
            NSInteger m1 = [[dt stringFromDate:d] integerValue];
            NSInteger m2 = [[dt stringFromDate:self.monthShowing] integerValue];
            if(m1==m2)return;
            self.monthShowing = [self.calendar dateByAddingComponents:comps toDate:self.monthShowing options:0];
        }

}



- (void)moveCalendarToPreviousMonth
{
    if([self.minimumDate isEqualToDate:[self.monthShowing laterDate:self.minimumDate]])
        return;
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    [comps setMonth:-1];
    self.monthShowing = [self.calendar dateByAddingComponents:comps toDate:self.monthShowing options:0];
    if([self.minimumDate isEqualToDate:[self.minimumDate laterDate:self.monthShowing]])return;
    if ( [self.delegate respondsToSelector:@selector(calendar:didChangeMonth:)] ) {
        [self.delegate calendar:self didChangeMonth:self.monthShowing];
    }
}



-(void)updateWithDates:(NSDate *)dateStart andOff:(NSDate *)dateFinish
{
     needspecial =NO;
    if(dateFinish==nil)
    {
        [self  deselectall];
        self.selectedDate=dateStart;
        self.selectedDateBackgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:@"Rectangle 25"]];
        count_of_click=1;
    }
    else if([dateStart isEqualToDate:dateFinish])
    {
        self.selectedDate = dateStart;
        self.selectedDateBackgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:@"Rectangle 25"]];
        count_of_click=3;
    }
    else
    {
        
        start=dateStart;
        finish=dateFinish;
        needspecial=YES;

        count_of_click=3;
        
    }
    lastdate = dateFinish==nil?dateStart:dateFinish;
    
}


- (void)dateButtonPressed:(id)sender
{
    NSDate *date = ((DateButton *)sender).date;
   if(count_of_click==0 || [[start laterDate:date]isEqualToDate:start])
  {
    start = date;
    finish = nil;
    count_of_click=1;
  }
  else
  {
      if(!start){
          start = date;
      }else if([[start laterDate:date]isEqualToDate:date]){
          finish = date;
      }else if([[start laterDate:date]isEqualToDate:start]){
          if([[finish laterDate:start]isEqualToDate:start]){
              finish = start;
          }
          start = date;
      }
    count_of_click=0;
  }
    lastdate = date;
    [self layoutSubviews];
    [self.delegate calendar:self didSelectDate:date click:count_of_click];
    
}




-(void)deselectall
{
  NSDate *date = [self firstDayOfMonthContainingDate:self.monthShowing];
  NSDate*today = [NSDate date];
  
  NSDate *endDate = [self firstDayOfNextMonthContainingDate:self.monthShowing];

  NSUInteger dateButtonPosition = 0;
  while ([date laterDate:endDate] != date)
  {
    
    DateButton*dateButton = [_dateButtons objectAtIndex:dateButtonPosition];
    if ([self dateIsToday:dateButton.date])
    {
      [dateButton setTitleColor:self.currentDateTextColor forState:UIControlStateNormal];
      dateButton.backgroundColor = self.currentDateBackgroundColor;
    }
    else if (today ==[dateButton.date laterDate:today]) {
      [dateButton setTitleColor:self.disabledDateTextColor forState:UIControlStateNormal];
      dateButton.backgroundColor = self.disabledDateBackgroundColor;
    } else if ([self compareByMonth:dateButton.date  toDate:self.monthShowing] != NSOrderedSame) {
     // dateButton.backgroundColor  =[UIColor colorWithPatternImage:[UIImage imageNamed:@"search_bg_date"]];
    } else {
      [dateButton setTitleColor:self.dateTextColor forState:UIControlStateNormal];
      //dateButton.backgroundColor  = [UIColor colorWithPatternImage:[UIImage imageNamed:@"search_bg_date"]];
    }
    dateButtonPosition++;
    if(dateButtonPosition>=_dateButtons.count)
      break;
  }

  
 

}


#pragma mark - Theming getters/setters

- (void)setTitleFont:(UIFont *)font {
    self.titleLabel.font = font;
}
- (UIFont *)titleFont {
    return self.titleLabel.font;
}

- (void)setTitleColor:(UIColor *)color {
    self.titleLabel.textColor = color;
}
- (UIColor *)titleColor {
    return self.titleLabel.textColor;
}

- (void)setButtonColor:(UIColor *)color {
    [self.prevButton setImage:[CKCalendarView imageNamed:@"search_btn_month_prev" withColor:color] forState:UIControlStateNormal];
    [self.nextButton setImage:[CKCalendarView imageNamed:@"search_btn_month_next" withColor:color] forState:UIControlStateNormal];
}

- (void)setInnerBorderColor:(UIColor *)color {
    self.calendarContainer.layer.borderColor = color.CGColor;
}

- (void)setDayOfWeekFont:(UIFont *)font {
    for (UILabel *label in self.dayOfWeekLabels) {
        label.font = font;
    }
}
- (UIFont *)dayOfWeekFont {
    return (self.dayOfWeekLabels.count > 0) ? ((UILabel *)[self.dayOfWeekLabels lastObject]).font : nil;
}

- (void)setDayOfWeekTextColor:(UIColor *)color {
    for (UILabel *label in self.dayOfWeekLabels) {
        label.textColor = color;
    }
}
- (UIColor *)dayOfWeekTextColor {
    return (self.dayOfWeekLabels.count > 0) ? ((UILabel *)[self.dayOfWeekLabels lastObject]).textColor : nil;
}
- (void)setDayOfWeekBackGroundColor:(UIColor *)color {
    for (UILabel *label in self.dayOfWeekLabels) {
        label.backgroundColor = color;
    }
}
- (UIColor *)dayOfWeekBackGroundColor {
    return (self.dayOfWeekLabels.count > 0) ? ((UILabel *)[self.dayOfWeekLabels lastObject]).backgroundColor : nil;
}
- (void)setDayOfWeekBottomColor:(UIColor *)bottomColor topColor:(UIColor *)topColor {
    [self.daysHeader setColors:[NSArray arrayWithObjects:topColor, bottomColor, nil]];
}

- (void)setDateFont:(UIFont *)font {
    for (DateButton *dateButton in self.dateButtons) {
        dateButton.titleLabel.font = font;
    }
}
- (UIFont *)dateFont {
    return (self.dateButtons.count > 0) ? ((DateButton *)[self.dateButtons lastObject]).titleLabel.font : nil;
}

- (void)setDateTextColor:(UIColor *)color {
    _dateTextColor = color;
    [self setNeedsLayout];
}

- (void)setDisabledDateTextColor:(UIColor *)color {
    _disabledDateTextColor = color;
    [self setNeedsLayout];
}

- (void)setDateBackgroundColor:(UIColor *)color {
    for (DateButton *dateButton in self.dateButtons) {
        dateButton.backgroundColor = color;
    }
}
- (UIColor *)dateBackgroundColor {
    return (self.dateButtons.count > 0) ? ((DateButton *)[self.dateButtons lastObject]).backgroundColor : nil;
}

- (void)setDateBorderColor:(UIColor *)color {
    self.calendarContainer.backgroundColor = color;
}
- (UIColor *)dateBorderColor {
    return self.calendarContainer.backgroundColor;
}

#pragma mark - Calendar helpers

- (NSDate *)firstDayOfMonthContainingDate:(NSDate *)date {
    NSDateComponents *comps = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    comps.day = 1;
    return [self.calendar dateFromComponents:comps];
}

- (NSDate *)firstDayOfNextMonthContainingDate:(NSDate *)date {
    NSDateComponents *comps = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    comps.day = 1;
    comps.month = comps.month + 1;
    return [self.calendar dateFromComponents:comps];
}

- (NSComparisonResult)compareByMonth:(NSDate *)date toDate:(NSDate *)otherDate
{
    if(date == nil || otherDate == nil)
        return NSOrderedSame;
    NSDateComponents *day = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:date];
    NSDateComponents *day2 = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:otherDate];
    if (day.year < day2.year) {
        return NSOrderedAscending;
    } else if (day.year > day2.year) {
        return NSOrderedDescending;
    } else if (day.month < day2.month) {
        return NSOrderedAscending;
    } else if (day.month > day2.month) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

- (NSInteger)placeInWeekForDate:(NSDate *)date {
    NSDateComponents *compsFirstDayInMonth = [self.calendar components:NSWeekdayCalendarUnit fromDate:date];
    return (compsFirstDayInMonth.weekday - 1 - self.calendar.firstWeekday + 8) % 7;
}

- (BOOL)dateIsToday:(NSDate *)date {
    return [self date:[NSDate date] isSameDayAsDate:date];
}

- (BOOL)date:(NSDate *)date1 isSameDayAsDate:(NSDate *)date2 {
    // Both dates must be defined, or they're not the same
    if (date1 == nil || date2 == nil) {
        return NO;
    }

    NSDateComponents *day = [self.calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date1];
    NSDateComponents *day2 = [self.calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date2];
    return ([day2 day] == [day day] &&
            [day2 month] == [day month] &&
            [day2 year] == [day year] &&
            [day2 era] == [day era]);
}

- (NSInteger)weekNumberInMonthForDate:(NSDate *)date {
    // Return zero-based week in month
    NSInteger placeInWeek = [self placeInWeekForDate:self.monthShowing];
    NSDateComponents *comps = [self.calendar components:(NSDayCalendarUnit) fromDate:date];
    return (comps.day + placeInWeek - 1) / 7;
}

- (NSInteger)numberOfWeeksInMonthContainingDate:(NSDate *)date {
    return [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:date].length;
}

- (NSDate *)nextDay:(NSDate *)date {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    return [self.calendar dateByAddingComponents:comps toDate:date options:0];
}

- (NSDate *)previousDay:(NSDate *)date {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:-1];
    return [self.calendar dateByAddingComponents:comps toDate:date options:0];
}

- (NSInteger)numberOfDaysFromDate:(NSDate *)startDate toDate:(NSDate *)endDate {
    NSInteger startDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:startDate];
    NSInteger endDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:endDate];
    return endDay - startDay;
}

+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color {
    UIImage *img = [UIImage imageNamed:name];

    UIGraphicsBeginImageContextWithOptions(img.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];

    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);

    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);

    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return coloredImg;
}

-(BOOL)isDatePresentInArray:(NSDate *)date{
    
    for(NSDate *d in self.datesArray){
        if([self date:date isSameDayAsDate:d]){
            return YES;
        }
    }
    
    return NO;
}

-(void)okButtonPress{
    [self.delegate calendar:self didSelectDate:nil click:3];
}



@end