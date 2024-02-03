//
//  ImageAlbum.m
//  TimeFoto
//
//  Created by Igor Delovski on 09.04.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ImageAlbum.h"
#import "ImageCache.h"

#import "GameController.h"
#import "GradView.h"

static void  id_addRoundedRectToPath (CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight);

@implementation ImageAlbum

@synthesize  albumName, albumMediaItems;
@synthesize  dirtyFlag;
@synthesize  creationDate, modificationDate, albumEnvConditions;

/*
@synthesize  imageArray;
@synthesize  thumbArray;
@synthesize  imageNames;
*/

- (id)initWithAlbumName:(NSString *)newAlbumName
{
   if (self = [super init])  {
      self.albumName =  newAlbumName;
      self.albumMediaItems = [[NSMutableArray alloc] init];

      self.creationDate = [NSDate date];
      self.modificationDate = self.creationDate;

      dirtyFlag = NO;
   }
   
   return (self);
}

- (id)initWithBuiltInAlbumName:(NSString *)newAlbumNameOrNil
{
   NSMutableArray  *tmpImages, *tmpThumbs;
   MediaItem       *tmpMediaItem;
   
   if (!newAlbumNameOrNil)
      newAlbumNameOrNil = @"Built-in Album";
   
   if (self = [self initWithAlbumName:newAlbumNameOrNil])  {
      tmpImages = [NSMutableArray arrayWithObjects:
                   [ImageAlbum internalImageForIndex:0],
                   [ImageAlbum internalImageForIndex:1],
                   [ImageAlbum internalImageForIndex:2],
                   [NSNull null]/*[ImageAlbum internalImageForIndex:3]*/,
                   [NSNull null]/*[ImageAlbum internalImageForIndex:4]*/,
                   [NSNull null]/*[ImageAlbum internalImageForIndex:5]*/,
                   [NSNull null]/*[ImageAlbum internalImageForIndex:6]*/,
                   [NSNull null]/*[ImageAlbum internalImageForIndex:7]*/,
                   [NSNull null]/*[ImageAlbum internalImageForIndex:6]*/,
                   [NSNull null]/*[ImageAlbum internalImageForIndex:7]*/,
                   nil];
      tmpThumbs = [NSMutableArray arrayWithObjects:
                   [UIImage imageNamed:@"Tbrrrr1Wi.png"],
                   [UIImage imageNamed:@"TImage229Wi.png"],
                   [UIImage imageNamed:@"T0001_clock1Wi.png"],
                   [UIImage imageNamed:@"TflowervWi.png"],
                   [UIImage imageNamed:@"Tglass5Wi.png"],
                   [UIImage imageNamed:@"TmachineWi.png"],
                   [UIImage imageNamed:@"TskyscraperWi.png"],
                   [UIImage imageNamed:@"TsljemeWinterWi.png"],
                   [UIImage imageNamed:@"TP1010010Wi.png"],
                   [UIImage imageNamed:@"TpianomanLWi.png"],
                   nil];

      for (int i=0; i < [tmpImages count]; i++)  {
         tmpMediaItem = [[MediaItem alloc] initWithScreenImage:[tmpImages objectAtIndex:i]
                                                    thumbImage:[tmpThumbs objectAtIndex:i]
                                                     imageName:[NSString stringWithFormat:@"%@ %d", self.albumName, i+1]
                                                   imageSource:kImageSourceBuiltInAlbum
                                                      imageKey:nil
                                              andEnvConditions:nil];
         [self.albumMediaItems addObject:tmpMediaItem];
         [tmpMediaItem release];
      }
   }
   
   return (self);
}

