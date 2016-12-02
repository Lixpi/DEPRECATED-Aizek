//
//  CaptureViewController.m
//  Aizek
//
//  Created by Elchibek Konurbaev on 11/6/14.
//  Copyright (c) 2014 Linum. All rights reserved.
//

#import "CaptureViewController.h"
#import "StatisticsViewController.h"

#define toolbarSize 25

static NSArray *flArray;

@implementation filterCell
-(void)setFilterAtPosition:(GPUImageFilter *)filter {
    [filter removeAllTargets];
    for(GPUImageFilter*fr in flArray){
            [fr removeTarget:mFilterView];
    }
    
    [filter addTarget:mFilterView];
    mFilterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    mFilterName.text = filter.description;
    

    [filter forceProcessingAtSizeRespectingAspectRatio:mFilterView.frame.size];
}

-(void)setSelected:(BOOL)selected {
    if(selected) {
        mFilterView.layer.borderColor = [UIColor whiteColor].CGColor;
        mFilterView.layer.borderWidth = 1;
    }
    else {
        mFilterView.layer.borderWidth = 0;
    }
}

@end

@implementation CaptureViewController

@synthesize viewContainer, pictureView, takePhoto_btn, switchCamera_btn, alreadyTaken, ratingsTopTenTable, ratingsTable, mFiltersArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.recognizePhoto_btn.hidden = YES;
    
    stillCamera = [[GPUImageStillCamera alloc] init];
    stillCamera.horizontallyMirrorFrontFacingCamera = YES;
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _previewView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    filter1 = [[GPUImageMedianFilter alloc] init];
    [stillCamera addTarget:filter1];
    
    //[filter1 forceProcessingAtSize:filterView1.frame.size];
    
    selectedIndex = -1;
    
    filter2 = [[GPUImageMonochromeFilter alloc] init];
    [stillCamera addTarget:filter2];

    
    filter3 = [[GPUImageSepiaFilter alloc] init];
    [stillCamera addTarget:filter3];

    
    filter4 = [[GPUImageSketchFilter alloc] init];
    [stillCamera addTarget:filter4];

    filter5 = [[GPUImageGrayscaleFilter alloc] init];
    [stillCamera addTarget:filter5];
    
    filter6 = [[GPUImageColorInvertFilter alloc] init];
    [stillCamera addTarget:filter6];
    
    
    selectedFilter = [[GPUImageMedianFilter alloc] init];
    [stillCamera addTarget:selectedFilter];

    [selectedFilter addTarget:_previewView];

    [selectedFilter setInputRotation:kGPUImageRotate180 atIndex:0];
    mFiltersArray = [[NSMutableArray alloc]init];
    
    [mFiltersArray addObject:filter1];
    [mFiltersArray addObject:filter2];
    [mFiltersArray addObject:filter3];
    [mFiltersArray addObject:filter4];
    [mFiltersArray addObject:filter5];
    [mFiltersArray addObject:filter6];
    flArray = mFiltersArray;
    [stillCamera startCameraCapture];
    self.ratingsTable = [[AizekDB sharedInstance]getRatings];
    self.ratingsTopTenTable = [[AizekDB sharedInstance]getTopRatings];
    
    animationDimansion = [UIScreen mainScreen].applicationFrame.size.height;
    
    flashHeight = _flashButton.frame.size.height;
    
    filtersContainer.frame = CGRectMake(filtersContainer.frame.origin.x, animationDimansion+toolbarSize, filtersContainer.frame.size.width, filtersContainer.frame.size.height);
    shutterContainer.frame = CGRectMake(shutterContainer.frame.origin.x, animationDimansion-shutterContainer.frame.size.height-toolbarSize, shutterContainer.frame.size.width, shutterContainer.frame.size.height);
    mFlashView.frame = CGRectMake(mFlashView.frame.origin.x, animationDimansion+toolbarSize, mFlashView.frame.size.width, mFlashView.frame.size.height);
    
    
    mFilterOrigin = filtersContainer.frame.origin;
    mShutterOrigin = shutterContainer.frame.origin;
    
    //UISwipeGestureRecognizer *swp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(openOrCloseFilters:)];
    //swp.direction = UISwipeGestureRecognizerDirectionDown;
    //[filtersContainer addGestureRecognizer:swp];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    pan.maximumNumberOfTouches=1;
    pan.minimumNumberOfTouches=1;
    [filtersContainer addGestureRecognizer:pan];
    
    
    UISwipeGestureRecognizer *swpUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(openOrCloseFilters:)];
    swpUp.direction = UISwipeGestureRecognizerDirectionDown;
    [filterButton addGestureRecognizer:swpUp];
    
    UISwipeGestureRecognizer *flhUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showFlashView:)];
    swpUp.direction = UISwipeGestureRecognizerDirectionDown;
    [_flashButton addGestureRecognizer:flhUp];
    
    
    shutterContainerOnScreen = YES;
    shutterAnimation = [CATransition animation];
    [shutterAnimation setDelegate:self];
    [shutterAnimation setDuration:0.3];
    
    shutterAnimation.timingFunction = UIViewAnimationCurveEaseInOut;
    [shutterAnimation setType:@"cameraIris"];
    [shutterAnimation setValue:@"cameraIris" forKey:@"cameraIris"];
    CALayer *cameraShutter = [[CALayer alloc]init];
    [cameraShutter setBounds:CGRectMake(0.0, 0.0, 320.0, 425.0)];
    [_previewView.layer addSublayer:cameraShutter];

    [self.view insertSubview:_previewView atIndex:0];
    [stillCamera rotateCamera];
    
    audioSession = [AVAudioSession sharedInstance];
    
}


