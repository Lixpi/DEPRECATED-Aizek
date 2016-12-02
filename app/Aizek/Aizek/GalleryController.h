//
//  GalleryController.h
//  Aizek
//
//  Created by Dmitry on 29.07.15.
//  Copyright (c) 2015 Linum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AizekDB.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CEMovieMaker.h"
@interface  galleryCell: UICollectionViewCell
{
    IBOutlet UIImageView *mImageView;
    IBOutlet UIImageView *mCheck;

}
-(void)setImage:(UIImage*)image andState:(BOOL)selected;
@end

@interface GalleryController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MBProgressHUDDelegate>
{
    IBOutlet UICollectionView *mGallery;
    IBOutlet UISegmentedControl *mSegment;

    NSMutableArray* mPhotos;
    NSMutableArray* mSelectedPhotos;
    int index;
    BOOL shouldSelect;
    BOOL needAll;
    BOOL isSlideshow;
    BOOL savingError;
    IBOutlet UIButton *mSelectButton;
    
    IBOutlet UIView *mTopMenu;
    
    IBOutlet UIView *mTypeMenu;
    
    IBOutlet UIButton *mHidebutton;
    
    
    IBOutlet UIButton *mExportAll;
    IBOutlet UIButton *mExportSlected;
    
    IBOutlet UIButton *mOkButton;
    IBOutlet UIButton *mDotsButton;
    
    MBProgressHUD *HUD;
}

@property (nonatomic, strong) CEMovieMaker *movieMaker;

- (IBAction)toggleSelect:(UIButton *)sender;
- (IBAction)segmentAtIndexSelected:(UISegmentedControl *)sender;
- (IBAction)toggleMore:(UIButton *)sender;

- (IBAction)exportAll:(UIButton *)sender;
- (IBAction)exportSelected:(UIButton *)sender;
- (IBAction)exportAsSlideshow:(UIButton *)sender;
- (IBAction)exportAsImage:(UIButton *)sender;
- (IBAction)hide:(UIButton *)sender;
- (IBAction)okPress:(UIButton *)sender;



@end