- (id)init
{
   return ([self initWithAlbumName:@"Untitled"]);
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
   if (self = [super init])  {
      self.albumName       = [decoder decodeObjectForKey:kAlbumNameKey];
      
      albumMediaItems = [[decoder decodeObjectForKey:kMediaItemsKey] mutableCopy];  // direct assignment!

      self.creationDate     = [decoder decodeObjectForKey:kCreationKey];
      self.modificationDate = [decoder decodeObjectForKey:kModificationKey];
      
      self.albumEnvConditions = [decoder decodeObjectForKey:kEnvCondKey];
}
   
   return (self);
}

- (void)encodeWithCoder:(NSCoder *)coder
{
   [coder encodeObject:self.albumName forKey:kAlbumNameKey];
   [coder encodeObject:self.albumMediaItems forKey:kMediaItemsKey];

   [coder encodeObject:self.creationDate forKey:kCreationKey];
   [coder encodeObject:self.modificationDate forKey:kModificationKey];

   [coder encodeObject:self.albumEnvConditions forKey:kEnvCondKey];
}

- (void)dealloc
{
   [albumName release];
   [albumMediaItems release];

   [creationDate release];
   [modificationDate release];

   [super dealloc];
}

#pragma mark -
#pragma mark Convenience shit

#ifdef _NIJE_
- (NSArray *)imageArray
{
   NSMutableArray  *retArray = [NSMutableArray arrayWithCapacity:[self.albumMediaItems count]];
   
   for (int i=0; i < [self.albumMediaItems count]; i++)  {
      MediaItem  *tmpMediaItem = [self.albumMediaItems objectAtIndex:i];
      if (tmpMediaItem.smallImage)
         [retArray addObject:tmpMediaItem.smallImage];
      else
         [retArray addObject:[NSNull null]];
   }
   
   return (retArray);
}
#endif

- (NSArray *)imageNames
{
   NSMutableArray  *retArray = [NSMutableArray arrayWithCapacity:[self.albumMediaItems count]];
   
   for (int i=0; i < [self.albumMediaItems count]; i++)  {
      MediaItem  *tmpMediaItem = [self.albumMediaItems objectAtIndex:i];
      [retArray addObject:tmpMediaItem.imgName];
   }
   
   return (retArray);
}

- (MediaItem *)mediaItemForKey:(NSString *)iKey returningIndex:(NSUInteger *)retIndex
{
   for (int i=0; i < [self.albumMediaItems count]; i++)  {
      MediaItem  *tmpMediaItem = [self.albumMediaItems objectAtIndex:i];
      if ([tmpMediaItem.imgKey isEqualToString:iKey])  {
         if (retIndex)
            *retIndex = i;
         return (tmpMediaItem);
      }
   }
   
   return (nil);
}

- (NSString *)imageKeyAtIndex:(NSUInteger)idx
{
   MediaItem  *tmpMediaItem = [self.albumMediaItems objectAtIndex:idx];
   
   return (tmpMediaItem.imgKey);
}

- (UIImage *)imageAtIndex:(NSUInteger)idx
{
   MediaItem  *tmpMediaItem = [self.albumMediaItems objectAtIndex:idx];
   
   if (tmpMediaItem.smallImage)
      return (tmpMediaItem.smallImage);
   else  if (!tmpMediaItem.imgKey)
      return (tmpMediaItem.smallImage = [ImageAlbum internalImageForIndex:idx]);

   return ([[ImageCache sharedImageCache] imageForKey:tmpMediaItem.imgKey]);
}

