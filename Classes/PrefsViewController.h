//
//  PrefsViewController.h
//  ZaSlider
//
//  Created by Igor Delovski on 22.09.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <UIKit/UIKit.h>

// @class  CustomUISwitch;

extern PreferenceRecord  gGPrefsRec;


@interface PrefsViewController : UIViewController  {
   UIImageView  *imageView;
   UIToolbar    *bottomToolBar;
   
   UISwitch  *accelSwitch;
   UISwitch  *numbersSwitch;
   UISwitch  *quickSettings;
   UISwitch  *storeNewImagesSwitch;
   
   UIButton            *elemsBtn01, *elemsBtn02, *elemsBtn03, *elemsBtn04;
   UIButton            *coopBtn01,  *coopBtn02;
   
   // UISegmentedControl  *elemsSegmetCtrl;
   // UISegmentedControl  *coopSegmetCtrl;
   NSInteger            elemsButtonIndex;  // instead of elemsSegmetCtrl
   NSInteger           coopButtonIndex;   // instead of coopSegmetCtrl
   // internal
   UIViewController    *mainViewController;
}

@property (nonatomic, retain)  IBOutlet  UIImageView  *imageView;
@property (nonatomic, retain)  IBOutlet  UIToolbar    *bottomToolBar;

@property (nonatomic, retain)  IBOutlet  UISwitch  *accelSwitch;
@property (nonatomic, retain)  IBOutlet  UISwitch  *numbersSwitch;
@property (nonatomic, retain)  IBOutlet  UISwitch  *quickSettings;
@property (nonatomic, retain)  IBOutlet  UISwitch  *storeNewImagesSwitch;

@property (nonatomic, retain)  IBOutlet  UIButton            *elemsBtn01, *elemsBtn02, *elemsBtn03, *elemsBtn04;
@property (nonatomic, retain)  IBOutlet  UIButton            *coopBtn01, *coopBtn02;

// @property (nonatomic, retain)  IBOutlet  UISegmentedControl  *elemsSegmetCtrl;
// @property (nonatomic, retain)  IBOutlet  UISegmentedControl  *coopSegmetCtrl;

@property (nonatomic, assign)            NSInteger           elemsButtonIndex;
@property (nonatomic, assign)            NSInteger           coopButtonIndex;

@property (nonatomic, retain)            UIViewController    *mainViewController;

- (id)initWithMainViewController:(UIViewController *)vc
                         nibName:(NSString *)nibNameOrNil
                          bundle:(NSBundle *)nibBundleOrNil;

- (IBAction)doneButtonAction:(id)sender;
- (IBAction)pressButtonAction:(id)sender;
- (IBAction)pressCoopButtonAction:(id)sender;

- (UIButton *)buttonForElemIndex:(NSInteger)idx;
- (NSInteger)elemIndexForButton:(UIButton *)btn;

- (UIButton *)buttonForCoopIndex:(NSInteger)idx;
- (NSInteger)coopIndexForButton:(UIButton *)btn;

// - (UIImage *)imageForButton:(UIButton *)btn forState:(UIControlState)state;
+ (void)swapImageForButton:(UIButton *)btn;

- (void)registerElemButtonPressed:(UIButton *)btn;
- (void)registerCoopButtonPressed:(UIButton *)btn;

@end
