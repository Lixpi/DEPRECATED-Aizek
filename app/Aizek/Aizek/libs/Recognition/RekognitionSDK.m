//
//  RKPostJobs.m
//  Rekognition_iOS_SDK
//
//  Created by cys on 7/20/13.
//  Copyright (c) 2013 Orbeus Inc. All rights reserved.
//

#import "ReKognitionSDK.h"
#import "NSDictionary+HTTPBody.h"
#import "Base64.h"
#import "UIImageResize+Rotate.h"



@implementation ReKognitionSDK

static NSString *API_Key = @"CKUTslU24hKFpRUv";
static NSString *API_Secret = @"Jw10esAjK3DsMTz3";


+ (NSString*) postReKognitionJobs:(NSDictionary *) jobsDictionary{
    
    // NSDictionary to HttpBody
    NSData *data = [jobsDictionary dataUsingEncoding:NSASCIIStringEncoding];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];

    NSString *url = @"http://rekognition.com/func/api/";
    [request setURL:[NSURL URLWithString:url]];

    //NSLog(@"%@",url);
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];

    if([responseCode statusCode] != 200){
    //NSLog(@"Error getting, HTTP status code %d", [responseCode statusCode]);
    //return nil;
    }

    return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];

}

// ReKognition Face Detect Function
+ (NSString *) RKFaceDetect: (UIImage*) image
                      scale: (CGFloat) scale
{
    if (scale < 1){
        image  = [UIImage imageWithImage:image scaledToSize: CGSizeMake(image.size.width * scale, image.size.height * scale)];
    }
    
    //fix the orintation of the image, commment out the following line if not needed
    image = [image fixOrientation];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    NSString *encodedString = [Base64 encode:imageData];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    // Specify ReKognition parameters, please use your own API_Key and API_Secret
    NSDictionary * jobsDictionary = [[NSDictionary alloc] initWithObjects:@[API_Key,
                                     API_Secret,
                                     @"face_part_aggressive_age_glass_gender_emotion",
                                     encodedString
                                     ]
                                     forKeys:@[@"api_key",
                                     @"api_secret",
                                     @"jobs",
                                     @"base64"
                                     ]];
    return [self postReKognitionJobs:jobsDictionary];
}

// ReKognition Face Add Function
+ (NSString *) RKFaceAdd: (UIImage*) image
                   scale: (CGFloat) scale
               nameSpace: (NSString *) name_space
                  userID: (NSString *) user_id
                     tag:(NSString *) tag;
{
    
    if (scale < 1){
        image  = [UIImage imageWithImage:image scaledToSize: CGSizeMake(image.size.width * scale, image.size.height * scale)];
    }
    
    //fix the orintation of the image, commment out the following line if not needed
    image = [image fixOrientation];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    NSString *encodedString = [Base64 encode:imageData];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    NSString *tagString = [@"face_add_" stringByAppendingFormat:@"[%@]", tag];
    
    NSDictionary * jobsDictionary = [[NSDictionary alloc] initWithObjects:@[API_Key,
                                     API_Secret,
                                     tagString,
                                     name_space,
                                     user_id,
                                     encodedString
                                     ] forKeys:@[@"api_key",
                                     @"api_secret",
                                     @"job_list",
                                     @"name_space",
                                     @"user_id",
                                     @"base64"
                                     ]];
    
    return [self postReKognitionJobs:jobsDictionary];
    
}

//ReKognition Face Train Function
+ (NSString *) RKFaceTrain:(NSString *) name_space
                    userID:(NSString *) user_id{
    
    NSDictionary * jobsDictionary = [[NSDictionary alloc] initWithObjects:@[API_Key,
                                     API_Secret,
                                     @"face_train",
                                     name_space,
                                     user_id
                                     ] forKeys:@[@"api_key",
                                     @"api_secret",
                                     @"jobs",
                                     @"name_space",
                                     @"user_id",
                                     ]];
        
    return [self postReKognitionJobs:jobsDictionary];
}

//ReKognition Face Recognize Function
+ (NSString *) RKFaceRecognize: (UIImage *) image
                         scale: (CGFloat) scale
                     nameSpace: (NSString *) name_space
                        userID: (NSString *) user_id{
    
    if (scale < 1){
        image  = [UIImage imageWithImage:image scaledToSize: CGSizeMake(image.size.width * scale, image.size.height * scale)];
    }
    
    //fix the orintation of the image, commment out the following line if not needed
    image = [image fixOrientation];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    NSString *encodedString = [Base64 encode:imageData];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSDictionary * jobsDictionary = [[NSDictionary alloc] initWithObjects:@[API_Key,
                                     API_Secret,
                                     @"face_recognize",
                                     name_space,
                                     user_id,
                                     encodedString
                                     ] forKeys:@[@"api_key",
                                     @"api_secret",
                                     @"jobs",
                                     @"name_space",
                                     @"user_id",
                                     @"base64"
                                     ]];
    
    return [self postReKognitionJobs:jobsDictionary];
    
}