- (UIImage *)randomImageWithOtherAlbum:(ImageAlbum *)otherAlbumOrNil
                     returningImageKey:(NSString **)retImageKey       // if it has the key
                      orReturningIndex:(NSInteger *)retIndex         // otherwise return idx
                 andReturningMediaItem:(MediaItem **)retMediaItem      // may be nil
{
   NSUInteger  imgCount = [self.albumMediaItems count];
   NSUInteger  otherCount = 0;
   
   *retImageKey = nil;
   *retIndex = 0;
   if (retMediaItem)
      *retMediaItem = nil;
   
   if (otherAlbumOrNil)
      otherCount = [otherAlbumOrNil.albumMediaItems count];
   
   if (!imgCount && !otherCount)
      return (nil);
   
   NSUInteger  idx = arc4random() % (imgCount + otherCount);
   
   
   // REMOVE THIS SHIT!
   if (otherCount && idx < imgCount)  {
      idx = arc4random() % (imgCount + otherCount);
   }
   // REMOVE THIS SHIT!
   
   if (idx >= imgCount)  {
      *retImageKey = [otherAlbumOrNil imageKeyAtIndex:idx-imgCount];
      if (retMediaItem)
         *retMediaItem = [otherAlbumOrNil.albumMediaItems objectAtIndex:idx-imgCount];

      UIImage  *tmpImage = [otherAlbumOrNil imageAtIndex:idx-imgCount];
      
      if (retMediaItem && !(*retMediaItem).smallImage)
         (*retMediaItem).smallImage = tmpImage;
      
      return (tmpImage);
   }
   
   *retIndex = idx;
   if (retMediaItem)
      *retMediaItem = [self.albumMediaItems objectAtIndex:idx];
   
   return ([self imageAtIndex:idx]);
}

/*
- (UIImage *)smallImageAtIndex:(NSUInteger)idx evenIfExpensive:(BOOL)expFlag
{
   MediaItem  *tmpMediaItem = [self.albumMediaItems objectAtIndex:idx];
   
   if (tmpMediaItem.smallImage)
      return (tmpMediaItem.smallImage);
   
   if (expFlag)
      return (tmpMediaItem.smallImageEvenIfExpensive);

   return (nil);
}

- (void)needSmallImageAtIndex:(NSUInteger)idx delegate:(id<NSObject, SmallImageCreationDelegate>)siDelegate
{
   MediaItem  *tmpMediaItem = [self.albumMediaItems objectAtIndex:idx];
   
   [[ImageCache sharedImageCache] needSmallImageForKey:tmpMediaItem.imgKey andDelegate:siDelegate];
}
*/

#pragma mark -

// This shit adds image in the background in nsOp so we need another method when we already have small image

-      (void)addImage:(UIImage *)bigImage
           reusingKey:(NSString *)keyOrNil  // if nil, create new key
          imageSource:(NSString *)aSource
   withGameController:(GameController *)gameCtrl
    tileImageDelegate:(id<NSObject, TileImageCreationDelegate>)timageDelegate
andSmallImageDelegate:(id<NSObject, SmallImageCreationDelegate>)siDelegate
{
   dirtyFlag = YES;
   
   NSString *imgKey = keyOrNil ? keyOrNil : [ImageCache uuidForNewImage];
      
   NSString *tmpImageName  = [NSString stringWithFormat:@"%@ %d", self.albumName, [self.albumMediaItems count]+1];
   
   MediaItem *tmpMediaItem = [[MediaItem alloc] initWithScreenImage:nil // was tmpImage
                                                         thumbImage:nil // was tmpThumbImage
                                                          imageName:tmpImageName
                                                        imageSource:aSource
                                                           imageKey:imgKey
                                                   andEnvConditions:nil];  // Kill that
   [self.albumMediaItems addObject:tmpMediaItem];
   
   self.modificationDate = tmpMediaItem.creationDate;
   
   // self.albumEnvConditions = eCond;
   
   [tmpMediaItem release];
   
   NSOperation  *depOperation = [gameCtrl prepareTileImagesWithImage:bigImage
                                                           mediaItem:tmpMediaItem
                                                            delegate:timageDelegate];
   
   // Finally, produce screen size image

   [[ImageCache sharedImageCache] setImage:bigImage
                                    forKey:imgKey
                       dependencyOperation:depOperation
                     andSmallImageDelegate:siDelegate];
}

