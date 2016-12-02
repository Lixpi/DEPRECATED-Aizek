//
//  RKPostJobs.h
//  Rekognition_iOS_SDK
//
//  Created by cys on 7/20/13.
//  Copyright (c) 2013 Orbeus Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface ReKognitionSDK : NSObject{
    
}

// ReKognition Post Jobs Function (to customize your own recognition functions)
+ (NSString*) postReKognitionJobs:(NSDictionary *) jobsDictionary;

// ReKognition Face Detect Function (the image you want to recognize and the scaling factor for the image)
+ (NSString *) RKFaceDetect: (UIImage*) image
                      scale: (CGFloat) scale;

// ReKognition Face Add Function (for more details of name_space and user_id please go to reKognition.com and check out the API docs)
+ (NSString *) RKFaceAdd: (UIImage*) image
                   scale: (CGFloat) scale
               nameSpace: (NSString *) name_space
                  userID: (NSString *) user_id
                     tag: (NSString *) tag;

// ReKognition Face Train Function
+ (NSString *) RKFaceTrain:(NSString *) name_space
                    userID:(NSString *) user_id;

// ReKognition Face Recognize Function
+ (NSString *) RKFaceRecognize: (UIImage *) image
                         scale: (CGFloat) scale
                     nameSpace: (NSString *) name_space
                        userID: (NSString *) user_id;

// ReKognition Face Rename Function
+ (NSString *) RKFaceRename: (NSString *) oldTag
                    withTag: (NSString *) newTag
                  nameSpace: (NSString *) name_space
                     userID: (NSString *) user_id;

// ReKognition Face Crawl Function
+ (NSString *) RKFaceCrawl: (NSString *) access_token
                 nameSpace: (NSString *) name_space
                    userID: (NSString *) user_id
               crawl_fb_id: (NSArray *) crawl_fb_id_array
                     fb_id: (NSString *) fb_id;

// ReKognition Face Visualize Function
+ (NSString *) RKFaceVisualize: (NSArray *) tag_array
                     nameSpace: (NSString *) name_space
                        userID: (NSString *) user_id;

// ReKognition Face Search Function
+ (NSString *) RKFaceSearch: (UIImage *) image
                      scale: (CGFloat) scale
                  nameSpace: (NSString *) name_space
                     userID: (NSString *) user_id;

// ReKognition Face Delete Function
+ (NSString *) RKFaceDelete: (NSString *) tag
                 imageIndex: (NSArray *) img_index_array
                  nameSpace: (NSString *) name_space
                     userID: (NSString *) user_id;

// ReKognition Scene Understadning Function
+ (NSString *) RKSceneUnderstanding: (UIImage *) image
                              scale: (CGFloat) scale;


@end
