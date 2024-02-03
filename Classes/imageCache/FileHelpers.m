/*
 *  FileHelpers.m
 *  Homepwner
 *
 *  Created by Igor Delovski on 25.05.2010.
 *  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
 *
 */

#include "FileHelpers.h"

@implementation FileHelper

@synthesize  fileName;

+ (int)createNewDatabase:(NSString *)filePath creatingTableWithSqlString:(NSString *)sqlStr errString:(NSString **)retErrStr
{
   int          returnCode;
   const char  *cSqlStr = [sqlStr UTF8String];
   const char  *tmpMsg;
   char        *errMsg = NULL;
   sqlite3     *tmpDbHandle;
   
   returnCode = sqlite3_open ([filePath UTF8String], &tmpDbHandle);

   if (returnCode != SQLITE_OK)  {
      tmpMsg = sqlite3_errmsg (tmpDbHandle);
      if (retErrStr)
         *retErrStr = [NSString stringWithUTF8String:tmpMsg];
      NSLog (@"Error sqlite3_open() - %s", tmpMsg);
      if (tmpDbHandle)  {
         sqlite3_close (tmpDbHandle);
         tmpDbHandle = NULL;
      }
      return (returnCode);
   }
      
   returnCode = sqlite3_exec (tmpDbHandle, cSqlStr, NULL, NULL, &errMsg);
   
   if ((returnCode != SQLITE_OK) && errMsg)  {
      NSLog (@"Error sqlite3_open() - %s", errMsg);
      if (retErrStr)
         *retErrStr = [NSString stringWithUTF8String:errMsg];
      sqlite3_free (errMsg);
   }
   else  if (retErrStr)
      *retErrStr = nil;
      
   return (returnCode);
}

- (id)init
{
   // Dont call us (We'll call you)
   
   return (nil);
}

- (id)initWithFilePath:(NSString *)filePath
{
   int  returnCode;
   
   if (self = [super init])  {   
      returnCode = sqlite3_open ([filePath UTF8String], &dbHandle);
      
      self.fileName = [filePath lastPathComponent];  // needs retain it!
      
      if (returnCode != SQLITE_OK)  {
         NSLog (@"Error sqlite3_open() - %s", sqlite3_errmsg(dbHandle));
         if (dbHandle)  {
            sqlite3_close (dbHandle);
            dbHandle = NULL;

            [self release];
            self = nil;
         }
      }
   }
   
   return (self);
}

- (id)initWithFileInDocumentDirectory:(NSString *)aFileName
{
   NSString  *fullPath = id_PathInDocumentDirectory (aFileName);
      
   return ([self initWithFilePath:fullPath]);
}

- (void)dealloc
{
   if (dbHandle)  {
      sqlite3_close (dbHandle);
      dbHandle = NULL;
   }
   
   [fileName release];
   
   [super dealloc];
}

#pragma mark -

- (sqlite3 *)dbHandle
{
   return (dbHandle);
}

// Use for insert, update, delete
- (int)execSqlString:(NSString *)sqlString errString:(NSString **)retErrStr
{
   int          returnCode;
   char        *errMsg = NULL;
   const char  *utfString = [sqlString UTF8String];
   
   returnCode = sqlite3_exec (dbHandle, utfString, NULL, NULL, &errMsg);
   
   if ((returnCode != SQLITE_OK) && errMsg)  {
      NSLog (@"Error sqlite3_open() - %s", errMsg);
      if (retErrStr)
         *retErrStr = [NSString stringWithUTF8String:errMsg];
      sqlite3_free (errMsg);
   }
   else  if (retErrStr)
      *retErrStr = nil;
   
   return (returnCode);
}

#pragma mark -

- (int)prepare:(NSString *)sqlString sqlStatement:(sqlite3_stmt **)retStatement
{
   int          returnCode;
   const char  *utfString = [sqlString UTF8String];
   
   sqlite3_stmt  *tmpStatement = NULL;
   
   returnCode = sqlite3_prepare_v2 (dbHandle, utfString, -1, &tmpStatement, NULL);
   
   if (returnCode != SQLITE_OK)
      NSLog (@"Error sqlite3_prepare() - %s", sqlite3_errmsg(dbHandle));
   
   *retStatement = tmpStatement;
   
   return (returnCode);
}

