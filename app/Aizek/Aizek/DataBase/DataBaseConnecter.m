//
//  DataBaseConnector.m
//  Photo_worker
//
//  Created by Dmitry on 02.06.15.
//  Copyright (c) 2015 WinterInc. All rights reserved.
//

#import "DataBaseConnecter.h"

@implementation DataBaseConnecter

+(BOOL)isExistEntity:(NSString *)entityName ByPredicate:(NSString *)predicate WithSortDescriptor:(NSString *)sorter {
    return [[self getResultsForEntity:entityName ByPredicate:predicate withSortDescriptor:sorter] lastObject];
}

+(void)insertIntoDB:(NSManagedObject *)object {
    [[[DataBase sharedInstance]context]insertObject:object];
    [[DataBase sharedInstance]saveContext];
}

+(void)deleteFromDB:(NSManagedObject *)object {
    [[[DataBase sharedInstance]context]deleteObject:object];
    [[DataBase sharedInstance]saveContext];
}

+(NSArray *)getResultsForEntity:(NSString *)entityName ByPredicate:(NSString *)predicate withSortDescriptor:(NSString *)sorter {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext*cont = [[DataBase sharedInstance] context];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:cont];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sorter ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    if(predicate) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:predicate]];
    }
    NSArray* array = [cont executeFetchRequest:fetchRequest error:nil];
    return array;
}

@end
