//
//  DBManager.m
//  My Music
//
//  Created by CPU11808 on 9/25/19.
//  Copyright © 2019 CPU11808. All rights reserved.
//

#import "DBManager.h"
#import <sqlite3.h>

@interface DBManager()

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;
 
-(void)copyDatabaseIntoDocumentsDirectory;

@end

@implementation DBManager

- (instancetype)initWithDBFileName:(NSString *)fileName{
    self = [super init];
    if (self){
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        self.databaseFilename = fileName;
        
        [self copyDatabaseIntoDocumentsDirectory];
    }
    return self;
}

-(void) copyDatabaseIntoDocumentsDirectory {
    // Check if the database file exists in the documents directory.
    NSString *destinationPath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        // The database file does not exist in the documents directory, copy it from the main bundle
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFilename];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
 
        // Check if any error occurred during copying and display it.
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}

@end
