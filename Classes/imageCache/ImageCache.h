//
//  ImageCache.h
//  Homepwner
//
//  Created by Igor Delovski on 22.05.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <Foundation/Foundation.h>

// ---------------------------------------------------------------------
#pragma mark -
#pragma mark ThumbnailCreationDelegate
#pragma mark -
// ---------------------------------------------------------------------

#ifdef NIJE_
@protocol  ThumbnailCreationDelegate
- (void)imageCacheDidFinishCreatingThumbnail:(UIImage *)thumbImage forKey:(NSString *)key;
// @optional
@end
#endif
// ---------------------------------------------------------------------
#pragma mark -
#pragma mark SmallImageCreationDelegate
#pragma mark -
// ---------------------------------------------------------------------

@protocol  SmallImageCreationDelegate
- (void)imageCacheDidFinishCreatingSmallImage:(UIImage *)smallImage thumbnail:(UIImage*)thumbImg forKey:(NSString *)key;
// @optional
@end


// ---------------------------------------------------------------------
#pragma mark -
#pragma mark TileImageCreationDelegate
#pragma mark -
// ---------------------------------------------------------------------

@protocol  TileImageCreationDelegate
- (void)imageCacheDidFinishCreatingTileImage:(UIImage *)tileImage forKey:(NSString *)key withTileLocIndex:(NSUInteger)idx;
// @optional
@end


// ---------------------------------------------------------------------
#pragma mark -
#pragma mark ImageCache
#pragma mark -
// ---------------------------------------------------------------------

@class ImageDatabase, ImageAlbum;

#define  kMaxImagesInCache     24
#define  kMaxPrefechedImages   16

#define  kCGBestByteAlignment  16  // se MKQuartz 353


@interface ImageCache : NSObject  {
   NSMutableDictionary  *imageDictionary;     // screen sized images
   // NSMutableDictionary  *smallDictionary;  
   NSMutableArray       *dicKeys;          // used to keep count of items in cache
   NSMutableArray       *inOpKeys;         // used to keep keys already in operation
   ImageDatabase        *imgDatabase;
   NSOperationQueue     *workQueue;
   
   NSUInteger            cashingOperationsCnt;
}

@property (nonatomic, retain)  NSMutableDictionary  *imageDictionary;
// @property (nonatomic, retain)  NSMutableDictionary  *smallDictionary;
@property (nonatomic, retain)  NSMutableArray       *dicKeys;
@property (nonatomic, retain)  NSMutableArray       *inOpKeys;
@property (nonatomic, retain)  ImageDatabase        *imgDatabase;
@property (nonatomic, retain)  NSOperationQueue     *workQueue;

@property (readonly)           NSUInteger            cashingOperationsCnt;

#pragma mark class

+ (ImageCache *)sharedImageCache;
+ (NSString *)uuidForNewImage;

#pragma mark instance

- (BOOL)operationsInProgress;
- (void)cancelAllCachingOperations;
- (void)clearCache:(NSNotification *)aNote;
- (void)closeDatabase:(NSNotification *)aNote;

- (void)     setImage:(UIImage *)img
               forKey:(NSString *)key
  dependencyOperation:(NSOperation *)depOperation
andSmallImageDelegate:(id<NSObject, SmallImageCreationDelegate>)siDelegate;

- (UIImage *)imageForKey:(NSString *)key;
- (void)deleteImageForKey:(NSString *)key;

// - (UIImage *)cacheSmallImageForKey:(NSString *)key;
/*
- (void)setSmallImage:(UIImage *)img forKey:(NSString *)key;
- (UIImage *)smallImageForKey:(NSString *)key;
- (void)needSmallImageForKey:(NSString *)iKey andDelegate:(id<NSObject, SmallImageCreationDelegate>)smallImgDelegate;
*/
 - (NSOperation *)cacheSmallImageForKey:(NSString *)iKey
                                  image:(UIImage *)bigImage
                     asOperationOnQueue:(NSOperationQueue *)opQueue
                         withDependancy:(NSOperation *)dependancyOperation
                     smallImageDelegate:(id<NSObject, SmallImageCreationDelegate>)smallImgDelegate;

- (NSOperation *)makeTileImageForKey:(NSString *)iKey
                               image:(UIImage *)bigImage
                            partRect:(CGRect)pRect
                            locIndex:(NSUInteger)idx
                      withDependancy:(NSOperation *)dependancyOperation
                   tileImageDelegate:(id<NSObject, TileImageCreationDelegate>)tileImgDelegate;
                  // smallImageDelegate:(id<NSObject, SmallImageCreationDelegate>)smallImgDelegate;

- (void)finishedCashingSmallImage:(NSString *)iKey;
- (void)finishedCashingTileImage:(NSString *)iKey;

@end


// ---------------------------------------------------------------------
#pragma mark -
#pragma mark SmallImageOperation
#pragma mark -
// ---------------------------------------------------------------------


@interface SmallImageOperation : NSOperation  {
   
   NSString        *opKey;
   UIImage         *opBigImage;
   UIImage         *opResultImage;
   UIImage         *opThumbImage;
   
   // ----- OPTIONAL
   
   id              targetObject;
   SEL             targetMethod;

   id <NSObject, SmallImageCreationDelegate> smallImgDelegate;

}

@property (nonatomic, retain)  NSString        *opKey;
@property (nonatomic, retain)  UIImage         *opBigImage;
@property (nonatomic, retain)  UIImage         *opResultImage;
@property (nonatomic, retain)  UIImage         *opThumbImage;

@property (nonatomic, assign) id <NSObject, SmallImageCreationDelegate> smallImgDelegate;


-  (id)initWithKey:(NSString *)key
             image:(UIImage *)bigImage
            target:(id)tarObject
      targetMethod:(SEL)tarMethod
smallImageDelegate:(id<NSObject, SmallImageCreationDelegate>)smlImgDelegate;

- (void)performCallback;

@end

// ---------------------------------------------------------------------
#pragma mark -
#pragma mark TileImageOperation
#pragma mark -
// ---------------------------------------------------------------------


@interface TileImageOperation : NSOperation  {
   
   NSString        *opKey;
   NSUInteger       locIndex;
   CGRect           opPartRect;
   UIImage         *opBigImage;
   UIImage         *opResultImage;
   
   // ----- OPTIONAL
   
   id              targetObject;
   SEL             targetMethod;
   
   id <NSObject, TileImageCreationDelegate> tileImgDelegate;
//    id <NSObject, SmallImageCreationDelegate> smallImgDelegate;
}

@property (nonatomic, retain)  NSString        *opKey;
@property                      NSUInteger       locIndex;
@property                      CGRect           opPartRect;
@property (nonatomic, retain)  UIImage         *opBigImage;
@property (nonatomic, retain)  UIImage         *opResultImage;

@property (nonatomic, assign) id <NSObject, TileImageCreationDelegate> tileImgDelegate;
// @property (nonatomic, assign) id <NSObject, SmallImageCreationDelegate> smallImgDelegate;


-  (id)initWithKey:(NSString *)key
             image:(UIImage *)bigImage
          partRect:(CGRect)pRect
          locIndex:(NSUInteger)idx
            target:(id)tarObject
      targetMethod:(SEL)tarMethod
 tileImageDelegate:(id<NSObject, TileImageCreationDelegate>)tImgDelegate;
// smallImageDelegate:(id<NSObject, SmallImageCreationDelegate>)smlImgDelegate;

- (void)performCallback;

@end

