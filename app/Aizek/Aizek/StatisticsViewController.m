//
//  StatisticsViewController.m
//  Aizek
//
//  Created by Elchibek Konurbaev on 11/6/14.
//  Copyright (c) 2014 Linum. All rights reserved.
//

#import "StatisticsViewController.h"
#import "AppDelegate.h"
#define ARC4RANDOM_MAX 0x100000000

@implementation StatisticsViewController

@synthesize pictureView, arrayOfRatings;

- (void)viewDidLoad {
    [super viewDidLoad];
    CaptureViewController *cp = (CaptureViewController*) [[[self.tabBarController.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0];
    self.arrayOfRatings = cp.ratingsTopTenTable;
    isStatistickOpen = YES;
    mCalendarContainer.hidden  = isStatistickOpen;
    openLabelFrame = mCounterContainer.frame;
    openButtonsFrame = mButtonsContainer.frame;
    isSliderOpen = NO;
    [self updateData];
    [self prepareCalendar];
    [self configureThemeForSlider];
    pictureView.image = [[AppDelegate delegate]lastImage].image;
    UIPanGestureRecognizer *gest = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    gest.maximumNumberOfTouches = 1;
    gest.minimumNumberOfTouches = 1;
    [mSliderContainer addGestureRecognizer:gest];
    closeDimension = self.view.frame.size.width+20;
    botFrameOpen = botContainer.frame;
    botFrameClose = botFrameOpen;
    botFrameClose.origin.y = self.view.frame.size.height - 139;
    
    gest = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panBot:)];
    gest.maximumNumberOfTouches = 1;
    gest.minimumNumberOfTouches = 1;
    [self.view addGestureRecognizer:gest];
    [mEmptyView setHidden:values.count != 0];
    UIBlurEffect* blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    CGRect f = botContainer.frame;
    effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = f;
    [self.pictureView addSubview:effectView];
    
}

-(void)panBot:(UIPanGestureRecognizer *)pan {
    CGFloat y;
    if(pan.state == UIGestureRecognizerStateBegan){
        offset = -[pan locationInView:botContainer].y;
    }else if(pan.state == UIGestureRecognizerStateChanged){
        y = [pan locationInView:self.view].y + offset;;
        CGRect fr = botContainer.frame;
        if(y>=botFrameOpen.origin.y&&y<=botFrameClose.origin.y){
            fr.origin.y = y;
            effectView.frame = fr;
        }
        botContainer.frame = fr;
    }else if(pan.state == UIGestureRecognizerStateEnded||pan.state == UIGestureRecognizerStateFailed){
        y = [pan locationInView:self.view].y + offset;

        BOOL close = y - botFrameOpen.origin.y >= botFrameOpen.size.height/2;

        if(y/offset>=-2.5&&y/offset<0) {
            close = NO;
        }
        [UIView animateWithDuration:.3
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             botContainer.frame = close?botFrameClose:botFrameOpen;
                             effectView.frame = botContainer.frame;
                       
                         }
                         completion:^(BOOL finished){
                             
                         }];

        
        
    }

}

-(void)pan:(UIPanGestureRecognizer *)pan {
    
    CGFloat x;
    if(pan.state == UIGestureRecognizerStateBegan){
        offset = -[pan locationInView:mSliderContainer].x;
    }else if(pan.state == UIGestureRecognizerStateChanged){
        x = [pan locationInView:self.view].x + offset;;
        CGRect fr = mSliderContainer.frame;
        if(x>0){
            fr.origin.x = x;
        }
        mSliderContainer.frame = fr;
    }else if(pan.state == UIGestureRecognizerStateEnded||pan.state == UIGestureRecognizerStateFailed){
        x = [pan locationInView:self.view].x ;
        isSliderOpen = x>=self.view.frame.size.width/2;
        [self sliderView];
    }
    
}


