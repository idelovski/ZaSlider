//
//  ImageCache.m
//  Homepwner
//
//  Created by Igor Delovski on 22.05.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import "ImageCache.h"
#import "ImageDatabase.h"
#import "ImageAlbum.h"

static ImageCache  *sharedImageCache = NULL;

@implementation ImageCache

@synthesize  imageDictionary, /*smallDictionary,*/ dicKeys, inOpKeys, imgDatabase, workQueue, cashingOperationsCnt;

#pragma mark -

+ (ImageCache *)sharedImageCache
{
   @synchronized(self)  {
      if (!sharedImageCache)
         sharedImageCache = [[ImageCache alloc] init];
   }
   
   return (sharedImageCache);
}

+ (id)allocWithZone:(NSZone *)zone
{
   if (!sharedImageCache)  {
      sharedImageCache = [super allocWithZone:zone];
      return (sharedImageCache);
   }
   
   return (nil);
}

- (id)copyWithZone:(NSZone *)zone
{
   return (self);
}

- (void)release
{
   // No op!
}

#pragma mark -

- (id)init
{
   // Call the superclass's designated initializer 
   if (self = [super init])  {
      imageDictionary = [[NSMutableDictionary alloc] init];
      //- smallDictionary = [[NSMutableDictionary alloc] init];
      
      dicKeys = [[NSMutableArray alloc] init];
      inOpKeys = [[NSMutableArray alloc] init];

      imgDatabase = [[ImageDatabase alloc] initWithFileName:@"imagecache.db"];

      workQueue = [[NSOperationQueue alloc] init];
      [workQueue setMaxConcurrentOperationCount:1];
      
      
      // If this wasn't a singelton, in dealloc we would need [nc removeObserver:self];
      NSNotificationCenter  *nc = [NSNotificationCenter defaultCenter];
      [nc addObserver:self
             selector:@selector(clearCache:)
                 name:UIApplicationDidReceiveMemoryWarningNotification
               object:nil];
      
      // We are singelton, so we never die. In order to close the database,
      // we need to register for the termination !!! See Patt-155
      
      [nc addObserver:self
             selector:@selector(closeDatabase:)
                 name:UIApplicationWillTerminateNotification
               object:nil];
   }
   
   return (self);
}

- (void)cancelAllCachingOperations
{
   [workQueue cancelAllOperations];
   [inOpKeys removeAllObjects];
   
   cashingOperationsCnt = 0;
}

- (BOOL)operationsInProgress
{
   return (cashingOperationsCnt ? YES : NO);
}

- (void)clearCache:(NSNotification *)aNote  // flush it
{
   // NO! NO! NO!
   // remove only objects that are not in inOpKeys and do not cancel all operations
   if (!cashingOperationsCnt)  {
      [self cancelAllCachingOperations];
      NSLog (@"Flushing %d images out of cache.", [imageDictionary count]);
      
      [imageDictionary removeAllObjects];
      //- [smallDictionary removeAllObjects];
      
      [dicKeys removeAllObjects];
      [inOpKeys removeAllObjects];
   }
   else  {
      if ([dicKeys count] > [inOpKeys count])  {
         NSMutableArray  *tmpArray = [[NSMutableArray alloc] init];
         for (NSString  *key in dicKeys)  {
            if (![inOpKeys containsObject:key])
               [tmpArray addObject:key];
         }
         for (NSString  *key in tmpArray)  {
            [dicKeys removeObject:key];
            [imageDictionary removeObjectForKey:key];
         }
         [tmpArray release];
      }
      [self performSelector:@selector(clearCache:) withObject:nil afterDelay:1.];
   }
}

- (void)closeDatabase:(NSNotification *)aNote
{
   [self cancelAllCachingOperations];
   NSLog (@"Closing database because of received notification.");
   
   self.imgDatabase = nil;
}

#pragma mark -

// this is not really setting this image to the cache, just creating (in nsoperation) an image that would be set

- (void)     setImage:(UIImage *)img
               forKey:(NSString *)key
  dependencyOperation:(NSOperation *)depOperation
