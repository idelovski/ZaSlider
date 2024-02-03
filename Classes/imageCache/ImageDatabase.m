//
//  ImageDatabase.m
//  Homepwner
//
//  Created by Igor Delovski on 30.06.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import "ImageDatabase.h"


@implementation ImageDatabase

@synthesize  fullPath, dbFileHelper;

- (id)initWithFileName:(NSString *)aFileName
{
   int             returnCode = SQLITE_OK;
   NSFileManager  *fm = [NSFileManager defaultManager];
   
   char           *cSqlString = sqlite3_mprintf ("CREATE TABLE %s (id integer primary key, name TEXT UNIQUE, image BLOB, comment TEXT);", kTableName);
   NSString       *sqlString = [NSString stringWithCString:cSqlString encoding:NSUTF8StringEncoding];
   
   if (self = [super init])  {
      self.fullPath = id_PathInDocumentDirectory (aFileName);  // need to retain it
      if (![fm fileExistsAtPath:fullPath])
         returnCode = [FileHelper createNewDatabase:fullPath creatingTableWithSqlString:sqlString errString:nil];
      
      if (returnCode == SQLITE_OK)
         dbFileHelper = [[FileHelper alloc] initWithFilePath:fullPath];

      if ((returnCode != SQLITE_OK) || !dbFileHelper)  {
         if (dbFileHelper)
            [dbFileHelper release];
         [self release];
         self = nil;
      }

   }
   
   sqlite3_free (cSqlString);
   
   return (self);
}

- (void)dealloc
{
   [fullPath release];
   [dbFileHelper release];
   
   [super dealloc];
}

#pragma mark -

- (int)addImage:(UIImage *)img withName:(NSString *)iName
{
   NSString      *sqlString = [NSString stringWithFormat:@"INSERT INTO %s (name, image, comment) values (?,?,?)", kTableName];
   sqlite3_stmt  *sqlStatement;
   
   int            returnCode = [dbFileHelper prepare:sqlString sqlStatement:&sqlStatement];
   
   if (returnCode == SQLITE_OK)
      returnCode = [dbFileHelper bindText:[iName UTF8String] withSqlStatement:sqlStatement forParamNumber:1 asTransient:YES];

   if (returnCode == SQLITE_OK)  {
      NSData  *imgData = UIImageJPEGRepresentation (img, 1.);
      returnCode = [dbFileHelper bindBlob:[imgData bytes] withSqlStatement:sqlStatement forParamNumber:2 ofLength:[imgData length] asTransient:YES];
   }
   if (returnCode == SQLITE_OK)
      returnCode = [dbFileHelper bindText:"No comment" withSqlStatement:sqlStatement forParamNumber:3 asTransient:YES];

   returnCode = [dbFileHelper stepWithSqlStatement:sqlStatement];
   if (returnCode == SQLITE_DONE)
      returnCode = SQLITE_OK;

   if (returnCode == SQLITE_OK)  {
      returnCode = [dbFileHelper finalizeSqlStatement:sqlStatement];
   }

#ifdef _SQLITE_LOG_
   if (returnCode == SQLITE_OK)
      NSLog (@"Added one image to SQLite db!");
#endif
   
   return (returnCode);
}

- (int)updateImage:(UIImage *)img withName:(NSString *)iName
{
   NSString      *sqlString = [NSString stringWithFormat:@"UPDATE %s SET image = ? WHERE name = ?", kTableName];
   sqlite3_stmt  *sqlStatement;
   
   int            returnCode = [dbFileHelper prepare:sqlString sqlStatement:&sqlStatement];
   
   if (returnCode == SQLITE_OK)  {
      NSData  *imgData = UIImageJPEGRepresentation (img, 1.);
      returnCode = [dbFileHelper bindBlob:[imgData bytes] withSqlStatement:sqlStatement forParamNumber:1 ofLength:[imgData length] asTransient:YES];
   }
   if (returnCode == SQLITE_OK)
      returnCode = [dbFileHelper bindText:[iName UTF8String] withSqlStatement:sqlStatement forParamNumber:2 asTransient:YES];
   
   returnCode = [dbFileHelper stepWithSqlStatement:sqlStatement];
   if (returnCode == SQLITE_DONE)
      returnCode = SQLITE_OK;

   if (returnCode == SQLITE_OK)
      returnCode = [dbFileHelper finalizeSqlStatement:sqlStatement];
   
   return (returnCode);
}