-(void)prepareCalendar
{
    calendar = [[CKCalendarView alloc] initWithStartDay:startMonday frame:CGRectMake(0, 0, mCalendarContainer.frame.size.width, mCalendarContainer.frame.size.height-10)];
    calendar.delegate = self;
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc] init];
    NSDate*r = [NSDate date];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    calendar.selectedDate = r;
    calendar.shouldFillCalendar = YES;
    calendar.adaptHeightToNumberOfWeeksInMonth = NO;
    calendar.minimumDate  = [NSDate date];
    calendar.datesArray = datesArray;
    calendar.maximumDate = [NSDate dateWithTimeIntervalSinceNow:(60*60*24*310)];

    [calendar setDayOfWeekTextColor:[UIColor whiteColor]];
    [mCalendarContainer addSubview:calendar];
    UISwipeGestureRecognizer* mCalendarSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(calendarSwype:)];
    [mCalendarSwipe setDirection:UISwipeGestureRecognizerDirectionDown];
    UISwipeGestureRecognizer* mCalendarSwipe1 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(calendarSwype:)];
    [mCalendarSwipe1 setDirection:UISwipeGestureRecognizerDirectionUp];
    [calendar addGestureRecognizer:mCalendarSwipe];
    [calendar addGestureRecognizer:mCalendarSwipe1];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    axesMultiplier =  mScrollView.frame.size.height/10 -7;
    if(self.view.frame.size.width>600){
         ayesMultiplier = mScrollView.frame.size.width/16;
    }
    else{
        ayesMultiplier = mScrollView.frame.size.width/7;
    }
    if([[AizekDB sharedInstance] getAllByDate]) {
        [mEmptyView setHidden:YES];
    }
    [self updateData];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [mHUD hide:YES];
}

-(void)showHud {
    if(mHUD == nil) {
        mHUD = [[MBProgressHUD alloc] initWithView:self.view];
    }
}

-(void)clearGraph{
    mGraphView.layer.sublayers = nil;
    mGraphBgView.layer.sublayers = nil;
    points = nil;
    
}

- (void) initPictureView
{
    AizekImage *dict = [self.arrayOfRatings lastObject];
        [self.pictureView setImage:dict.image];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)drawGraph{
    
    [self clearGraph];
    NSDateFormatter *frms = [[NSDateFormatter alloc]init];
    [frms setDateFormat:@"dd MMM"];
    
    for(UIView* v in mScrollView.subviews){
        if(![v isEqual:mGraphView]&&![v isEqual:mGraphBgView]&&![v isEqual:mStatistickHeader]){
            [v removeFromSuperview];
        }
    }
    [mScrollView setContentSize:CGSizeMake(ayesMultiplier*values.count,mScrollView.frame.size.height)];
    
    if(ayesMultiplier!=0){
        pickArray = [[NSMutableArray alloc]init];
        for(int i=0;i<(mScrollView.contentSize.width>mScrollView.frame.size.width?mScrollView.contentSize.width:mScrollView.frame.size.width)/ayesMultiplier;i++){
            UIView *bg = [[UIView alloc]initWithFrame:CGRectMake((ayesMultiplier*i), 0, ayesMultiplier, mScrollView.frame.size.height)];
            bg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"statsector"]];
            bg.alpha = .3;
            [mScrollView addSubview:bg];
        }
           mStatistickHeader.frame = CGRectMake(0, mStatistickHeader.frame.origin.y,mScrollView.contentSize.width>mScrollView.frame.size.width?ayesMultiplier*values.count:mScrollView.frame.size.width, mStatistickHeader.frame.size.height);
        [mScrollView bringSubviewToFront:mStatistickHeader];
        
        for(AizekImage * i in values){
            UIView *bg = [[UIView alloc]initWithFrame:CGRectMake((ayesMultiplier*[values indexOfObject:i]), 0, ayesMultiplier, mScrollView.frame.size.height)];
            [mScrollView addSubview:bg];
            UITapGestureRecognizer *gst = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapElement:)];
            [bg addGestureRecognizer:gst];
            [pickArray addObject:bg];
            CGFloat imageSize = ayesMultiplier-10;
            UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake((ayesMultiplier*[values indexOfObject:i])+5, 5, imageSize, imageSize)];
            img.contentMode = UIViewContentModeScaleAspectFill;
            img.image = i.image;
            img.layer.masksToBounds = YES;
            img.layer.borderWidth = 1;

            img.layer.cornerRadius = imageSize /2;
            [mScrollView addSubview:img];
            UILabel *l = [[UILabel alloc]initWithFrame:CGRectMake((ayesMultiplier*[values indexOfObject:i])+5, 2+imageSize, imageSize, 10)];
            l.textAlignment = NSTextAlignmentCenter;
            l.textColor = [UIColor whiteColor];
            l.font = [UIFont systemFontOfSize:7];
            l.text = [frms stringFromDate:i.time];
            [mScrollView addSubview:l];
        }
        

        mGraphView.frame = CGRectMake(0, mGraphView.frame.origin.y, ayesMultiplier*values.count, mScrollView.frame.size.height-10);
        mGraphBgView.frame = CGRectMake(0, mGraphView.frame.origin.y, ayesMultiplier*values.count, mScrollView.frame.size.height-10);
        lineArray = [[NSMutableArray alloc]init];
        for(int y=0;y<3&&values.count>0;y++){
            NSMutableArray* ar = [[NSMutableArray alloc]init];
            
            [ar addObject:[NSValue valueWithCGPoint:CGPointMake(0,[self makePointForImage:[values objectAtIndex:0] withType:y numberInValues:0].y)]];
            for(AizekImage* i in values) {
                NSValue*v = [NSValue valueWithCGPoint:[self makePointForImage:i withType:y numberInValues:[values indexOfObject:i]]];
                [ar addObject:v];
            }
            [lineArray setObject:[self interpolateCGPointsWithHermite:ar closed:NO] atIndexedSubscript:y];
        }

        for(int y=0;y<3;y++){
            [self drawNext:0 andType:y];
        }
        

    }
    
}

