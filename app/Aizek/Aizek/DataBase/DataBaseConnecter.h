//
//  DataBaseConnector.h
//  Photo_worker
//
//  Created by Dmitry on 02.06.15.
//  Copyright (c) 2015 WinterInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataBase.h"
@interface DataBaseConnecter : NSObject <NSFetchedResultsControllerDelegate>
+(BOOL)isExistEntity:(NSString *)entityName ByPredicate:(NSString *)predicate WithSortDescriptor:(NSString *)sorter;
+(void)insertIntoDB:(NSManagedObject *)object;
+(void)deleteFromDB:(NSManagedObject *)object;
+(NSArray *)getResultsForEntity:(NSString *)entityName ByPredicate:(NSString *)predicate withSortDescriptor:(NSString *)sorter;
@end