- (void)changeImageWithMediaItem:(MediaItem *)theMediaItem
              withGameController:(GameController *)gameCtrl
               tileImageDelegate:(id<NSObject, TileImageCreationDelegate>)timageDelegate
{
   UIImage  *tmpImage = theMediaItem.smallImage;
   
   if (!tmpImage)  {
      NSLog (@"No image!");
      return;
   }
   
   /*NSOperation  *depOperation =*/ [gameCtrl prepareTileImagesWithImage:tmpImage
                                                               mediaItem:theMediaItem
                                                                delegate:timageDelegate];
   
}

- (void)deleteImageForKey:(NSString *)anImageKey
{
   MediaItem  *itemToRemove = nil;
   
   for (MediaItem *tmpMediaItem in self.albumMediaItems)  {
      if (!itemToRemove && [tmpMediaItem.imgKey isEqualToString:anImageKey])
         itemToRemove = tmpMediaItem;
   }
   
   if (itemToRemove)  {
      dirtyFlag = YES;
      [[ImageCache sharedImageCache] deleteImageForKey:anImageKey];
      [self.albumMediaItems removeObject:itemToRemove];
   
      self.modificationDate = [NSDate date];
   }   
}

- (void)deleteImageForName:(NSString *)anImageName
{
   MediaItem  *itemToRemove = nil;
   
   for (MediaItem *tmpMediaItem in self.albumMediaItems)  {
      if (!itemToRemove && [tmpMediaItem.imgName isEqualToString:anImageName])
         itemToRemove = tmpMediaItem;
   }
   
   if (itemToRemove)
      [self deleteImageForKey:itemToRemove.imgKey];
}

- (void)flushScreenSizedImages
{
   for (MediaItem *tmpMediaItem in self.albumMediaItems)  {
      if (tmpMediaItem.smallImage)
         tmpMediaItem.smallImage = nil;
   }
#ifdef _FREEMEM_
   NSLog (@"Built-in album flushed!");
#endif
}

#pragma mark -

+ (CGSize)fitSize:(CGSize)thisSize inSize: (CGSize)aSize
{
   CGFloat scale;
   CGSize  newsize = thisSize;
   
   if (newsize.height && (newsize.height > aSize.height))  {
      scale = aSize.height / newsize.height;
      newsize.width *= scale;
      newsize.height *= scale;
   }
   
   if (newsize.width && (newsize.width >= aSize.width))  {
      scale = aSize.width / newsize.width;
      newsize.width *= scale;
      newsize.height *= scale;
   }
   
   return (newsize);
}

// Centers the fit size in the frame
+ (CGRect)frameSize:(CGSize)thisSize inSize: (CGSize)aSize
{
	CGSize size = [ImageAlbum fitSize:thisSize inSize:aSize];
   
   // NSLog (@"Size [%.0f,%.0f] by fitSize:[%.0f,%.0f] inSize: [%.0f,%.0f]",
   //        size.width, size.height, thisSize.width, thisSize.height, aSize.width, aSize.height);

   
	float dWidth = aSize.width - size.width;
	float dHeight = aSize.height - size.height;
	
	return (CGRectMake (dWidth / 2.0f, dHeight / 2.0f, size.width, size.height));
}

// Proportionately resize, completely fit in view, no cropping
+ (UIImage *)image:(UIImage *)image fitInSize:(CGSize)viewSize
{
   CGRect  tmpRect = [ImageAlbum frameSize:image.size inSize:viewSize];

#ifdef _NIJE_
	UIGraphicsBeginImageContext (tmpRect.size);
   
   // NSLog (@"Rect [%.0f,%.0f,%.0f,%.0f] by frameSize:[%.0f,%.0f] inSize: [%.0f,%.0f]",
   //        tmpRect.origin.x, tmpRect.origin.y, tmpRect.size.width, tmpRect.size.height,
   //        image.size.width, image.size.height, viewSize.width, viewSize.height);

   tmpRect.origin.x = tmpRect.origin.y = 0.f;
   
	[image drawInRect:tmpRect];
   
   UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext ();
   UIGraphicsEndImageContext ();  
   
   return (newImage);  
#endif
   return ([ImageAlbum image:image resizeTo:tmpRect.size rotate:YES]);
}

