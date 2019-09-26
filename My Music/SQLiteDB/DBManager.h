//
//  DBManager.h
//  My Music
//
//  Created by CPU11808 on 9/25/19.
//  Copyright © 2019 CPU11808. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MUSIC_DATABASE_FILENAME @"musicdb.sql"

NS_ASSUME_NONNULL_BEGIN

@interface DBManager : NSObject

@property (nonatomic, strong) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

//MARK: init
-(instancetype) initWithDBFileName:(NSString*) fileName;

-(NSArray *)loadDataFromDB:(NSString *)query;
-(void)executeQuery:(NSString *)query;

@end

NS_ASSUME_NONNULL_END
