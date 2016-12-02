//
//  DataBase.m
//  Photo_worker
//
//  Created by Dmitry on 02.06.15.
//  Copyright (c) 2015 WinterInc. All rights reserved.
//

#import "DataBase.h"

@implementation DataBase

+(void)setDBPath:(NSString *)path {
    dbPath = path;
}

+(void)setModelName:(NSString *)name {
    modelName = name;
}

+ (instancetype) sharedInstance {
    static DataBase * instance;
    NSURL *dbUrl;
    if (instance==nil) {
        dbUrl = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:dbPath];
        instance = [[DataBase alloc] initWithModelName:modelName storagePath:dbUrl readOnly:NO];
    }
    return instance;
}

+ (BOOL)saveContext:(NSManagedObjectContext *)context {
    NSError *error = nil;
    if (context != nil) {
        if ([context hasChanges] && ![context save:&error]) {
            return false;
        }
    }
    return true;
}

- (id) init {
    [NSException raise:@"DataBase please use initWithModelName instead of init" format:nil];
    return nil;
}

- (id) initWithModelName:(NSString *)modelName storagePath:(NSURL *)stPath readOnly:(Boolean)ro {
    NSURL *modelURL;
    self = [super init];
    if (self) {
        modelURL = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"];
        mModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        mIsReadOnly = ro;
        mCoordinator = [DataBase persistentStoreCoordinatorForURL:stPath model:mModel readOnly:ro];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

-(void)didEnterBackground:(NSNotification *)n {
    [self saveContext];
}

-(NSManagedObjectContext *)context {
    if (mContext==nil) {
        mContext=[self newContext];
    }
    return mContext;
}

-(void)saveContext {
    [DataBase saveContext:self.context];
}

-(NSManagedObjectContext *)newContext{
    NSManagedObjectContext * c;
    c = [[NSManagedObjectContext alloc] init];
    [c setPersistentStoreCoordinator:mCoordinator];
    return c;
}

+(NSPersistentStoreCoordinator *)persistentStoreCoordinatorForURL:(NSURL *)url model:(NSManagedObjectModel *)mModel readOnly:(Boolean)ro {
    NSError *error = nil;
    NSMutableDictionary *opts = nil;
    NSPersistentStoreCoordinator * ret;
    ret = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mModel];
    opts = [[NSMutableDictionary alloc] initWithCapacity:4];
    //automatically migrate to latest version of model if possible
    [opts setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
    [opts setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
    if (ro) {
        [opts setObject:[NSNumber numberWithBool:YES] forKey:NSReadOnlyPersistentStoreOption];
    }
    if (![ret addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:opts error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
    return ret;
}
@end