+ (UIImage*)image:(UIImage *)srcImage resizeTo:(CGSize)newImgSize rotate:(BOOL)rotate
{
   return ([ImageAlbum image:srcImage partialRect:CGRectZero resizeTo:newImgSize rotate:rotate]);
}

// This version will rotate images with the Up rotation if we pass partRect;
// So it will rotate partial image for the tile, but not the whole image for the database

+ (UIImage*)image:(UIImage *)srcImage partialRect:(CGRect)partRect resizeTo:(CGSize)newImgSize rotate:(BOOL)rotate
{
   CGSize   imgSize = srcImage.size;
   BOOL     landscapeRotationFlag = NO;
   
   if (newImgSize.width == newImgSize.height)
      newImgSize = [ImageAlbum fitSize:imgSize inSize:newImgSize];

   if (!CGRectEqualToRect(partRect, CGRectZero))  {
      CGFloat  partRatioHor = partRect.size.width / imgSize.width;
      CGFloat  partRatioVer = partRect.size.height / imgSize.height;
      
      newImgSize.width *= partRatioHor;
      newImgSize.height *= partRatioVer;      
   }
   
   CGFloat  dstWidth  = newImgSize.width;
   CGFloat  dstHeight = newImgSize.height;
   CGFloat  srcWidth  = newImgSize.width;
   CGFloat  srcHeight = newImgSize.height;
   
   if (rotate)  {
      if (srcImage.imageOrientation == UIImageOrientationRight ||
          srcImage.imageOrientation == UIImageOrientationLeft)  {
         srcWidth = dstHeight;
         srcHeight = dstWidth;
      }
      else  if ((srcImage.imageOrientation == UIImageOrientationUp || srcImage.imageOrientation == UIImageOrientationDown) &&
                (srcWidth > srcHeight) && !CGRectEqualToRect(partRect, CGRectZero))  {
         srcWidth = dstHeight;
         srcHeight = dstWidth;
         landscapeRotationFlag = YES;
      }
   }
   
#ifdef _IMGSIZE_LOG_
   NSLog (@"imgSize: [%.0f,%.0f]", imgSize.width, imgSize.height);
   NSLog (@"partRect: [%.0f,%.0f][%.0f,%.0f]", partRect.origin.x, partRect.origin.y, partRect.size.width, partRect.size.height);
   NSLog (@"resizeTo: [%.0f,%.0f]", newImgSize.width, newImgSize.height);
#endif

   CGImageRef  srcImageRef = srcImage.CGImage;
   
   if (!CGRectEqualToRect(partRect, CGRectZero))
      srcImageRef = CGImageCreateWithImageInRect (srcImageRef, partRect);  // need to release it later
   
   // size_t  cgWidth  = CGImageGetWidth (srcImageRef);
   // size_t  cgHeight = CGImageGetHeight (srcImageRef);
   
   size_t  bytesPerRow = dstWidth * 4;
   // size_t  bytesPerRow = cgWidth * 4;
   
   bytesPerRow = ((bytesPerRow + (kCGBestByteAlignment-1)) & ~(kCGBestByteAlignment-1));  // Just leave it in two lines
   
	CGBitmapInfo     bitmapInfo   = CGImageGetBitmapInfo (srcImageRef);
   CGColorSpaceRef  colorSpace = CGImageGetColorSpace (srcImageRef);
   
   size_t       bitsPerComponent = CGImageGetBitsPerComponent (srcImageRef);
   size_t       bitsPerPixel = CGImageGetBitsPerPixel (srcImageRef);
   
	if (bitsPerPixel != 8)  {
      if ((bitmapInfo == kCGImageAlphaLast) ||
          (bitmapInfo == kCGImageAlphaFirst) ||
          (CGImageGetAlphaInfo(srcImageRef) == kCGImageAlphaNone))  {
   		bitmapInfo &= ~kCGBitmapAlphaInfoMask;
		   bitmapInfo |= kCGImageAlphaNoneSkipLast;
      }
	}
   
   CGContextRef bitmapCtx = CGBitmapContextCreate (NULL, dstWidth, dstHeight,
                                                   bitsPerComponent, bytesPerRow /*0 or 4*dstWidth*/,
                                                   colorSpace,
                                                   bitmapInfo);
   
   if (rotate)  {
      if ((srcImage.imageOrientation == UIImageOrientationLeft) ||
          (srcImage.imageOrientation == UIImageOrientationDown && landscapeRotationFlag))  {
         CGContextTranslateCTM (bitmapCtx, srcHeight, 0);
         CGContextRotateCTM (bitmapCtx, 90 * (M_PI/180));
      }
      else if ((srcImage.imageOrientation == UIImageOrientationRight)  ||
               (srcImage.imageOrientation == UIImageOrientationUp && landscapeRotationFlag))  {
         CGContextTranslateCTM (bitmapCtx, 0, srcWidth);
         CGContextRotateCTM (bitmapCtx, -90 * (M_PI/180));
      }
      else if (srcImage.imageOrientation == UIImageOrientationDown)  {
         CGContextTranslateCTM (bitmapCtx, srcWidth, srcHeight);
         CGContextRotateCTM (bitmapCtx, 180 * (M_PI/180));
      }
      else if (srcImage.imageOrientation != UIImageOrientationUp)
         NSLog (@"Oh, one of those mirrored images!");
   }
   
   CGContextDrawImage (bitmapCtx, CGRectMake(0, 0, srcWidth, srcHeight), srcImageRef);
   
   CGImageRef  imgRef = CGBitmapContextCreateImage (bitmapCtx);
   UIImage    *resImage = [UIImage imageWithCGImage:imgRef];
   
   CGContextRelease (bitmapCtx);
   CGImageRelease (imgRef);
   
   if (!CGRectEqualToRect (partRect, CGRectZero))
      CGImageRelease (srcImageRef);
   
   return (resImage);
}

