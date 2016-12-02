//
//  DataBase.h
//  Photo_worker
//
//  Created by Dmitry on 02.06.15.
//  Copyright (c) 2015 WinterInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

static NSString *modelName;
static NSString *dbPath;

@interface DataBase : NSObject
{
    NSManagedObjectModel *mModel;
    NSPersistentStoreCoordinator *mCoordinator;
    Boolean mIsReadOnly;
    NSManagedObjectContext *mContext;
}


+(instancetype)sharedInstance;
+(BOOL)saveContext:(NSManagedObjectContext *)context;
+(void)setModelName:(NSString *)name;
+(void)setDBPath:(NSString *)path;


-(id)init;
-(id)initWithModelName:(NSString *)modelName storagePath:(NSURL *)stPath readOnly:(Boolean) ro;
-(NSManagedObjectContext *)context;
-(NSManagedObjectContext *)newContext;
-(void)saveContext;
@end
