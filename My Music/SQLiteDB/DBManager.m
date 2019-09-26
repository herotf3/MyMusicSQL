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
// Array of all rows which is result of a query
@property (nonatomic, strong) NSMutableArray *arrResults;
 
-(void)copyDatabaseIntoDocumentsDirectory;
-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable;

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

-(void) resetResultsAndColumnName {
    if (self.arrResults != nil) {
        [self.arrResults removeAllObjects];
        self.arrResults = nil;
    }
    self.arrResults = [[NSMutableArray alloc] init];
 
    if (self.arrColumnNames != nil) {
        [self.arrColumnNames removeAllObjects];
//      shall I need the below line?
//        self.arrColumnNames = nil;
    }
    self.arrColumnNames = [[NSMutableArray alloc] init];
}

-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable{
    // Create a sqlite object.
    sqlite3 *sqlite3Database;
    NSString *databasePath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
 
    [self resetResultsAndColumnName];

    // Open the database.
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if(openDatabaseResult == SQLITE_OK){
        // Declare a sqlite3_stmt object in which will be stored the query after having been compiled into a SQLite statement.
        sqlite3_stmt *compiledStatement;
 
        // Load all data from database to memory.
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK) {
            if (!queryExecutable){
                // In this case data must be loaded from the database.            
                NSMutableArray *arrDataRow; //array to keep the data for each fetched row.
        
                // Loop through the results and add them to the results array row by row.
                while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    // Array that will contain the data of a fetched row.
                    arrDataRow = [[NSMutableArray alloc] init];
                    
                    int totalColumns = sqlite3_column_count(compiledStatement);
        
                    // Go through all columns and fetch each column data.
                    for (int i=0; i<totalColumns; i++){
                        // Convert the column data to text (char*).
                        char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
        
                        // If there are contents in the currenct column, add them to the current row array.
                        if (dbDataAsChars != NULL) {                    
                            [arrDataRow addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
                        }
        
                        // Keep the current column name.
                        if (self.arrColumnNames.count != totalColumns) {
                            dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                            [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                    }
        
                    // Store each fetched data row in the results array, but first check if there is actually data.
                    if (arrDataRow.count > 0) {
                        [self.arrResults addObject:arrDataRow];
                    }
                }
            }else {
                // This is the case of an executable query (insert, update, ...). 
                // Execute the query.
                if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
                    // Keep the affected rows & last inserted row.
                    self.affectedRows = sqlite3_changes(sqlite3Database); 
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                }else {
                    NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
                }
            }

        }else{
            // database cannot be opened 
            NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
        }
        // Release the compiled statement from memory.
        sqlite3_finalize(compiledStatement);
    }
    //Close DB
    sqlite3_close(sqlite3Database);
}

-(NSArray *)loadDataFromDB:(NSString *)query{    
    [self runQuery:[query UTF8String] isQueryExecutable:NO];     
    return (NSArray *)self.arrResults;
}

-(void)executeQuery:(NSString *)query{
    // Run the query and indicate that is executable.
    [self runQuery:[query UTF8String] isQueryExecutable:YES];
}

@end