#pragma mark -

- (void)saveToPath:(NSString *)basePath
{
   BOOL  okFlag = NO;
   
   if (dirtyFlag)  {
      dirtyFlag = NO;
   
      NSString  *tmpStr = [NSString stringWithFormat:@"%@_%@", self.albumName, kFileSuffixAndExtension];
      NSString  *fullPath = [basePath stringByAppendingPathComponent:tmpStr];
   
      okFlag = [NSKeyedArchiver archiveRootObject:self toFile:fullPath];
   }
}

+ (ImageAlbum *)loadFromPath:(NSString *)basePath andAlbumName:(NSString *)aName
{
   ImageAlbum  *newAlbum;
   
#ifdef _FILES_LOG_
   NSLog (@"%s - loadFromPath: %@", __FILE__, basePath);
#endif
   
   NSString  *tmpStr = [NSString stringWithFormat:@"%@_%@", aName, kFileSuffixAndExtension];
   NSString  *fullPath = [basePath stringByAppendingPathComponent:tmpStr];
      
   newAlbum = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
   
   if ([newAlbum.albumMediaItems count] > kMaxItemsInImageAlbum)  {
      [newAlbum.albumMediaItems removeObjectAtIndex:0];
      newAlbum.dirtyFlag = YES;
   }

   return (newAlbum);
}

#pragma mark -

