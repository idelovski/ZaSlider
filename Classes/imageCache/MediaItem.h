//
//  MediaItem.h
//  TimeFoto
//
//  Created by Igor Delovski on 01.05.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class  EnvConditions;

#define  kMediaTypeKey      @"media"
#define  kImageNameKey      @"name"
#define  kImageKeyKey       @"key"
#define  kImageDescKey      @"desc"
#define  kImageDataKey      @"image"
#define  kImageThumbKey     @"thumb"
#define  kImageDateKey      @"date"
#define  kEnvCondKey        @"cond"


typedef enum  _medType  {

   kMediaTypeImage = 0

} MediaType;

@interface MediaItem : NSObject <NSCoding>  {
   MediaType        mediaType;
   NSString        *imgName;
   NSString        *imgKey;
   NSString        *imgSource;    // Where it came from
   UIImage         *smallImage;
   UIImage         *imgThumb;
   NSDate          *creationDate;
   
   EnvConditions   *imgEnvConditions;
}

@property (nonatomic, assign)           MediaType        mediaType;
@property (nonatomic, retain)           NSString        *imgName;
@property (nonatomic, retain)           NSString        *imgKey;
@property (nonatomic, retain)           NSString        *imgSource;
@property (nonatomic, retain)           UIImage         *smallImage;
@property (nonatomic, retain)           UIImage         *imgThumb;       // setter manualy
@property (nonatomic, retain)           NSDate          *creationDate;

@property (nonatomic, retain)           EnvConditions   *imgEnvConditions;

- (id)initWithScreenImage:(UIImage *)anImage
               thumbImage:(UIImage *)aThumb
                imageName:(NSString *)aName
              imageSource:(NSString *)aSource
                 imageKey:(NSString *)aKey
         andEnvConditions:(EnvConditions *)eCond;
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)coder;

//- - (UIImage *)smallImageEvenIfExpensive;

@end

#pragma mark -
#pragma mark NSCoding category for UIImage
#pragma mark -

@interface  UIImage (NSCoding)                   // add NSCoding protocol methods to UIImage
- (id)initWithCoder:(NSCoder *)decoder;         // create slideshow from archive
- (void)encodeWithCoder:(NSCoder *)encoder;     // archive slideshow

@end

#pragma mark -
#pragma mark NSCoding category for UIImage
#pragma mark -

@interface  UIColor (HexColors)                 // add hexColors methods to UIImage

// UIColor *newColor = [UIColor colorWithHex:0x336699];

+ (UIColor *)colorWithHex:(UInt32)col;
+ (UIColor *)colorWithHex:(UInt32)col alpha:(UInt32)zeroTo100;

@end