- (int)stepWithSqlStatement:(sqlite3_stmt *)statement
{
   int  returnCode;
   
   returnCode = sqlite3_step (statement);

   if (returnCode != SQLITE_ROW && returnCode != SQLITE_DONE)
      NSLog (@"Error sqlite3_step() - %s", sqlite3_errmsg(dbHandle));

   return (returnCode);
}

- (int)finalizeSqlStatement:(sqlite3_stmt *)statement
{
   return (sqlite3_finalize(statement));
}

#pragma mark -

- (int)bindText:(const char *)txt withSqlStatement:(sqlite3_stmt *)statement forParamNumber:(NSInteger)paramNum asTransient:(BOOL)asTrans
{
   int  returnCode;
   
   returnCode = sqlite3_bind_text (statement, paramNum, (const char *)txt, -1, asTrans ? SQLITE_TRANSIENT : SQLITE_STATIC);
   
   return (returnCode);
}

- (int)bindInt:(int)intVal withSqlStatement:(sqlite3_stmt *)statement forParamNumber:(NSInteger)paramNum
{
   int  returnCode;
   
   returnCode = sqlite3_bind_int (statement, paramNum, intVal);
   
   return (returnCode);
}

- (int)bindBlob:(const void *)ptr withSqlStatement:(sqlite3_stmt *)statement forParamNumber:(NSInteger)paramNum ofLength:(NSInteger)length asTransient:(BOOL)asTrans
{
   int  returnCode;
   
   returnCode = sqlite3_bind_blob (statement, paramNum, (const char *)ptr, length, asTrans ? SQLITE_TRANSIENT : SQLITE_STATIC);
   
   return (returnCode);
}

#pragma mark -

- (const unsigned char *)textWithSqlStatement:(sqlite3_stmt *)statement forColumnIndex:(NSInteger)idx
{
   return (sqlite3_column_text(statement, idx));
}

- (int)intWithSqlStatement:(sqlite3_stmt *)statement forColumnIndex:(NSInteger)idx
{
   return (sqlite3_column_int(statement, idx));
}

- (const void *)blobWithSqlStatement:(sqlite3_stmt *)statement forColumnIndex:(NSInteger)idx andLength:(NSInteger *)retLength
{
   if (retLength)
      *retLength = sqlite3_column_bytes (statement, idx);  // size in bytes
   
   return (sqlite3_column_blob(statement, idx));
}

#pragma mark -
#pragma mark Preferences
#pragma mark -

+ (NSString *)getUserDefaultsStringForKey:(NSString *)aKey withDefault:(NSString *)aDefaultValue
{
	NSString  *resultStr = [[NSUserDefaults standardUserDefaults] stringForKey:aKey];
   
	if (!resultStr || [resultStr isEqualToString:@""])
		return (aDefaultValue);
	
	return (resultStr);
}

+ (void)setUserDefaultsString:(NSString *)aStrValue forKey:(NSString *)aKey
{	
	[[NSUserDefaults standardUserDefaults] setObject:aStrValue forKey:aKey];
}

#pragma mark -

+ (NSInteger)getUserDefaultsIntegerForKey:(NSString *)aKey withDefault:(NSInteger)aDefaultValue
{
	NSString  *resultStr = [self getUserDefaultsStringForKey:aKey withDefault:[NSString stringWithFormat:@"%d", aDefaultValue]];
	
	return ([resultStr intValue]);
}

+ (void)setUserDefaultsInteger:(NSInteger)anIntValue forKey:(NSString *)aKey
{	
   [self setUserDefaultsString:[NSString stringWithFormat:@"%d", anIntValue] forKey:aKey];
}

#pragma mark -

+ (NSInteger)getUserDefaultsBoolForKey:(NSString *)aKey withDefault:(BOOL)aDefaultValue
{
	NSString  *resultStr = [self getUserDefaultsStringForKey:aKey withDefault:aDefaultValue ? kStringYES : kStringNO];
	
   if ([resultStr isEqualToString:kStringYES])
      return (YES);

	return (NO);
}

+ (void)setUserDefaultsBool:(BOOL)aBoolValue forKey:(NSString *)aKey
{	
   [self setUserDefaultsString:aBoolValue ? kStringYES : kStringNO forKey:aKey];
}

@end

// Straight C

#pragma mark -

NSString  *id_PathInDocumentDirectory (NSString *fileName)
{
   NSArray  *docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   
   NSString  *docDir = [docDirs objectAtIndex:0];
   
   if (!fileName)
      return (docDir);
   
   return ([docDir stringByAppendingPathComponent:fileName]);
}