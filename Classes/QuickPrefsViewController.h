//
//  QuickPrefsViewController.h
//  ZaSlider
//
//  Created by Igor Delovski on 31.10.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  ZaSliderViewController, CustomUISwitch;


@interface QuickPrefsViewController : UIViewController {
   UIImageView             *backgroundImageView;

   UIImageView             *centerImageView;
   UIImageView             *prevImageView;
   UIImageView             *nextImageView;

   UIImageView             *accelLabelImageView;
   CustomUISwitch          *accelSwitch;
   UIImageView             *numbersLabelImageView;
   CustomUISwitch          *numbersSwitch;
   // UISwitch                *arrowSwitch;
   // UISegmentedControl      *elemsSegmetCtrl;
   UIButton                *elemsBtn01, *elemsBtn02, *elemsBtn03, *elemsBtn04;
   NSInteger                elemsButtonIndex;  // instead of elemsSegmetCtrl
   
   // UILabel                 *coopLabel;
   // UISegmentedControl      *coopSegmetCtrl;
   UIImageView             *coopLabelImageView;
   UIButton                *coopBtn01,  *coopBtn02;
   NSInteger                coopButtonIndex;
   
   UIButton                *playButton;
   UIButton                *cancelButton;

   // internal
   ZaSliderViewController  *mainViewController;
   UIImage                 *usedImage;            // in - start with it, out - take this
   NSString                *imageKey;
   NSInteger                builtInAlbumIndex;
   UIView                  *touchView;

   UIImageView             *aniCenterImageView;
   UIImageView             *aniPrevImageView;
   UIImageView             *aniNextImageView;

   CGPoint                  gestureStartPoint;
   BOOL                     inNetworkModeFlag;
}

@property (nonatomic, retain)  IBOutlet  UIImageView             *backgroundImageView;

@property (nonatomic, retain)  IBOutlet  UIImageView             *centerImageView;
@property (nonatomic, retain)  IBOutlet  UIImageView             *prevImageView;
@property (nonatomic, retain)  IBOutlet  UIImageView             *nextImageView;

@property (nonatomic, retain)  IBOutlet  UIImageView             *accelLabelImageView;
@property (nonatomic, retain)  IBOutlet  CustomUISwitch          *accelSwitch;
@property (nonatomic, retain)  IBOutlet  UIImageView             *numbersLabelImageView;
@property (nonatomic, retain)  IBOutlet  CustomUISwitch          *numbersSwitch;
// @property (nonatomic, retain)  IBOutlet  UISegmentedControl      *elemsSegmetCtrl;
@property (nonatomic, retain)  IBOutlet  UIButton                *elemsBtn01, *elemsBtn02, *elemsBtn03, *elemsBtn04;
@property (nonatomic, assign)            NSInteger           elemsButtonIndex;

// @property (nonatomic, retain)  IBOutlet  UILabel                 *coopLabel;
// @property (nonatomic, retain)  IBOutlet  UISegmentedControl      *coopSegmetCtrl;
@property (nonatomic, retain)  IBOutlet  UIImageView             *coopLabelImageView;
@property (nonatomic, retain)  IBOutlet  UIButton                *coopBtn01,  *coopBtn02;
@property (nonatomic, assign)            NSInteger                coopButtonIndex;

@property (nonatomic, retain)  IBOutlet  UIButton                *playButton;
@property (nonatomic, retain)  IBOutlet  UIButton                *cancelButton;

@property (nonatomic, retain)            ZaSliderViewController  *mainViewController;
@property (nonatomic, retain)            UIImage                 *usedImage;
@property (nonatomic, retain)            NSString                *imageKey;
@property                                NSInteger                builtInAlbumIndex;
@property (nonatomic, retain)            UIView                  *touchView;
@property                                CGPoint                  gestureStartPoint;

- (id)initWithMainViewController:(UIViewController *)vc
                        imageKey:(NSString *)imageKey
               builtInAlbumIndex:(NSUInteger)idx
                   inNetworkMode:(BOOL)inNetworkFlag
                         nibName:(NSString *)nibNameOrNil
                          bundle:(NSBundle *)nibBundleOrNil;

- (IBAction)pressElemButtonAction:(id)sender;
- (IBAction)pressCoopButtonAction:(id)sender;
- (IBAction)playButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;

- (void)offsetView:(UIView *)theView horizontally:(CGFloat)hor vertically:(CGFloat)ver;

- (UIButton *)buttonForElemIndex:(NSInteger)idx;
- (NSInteger)elemIndexForButton:(UIButton *)btn;

- (UIButton *)buttonForCoopIndex:(NSInteger)idx;
- (NSInteger)coopIndexForButton:(UIButton *)btn;

- (void)registerElemButtonPressed:(UIButton *)btn;
- (void)registerCoopButtonPressed:(UIButton *)btn;

- (void)loadSideImages;
- (void)slideToPrevImage;
- (void)slideToNextImage;

- (void)prepareGhostImageViews;
- (void)shiftGhostImageViewsWithDirectionSign:(NSInteger)dirSign;

@end