+ (UIImage *)roundCornersOfImage:(UIImage *)source  // or -imageWithRoundCornersFromImage:
{
   int  w = source.size.width;
   int  h = source.size.height;
   
   CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB ();
   CGContextRef context = CGBitmapContextCreate (NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
   
   CGContextBeginPath (context);
   CGRect rect = CGRectMake (0, 0, w, h);
   id_addRoundedRectToPath (context, rect, 8, 8);
   CGContextClosePath (context);
   CGContextClip (context);
   
   CGContextDrawImage (context, CGRectMake(0, 0, w, h), source.CGImage);
   
   CGImageRef imageMasked = CGBitmapContextCreateImage (context);
   CGContextRelease (context);
   CGColorSpaceRelease (colorSpace);
   
   UIImage  *retImage = [UIImage imageWithCGImage:imageMasked];
   
   CGImageRelease (imageMasked);
   
   return (retImage);    
}

// Public methods used by other classes

#pragma mark Generic Image Cell

+ (UITableViewCell *)genericCellWithCellIdentifier:(NSString *)cellIdentifier needsActivityIndicator:(BOOL)actFlag
{
   UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
   
   UACellBackgroundView  *backView = [[UACellBackgroundView alloc] initWithFrame:CGRectZero];
   backView.position = UACellBackgroundViewPositionMiddle;
   cell.backgroundView = backView;
   
   [backView release];
      
   for (UIView *view in cell.contentView.subviews)
      [view removeFromSuperview];

   CGRect           tmpRect;
   
   tmpRect = cell.frame;  tmpRect.size.height = kThumbImageHeight;
   
   UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kThumbImageHeight, tmpRect.size.height)];
   picView.tag = kImageFieldTag;
   picView.contentMode = UIViewContentModeScaleAspectFit;
   // picView.backgroundColor = [UIColor blackColor];
   // picView.backgroundColor = [UIColor colorWithRed:.96f green:.34f blue:0.f alpha:.1f];  -  original bež
   picView.backgroundColor = [UIColor colorWithRed:.66f
                                             green:.54f
                                              blue:.46f
                                             alpha:.25f];
   // picView.contentMode = UIViewContentModeCenter;
   [cell.contentView addSubview:picView];

   if (actFlag)  {
      UIActivityIndicatorView  *actIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
      actIndicatorView.tag = kActivFieldTag;
      actIndicatorView.backgroundColor = [UIColor clearColor];
      actIndicatorView.hidden = YES;
      actIndicatorView.center = picView.center;
      [cell.contentView addSubview:actIndicatorView];
      [actIndicatorView release];
   }

   [picView release];  // its frame is used for actIndicatorView's frame
   
   CGRect   fldRect = CGRectMake(kThumbImageWidth+24, kDescFiledHeight-2, tmpRect.size.width-kThumbImageWidth-2, kNameFiledHeight);
   UILabel *nameLabel = [[UILabel alloc] initWithFrame:fldRect];
   nameLabel.tag = kNameFieldTag;
   nameLabel.font = [UIFont boldSystemFontOfSize:20];
   nameLabel.backgroundColor = [UIColor clearColor];
   // nameLabel.textColor = [UIColor colorWithRed:.56f
   //                                       green:.29f
   //                                        blue:.2f
   //                                       alpha:1.f];
   nameLabel.textColor = [UIColor colorWithRed:.32f
                                         green:.19f
                                          blue:.15f
                                         alpha:1.f];
   [cell.contentView addSubview:nameLabel];
   [nameLabel release];

   fldRect = CGRectMake(kThumbImageWidth+24, 4.f, tmpRect.size.width-kThumbImageWidth-2, kDescFiledHeight);

   UILabel *descLabel = [[UILabel alloc] initWithFrame:fldRect];
   descLabel.tag = kUpDescFieldTag;
   descLabel.font = [UIFont systemFontOfSize:12];
   descLabel.backgroundColor = [UIColor clearColor];
   descLabel.textColor = [UIColor colorWithRed:.32f
                                         green:.18f
                                          blue:.09f
                                         alpha:1.f];
   [cell.contentView addSubview:descLabel];
   [descLabel release];
   
   fldRect = CGRectMake(kThumbImageWidth+24, kDescFiledHeight+kNameFiledHeight-8, tmpRect.size.width-kThumbImageWidth-2, kDescFiledHeight);

   descLabel = [[UILabel alloc] initWithFrame:fldRect];
   descLabel.tag = kDnDescFieldTag;
   descLabel.font = [UIFont systemFontOfSize:12];
   descLabel.backgroundColor = [UIColor clearColor];
   descLabel.textColor = [UIColor colorWithRed:.30f
                                         green:.16f
                                          blue:.08f
                                         alpha:1.f];
   [cell.contentView addSubview:descLabel];
   [descLabel release];
      
   return (cell);
}

