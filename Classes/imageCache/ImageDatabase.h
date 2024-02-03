//
//  ImageDatabase.h
//  Homepwner
//
//  Created by Igor Delovski on 30.06.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  kTableName  "imgcache"


@interface ImageDatabase : NSObject {
   NSString    *fullPath;
   FileHelper  *dbFileHelper;
}

@property (nonatomic, retain)  NSString    *fullPath;
@property (nonatomic, retain)  FileHelper  *dbFileHelper;

- (id)initWithFileName:(NSString *)aFileName;

- (int)addImage:(UIImage *)img withName:(NSString *)iName;
- (int)updateImage:(UIImage *)img withName:(NSString *)iName;
- (int)deleteImageWithName:(NSString *)iName;
- (UIImage *)imageWithName:(NSString *)iName;

- (NSOperation *)addImage:(UIImage *)img withName:(NSString *)iName asOperationOnQueue:(NSOperationQueue *)opQueue;

@end

// ---------------------------------------------------------------------
#pragma mark -
#pragma mark StoreImageOperation
#pragma mark -
// ---------------------------------------------------------------------

@interface StoreImageOperation : NSOperation  {
   
   ImageDatabase  *opImageDB;
   
   UIImage        *opImage;
   NSString       *opKey;
   NSString       *opComment;
   
   // ----- OPTIONAL
   
   id              targetObject;
   SEL             targetMethod;
}

@property (nonatomic, retain)  ImageDatabase  *opImageDB;
@property (nonatomic, retain)  UIImage        *opImage;
@property (nonatomic, retain)  NSString       *opKey;
@property (nonatomic, retain)  NSString       *opComment;


- (id)initWithImageDB:(ImageDatabase *)idb
                image:(UIImage *)img
                  key:(NSString *)key
              comment:(NSString *)com
               target:(id)tarObject
      andTargetMethod:(SEL)tarMethod;

@end
