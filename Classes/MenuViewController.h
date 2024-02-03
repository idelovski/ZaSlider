//
//  MenuViewController.h
//  ZaSlider
//
//  Created by Igor Mini on 27.12.2010..
//  Copyright 2010 Delovski d.o.o. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  ZaSliderViewController;

@interface MenuViewController : UIViewController {
	ZaSliderViewController   *mainViewController;
	
   UIImageView              *imageView;
   
   UIButton                 *startButton;      // all were GradientButton
   UIButton                 *historyButton;
   UIButton                 *prefsButton;
   UIButton                 *addPhotoButton;
   UIButton                 *netSearchButton;
   UIButton                 *helpButton;
}

@property (nonatomic, retain) IBOutlet ZaSliderViewController  *mainViewController;

@property (nonatomic, retain) IBOutlet UIImageView             *imageView;

@property (nonatomic, retain) IBOutlet UIButton                *startButton;
@property (nonatomic, retain) IBOutlet UIButton                *historyButton;
@property (nonatomic, retain) IBOutlet UIButton                *prefsButton;
@property (nonatomic, retain) IBOutlet UIButton                *addPhotoButton;
@property (nonatomic, retain) IBOutlet UIButton                *netSearchButton;
@property (nonatomic, retain) IBOutlet UIButton                *helpButton;

- (id)initWithMainViewController:(UIViewController *)vc;

// IB Actions ---------------------------

- (IBAction)startButtonAction:(id)sender;
- (IBAction)addNewPhoto:(id)sender;
- (IBAction)historyButtonAction:(id)sender;
- (IBAction)startNetworkedPlayAction:(id)sender;
- (IBAction)prefsButtonAction:(id)sender;
- (IBAction)helpButtonAction:(id)sender;

@end
