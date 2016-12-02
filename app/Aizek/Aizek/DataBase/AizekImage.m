//
//  AizekImage.m
//  Aizek
//
//  Created by Dmitry on 29.07.15.
//  Copyright (c) 2015 Linum. All rights reserved.
//

#import "AizekImage.h"

@implementation AizekImage

+(instancetype)initWithManageObject:(AizekImageStrored *)stored{
    AizekImage *image = [[AizekImage alloc]init];
    image.image = [UIImage imageWithData:stored.image];
    image.look = stored.look.integerValue;
    image.feel = stored.feel.integerValue;
    image.aizek = stored.aizek.integerValue;
    image.time = [NSDate dateWithTimeIntervalSince1970:stored.time.doubleValue];
    return image;
}

+(instancetype)initWithImage:(UIImage *)image{
    AizekImage *res = [[AizekImage alloc]init];
    res.image = image;
    res.look = 0;
    res.feel = 0;
    res.aizek = 0;
    res.time = [NSDate date];
    return res;
}


-(NSString *)getTime{
    return @"";
}

-(void)setDataToObject:(AizekImageStrored *)object{
    object.feel = [NSNumber numberWithDouble:self.feel];
    object.aizek = [NSNumber numberWithDouble:self.aizek];
    object.look = [NSNumber numberWithDouble:self.look];
    object.time = [NSNumber numberWithDouble:self.time.timeIntervalSince1970];//self.time.timeIntervalSince1970;
    object.image = UIImagePNGRepresentation(self.image);
}

-(NSString *)description {
    return [NSString stringWithFormat:@"look = %ld, feel = %ld, aizek = %ld, time = %@", (long)self.look, (long)self.feel, (long)self.aizek, self.time];
}


@end