andSmallImageDelegate:(id<NSObject, SmallImageCreationDelegate>)siDelegate;
{
   [self.dicKeys addObject:key];

   // first, we're create small version and put it into database at the end of NSOperation
   
   [self cacheSmallImageForKey:key
                         image:img
            asOperationOnQueue:self.workQueue
                withDependancy:depOperation
            smallImageDelegate:siDelegate];
   
   // Remove extra images
   
   if ([dicKeys count] > kMaxImagesInCache)  {
      NSString  *tmpKey = [dicKeys objectAtIndex:0];  // oldest key
      if (![tmpKey isEqualToString:key])  {
         [self.imageDictionary removeObjectForKey:tmpKey];
         //+ [self.smallDictionary removeObjectForKey:tmpKey];
      }
      else
         NSLog (@"Internal error: dicKeys does not have expected value!");
   }
}

- (UIImage *)imageForKey:(NSString *)key
{
   UIImage  *retImage = [self.imageDictionary objectForKey:key];
   
   if (!retImage)  {
      NSString  *imgFilePath = id_PathInDocumentDirectory (key);
      
      retImage = [imgDatabase imageWithName:key];
#ifdef _INTO_SEPARATE_FILE_
      if (!retImage)
         retImage = [UIImage imageWithContentsOfFile:imgFilePath];
#endif

      if (retImage)
         [self.imageDictionary setObject:retImage forKey:key];
      else
         NSLog (@"Error: unable to find %@", imgFilePath);
   }
   
   return (retImage);
}

- (void)deleteImageForKey:(NSString *)key
{
   [self.imageDictionary removeObjectForKey:key];
   //- [self.smallDictionary removeObjectForKey:key];
   
#ifdef _INTO_SEPARATE_FILE_
   NSString  *imgFilePath = id_PathInDocumentDirectory (key);
   [[NSFileManager defaultManager] removeItemAtPath:imgFilePath error:nil];
#endif
   
   [imgDatabase deleteImageWithName:key];
}

#pragma mark -

- (NSOperation *)cacheSmallImageForKey:(NSString *)iKey
                                 image:(UIImage *)bigImage
                    asOperationOnQueue:(NSOperationQueue *)opQueue
                        withDependancy:(NSOperation *)dependancyOperation
                    smallImageDelegate:(id<NSObject, SmallImageCreationDelegate>)smallImgDelegate
{
#ifdef  _NSOPERATIONS_LOG_
   NSLog (@"cacheSmallImageForKey:%@", iKey);
#endif
   // Somehow use this:  if (![inOpKeys containsObject:iKey])

   SmallImageOperation  *siOp = [[SmallImageOperation alloc] initWithKey:iKey
                                                                   image:bigImage
                                                                  target:self
                                                            targetMethod:@selector(finishedCashingSmallImage:)
                                                      smallImageDelegate:smallImgDelegate];
   
   if (dependancyOperation)
      [siOp addDependency:dependancyOperation];
   
   cashingOperationsCnt++;
   
   [inOpKeys addObject:iKey];
   
   [opQueue addOperation:siOp];
   
   return ([siOp autorelease]);  // so it can be used as dependancy
}

- (NSOperation *)makeTileImageForKey:(NSString *)iKey
                               image:(UIImage *)bigImage
                            partRect:(CGRect)pRect
                            locIndex:(NSUInteger)idx
                      withDependancy:(NSOperation *)dependancyOperation
                   tileImageDelegate:(id<NSObject, TileImageCreationDelegate>)tileImgDelegate
//                  smallImageDelegate:(id<NSObject, SmallImageCreationDelegate>)smallImgDelegate
{
#ifdef  _NSOPERATIONS_LOG_
   NSLog (@"makeTileImageForKey:%@", iKey);
#endif   
   // Somehow use this:  if (![inOpKeys containsObject:iKey])
   
   TileImageOperation  *siOp = [[TileImageOperation alloc] initWithKey:iKey
                                                                 image:bigImage
                                                              partRect:pRect
                                                              locIndex:idx
                                                                target:self
                                                          targetMethod:@selector(finishedCashingTileImage:)
                                                     tileImageDelegate:tileImgDelegate
                                                    /*smallImageDelegate:smallImgDelegate*/];
   
   if (dependancyOperation)
      [siOp addDependency:dependancyOperation];
   
   cashingOperationsCnt++;
   
   // [inOpKeys addObject:iKey];   no need for this
   
   [self.workQueue addOperation:siOp];
   
   return ([siOp autorelease]);  // so it can be used as dependancy
}