-(void)pan:(UIPanGestureRecognizer *)pan {
    
    CGFloat y, openedFilter = animationDimansion-filtersContainer.frame.size.height-toolbarSize;
    if(pan.state == UIGestureRecognizerStateBegan){
        offset = -[pan locationInView:filtersContainer].y;
    }else if(pan.state == UIGestureRecognizerStateChanged){
        y = [pan locationInView:self.view].y + offset;
        CGRect fr = filtersContainer.frame;
        if(y>openedFilter&&y<animationDimansion+toolbarSize){
            fr.origin.y = y;
        }
        filtersContainer.frame = fr;
    }else if(pan.state == UIGestureRecognizerStateEnded||pan.state == UIGestureRecognizerStateFailed){
        y = [pan locationInView:self.view].y +offset;
        shutterContainerOnScreen =  y-openedFilter <= filtersContainer.frame.size.height/2;
        [self openOrCloseFilters:nil];
    }

}




-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return mFiltersArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    filterCell *cell = (filterCell*)[mCollectionView dequeueReusableCellWithReuseIdentifier:@"filterCell" forIndexPath:indexPath];
    [cell setFilterAtPosition:[mFiltersArray objectAtIndex:indexPath.row]];
    return cell;
}




-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqual:@"outputVolume"]) {
        [self takePhoto:nil];
    }
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [selectedFilter removeTarget:_previewView];
    if(indexPath.row == 0) {
        selectedFilter = [[GPUImageMedianFilter alloc] init];
    }else if(indexPath.row == 1) {
        selectedFilter = [[GPUImageMonochromeFilter alloc] init];
    }else if(indexPath.row == 2) {
        selectedFilter = [[GPUImageSepiaFilter alloc] init];
    }else if(indexPath.row == 3) {
        selectedFilter = [[GPUImageSketchFilter alloc] init];
    }else if(indexPath.row == 4) {
        selectedFilter = [[GPUImageGrayscaleFilter alloc] init];
    }else if(indexPath.row == 5) {
        selectedFilter = [[GPUImageColorInvertFilter alloc] init];
    }
    selectedIndex = (int)indexPath.row;
    [stillCamera addTarget:selectedFilter];
    [selectedFilter addTarget:_previewView];
    [self filterHiglight];
    [self openOrCloseFilters:nil];

}

-(void)filterHiglight{
    [filterButton setImage:[selectedFilter isKindOfClass:[GPUImageMedianFilter class]]?[UIImage imageNamed:@"filters"]:[UIImage imageNamed:@"filters color"] forState:UIControlStateNormal];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    [stillCamera startCameraCapture];
    [takePhoto_btn setUserInteractionEnabled:YES];
    [self setFlashImage];
    self.navigationController.navigationBar.hidden = YES;
    [self filterHiglight];
    [self hideAll:nil];
    [self checkFlash];
    [audioSession setActive:YES error:nil];
    [audioSession addObserver:self
                   forKeyPath:@"outputVolume"
                      options:0
                      context:nil];
}

-(void)updateDB{
    [[AizekDB sharedInstance]updateObjectFromObject:current];
}

- (IBAction) takePhoto:(id)sender {
    [takePhoto_btn setUserInteractionEnabled:NO];
    
    [stillCamera capturePhotoAsImageProcessedUpToFilter:selectedFilter withOrientation:UIImageOrientationUp withCompletionHandler:^(UIImage *formattedPhoto, NSError *erro){
        if(formattedPhoto != nil) {
            current = [AizekImage initWithImage:formattedPhoto];
                        [_previewView.layer addAnimation:shutterAnimation forKey:@"cameraIris"];
            [CATransaction setCompletionBlock:^{
                if(stillCamera.inputCamera.position == AVCaptureDevicePositionFront) {
                     AudioServicesPlaySystemSound(1108);
                }
                [self performSegueWithIdentifier:@"openDetail" sender:nil];
            }];
        }
        [stillCamera startCameraCapture];
    }];
}

- (IBAction) switchCamera:(id)sender {
    [stillCamera rotateCamera];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    CGRect f = _previewView.frame;
    UIVisualEffectView * effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = f;
    [_previewView addSubview:effectView];
    [CATransaction setCompletionBlock:^{ [effectView.layer removeFromSuperlayer]; }];
        CATransition *animation = [CATransition animation];
        animation.duration = .5f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"oglFlip";
        if (stillCamera.inputCamera.position == AVCaptureDevicePositionFront) {
            animation.subtype = kCATransitionFromRight;
        }
        else if(stillCamera.inputCamera.position == AVCaptureDevicePositionBack){
            animation.subtype = kCATransitionFromLeft;
        }
        [_previewView.layer addAnimation:animation forKey:nil];
        [self setFlashImage];
    [self checkFlash];
    [self hideFlash];
}

