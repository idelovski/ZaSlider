/*
 *  FileHelpers.h
 *  Homepwner
 *
 *  Created by Igor Delovski on 25.05.2010.
 *  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface FileHelper : NSObject {
   sqlite3   *dbHandle;
   NSString  *fileName;
}

@property (nonatomic, retain)  NSString  *fileName;

+ (int)createNewDatabase:(NSString *)filePath creatingTableWithSqlString:(NSString *)sqlStr errString:(NSString **)retErrStr;


- (id)initWithFilePath:(NSString *)filePath;
- (id)initWithFileInDocumentDirectory:(NSString *)fileName;

- (sqlite3 *)dbHandle;

- (int)execSqlString:(NSString *)sqlString errString:(NSString **)retErrStr;

- (int)prepare:(NSString *)sqlString sqlStatement:(sqlite3_stmt **)retStatement;
- (int)stepWithSqlStatement:(sqlite3_stmt *)statement;
- (int)finalizeSqlStatement:(sqlite3_stmt *)statement;

- (int)bindText:(const char *)txt withSqlStatement:(sqlite3_stmt *)statement forParamNumber:(NSInteger)paramNum asTransient:(BOOL)byRef;
- (int)bindInt:(int)intVal withSqlStatement:(sqlite3_stmt *)statement forParamNumber:(NSInteger)paramNum;
- (int)bindBlob:(const void *)ptr withSqlStatement:(sqlite3_stmt *)statement forParamNumber:(NSInteger)paramNum ofLength:(NSInteger)length asTransient:(BOOL)byRef;

- (const unsigned char *)textWithSqlStatement:(sqlite3_stmt *)statement forColumnIndex:(NSInteger)idx;
- (int)intWithSqlStatement:(sqlite3_stmt *)statement forColumnIndex:(NSInteger)idx;
- (const void *)blobWithSqlStatement:(sqlite3_stmt *)statement forColumnIndex:(NSInteger)idx andLength:(NSInteger *)retLength;

// ---- Prefs ---

+ (NSString *)getUserDefaultsStringForKey:(NSString *)aKey withDefault:(NSString *)aDefaultValue;
+ (void)setUserDefaultsString:(NSString *)aStrValue forKey:(NSString *)aKey;
+ (NSInteger)getUserDefaultsIntegerForKey:(NSString *)aKey withDefault:(NSInteger)aDefaultValue;
+ (void)setUserDefaultsInteger:(NSInteger)anIntValue forKey:(NSString *)aKey;
+ (NSInteger)getUserDefaultsBoolForKey:(NSString *)aKey withDefault:(BOOL)aDefaultValue;
+ (void)setUserDefaultsBool:(BOOL)aBoolValue forKey:(NSString *)aKey;

@end

// Straight C

NSString  *id_PathInDocumentDirectory (NSString *fileName);