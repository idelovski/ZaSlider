//
//  MediaItem.m
//  TimeFoto
//
//  Created by Igor Delovski on 01.05.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import "MediaItem.h"
#import "ImageCache.h"


@implementation MediaItem

@synthesize   mediaType;
@synthesize   imgName, imgKey, imgSource, smallImage, imgThumb;
@synthesize   creationDate, imgEnvConditions;

- (id)initWithScreenImage:(UIImage *)anImage  // may be nil
               thumbImage:(UIImage *)aThumb
                imageName:(NSString *)aName
              imageSource:(NSString *)aSource
                 imageKey:(NSString *)aKey   // key used in database
         andEnvConditions:(EnvConditions *)eCond
{
   if (self = [super init])  {
      if ((NSNull *)anImage == [NSNull null])
         self.smallImage = nil;
      else
         self.smallImage = anImage;
      self.imgThumb = aThumb;
      self.imgName  = aName;
      self.imgKey   = aKey;
      self.imgEnvConditions = eCond;
      
      self.creationDate  = [NSDate date];
      
      self.mediaType = kMediaTypeImage;
      self.imgSource = aSource;
   }
   
   return (self);
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
   if (self = [super init])  {
      self.mediaType = [decoder decodeIntForKey:kMediaTypeKey];
      
      self.imgName        = [decoder decodeObjectForKey:kImageNameKey];
      self.imgKey         = [decoder decodeObjectForKey:kImageKeyKey];
      self.imgSource = [decoder decodeObjectForKey:kImageDescKey];
      self.creationDate   = [decoder decodeObjectForKey:kImageDateKey];
      
      // self.smallImage = [decoder decodeObjectForKey:kImageDataKey]; not any more!
      self.imgThumb = [decoder decodeObjectForKey:kImageThumbKey];

      self.imgEnvConditions = [decoder decodeObjectForKey:kEnvCondKey];
   }
   
   return (self);
}

- (void)encodeWithCoder:(NSCoder *)coder
{
   [coder encodeInt:self.mediaType forKey:kMediaTypeKey];
   
   [coder encodeObject:self.imgName forKey:kImageNameKey];
   [coder encodeObject:self.imgKey forKey:kImageKeyKey];
   [coder encodeObject:self.imgSource forKey:kImageDescKey];
   [coder encodeObject:self.creationDate forKey:kImageDateKey];

   // [coder encodeObject:self.smallImage forKey:kImageDataKey];
   [coder encodeObject:self.imgThumb forKey:kImageThumbKey];

   [coder encodeObject:self.imgEnvConditions forKey:kEnvCondKey];
}

- (void)dealloc
{
   [imgName release];
   [imgKey release];
   [imgSource release];
   [smallImage release];
   [imgThumb release];
   [creationDate release];

   [super dealloc];
}

/*
#pragma mark -

- (UIImage *)smallImageEvenIfExpensive
{
   NSLog (@"smallImageEvenIfExpensive");

   if (!self.smallImage)  {
      if ([ImageCache sharedImageCache].cashingOperationsCnt)
         NSLog (@"smallImageEvenIfExpensive - cashingOperationsCnt: %d", [ImageCache sharedImageCache].cashingOperationsCnt);
      self.smallImage = [[ImageCache sharedImageCache] smallImageForKey:self.imgKey];
   }
   return (self.smallImage);
}
*/
@end

#pragma mark -
#pragma mark NSCoding category for UIImage
#pragma mark -


@implementation UIImage (NSCoding)

- (id)initWithCoder:(NSCoder *)decoder
{
   // Old version
   // if (self = [super init])  {
   //    NSData  *data = [decoder decodeObjectForKey:@"UIImage"];
   // 
   //    self = [self initWithData:data]; // initialize the UIImage with data
   // }
   
   NSData  *data = [decoder decodeObjectForKey:@"UIImage"];
      
   self = [self initWithData:data]; // initialize the UIImage with data
   
   return (self);
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
   NSData *data = UIImagePNGRepresentation (self);    // get the PNG representation of the UIImage

   [encoder encodeObject:data forKey:@"UIImage"];
}

@end

#pragma mark -
#pragma mark HexColors category for UIColor
#pragma mark -


@implementation  UIColor (HexColors)

// UIColor *newColor = [UIColor colorWithHex:0x336699];

+ (UIColor *)colorWithHex:(UInt32)col
{
   return ([self colorWithHex:col alpha:1]);
} 

+ (UIColor *)colorWithHex:(UInt32)col alpha:(UInt32)zeroTo100
{ 
   unsigned char  r, g, b;
   
   b = col & 0xFF;
   g = (col >> 8) & 0xFF;
   r = (col >> 16) & 0xFF;
   
   return ([UIColor colorWithRed:(CGFloat)r/255.f green:(CGFloat)g/255.0f blue:(CGFloat)b/255.f alpha:(CGFloat)zeroTo100/100.f]);
} 

@end