+ (void)setupGenericTableViewCell:(UITableViewCell *)cell
                        withImage:(UIImage *)img
                         mainText:(NSString *)aText
                         topTitle:(NSString *)topTitle
                             date:(NSDate *)aDate
{
   // img may be nil, use activity in that case
   UIActivityIndicatorView  *actIndicatorView = (UIActivityIndicatorView *) [cell.contentView viewWithTag:kActivFieldTag];

   UIImageView  *tmpImageView = (UIImageView *) [cell.contentView viewWithTag:kImageFieldTag];
   if (img)  {
      tmpImageView.image = img;  // [self roundCornersOfImage:img];
      if (tmpImageView.hidden)
         tmpImageView.hidden = NO;
      if (actIndicatorView && !actIndicatorView.hidden)  {
         [actIndicatorView stopAnimating];
         actIndicatorView.hidden = YES;
      }
   }
   else  if (actIndicatorView)  {
      tmpImageView.hidden = YES;
      actIndicatorView.hidden = NO;
      [actIndicatorView startAnimating];
   }
   
   UILabel      *tmpLabel = (UILabel *) [cell.contentView viewWithTag:kNameFieldTag];
   tmpLabel.text = aText;
   
   tmpLabel = (UILabel *) [cell.contentView viewWithTag:kUpDescFieldTag];
   tmpLabel.text = topTitle;

   tmpLabel = (UILabel *) [cell.contentView viewWithTag:kDnDescFieldTag];
   if (aDate)  {
      NSDateFormatter  *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
      [dateFormatter setDateStyle:NSDateFormatterLongStyle];
      tmpLabel.text = [dateFormatter stringFromDate:aDate];
      [dateFormatter release];
   }
   else
      tmpLabel.text = @"Very nice pictures inside";

   cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark Built In Album

+ (UIImage *)internalImageForIndex:(NSUInteger)idx
{
   NSString  *useImageName = @"brrrr1Wi";
   
   switch (idx)  {
      case  1:  useImageName = @"Image229Wi";  break;
      case  2:  useImageName = @"0001_clock1Wi";  break;
      case  3:  useImageName = @"flowervWi";  break;
      case  4:  useImageName = @"glass5Wi";  break;
      case  5:  useImageName = @"machineWi";  break;
      case  6:  useImageName = @"skyscraperWi";  break;
      case  7:  useImageName = @"sljemeWinterWi";  break;
      case  8:  useImageName = @"P1010010Wi";  break;
      case  9:  useImageName = @"pianomanLWi";  break;
   }
   
   NSString  *filePath = [[NSBundle mainBundle] pathForResource:useImageName ofType:@"png"];
   UIImage   *retImage = [UIImage imageWithContentsOfFile:filePath];
   
   return (retImage);
}

@end

// see addRoundedRectToPath() in GradView.m

static void  id_addRoundedRectToPath (CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
   float fw, fh;
   if (ovalWidth == 0 || ovalHeight == 0) {
      CGContextAddRect(context, rect);
      return;
   }
   CGContextSaveGState(context);
   CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
   CGContextScaleCTM (context, ovalWidth, ovalHeight);
   fw = CGRectGetWidth (rect) / ovalWidth;
   fh = CGRectGetHeight (rect) / ovalHeight;
   CGContextMoveToPoint(context, fw, fh/2);
   CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
   CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
   CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
   CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
   CGContextClosePath(context);
   CGContextRestoreGState(context);
}

