//
//  GalleryController.m
//  Aizek
//
//  Created by Dmitry on 29.07.15.
//  Copyright (c) 2015 Linum. All rights reserved.
//

#import "GalleryController.h"
#import "Utilities.h"
#import "OpenImageViewController.h"
#import <MediaPlayer/MediaPlayer.h>



@implementation galleryCell
-(void)setImage:(UIImage *)image andState:(BOOL)selected {
    [mImageView setImage:image];
    mCheck.hidden = !selected;
    mImageView.clipsToBounds = YES;
    mImageView.layer.cornerRadius = 0.0;
    
    [self setImageToCenter:mImageView];
}

-(void)setSelected:(BOOL)selected {
    if(selected) {
        mImageView.layer.borderWidth = 2.0;
        mImageView.layer.borderColor = [UIColor redColor].CGColor;
    }
    else {
        mImageView.layer.borderWidth = 0;
    }
}

- (void)setImageToCenter:(UIImageView *)imageView {
    CGSize imageSize = imageView.image.size;
    [imageView sizeThatFits:imageSize];
    CGPoint imageViewCenter = imageView.center;
    imageViewCenter.x = CGRectGetMidX(self.contentView.frame);
    [imageView setCenter:imageViewCenter];
}
@end

@implementation GalleryController

- (void)viewDidLoad {
    [super viewDidLoad];
    shouldSelect = NO;
    [self hideAll];
    
    mSelectedPhotos = [[NSMutableArray alloc]init];
    mSegment.selectedSegmentIndex = 1;
}

-(void)hideAll {
    [mTopMenu setHidden:YES];
    shouldSelect = NO;
    [self showDotsOrNot:YES];
    
    [mTypeMenu setHidden:YES];
    [mHidebutton setHidden:YES];
}

