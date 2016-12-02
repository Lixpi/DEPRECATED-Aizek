//
//  CaptureDetailViewController.h
//  Aizek
//
//  Created by Elchibek Konurbaev on 7/26/15.
//  Copyright (c) 2015 Linum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReKognitionSDK.h"
#import "MBProgressHUD.h"
#import "AizekDB.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
@interface CaptureDetailViewController : UIViewController<MBProgressHUDDelegate, UIAlertViewDelegate>
{
    MBProgressHUD *HUD;
    float offset;
    float screenSize;
    float hideSize;
    IBOutlet UIView *sliderView;
    BOOL isSliderOpen;
    IBOutlet UIButton *hideButton;
    IBOutlet UIButton *saveButton;
}

@property (strong, nonatomic) IBOutlet UIImageView *pictureView;
@property (nonatomic, retain) AizekImage *img;
@property (nonatomic, retain) IBOutlet UISlider *look_sl;
@property (nonatomic, retain) IBOutlet UISlider *feel_sl;
@property (nonatomic, retain) IBOutlet UILabel *look_lb;
@property (nonatomic, retain) IBOutlet UILabel *feel_lb;
@property (strong, nonatomic) IBOutlet UIImageView *blurDarkView;
@property (strong, nonatomic) IBOutlet UIImageView *blurLightView;
@property (strong, nonatomic) IBOutlet UIButton *ok_btn;

- (IBAction)dismissView:(id)sender;
- (void) recognizePhoto;
- (IBAction)saveToRoll:(UIButton *)sender;
- (IBAction)hideView:(UIButton *)sender;

@end
