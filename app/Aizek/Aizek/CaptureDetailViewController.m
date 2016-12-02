//
//  CaptureDetailViewController.m
//  Aizek
//
//  Created by Elchibek Konurbaev on 7/26/15.
//  Copyright (c) 2015 Linum. All rights reserved.
//

#import "CaptureDetailViewController.h"
#import "AppDelegate.h"

#define tabBarHeight 44

@interface CaptureDetailViewController ()

@end

@implementation CaptureDetailViewController

@synthesize img, pictureView, look_sl, feel_sl, blurDarkView, blurLightView, ok_btn;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    
    self.pictureView.image = img.image;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    pan.maximumNumberOfTouches=1;
    pan.minimumNumberOfTouches=1;
    [sliderView addGestureRecognizer:pan];
    screenSize = [UIScreen mainScreen].bounds.size.height;
    isSliderOpen = YES;
    [self recognizePhoto];
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    hideSize = hideButton.frame.size.height;
}
-(void)pan:(UIPanGestureRecognizer *)pan {
    
    CGFloat y;
    if(pan.state == UIGestureRecognizerStateBegan){
        offset = -[pan locationInView:sliderView].y;
    }else if(pan.state == UIGestureRecognizerStateChanged){
        y = [pan locationInView:self.view].y + offset;;
        CGRect fr = sliderView.frame;
        if(y>screenSize-sliderView.frame.size.height-tabBarHeight){
            fr.origin.y = y;
        }
        sliderView.frame = fr;
    }else if(pan.state == UIGestureRecognizerStateEnded||pan.state == UIGestureRecognizerStateFailed){
        y = [pan locationInView:self.view].y ;
        isSliderOpen = y>=self.view.frame.size.height/4*3;
        [self sliderView];
    }
    
}

-(void)sliderView{
    isSliderOpen = !isSliderOpen;
    hideSize = isSliderOpen?screenSize-sliderView.frame.size.height-tabBarHeight:screenSize;
    CGRect frame = hideButton.frame;
    frame.size.height = hideSize;
    hideButton.frame = frame;
    [UIView animateWithDuration:.3
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         if(isSliderOpen){
                             sliderView.frame = CGRectMake(0, screenSize-sliderView.frame.size.height-tabBarHeight, sliderView.frame.size.width, sliderView.frame.size.height);
                         }else{
                             sliderView.frame = CGRectMake(0, screenSize-tabBarHeight*2, sliderView.frame.size.width, sliderView.frame.size.height);
                             
                         }
                         
                     }
                     completion:^(BOOL finished){
                     }];
    
}


- (void) recognizePhoto {
    dispatch_queue_t queue = dispatch_get_global_queue(0,0);
    //[self showHUD:@"Recognizing..."];
    dispatch_async(queue, ^{
        NSString* detectResultString = [ReKognitionSDK RKFaceDetect:self.pictureView.image scale:1.0];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [HUD hide:YES];
            NSData * data = [detectResultString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//            if([[results objectForKey:@"face_detection"] count] == 0) {
//                [[[UIAlertView alloc]
//                  initWithTitle:@"ERROR"
//                  message:@"No selfie was detected"
//                  delegate:self
//                  cancelButtonTitle:@"OK"
//                  otherButtonTitles:nil] show];
//            }
            img.aizek = arc4random_uniform(10);
            NSLog(@"detectResultString = %@", results);
        });
    });
}

- (IBAction)saveToRoll:(UIButton *)sender {
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    [lib saveImage:img.image toAlbum:@"Aizek" withCompletionBlock:^(NSError *error) {
        NSLog(@"%@",error.description);
    }];
    [[[UIAlertView alloc]initWithTitle:@""
                               message:@"Saved to Aizek album"
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles: nil] show];
}

- (IBAction)hideView:(UIButton *)sender {
    [self sliderView];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    // Unable to save the image
    if (error) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Could not save photo"
                                   delegate:nil cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (IBAction) dismissView:(id)sender {
    img.look = (int)look_sl.value/10;
    img.feel = (int)feel_sl.value/10;
    img.aizek = rand()%10;
    [[AizekDB sharedInstance]insertNewObject:img];
    [self.navigationController popViewControllerAnimated:NO];
    [[AppDelegate delegate] switchToTab:1];
}

- (IBAction) lookValueChanged:(UISlider*)sender {
    int discreteValue = roundl([sender value]);
    NSLog(@"lookValueChanged=%i", discreteValue);
    [sender setValue:(float)discreteValue];
    self.look_lb.text = [NSString stringWithFormat:@"%i/10", discreteValue/10];
    self.img.look = discreteValue;
}

- (IBAction) feelValueChanged:(UISlider*)sender {
    int discreteValue = roundl([sender value]);
    NSLog(@"feelValueChanged=%i", discreteValue);
    [sender setValue:(float)discreteValue];
    self.feel_lb.text = [NSString stringWithFormat:@"%i/10", discreteValue/10];
    self.img.feel = discreteValue;
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
