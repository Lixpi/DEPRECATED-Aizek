//
//  AizekImage.h
//  Aizek
//
//  Created by Dmitry on 29.07.15.
//  Copyright (c) 2015 Linum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AizekImageStrored.h"


@interface AizekImage : NSObject

@property (readwrite,nonatomic)UIImage *image;
@property (readwrite,nonatomic)NSDate *time;
@property (readwrite)NSInteger aizek;
@property (readwrite)NSInteger feel;
@property (readwrite)NSInteger look;

+(instancetype)initWithManageObject:(AizekImageStrored *)stored;
-(NSString *)getTime;
+(instancetype)initWithImage:(UIImage *)image;
-(void)setDataToObject:(AizekImageStrored *)object;
@end
