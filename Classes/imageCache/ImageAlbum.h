//
//  ImageAlbum.h
//  TimeFoto
//
//  Created by Igor Delovski on 09.04.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/UTCoreTypes.h>  // for kUTTypeImage, etc
#import <CoreLocation/CoreLocation.h>

#import "MediaItem.h"
#import "ImageCache.h"


#define  kAlbumNameKey            @"name"
#define  kMediaItemsKey           @"images"
#define  kCreationKey             @"created"
#define  kModificationKey         @"modified"
#define  kEnvCondKey              @"cond"

#define  kFileSuffixAndExtension  @"PhotoAlbum.saved"

#define  kMaxItemsInImageAlbum    64

// --------------------------------------------------

@class  GameController;


@interface ImageAlbum : NSObject <NSCoding>  {
   NSString        *albumName;
   
   NSMutableArray  *albumMediaItems;  // of MediaItem

   BOOL             dirtyFlag;     // flag, needs saving
   NSDate          *creationDate;
   NSDate          *modificationDate;

   EnvConditions   *albumEnvConditions;
}

@property (nonatomic, retain)           NSString        *albumName;
@property (nonatomic, retain)           NSMutableArray  *albumMediaItems;
@property (nonatomic, assign)           BOOL             dirtyFlag;
@property (nonatomic, retain)           NSDate          *creationDate;
@property (nonatomic, retain)           NSDate          *modificationDate;

@property (nonatomic, retain)           EnvConditions   *albumEnvConditions;

/*
 @property (nonatomic, retain)           NSMutableArray  *imageArray;
@property (nonatomic, retain)           NSMutableArray  *thumbArray;
@property (nonatomic, retain)           NSMutableArray  *imageNames;
*/
- (id)initWithAlbumName:(NSString *)newAlbumName;
- (id)initWithBuiltInAlbumName:(NSString *)newAlbumName;
- (id)init;

- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)coder;

// - (NSArray *)imageArray;
- (NSArray *)imageNames;

- (MediaItem *)mediaItemForKey:(NSString *)iKey returningIndex:(NSUInteger *)retIndex;

- (NSString *)imageKeyAtIndex:(NSUInteger)idx;
- (UIImage *)imageAtIndex:(NSUInteger)idx;
- (UIImage *)randomImageWithOtherAlbum:(ImageAlbum *)otherAlbumOrNil
                     returningImageKey:(NSString **)retImageKey       // if it has the key
                      orReturningIndex:(NSInteger *)retIndex         // otherwise return idx
                 andReturningMediaItem:(MediaItem **)retMediaItem;

/*
- (UIImage *)smallImageAtIndex:(NSUInteger)idx evenIfExpensive:(BOOL)expFlag;
- (void)needSmallImageAtIndex:(NSUInteger)idx
                     delegate:(id<NSObject, SmallImageCreationDelegate>)siDelegate;
*/

-      (void)addImage:(UIImage *)bigImage
           reusingKey:(NSString *)keyOrNil  // if nil, create new key
          imageSource:(NSString *)aSource
   withGameController:(GameController *)gameCtrl
    tileImageDelegate:(id<NSObject, TileImageCreationDelegate>)timageDelegate
andSmallImageDelegate:(id<NSObject, SmallImageCreationDelegate>)siDelegate;

- (void)changeImageWithMediaItem:(MediaItem *)theMediaItem
              withGameController:(GameController *)gameCtrl
               tileImageDelegate:(id<NSObject, TileImageCreationDelegate>)timageDelegate;

- (void)deleteImageForKey:(NSString *)anImageKey;
- (void)deleteImageForName:(NSString *)anImageName;
- (void)flushScreenSizedImages;

// + (UIImage *)thumbForAlbumName:(NSString *)theAlbumName;

+ (CGSize)fitSize:(CGSize)thisSize inSize:(CGSize)aSize;
+ (CGRect)frameSize:(CGSize)thisSize inSize:(CGSize)aSize;
+ (UIImage *)image:(UIImage *)image fitInSize:(CGSize)viewSize;
+ (UIImage*)image:(UIImage *)srcImage resizeTo:(CGSize)newImgSize rotate:(BOOL)rotate;
+ (UIImage*)image:(UIImage *)srcImage partialRect:(CGRect)partRect resizeTo:(CGSize)newImgSize rotate:(BOOL)rotate;

- (void)saveToPath:(NSString *)basePath;
+ (ImageAlbum *)loadFromPath:(NSString *)basePath andAlbumName:(NSString *)anAlbumName;

+ (UITableViewCell *)genericCellWithCellIdentifier:(NSString *)cellIdentifier needsActivityIndicator:(BOOL)flag;
+ (void)setupGenericTableViewCell:(UITableViewCell *)cell
                        withImage:(UIImage *)img
                         mainText:(NSString *)aText
                         topTitle:(NSString *)topTitle
                             date:(NSDate *)aDate;

+ (UIImage *)internalImageForIndex:(NSUInteger)idx;

@end

// TableViewCell constants

#define  kImageFieldTag       1
#define  kUpDescFieldTag      2
#define  kNameFieldTag        3
#define  kDnDescFieldTag      4
#define  kActivFieldTag       5

#define  kNameFiledHeight     (68.f/2.f)
#define  kDescFiledHeight     (68.f/4.f)

#define  kThumbImageHeight    68.f
#define  kThumbImageWidth    kThumbImageHeight
