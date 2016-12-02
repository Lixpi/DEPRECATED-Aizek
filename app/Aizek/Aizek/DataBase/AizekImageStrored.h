//
//  AizekImageStrored.h
//  Aizek
//
//  Created by Dmitry on 29.07.15.
//  Copyright (c) 2015 Linum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AizekImageStrored : NSManagedObject

@property (readwrite)NSData * image;
@property (readwrite)NSNumber* time;
@property (readwrite)NSNumber* feel;
@property (readwrite)NSNumber* look;
@property (readwrite)NSNumber* aizek;

@end