-(void)showDotsOrNot:(BOOL)show {
    [mDotsButton setHidden:!show];
    [mSelectButton setHidden:show];
    [mOkButton setHidden:show];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    savingError = NO;
    isSlideshow = NO;
    shouldSelect = NO;
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
    [mTypeMenu setHidden:YES];
    self.navigationController.navigationBar.hidden = YES;
    [self drawShadowForView:mTopMenu];
    [self hideGridSelection];
    [mOkButton setHidden:YES];
    [mSelectButton setHidden:YES];
    [self showDotsOrNot:YES];
    //[self showHudWithTitle:@"Updating" andMessage:@"Please wait..."];
    dispatch_queue_t queue = dispatch_get_global_queue(0,0);
    //[self showHUD:@"Recognizing..."];
    [self segmentAtIndexSelected:mSegment];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    isSlideshow = NO;
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)drawShadowForView:(UIView *)view {
    view.layer.masksToBounds = NO;
    view.layer.cornerRadius = 8; // if you like rounded corners
    view.layer.shadowOffset = CGSizeMake(0, -2);
    view.layer.shadowRadius = 5;
    view.layer.shadowOpacity = 0.5;
    view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return mPhotos.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)_collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    galleryCell*cell = (galleryCell*)[_collectionView dequeueReusableCellWithReuseIdentifier:@"galleryCell" forIndexPath:indexPath];
        [cell setImage:[[mPhotos objectAtIndex:indexPath.row] image] andState:[mSelectedPhotos containsObject:[mPhotos objectAtIndex:indexPath.row]]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(shouldSelect) {
        if([mSelectedPhotos containsObject:[mPhotos objectAtIndex:indexPath.row]]) {
            [mSelectedPhotos removeObject:[mPhotos objectAtIndex:indexPath.row]];
        }
        else {
            [mSelectedPhotos addObject:[mPhotos objectAtIndex:indexPath.row]];
        }
        [mGallery reloadData];
    }
    else {
        index = (int)indexPath.row;
        [self performSegueWithIdentifier:@"openImage" sender:nil];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    OpenImageViewController* controller = [segue destinationViewController];
    if(isSlideshow) {
        controller.index = 0;
        controller.needScroll = YES;
        controller.mData = needAll?mPhotos:mSelectedPhotos;
    }
    else {
        controller.index = index;
        controller.mData = mPhotos;
    }
}

- (IBAction)toggleSelect:(UIButton *)sender {
    [self hideAll];
    [self showDotsOrNot:YES];
    [self hideGridSelection];
    shouldSelect = NO;
}


-(void)hideGridSelection {
    mSelectedPhotos = [[NSMutableArray alloc]init];
    [mGallery reloadData];
}

- (IBAction)segmentAtIndexSelected:(UISegmentedControl *)sender {
    dispatch_queue_t queue = dispatch_get_global_queue(0,0);
    dispatch_async(queue, ^{
        switch (sender.selectedSegmentIndex) {
            case 0:
                mPhotos = [NSMutableArray arrayWithArray:[[AizekDB sharedInstance]getPrettiest]];
                break;
            case 1:
                //[self showHudWithTitle:@"Updating" andMessage:@"Please wait..."];
                mPhotos = [NSMutableArray arrayWithArray:[[AizekDB sharedInstance]getRatings]];
                break;
            case 2:
                mPhotos = [NSMutableArray arrayWithArray:[[AizekDB sharedInstance]getUgliest]];
                break;
                
            default:
                break;
        }
        [self performSelectorOnMainThread:@selector(updateGrid) withObject:nil waitUntilDone:NO];
    });
    
}

-(void)updateGrid {
    if(HUD.hidden == NO) {
        [HUD hide:YES];
    }
    [mGallery reloadData];
}

- (IBAction)toggleMore:(UIButton *)sender {
    [mTopMenu setHidden:NO];
    [mHidebutton setHidden:NO];
    [mTypeMenu setHidden:YES];
}

- (IBAction)exportAll:(UIButton *)sender {
    [mTopMenu setHidden:YES];
    needAll = YES;
    [self hideGridSelection];
    [mHidebutton setHidden:NO];
    [mTypeMenu setHidden:NO];
}

- (IBAction)exportSelected:(UIButton *)sender {
    [mTopMenu setHidden:YES];
    needAll = NO;
    shouldSelect = YES;
    [mHidebutton setHidden:YES];
    [self hideGridSelection];
    [self showDotsOrNot:NO];

}


- (IBAction)exportAsSlideshow:(UIButton *)sender {
    
    NSDictionary *settings = [CEMovieMaker videoSettingsWithCodec:AVVideoCodecH264 withWidth:352 andHeight:496];
    self.movieMaker = [[CEMovieMaker alloc] initWithSettings:settings];

    NSMutableArray *imageArray = [[NSMutableArray alloc]init];
    for (AizekImage *i in needAll?mPhotos:mSelectedPhotos) {
        [imageArray addObject:i.image];
    }
    [self.movieMaker createMovieFromImages:[imageArray copy] withCompletion:^(NSURL *fileURL){
        [self viewMovieAtUrl:fileURL];
    }];
}

- (void)viewMovieAtUrl:(NSURL *)fileURL
{
    MPMoviePlayerViewController *playerController = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];
    [playerController.view setFrame:self.view.bounds];
    [self presentMoviePlayerViewControllerAnimated:playerController];
    [playerController.moviePlayer prepareToPlay];
    [playerController.moviePlayer play];
    [self.view addSubview:playerController.view];


    ALAssetsLibrary * lib = [[ALAssetsLibrary alloc]init];
    [lib writeVideoAtPathToSavedPhotosAlbum:fileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        NSLog(@"finish");
    }];
    
    [lib saveVideoAtPath:fileURL toAlbum:@"Aizek" withCompletionBlock:^(NSError *error) {
        NSLog(@"");
    }];
}

-(void)savedVideo {
    
}

- (IBAction)exportAsImage:(UIButton *)sender {
    if(!needAll && mSelectedPhotos.count == 0) {
        [mTypeMenu setHidden:YES];
        return;
    }
    [self showHudWithTitle:@"Saving" andMessage:@"Please wait..."];
    for(AizekImage* image in (needAll?mPhotos:mSelectedPhotos)) {
        UIImageWriteToSavedPhotosAlbum(image.image, self, @selector(image:didFinishSavingWithError:contextInfo:),nil);
    }
    [self hideGridSelection];
    [mTypeMenu setHidden:YES];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    // Unable to save the image
    if (error&&!savingError) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Could not save photo"
                                   delegate:nil cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        savingError = YES;
    }
}

-(void)showHudWithTitle:(NSString *)title andMessage:(NSString *)message {
    if(HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
    }
    [self.view addSubview:HUD];
    [HUD setLabelText:title];
    [HUD setDetailsLabelText:message];
    [HUD setDimBackground:YES];
    [HUD setOpacity:0.5f];
    [HUD show:YES];
    [HUD hide:YES afterDelay:2.0];
}

- (IBAction)hide:(UIButton *)sender {
    [self hideAll];
}

- (IBAction)okPress:(UIButton *)sender {
    if(mSelectedPhotos.count == 0) {
        [[[UIAlertView alloc]initWithTitle:@"Error"
                                   message:@"Select at least 1"
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil] show];
        return;
    }
    [mTopMenu setHidden:YES];
    [mHidebutton setHidden:NO];
    needAll = NO;
    shouldSelect = NO;
    [self showDotsOrNot:YES];
    [mTypeMenu setHidden:NO];
}
@end