-(void)drawNext:(int)iterator andType:(GraphType)type{
    
    if(iterator+1>=values.count)return;
        AizekImage *i1 = [values objectAtIndex:iterator];
        AizekImage *i2 = [values objectAtIndex:iterator+1];
        [self drawLine:[self makePointForImage:i1 withType:type numberInValues:iterator] toPoint:[self makePointForImage:i2 withType:type numberInValues:iterator+1] withGraphType:type iteratorValue:iterator];
}

-(CGPoint)makePointForImage:(AizekImage *)image withType:(GraphType)type numberInValues:(NSInteger)i{
    float x = i*ayesMultiplier+ayesMultiplier/2;
    float y =0;
    
    switch (type) {
        case feel:
            y = (10 - image.feel) * axesMultiplier;
            break;
        case look:
            y = (10 - image.look) * axesMultiplier;
            break;
        case aizek:
            y = (10 - image.aizek) * axesMultiplier;
            break;

    }
    
     //y = rand()%10 * axesMultiplier;
    return CGPointMake(x, y);
}

-(CGColorRef)getStrokeColorFortype:(GraphType)type{
    switch (type) {
        case look:
            return [UIColorFromRGB(0x91c0f4) CGColor];
            break;
        case feel:
            return [UIColorFromRGB(0xa1fcac) CGColor];
            break;
        case aizek:
            return [UIColorFromRGB(0xffa2a3) CGColor];
            break;
            
    }
}

-(CGColorRef)getFillColorFortype:(GraphType)type{
    switch (type) {
        case look:
            return [[UIColorFromRGB(0x91c0f4) colorWithAlphaComponent:0.4] CGColor];
            break;
        case feel:
            return [[UIColorFromRGB(0xa1fcac) colorWithAlphaComponent:0.4] CGColor];
            break;
        case aizek:
            return [[UIColorFromRGB(0xffa2a3) colorWithAlphaComponent:0.4] CGColor];
            break;
    }
}

