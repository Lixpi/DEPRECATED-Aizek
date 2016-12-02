//
//  AizekDB.m
//  Aizek
//
//  Created by Dmitry on 28.07.15.
//  Copyright (c) 2015 Linum. All rights reserved.
//

#import "AizekDB.h"


static AizekDB *instance;


@implementation AizekDB

@synthesize resultarray;

+(instancetype)sharedInstance {
    if(instance == nil) {
        
        instance = [[AizekDB alloc]init];
    }
    return instance;
}


-(NSMutableArray*)getArrayFromPredicate:(NSString *)predicate{
    if(resultarray) return  resultarray;
    resultarray = [self getObjectFromStored:[DataBaseConnecter getResultsForEntity:modelName ByPredicate:predicate withSortDescriptor:sorter]];
    return resultarray;
}

-(NSMutableArray *)getTopRatings{
    NSArray *res = [self getArrayFromPredicate:nil];
    if(res.count>10){
        res =[res subarrayWithRange:NSMakeRange(0, 10)];
    }
    
    return [[NSMutableArray alloc]initWithArray:res];
}

-(NSMutableArray *) getResultsForPredicate:(NSString *)predicate {
    return [self getObjectFromStored:[DataBaseConnecter getResultsForEntity:modelName ByPredicate:predicate withSortDescriptor:sorter]];
}

-(NSArray *)getRatings{
    return [self getArrayFromPredicate:nil];
}

-(NSArray *)getPrettiest {
    if(prettiestArray) return prettiestArray;
    prettiestArray = [[NSMutableArray alloc]init];
    for(AizekImage*i in resultarray) {
        if(i.look>6){
            [prettiestArray addObject:i];
        }
    }
    
    return prettiestArray;
}

-(NSArray *)getUgliest {
    if(ugliestArray) return ugliestArray;
    ugliestArray = [[NSMutableArray alloc]init];
    for(AizekImage*i in resultarray) {
        if(i.look<4){
            [ugliestArray addObject:i];
        }
    }
    
    return ugliestArray;
}

-(NSMutableArray *)getObjectFromStored:(NSArray *)array{
    NSMutableArray *res = [[NSMutableArray alloc]init];
    for(AizekImageStrored *st in array){
        AizekImage *i = [AizekImage initWithManageObject:st];
        [res addObject:i];
    }
    
    return res;
}

-(NSNumber *)getMax{
    return [[self getStoredImageByPredicate:@"feel==max(feel)"] look];
}

-(NSMutableArray *)getAllByDate {
    NSArray *res = [[[self getArrayFromPredicate:nil] reverseObjectEnumerator] allObjects];
    NSDateComponents*cmp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[(AizekImage *)[res firstObject] time]];
    cmp.minute = 0;
    cmp.hour = 0;
    cmp.second = 0;
    NSDateComponents *currentComp;
    NSDateComponents *nextComp;
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for(AizekImage*i in res) {
        if(currentComp==nil)
        {
            currentComp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:i.time];
            [array addObject:i];
            continue;
        }
        
        nextComp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:i.time];
        if(currentComp.day != nextComp.day || nextComp.month != nextComp.month) {
            [array addObject:i];
            currentComp = nextComp;
        }
        else {
            [array removeObject:[array lastObject]];
            [array addObject:i];
        }
    }
    return array;
}

-(NSMutableArray *)getAllInRangeWithMinDate:(NSDate *)minDate andMaxDate:(NSDate *)maxDate {
    NSArray *res = [[[self getArrayFromPredicate:nil] reverseObjectEnumerator] allObjects];
    NSDateComponents*cmp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[(AizekImage *)[res firstObject] time]];
    cmp.minute = 0;
    cmp.hour = 0;
    cmp.second = 0;
    
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = 1;
    maxDate = [[NSCalendar currentCalendar]dateByAddingComponents:dateComponents
                                                                   toDate: maxDate
                                                                  options:0];
    dateComponents.day = -1;
    minDate = [[NSCalendar currentCalendar]dateByAddingComponents:dateComponents
                                                           toDate: minDate
                                                          options:0];
    NSMutableArray* ar = [[NSMutableArray alloc]init];
    for(AizekImage* i in res) {
        if([[i.time laterDate:minDate]isEqualToDate:i.time]&&[[i.time laterDate:maxDate]isEqualToDate:maxDate]) {
            [ar addObject:i];
        }
    }
    NSDateComponents *currentComp ;
    NSDateComponents *nextComp;
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for(AizekImage*i in ar) {
        if(currentComp==nil)
        {
            currentComp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:i.time];
            [array addObject:i];
            continue;
        }
        
        nextComp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:i.time];
        if(currentComp.day != nextComp.day || nextComp.month != nextComp.month) {
            [array addObject:i];
            currentComp = nextComp;
        }
        else {
            [array removeObject:[array lastObject]];
            [array addObject:i];
        }
    }
    return array;
}

-(AizekImage *)getLastImage {
    AizekImage *i;
    NSArray * res = [self getObjectFromStored:[DataBaseConnecter getResultsForEntity:modelName ByPredicate:nil withSortDescriptor:sorter]];
    if(res.count>0) {
        i = [res objectAtIndex:0];
    }
    return i;
}

-(AizekImageStrored *)getStoredImageByPredicate:(NSString *)predicate{
    NSArray*res = [DataBaseConnecter getResultsForEntity:modelName ByPredicate:predicate withSortDescriptor:sorter];
    if(res.count==0){
        return nil;
    }
    return [res objectAtIndex:0];
}

-(void)insertNewObject:(AizekImage *)i{
    if(!resultarray)resultarray = [[NSMutableArray alloc]init];
    [resultarray insertObject:i atIndex:0];
    NSEntityDescription *entity = [NSEntityDescription entityForName:modelName inManagedObjectContext:[[DataBase sharedInstance] context]];
    AizekImageStrored *nmo = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:[[DataBase sharedInstance] context]];
    [i setDataToObject:nmo];
    [DataBaseConnecter insertIntoDB:nmo];
}

-(void)updateObjectFromObject:(AizekImage*)i{
    NSString *pred = [NSString stringWithFormat:@"time==%f",i.time.timeIntervalSince1970];
    AizekImageStrored *r = [self getStoredImageByPredicate:pred];
    if(r){
        [i setDataToObject:r];
    }
    
}

-(void)deleteObject:(AizekImage *)i {
    NSString *pred = [NSString stringWithFormat:@"time==%f",i.time.timeIntervalSince1970];
    AizekImageStrored *stored = [self getStoredImageByPredicate:pred];
    if(stored != nil) {
        [DataBaseConnecter deleteFromDB:stored];
        [resultarray removeObject:i];
    }
}




@end
