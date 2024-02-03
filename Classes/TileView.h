//
//  TileView.h
//  ZaSlider
//
//  Created by Igor Delovski on 16.09.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ImageAlbum.h"
#import "GameController.h"
#import "FingerSphereView.h"

@interface TileView : UIView {
	CGSize             sizeInPixels;       // pixels
	int                locIndex;           // where it should be
	int                curLocIndex;        // where it is
	int                prevLocIndex;       // where it was
	int                sideElements;       // number of elements at each sides, dimension of matrix
   
   BOOL               finishedInit;       // so other methods know we did -init already
   
	TileType           tileType;
   
	UILabel           *indexLabel;
	// UILabel           *arrowLabel;
	UIImageView       *arrowView;
   UIImageView       *highliteView;
	UIImageView       *picView;
   FingerSphereView  *fingerView;
}

@property (nonatomic) CGSize    sizeInPixels;
@property (nonatomic) int       locIndex;      // manually created setter
@property (nonatomic) int       curLocIndex;
@property (nonatomic) int       prevLocIndex;
@property (nonatomic) int       sideElements;

@property (nonatomic) TileType  tileType;


@property (nonatomic, retain)  UILabel           *indexLabel;
// @property (nonatomic, retain)  UILabel           *arrowLabel;
@property (nonatomic, retain)  UIImageView       *arrowView;
@property (nonatomic, retain)  UIImageView       *highliteView;
@property (nonatomic, retain)  UIImageView       *picView;
@property (nonatomic, retain)  FingerSphereView  *fingerView;

- (id)initWithDestinationIndex:(int)aIndex
                 nowAtLocation:(int)aLocation
                  sideElements:(int)sideElems  // or dimension
                      withType:(TileType)aTileType
                gameController:(GameController *)gameController
                      andImage:(UIImage *)completeImage;

- (void)showArrow;
- (void)hideArrow;

- (void)drawShimInRect:(NSValue *)rectAsValue userInfo:(NSValue *)voidPtrAsValue;

@end
