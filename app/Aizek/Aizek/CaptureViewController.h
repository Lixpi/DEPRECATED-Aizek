//
//  CaptureViewController.h
//  Aizek
//
//  Created by Elchibek Konurbaev on 11/6/14.
//  Copyright (c) 2014 Linum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utilities.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ReKognitionSDK.h"
#import "CaptureDetailViewController.h"
#import "AizekDB.h"
#import "AizekImage.h"
#import "MBProgressHUD.h"
#import "GPUImage.h"

static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;
static void * CapturingStillImageContext = &CapturingStillImageContext;

@interface  filterCell: UICollectionViewCell
{

    IBOutlet GPUImageView *mFilterView;
    IBOutlet UILabel *mFilterName;
    
}
-(void)setFilterAtPosition:(GPUImageFilter *)position;
@end


@interface CaptureViewController : UIViewController<UIImagePickerControllerDelegate, MBProgressHUDDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    GPUImageStillCamera *stillCamera;
    CGPoint mShutterOrigin;
    CGPoint mFilterOrigin;
    IBOutlet UIView *filtersContainer;
    float animationDimansion;
    float flashHeight;
    CGFloat offset;
    IBOutlet UIButton *filterButton;
    IBOutlet UIView *shutterContainer;
    
    IBOutlet UIView *mFlashView;
    IBOutlet UIButton *mFlashOffButton;
    IBOutlet UIButton *mFlashOnButton;
    IBOutlet UIButton *mFlashAutoButton;
    IBOutlet UICollectionView *mCollectionView;
    
    GPUImageOutput<GPUImageInput> *selectedFilter;
    GPUImageOutput<GPUImageInput> *filter1;
    GPUImageOutput<GPUImageInput> *filter2;
    GPUImageOutput<GPUImageInput> *filter3;
    GPUImageOutput<GPUImageInput> *filter4;
    GPUImageOutput<GPUImageInput> *filter5;
    GPUImageOutput<GPUImageInput> *filter6;
    
    AVAudioSession* audioSession;
    
    BOOL shutterContainerOnScreen;
    BOOL flashOnScreen;
    int selectedIndex;
    MBProgressHUD *HUD;
    AizekImage *current;
    CATransition *shutterAnimation;
}
@property (strong, nonatomic) NSMutableArray *mFiltersArray;

@property (strong, nonatomic) NSArray *ratingsTable;
@property (strong, nonatomic) NSMutableArray *ratingsTopTenTable;
@property (strong, nonatomic) IBOutlet UIView *viewContainer;
@property (strong, nonatomic) IBOutlet UIButton *takePhoto_btn;
@property (strong, nonatomic) IBOutlet UIButton *recognizePhoto_btn;
@property (strong, nonatomic) IBOutlet UIButton *switchCamera_btn;
@property (strong, nonatomic) IBOutlet UIButton *retakePhoto_btn;
@property (strong, nonatomic) IBOutlet UIButton *alreadyTaken;
@property (strong, nonatomic) IBOutlet GPUImageView *pictureView;
@property (nonatomic, weak) IBOutlet GPUImageView *previewView;
@property (strong, nonatomic) IBOutlet UIButton *flashButton;

- (IBAction) takePhoto:(id)sender;
- (IBAction) recognizePhoto:(id)sender;
- (IBAction)toggleFlashlight:(id)sender;
- (IBAction)openOrCloseFilters:(UIButton *)sender;
- (IBAction)showFlashView:(UIButton *)sender;
- (IBAction)hideAll:(UIButton *)sender;


@end