- (IBAction) recognizePhoto:(id)sender {
    dispatch_queue_t queue = dispatch_get_global_queue(0,0);
    [self showHUD:@"Recognizing..."];
    dispatch_async(queue, ^{
        NSString* detectResultString = [ReKognitionSDK RKFaceDetect:current.image scale:1.0];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [HUD hide:YES];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Status" message:@"Please check the results in the console" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            NSData * data = [detectResultString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSLog(@"detectResultString = %@", results);
        });
    });
}

-(void)checkFlash {
    if([stillCamera.inputCamera hasFlash]){
        [_flashButton setHidden:NO];
    }
    else {
        [_flashButton setHidden:YES];
    }
}

- (IBAction)toggleFlashlight:(id)sender {
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         if(flashOnScreen) {

                             [self showFlashView:nil];
                         }
                                 }
                     completion:nil];
    
    AVCaptureDevice *device = stillCamera.inputCamera;
    [device lockForConfiguration:nil];
    if ([device hasFlash]) {
        
        if(sender == mFlashOnButton) {
            device.flashMode = AVCaptureFlashModeOn;
        }
        else if (sender == mFlashOffButton) {
            device.flashMode = AVCaptureFlashModeOff;
        }
        else if (sender == mFlashAutoButton) {
            device.flashMode = AVCaptureFlashModeAuto;
        }
    }
    else {
        
    }
    [self setFlashImage];
}

- (IBAction)openOrCloseFilters:(UIButton *)sender {
    shutterContainerOnScreen = !shutterContainerOnScreen;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         shutterContainer.frame = CGRectMake(shutterContainer.frame.origin.x,shutterContainerOnScreen?animationDimansion-shutterContainer.frame.size.height-toolbarSize:animationDimansion+toolbarSize, shutterContainer.frame.size.width, shutterContainer.frame.size.height);
                         
                         filtersContainer.frame = CGRectMake(filtersContainer.frame.origin.x,!shutterContainerOnScreen?animationDimansion-filtersContainer.frame.size.height-toolbarSize:animationDimansion+toolbarSize, filtersContainer.frame.size.width, filtersContainer.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
}

- (IBAction)showFlashView:(UIButton *)sender {
    if([stillCamera.inputCamera hasFlash]) {
        flashOnScreen = !flashOnScreen;
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                                        mFlashView.frame = CGRectMake(mFlashView.frame.origin.x,flashOnScreen?animationDimansion-mFlashView.frame.size.height-toolbarSize-flashHeight+20:animationDimansion+toolbarSize, mFlashView.frame.size.width, mFlashView.frame.size.height);
                                     }
                         completion:nil];
    }
    
}

- (IBAction)hideAll:(UIButton *)sender {
    [self hideFilters];
    [self hideFlash];
    
}

-(void)hideFlash {
    flashOnScreen = false;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
         mFlashView.frame = CGRectMake(mFlashView.frame.origin.x, animationDimansion+toolbarSize, mFlashView.frame.size.width, mFlashView.frame.size.height);
    } completion:nil];
   
}

-(void)hideFilters {
    shutterContainerOnScreen = true;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        shutterContainer.frame = CGRectMake(mShutterOrigin.x,animationDimansion-shutterContainer.frame.size.height-toolbarSize, shutterContainer.frame.size.width, shutterContainer.frame.size.height);
        filtersContainer.frame = CGRectMake(mShutterOrigin.x, animationDimansion+toolbarSize, filtersContainer.frame.size.width, filtersContainer.frame.size.height);
    } completion:nil];
    
}
- (void) showHUD:(NSString*) msg {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.color = [UIColor colorWithRed:0.23 green:0.50 blue:0.82 alpha:0.90];
    HUD.delegate = self;
    HUD.labelText = msg;
    [HUD show:YES];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [HUD removeFromSuperview];
    HUD = nil;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setFlashImage{
    [stillCamera.inputCamera lockForConfiguration:nil];
    NSString *image;
    if ([stillCamera.inputCamera hasFlash]) {
        if (stillCamera.inputCamera.flashMode == AVCaptureFlashModeOn) {
            image = @"flash ON";
        } else if (stillCamera.inputCamera.flashMode == AVCaptureFlashModeOff) {
            image = @"flash";
        }
        else if (stillCamera.inputCamera.flashMode == AVCaptureFlashModeAuto) {
            image = @"flash auto";
        }
    }else{
        image = @"flash disable";
    }
    [_flashButton setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
}



-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [stillCamera stopCameraCapture];
    [audioSession setActive:NO error:nil];
    @try{
        [audioSession removeObserver:self forKeyPath:@"outputVolume"];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
    
}




-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"openDetail"]) {
        ((CaptureDetailViewController*)segue.destinationViewController).img = current;
    }
}


@end