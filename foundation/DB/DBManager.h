//
//  DBManager.h
//  GoEmerchant.com
//
//  Created by Gal Blank on 12/19/14.
//  Copyright (c) 2014 Gal Blank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>




#define LOCAL_DB_FILE_NAME     @"database"
#define LOCAL_DB_FILE_EXT      @"sqlite"
#define DB_BUNDLE_VERSION_KEY  @"kDB_BUNDLE_VERSION_KEY"
#define DB_QUEUE_NAME          "com.goe.app.dbqueue"


@interface DBManager : NSObject
{
    NSString *databaseFullPath;
    NSMutableArray *arrColumnNames;
    int affectedRows;

    NSString *documentsDirectory;
    NSMutableArray *arrResults;
    dispatch_queue_t databaseQueue;
    int currentIndex;
}

@property(nonatomic)long long lastInsertedRowID;

-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable;
-(NSMutableArray *)loadDataFromDB:(NSString *)query;
-(void)executeQuery:(NSString *)query;
-(void)deleteAllDataFromDB;
-(void)initDB;
-(id)getValueForColumnName:(NSString*)name;
-(NSMutableDictionary*)next;
-(BOOL)hasData;
+ (DBManager *)sharedInstance;

@end
