//
//  AizekDB.h
//  Aizek
//
//  Created by Dmitry on 28.07.15.
//  Copyright (c) 2015 Linum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataBaseConnecter.h"
#import <UIKit/UIKit.h>

#import "AizekImage.h"
static NSString *modelName = @"AizekImageStrored";
static NSString *sorter = @"time";


@interface AizekDB : NSObject<NSFetchedResultsControllerDelegate>
{
    NSMutableArray *prettiestArray;
    NSMutableArray *ugliestArray;
}
@property (nonatomic,strong)  NSMutableArray *resultarray;
+(instancetype) sharedInstance;

-(NSArray *)getRatings;
-(NSMutableArray *)getTopRatings;
-(NSNumber *)getMax;
-(NSMutableArray *)getResultsForPredicate:(NSString *)predicate;
-(void)insertNewObject:(AizekImage *)i;
-(void)updateObjectFromObject:(AizekImage*)i;
-(NSMutableArray *)getAllByDate;
-(NSMutableArray *)getAllInRangeWithMinDate:(NSDate *)minDate andMaxDate:(NSDate *)maxDate;
-(void)deleteObject:(AizekImage *)i;
-(AizekImage *)getLastImage;
-(NSArray *)getPrettiest;
-(NSArray *)getUgliest;
@end