#pragma mark -

- (void)finishedCashingSmallImage:(NSString *)iKey
{
#ifdef  _NSOPERATIONS_LOG_
   NSLog (@"finishedCashingSmallImage: %d, inOpKeys count: %d", cashingOperationsCnt, [inOpKeys count]);
#endif
   [inOpKeys removeObject:iKey];
   cashingOperationsCnt--;
}

- (void)finishedCashingTileImage:(NSString *)iKey
{
#ifdef  _NSOPERATIONS_LOG_
   NSLog (@"finishedCashingTileImage: %d", cashingOperationsCnt);
#endif
   // [inOpKeys removeObject:iKey];  no op
   cashingOperationsCnt--;
}

#pragma mark -

+ (NSString *)uuidForNewImage
{
   NSString    *retStr;
   CFUUIDRef    newUniqueID    = CFUUIDCreate (kCFAllocatorDefault);
   CFStringRef  newUniqueIDStr = CFUUIDCreateString (kCFAllocatorDefault, newUniqueID);
   
   retStr = [(NSString *)newUniqueIDStr retain];  // maybe copy
   
   CFRelease (newUniqueID);
   CFRelease (newUniqueIDStr);
   
   return ([retStr autorelease]);
}

@end

// ---------------------------------------------------------------------
#pragma mark -
#pragma mark SmallImageOperation
#pragma mark -
// ---------------------------------------------------------------------



 
@implementation SmallImageOperation

@synthesize  opKey, opBigImage, opResultImage, opThumbImage, smallImgDelegate;


-  (id)initWithKey:(NSString *)key
             image:(UIImage *)bigImage
            target:(id)tarObject
      targetMethod:(SEL)tarMethod
smallImageDelegate:(id<NSObject, SmallImageCreationDelegate>)smlImgDelegate
{
   if (self = [super init])  {
		self.opKey = key;
      self.opBigImage = bigImage;
      self.opResultImage = nil;

		targetObject  = tarObject;
		targetMethod  = tarMethod;
      
      self.smallImgDelegate = smlImgDelegate;
   }
   
   return (self);
}

- (void)dealloc
{
   [opKey release];
   [opBigImage release];
   [opResultImage release];
   [opThumbImage release];
   
   [super dealloc];
}

#pragma mark -

- (void)performCallback
{
#ifdef  _NSOPERATIONS_LOG_
   NSLog (@"performCallback:%@", self.opKey);
#endif
   
   // [[ImageCache sharedImageCache] setSmallImage:self.opResultImage forKey:self.opKey];  // synchronized
   [[ImageCache sharedImageCache].imageDictionary setObject:self.opResultImage forKey:self.opKey];

   // internal delegate
   
   if (targetObject && targetMethod)
      if (![self isCancelled])
         [targetObject performSelector:targetMethod
                            withObject:self.opKey];
      else
         NSLog (@"But we're canceled! *****************1");

   // small image delegate

   if (smallImgDelegate && self.opResultImage)  {
#ifdef  _NSOPERATIONS_LOG_
      NSLog (@"We have smallImgDelegate && self.opResultImage!");
#endif
      if (![self isCancelled])
         [smallImgDelegate imageCacheDidFinishCreatingSmallImage:self.opResultImage
                                                       thumbnail:self.opThumbImage
                                                          forKey:self.opKey];
      else
         NSLog (@"But we're canceled! *****************2");
   }

   ImageDatabase  *tmpImgDatabase = [ImageCache sharedImageCache].imgDatabase;
   
   [tmpImgDatabase addImage:self.opResultImage
                   withName:self.opKey
         asOperationOnQueue:[ImageCache sharedImageCache].workQueue];
}