- (int)deleteImageWithName:(NSString *)iName
{
   NSString  *sqlString = [NSString stringWithFormat:@"DELETE FROM %s WHERE name = '%@'", kTableName, iName];
   
   int        returnCode = [dbFileHelper execSqlString:sqlString errString:nil];
      
   return (returnCode);
}

- (UIImage *)imageWithName:(NSString *)iName
{
   NSString      *sqlString = [NSString stringWithFormat:@"SELECT image FROM %s WHERE name = '%@'", kTableName, iName];
   UIImage       *img = nil;
   sqlite3_stmt  *sqlStatement;
   
   int            returnCode = [dbFileHelper prepare:sqlString sqlStatement:&sqlStatement];
   
   returnCode = [dbFileHelper stepWithSqlStatement:sqlStatement];
   if (returnCode == SQLITE_ROW)
      returnCode = SQLITE_OK;

   if (returnCode == SQLITE_OK)  {
      NSInteger   dataLength;
      const char *rowData = [dbFileHelper blobWithSqlStatement:sqlStatement forColumnIndex:0 andLength:&dataLength];
      NSData  *imgData = [NSData dataWithBytes:rowData
                                        length:dataLength];
      img = [UIImage imageWithData:imgData];
   }
   
   if (returnCode == SQLITE_OK)
      returnCode = [dbFileHelper finalizeSqlStatement:sqlStatement];

#ifdef _SQLITE_LOG_
   if (returnCode == SQLITE_OK)
      NSLog (@"Found one image in SQLite db!");
#endif
   
   return (img);
}

#pragma mark -

- (NSOperation *)addImage:(UIImage *)img withName:(NSString *)iName asOperationOnQueue:(NSOperationQueue *)opQueue
{
   StoreImageOperation  *siOp = [[StoreImageOperation alloc] initWithImageDB:self
                                                                       image:img
                                                                         key:iName
                                                                     comment:@"Nothing" 
                                                                      target:nil
                                                             andTargetMethod:nil];
   
   [opQueue addOperation:siOp];

   return ([siOp autorelease]);  // so it can be used as dependancy
}

@end

// ---------------------------------------------------------------------
#pragma mark -
#pragma mark StoreImageOperation
#pragma mark -
// ---------------------------------------------------------------------


@implementation StoreImageOperation

@synthesize  opImageDB, opImage, opKey, opComment;


- (id)initWithImageDB:(ImageDatabase *)idb
                image:(UIImage *)img
                  key:(NSString *)key
              comment:(NSString *)com
               target:(id)tarObject
      andTargetMethod:(SEL)tarMethod
{
   if (self = [super init])  {
      self.opImageDB = idb;
		self.opImage = img;
		self.opKey = key;
		self.opComment = com;
      
		targetObject  = tarObject;
		targetMethod  = tarMethod;
   }
   
   return (self);
}

- (void)dealloc
{
   [opImageDB release];
   [opImage release];
   [opKey release];
   [opComment release];
   
   [super dealloc];
}

#pragma mark -

- (void)main
{
   NSAutoreleasePool  *localPool;
   
   @try  {
      localPool = [[NSAutoreleasePool alloc] init];
      
      if ([self isCancelled])
         return;
      
      [self.opImageDB addImage:self.opImage withName:self.opKey];
      
      if (targetObject && targetMethod)
         if (![self isCancelled])
            [targetObject performSelectorOnMainThread:targetMethod
                                           withObject:nil
                                        waitUntilDone:NO];
   }
   @catch (NSException *e)  {
      NSLog (@"Exception: %@", [e reason]);
   }
   @finally {
      [localPool release];
   }
}

@end