//ReKognition Face Rename Function
+ (NSString *) RKFaceRename: (NSString *) oldTag
                    withTag: (NSString *) newTag
                  nameSpace: (NSString *) name_space
                     userID: (NSString *) user_id{
    
    NSDictionary * jobsDictionary = [[NSDictionary alloc] initWithObjects:@[API_Key,
                                     API_Secret,
                                     @"face_rename",
                                     name_space,
                                     user_id,
                                     oldTag,
                                     newTag 
                                     ] forKeys:@[@"api_key",
                                     @"api_secret",
                                     @"jobs",
                                     @"name_space",
                                     @"user_id",
                                     @"tag",
                                     @"new_tag"
                                     ]];
    
    return [self postReKognitionJobs:jobsDictionary];
    
}

// ReKognition Face Crawl Function
+ (NSString *) RKFaceCrawl: (NSString *) access_token
                 nameSpace: (NSString *) name_space
                    userID: (NSString *) user_id
               crawl_fb_id: (NSArray  *) crawl_fb_id_array
                     fb_id: (NSString *) fb_id;
{
    NSString *temp_string = [crawl_fb_id_array componentsJoinedByString:@";"];
    NSString *crawl_string = [@"face_crawl_" stringByAppendingFormat:@"[%@]", temp_string];
    NSDictionary * jobsDictionary = [[NSDictionary alloc] initWithObjects:@[API_Key,
                                     API_Secret,
                                     crawl_string,
                                     name_space,
                                     user_id,
                                     access_token,
                                     fb_id
                                     ] forKeys:@[@"api_key",
                                     @"api_secret",
                                     @"jobs",
                                     @"name_space",
                                     @"user_id",
                                     @"access_token",
                                     @"fb_id"
                                     ]];
    
    return [self postReKognitionJobs:jobsDictionary];
    
}

// ReKognition Face Visualize Function
+ (NSString *) RKFaceVisualize: (NSArray *) tag_array
                     nameSpace: (NSString *) name_space
                        userID: (NSString *) user_id
{
    NSString * temp_string = [tag_array componentsJoinedByString:@";"];
    NSString * job_string = [@"face_visualize_" stringByAppendingFormat:@"[%@]", temp_string];
    NSDictionary * jobsDictionary = [[NSDictionary alloc] initWithObjects:@[API_Key,
                                                                           API_Secret,
                                                                           job_string,
                                                                           name_space,
                                                                           user_id
                                     ]forKeys:@[@"api_key",@"api_secret",@"jobs", @"name_space", @"user_id"]];
    return [self postReKognitionJobs:jobsDictionary];
}

// ReKognition Face Search Function
+ (NSString *) RKFaceSearch: (UIImage *) image
                      scale: (CGFloat) scale
                  nameSpace: (NSString *) name_space
                     userID: (NSString *) user_id
{
    if (scale < 1){
        image  = [UIImage imageWithImage:image scaledToSize: CGSizeMake(image.size.width * scale, image.size.height * scale)];
    }
    
    //fix the orintation of the image, commment out the following line if not needed
    image = [image fixOrientation];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    NSString * encodedString = [Base64 encode:imageData];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSDictionary * jobsDictionary = [[NSDictionary alloc] initWithObjects:@[API_Key,
                                                                           API_Secret,
                                                                           encodedString,
                                                                           @"face_search",
                                                                           name_space,
                                                                           user_id]
                                                                 forKeys:@[@"api_key",
                                                                           @"api_secret",
                                                                           @"base64",
                                                                           @"jobs",
                                                                           @"name_space",
                                                                           @"user_id"]];
    return [self postReKognitionJobs:jobsDictionary];
                                                                                              
}

// ReKognition Face Delete Function
+ (NSString *) RKFaceDelete: (NSString *) tag
                 imageIndex: (NSArray *) img_index_array
                  nameSpace: (NSString *) name_space
                     userID: (NSString *) user_id
{
    NSString * index_string = [img_index_array componentsJoinedByString:@";"];
    NSString * job_string = [@"face_delete" stringByAppendingFormat:@"[%@]{%@}",tag, index_string];
    NSDictionary * jobDictionary = [[NSDictionary alloc] initWithObjects:@[API_Key,
                                                                          API_Secret,
                                                                          job_string,
                                                                          name_space,
                                    user_id] forKeys:@[@"api_key", @"api_secret", @"jobs", @"name_space", @"user_id"]];
    return [self postReKognitionJobs:jobDictionary];

}

// ReKognition Scene Understanding Function
+ (NSString *) RKSceneUnderstanding: (UIImage *) image
                              scale: (CGFloat) scale
{    
    if (scale < 1){
        image  = [UIImage imageWithImage:image scaledToSize: CGSizeMake(image.size.width * scale, image.size.height * scale)];
    }
    
    //fix the orintation of the image, commment out the following line if not needed
    image = [image fixOrientation];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    NSString * encodedString = [Base64 encode:imageData];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    NSDictionary * jobDictionary = [[NSDictionary alloc] initWithObjects:@[API_Key, API_Secret, @"scene", encodedString]
                                                                 forKeys:@[@"api_key", @"api_secret", @"jobs", @"base64"]];
    
    return [self postReKognitionJobs:jobDictionary];
    
}


@end