- (void)main
{
   NSAutoreleasePool  *localPool;
   
   @try  {
      localPool = [[NSAutoreleasePool alloc] init];
      
      if ([self isCancelled])  {
         NSLog (@"But we're canceled! *****************3");
         return;
      }
#ifdef  _NSOPERATIONS_LOG_
      NSLog (@"Doing Big Image:%@", self.opKey);
#endif
      if (self.opBigImage)  {
         self.opResultImage = [ImageAlbum image:self.opBigImage fitInSize:CGSizeMake(480.f, 480.f)];
         self.opThumbImage = [ImageAlbum image:self.opResultImage fitInSize:CGSizeMake(64.f, 64.f)];
      }
      else
         NSLog (@"Error: unable to find big image!");
      
#ifdef  _NSOPERATIONS_LOG_
      NSLog (@"Did Big Image:%@", self.opKey);
#endif
      // [[ImageCache sharedImageCache] cacheSmallImageForKey:self.opKey];
      
      if (![self isCancelled])
         [self performSelectorOnMainThread:@selector(performCallback)
                                withObject:nil
                             waitUntilDone:YES];
       else
          NSLog (@"But we're canceled! *****************4");
   }
   @catch (NSException *e)  {
      NSLog (@"Exception: %@", [e reason]);
   }
   @finally {
      [localPool release];
   }
}


@end

// ---------------------------------------------------------------------
#pragma mark -
#pragma mark TileImageOperation
#pragma mark -
// ---------------------------------------------------------------------



@implementation TileImageOperation

@synthesize  opKey, locIndex, opPartRect, opBigImage, opResultImage, tileImgDelegate /*, smallImgDelegate*/;


-  (id)initWithKey:(NSString *)key
             image:(UIImage *)bigImage
              partRect:(CGRect)pRect
          locIndex:(NSUInteger)idx
            target:(id)tarObject
      targetMethod:(SEL)tarMethod
 tileImageDelegate:(id<NSObject, TileImageCreationDelegate>)tImgDelegate
// smallImageDelegate:(id<NSObject, SmallImageCreationDelegate>)smlImgDelegate
{
   if (self = [super init])  {
		self.opKey = key;
      self.locIndex = idx;
      self.opPartRect = pRect;
      self.opBigImage = bigImage;
      self.opResultImage = nil;
      
		targetObject  = tarObject;
		targetMethod  = tarMethod;
      
      self.tileImgDelegate = tImgDelegate;
//       self.smallImgDelegate = smlImgDelegate;
   }
   
   return (self);
}

- (void)dealloc
{
   [opKey release];
   [opBigImage release];
   [opResultImage release];
   
   [super dealloc];
}

#pragma mark -

- (void)performCallback
{
#ifdef  _NSOPERATIONS_LOG_
   NSLog (@"performCallback:%@", self.opKey);
#endif   
   // internal delegate
   
   if (targetObject && targetMethod)
      if (![self isCancelled])
         [targetObject performSelector:targetMethod
                            withObject:self.opKey];
      else
         NSLog (@"But we're canceled! *****************5");
   
   // small image delegate
   
   if (tileImgDelegate && self.opResultImage)  {
#ifdef  _NSOPERATIONS_LOG_
      NSLog (@"We have tileImgDelegate && self.opResultImage!");
#endif
      if (![self isCancelled])
         [tileImgDelegate imageCacheDidFinishCreatingTileImage:self.opResultImage
                                                        forKey:self.opKey
                                              withTileLocIndex:self.locIndex];
      else
         NSLog (@"But we're canceled! *****************6");
   }
}

- (void)main
{
   NSAutoreleasePool  *localPool;
   
   @try  {
      localPool = [[NSAutoreleasePool alloc] init];
      
      if ([self isCancelled])  {
         NSLog (@"But we're canceled! *****************7");
         return;
      }
      
#ifdef  _NSOPERATIONS_LOG_
      NSLog (@"Doing Big Image:%@", self.opKey);
#endif      
      if (self.opBigImage)  {
         self.opResultImage = [ImageAlbum image:self.opBigImage partialRect:self.opPartRect resizeTo:CGSizeMake(480.f, 480.f) rotate:YES];
      }
      else
         NSLog (@"Error: unable to find big image!");
      
#ifdef  _NSOPERATIONS_LOG_
      NSLog (@"Did Big Image:%@", self.opKey);
#endif
      
      if (![self isCancelled])
         [self performSelectorOnMainThread:@selector(performCallback)
                                withObject:nil
                             waitUntilDone:YES];
      else
         NSLog (@"But we're canceled! *****************8");
   }
   @catch (NSException *e)  {
      NSLog (@"Exception: %@", [e reason]);
   }
   @finally {
      [localPool release];
   }
}

@end
