//
//  OpenImageViewController.m
//  Aizek
//
//  Created by Dmitry on 29.07.15.
//  Copyright (c) 2015 Linum. All rights reserved.
//

#import "OpenImageViewController.h"


static OpenImageViewController *ct;

@implementation openImageCell
-(void)setCell:(AizekImage *)image forSlide:(BOOL)isSlideshow {
    
    
    [mImageView setImage:image.image];
    _image = image;
    [self setImageToCenter:mImageView];
    mImageView.frame = self.frame;
    //[self insertSubview:mImageView atIndex:0];
    [mTopView insertSubview:mBackground atIndex:0];
    NSDateFormatter *date = [[NSDateFormatter alloc]init];
    [date setDateFormat:@"MMM dd, yyyy"];
    mDate.text = [NSString stringWithFormat:@"Captured Date: %@",[date stringFromDate:image.time]];
    mLookLabel.text = [NSString stringWithFormat:@"x%d",(int)image.look];
    mFeelLabel.text = [NSString stringWithFormat:@"x%d",(int)image.feel];
    mAizekLabel.text = [NSString stringWithFormat:@"x%d",(int)image.aizek];
    
    mImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
 
    if (isSlideshow) {
        [mInfoView setHidden:YES];
    }
    else {
          [mInfoView setHidden:NO];
    }
}

- (IBAction)shareViaFB:(UIButton *)sender {
    [self sendViaSL:SLServiceTypeFacebook];
}

- (IBAction)shareViaTwitter:(UIButton *)sender {
    [self sendViaSL:SLServiceTypeTwitter];
}

- (IBAction)saveToRoll:(UIButton *)sender {
    
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    [lib saveImage:_image.image toAlbum:@"Aizek" withCompletionBlock:^(NSError *error) {
        NSLog(@"%@",error.description);
    }];
    
    [[[UIAlertView alloc]initWithTitle:@""
                               message:@"Saved to Aizek album"
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles: nil] show];
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

- (IBAction)shareViaInstagram:(UIButton *)sender {
    [self shareInInstagram];
}

-(void)shareInInstagram
{
    NSData *imageData = UIImagePNGRepresentation(_image.image); //convert image into .png format.
    NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"insta.igo"]]; //add our image to the path
    [fileManager createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
    
    NSLog(@"image saved");
    
    CGRect rect = CGRectMake(0 ,0 , 0, 0);
    UIGraphicsEndImageContext();
    NSString *fileNameToSave = [NSString stringWithFormat:@"Documents/insta.igo"];
    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:fileNameToSave];
    NSLog(@"jpg path %@",jpgPath);
    NSString *newJpgPath = [NSString stringWithFormat:@"file://%@",jpgPath];
    NSLog(@"with File path %@",newJpgPath);
    NSURL *igImageHookFile = [[NSURL alloc] initFileURLWithPath:newJpgPath];
    NSLog(@"url Path %@",igImageHookFile);
    
    self.dic.UTI = @"com.instagram.exclusivegram";
    self.dic = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
    self.dic=[UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
    [self.dic presentOpenInMenuFromRect: rect    inView: self animated: YES ];
    
    
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    NSLog(@"file url %@",fileURL);
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

- (void)setImageToCenter:(UIImageView *)imageView {
    CGSize imageSize = imageView.image.size;
    [imageView sizeThatFits:imageSize];
    CGPoint imageViewCenter = imageView.center;
    imageViewCenter.x = CGRectGetMidX(self.contentView.frame);
    [imageView setCenter:imageViewCenter];
}

-(void)sendViaSL:(NSString*)type
{
    SLComposeViewController *Sheet = [SLComposeViewController
                                      composeViewControllerForServiceType:type];
    [Sheet setInitialText:@"My new selfie"];
    [Sheet addImage:_image.image];
    [[OpenImageViewController instance] presentViewController:Sheet animated:YES completion:nil];

}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@:root=TWITTER",UIApplicationOpenSettingsURLString]]];
    }
}

@end

@implementation OpenImageViewController

+(instancetype)instance{
    return ct;
}

- (void)viewDidLoad {
    ct = self;
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    if(_needScroll) {
        _index = 0;
        [self performSelector:@selector(scrollToNext) withObject:nil afterDelay:1];
    }
    else {
        [mGrid scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }

}

-(void)scrollToNext {
    if(_index < _mData.count) {
        [mGrid scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        _index++;
        [self performSelector:@selector(scrollToNext) withObject:nil afterDelay:1];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _needScroll = NO;
    _index = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _mData.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)_collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    openImageCell*cell = (openImageCell*)[_collectionView dequeueReusableCellWithReuseIdentifier:@"openImageCell" forIndexPath:indexPath];
    [cell setCell:[_mData objectAtIndex:indexPath.row] forSlide:_needScroll];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return collectionView.frame.size;
}



- (IBAction)backButtonPress:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