-(void)drawLine:(CGPoint)fromPoint toPoint:(CGPoint)toPoint withGraphType:(GraphType)type iteratorValue:(int)iterator{
    [self drawBG:fromPoint toPoint:toPoint withGraphType:type andIterator:iterator];
    UIBezierPath *path = [[[lineArray objectAtIndex:type] objectAtIndex:iterator] copy];
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.frame = self.view.bounds;
    pathLayer.path = path.CGPath;
    
    pathLayer.strokeColor = [self getStrokeColorFortype:type];
    pathLayer.fillColor = [UIColor clearColor].CGColor ;
    pathLayer.lineWidth = 3.0f;
    pathLayer.lineJoin = kCALineJoinBevel;
    // pathLayer.fillColor = [self getFillColorFortype:type];
    [mGraphView.layer addSublayer:pathLayer];
    
    [CATransaction begin];
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1.5;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [CATransaction setCompletionBlock:^{
        //if(iterator==0)
       
        //[self drawNext:iterator+1 andType:type];
    }];
    [pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    [CATransaction commit];
}

-(void)drawBG:(CGPoint)fromPoint toPoint:(CGPoint)toPoint withGraphType:(GraphType)type andIterator:(int)iterator{
    UIBezierPath *path = [[[lineArray objectAtIndex:type] objectAtIndex:iterator] copy];
    CGPoint nt = [self makePointForImage:[values lastObject] withType:type numberInValues:values.count-1];
    [path addLineToPoint:CGPointMake(nt.x, mGraphBgView.frame.size.height)];
    [path addLineToPoint:CGPointMake(0, mGraphBgView.frame.size.height)];
    [path addLineToPoint:CGPointMake(0, fromPoint.y)];
    NSLog(@"from point x:%f",mGraphBgView.frame.size.height);
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.frame = self.view.bounds;
    
    pathLayer.path = path.CGPath;
    
    pathLayer.fillColor = [self getFillColorFortype:type];
    
    pathLayer.strokeColor = [UIColor redColor].CGColor;
    pathLayer.lineWidth = 0.0f;
    pathLayer.lineJoin = kCALineJoinBevel;
    
    [mGraphBgView.layer addSublayer:pathLayer];
    mGraphBgView.alpha = 0;
    
    [UIView animateWithDuration:1.5 animations:^{
        mGraphBgView.alpha=1;
    }];
    
}



-(NSMutableArray *)interpolateCGPointsWithHermite:(NSArray *)pointsAsNSValues closed:(BOOL)closed {
    if ([pointsAsNSValues count] < 2)
        return nil;
    
    NSMutableArray*result = [[NSMutableArray alloc]init];
    
    NSInteger nCurves = (closed ? [pointsAsNSValues count] : [pointsAsNSValues count]-1);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (NSInteger ii=0; ii < nCurves; ++ii) {
        NSValue *value  = pointsAsNSValues[ii];
        
        CGPoint curPt, prevPt, nextPt, endPt;
        [value getValue:&curPt];
        if (ii==0)
            [path moveToPoint:curPt];
        
        NSInteger nextii = (ii+1)%[pointsAsNSValues count];
        NSInteger previi = (ii-1 < 0 ? [pointsAsNSValues count]-1 : ii-1);
        
        [pointsAsNSValues[previi] getValue:&prevPt];
        [pointsAsNSValues[nextii] getValue:&nextPt];
        endPt = nextPt;
        
        CGFloat mx, my;
        if (closed || ii > 0) {
            mx = (nextPt.x - curPt.x)*0.5 + (curPt.x - prevPt.x)*0.5;
            my = (nextPt.y - curPt.y)*0.5 + (curPt.y - prevPt.y)*0.5;
        }
        else {
            mx = (nextPt.x - curPt.x)*0.5;
            my = (nextPt.y - curPt.y)*0.5;
        }
        
        CGPoint ctrlPt1;
        ctrlPt1.x = curPt.x + mx / 3.0;
        ctrlPt1.y = curPt.y + my / 3.0;
        
        [pointsAsNSValues[nextii] getValue:&curPt];
        
        nextii = (nextii+1)%[pointsAsNSValues count];
        previi = ii;
        
        [pointsAsNSValues[previi] getValue:&prevPt];
        [pointsAsNSValues[nextii] getValue:&nextPt];
        
        if (closed || ii < nCurves-1) {
            mx = (nextPt.x - curPt.x)*0.5 + (curPt.x - prevPt.x)*0.5;
            my = (nextPt.y - curPt.y)*0.5 + (curPt.y - prevPt.y)*0.5;
        }
        else {
            mx = (curPt.x - prevPt.x)*0.5;
            my = (curPt.y - prevPt.y)*0.5;
        }
        
        CGPoint ctrlPt2;
        ctrlPt2.x = curPt.x - mx / 3.0;
        ctrlPt2.y = curPt.y - my / 3.0;
        
        [path addCurveToPoint:endPt controlPoint1:ctrlPt1 controlPoint2:ctrlPt2];
        [result addObject:path];
    }
    
    return result;
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date click:(int)click
{
    if(click==1){
        minDate = [datesArray firstObject];
        maxDate = date;
    }else if(click==0){
        minDate = maxDate;
        maxDate = date;
    }
    else {
        [self updateData];
        [self calendarButtonPress:nil];
        
    }
}


- (IBAction)calendarSwype:(UIGestureRecognizer *)sender
{
    
    
}


-(void)setLabels{
    
    pictureView.image = current.image;
    if(!current) {
        pictureView.image = [UIImage imageNamed:@"4"];
    }
    mAziekValueLabel.text = [[NSString alloc]initWithFormat:@"x%d",(int)current.aizek];
    mFellValueLabel.text = [[NSString alloc]initWithFormat:@"x%d",(int)current.feel];
    mLookValueLabel.text = [[NSString alloc]initWithFormat:@"x%d",(int)current.look];
    [self setPoints];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)deleteButtonPress:(UIButton *)sender {
    [[[UIAlertView alloc]initWithTitle:@"Confirmation" message:@"You realy want to delete photo?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil]show];
}

- (IBAction)dateRangeButtonPress:(UIButton *)sender {
     [self sliderView];
}

- (IBAction)calendarButtonPress:(UIButton *)sender {
    isStatistickOpen = !isStatistickOpen;
    [UIView animateWithDuration:.4
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         mScrollView.alpha = isStatistickOpen?1:0;
                         mCalendarContainer.alpha = isStatistickOpen?0:1;
                         botContainer.frame = botFrameOpen;
                         effectView.frame = botContainer.frame;
                     }
                     completion:^(BOOL finished){
                         mScrollView.hidden = !isStatistickOpen;
                         mCalendarContainer.hidden  = isStatistickOpen;

                     }];
}

- (IBAction)closeSliderView:(UIButton *)sender {
    [self sliderView];
}

- (IBAction)pushTest:(UIButton *)sender {
    [self performSegueWithIdentifier:@"openTest" sender:nil];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex != alertView.cancelButtonIndex){
        [[AizekDB sharedInstance]deleteObject:current];
        if([[AizekDB sharedInstance]getAllByDate].count == 0) {
            [self clearGraph];
        }
        else {
        [self updateData];
        }
    }
}

-(void)updateData{

    NSArray *old = datesArray;
    if(minDate!=nil&&maxDate!=nil){
        values = [[AizekDB sharedInstance]getAllInRangeWithMinDate:minDate andMaxDate:maxDate];
    }else{
        values = [[AizekDB sharedInstance]getAllByDate];
        datesArray = [[NSMutableArray alloc]init];
        for (AizekImage *im in values) {
            [datesArray addObject:im.time];
            }
        
        minDate = [datesArray firstObject];
        maxDate = [datesArray lastObject];
    }
    [self updateSliderLabels];
    current = [values lastObject];
    if(old.count != datesArray.count){
        [self configureSliderValue];
    }
    [self setLabels];
    [self drawGraph];
    [self hideHud];
}

-(void)hideHud {
    [mHUD hide:YES];
    
}

-(void)sliderView{
    isSliderOpen = !isSliderOpen;
    [UIView animateWithDuration:.3
    delay:0
    options:UIViewAnimationOptionBeginFromCurrentState
    animations:^{
        if(isSliderOpen){
            botContainer.frame = botFrameOpen;
            effectView.frame = botContainer.frame;
            mButtonsContainer.frame = CGRectMake(-closeDimension, openButtonsFrame.origin.y, openButtonsFrame.size.width, openButtonsFrame.size.height);
            mCounterContainer.frame = CGRectMake(-closeDimension, openLabelFrame.origin.y, openLabelFrame.size.width, openLabelFrame.size.height);
            mSliderContainer.frame = CGRectMake(0, mSliderContainer.frame.origin.y, mSliderContainer.frame.size.width, mSliderContainer.frame.size.height);
        }else{
            mButtonsContainer.frame = openButtonsFrame;
            mCounterContainer.frame = openLabelFrame;
            mSliderContainer.frame = CGRectMake(closeDimension, mSliderContainer.frame.origin.y, mSliderContainer.frame.size.width, mSliderContainer.frame.size.height);
            
        }
        
    }
    completion:^(BOOL finished){
    }];

}

-(void)updateSliderLabels{
    NSDateFormatter *f = [[NSDateFormatter alloc]init];
    [f setDateFormat:@"dd.MM.yy"];
    minDateLabel.text = [f stringFromDate:minDate];
    maxDateLabel.text = [f stringFromDate:maxDate];
}

-(void)tapElement:(UIGestureRecognizer *)gst{
    for(UIView *v in pickArray){
        v.alpha =1;
        v.backgroundColor = [UIColor clearColor];
    }
    gst.view.alpha = .2;
    gst.view.backgroundColor = [UIColor whiteColor];
    current = [values objectAtIndex:[pickArray indexOfObject:gst.view]];
    pictureView.image = current.image;
    [self setLabels];
}

-(void)setPoints{
    for(UIView *v in points){
        [v removeFromSuperview];
    }
    points = [[NSMutableArray alloc]init];
    for(int i=0;i<3;i++){
        CGPoint st = [self makePointForImage:current withType:i numberInValues:[values indexOfObject:current]];
        UIImageView *v = [[UIImageView alloc]initWithFrame:CGRectMake(st.x-5, st.y-5, 10, 10)];
        v.image = [UIImage imageNamed:@"circle"];
        [mGraphView addSubview:v];
        [points addObject:v];
    }
}

-(void)configureThemeForSlider{
    slider = [[RangeSlider alloc] initWithFrame:dateRangeSlider.frame]; // the slider enforces a height of 30, although I'm not sure that this is necessary
    [mSliderContainer addSubview:slider];
    slider.minimumRangeLength = 0; // this property enforces a minimum range size. By default it is set to 0.0
    
    [slider setMinThumbImage:[UIImage imageNamed:@"circle"]]; // the two thumb controls are given custom images
    [slider setMaxThumbImage:[UIImage imageNamed:@"circle"]];
    
    UIImage *image; // there are two track images, one for the range "track", and one for the filled in region of the track between the slider thumbs
    
    [slider setTrackImage:[[UIImage imageNamed:@"white line"] resizableImageWithCapInsets:UIEdgeInsetsMake(9.0, 9.0, 9.0, 9.0)]];
    
    image = [UIImage imageNamed:@"grey line"];
    [slider setInRangeTrackImage:image];
    
    [slider addTarget:self action:@selector(report:) forControlEvents:UIControlEventValueChanged]; // The slider sends actions when the value of the minimum or maximum changes
    [slider addTarget:self action:@selector(reportEnded:) forControlEvents:UIControlEventTouchUpInside];

}

-(void)configureSliderValue{
    slider.max = ([datesArray count]-1)*100;
    slider.min = 0;
    separator = 100/[datesArray count];
}

- (void)report:(RangeSlider *)sender {
    if([datesArray count] > 0) {
        int minIndex = ((slider.min*100)/separator)-1;
        if(minIndex<0)minIndex=0;
        int maxIndex = ((slider.max*100)/separator)-1;
        if(maxIndex<0)maxIndex=0;
        minDate = [datesArray objectAtIndex:minIndex];
        maxDate = [datesArray objectAtIndex:maxIndex];
    
        [self updateSliderLabels];
    }
}

- (void)reportEnded:(RangeSlider *)sender {
    [self updateData];
    [self clearGraph];
    [self drawGraph];
}
@end
