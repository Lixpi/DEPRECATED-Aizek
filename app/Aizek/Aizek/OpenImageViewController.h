//
//  OpenImageViewController.h
//  Aizek
//
//  Created by Dmitry on 29.07.15.
//  Copyright (c) 2015 Linum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AizekDB.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "MBProgressHUD.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
@interface  openImageCell: UICollectionViewCell <UIDocumentInteractionControllerDelegate,MBProgressHUDDelegate,UIAlertViewDelegate>
{
    AizekImage *_image;
    MBProgressHUD* HUD;
    IBOutlet UIImageView *mImageView;
    IBOutlet UIImageView *mBlurImage;
    IBOutlet UILabel *mDate;
    IBOutlet UILabel *mLookLabel;
    IBOutlet UILabel *mFeelLabel;
    IBOutlet UILabel *mAizekLabel;
    
    IBOutlet UIView *mTopView;
    IBOutlet UIImageView *mBackground;
    IBOutlet UIView *mInfoView;
    
}
@property (nonatomic, strong) UIDocumentInteractionController* dic;

-(void)setCell:(AizekImage*)image forSlide:(BOOL)isSlideshow;
- (IBAction)shareViaFB:(UIButton *)sender;
- (IBAction)shareViaTwitter:(UIButton *)sender;
- (IBAction)saveToRoll:(UIButton *)sender;
- (IBAction)shareViaInstagram:(UIButton *)sender;





@end

@interface OpenImageViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    
    IBOutlet UIButton *mBackButton;
    IBOutlet UICollectionView *mGrid;
}
@property int index;

@property (nonatomic, strong) NSMutableArray *mData;
@property BOOL needScroll;
- (IBAction)backButtonPress:(UIButton *)sender;
+(instancetype)instance;

@end
