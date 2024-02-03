//
//  HistDetailViewController.h
//  ZaSlider
//
//  Created by Igor Delovski on 13.10.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class  GameHistory, ZaSliderViewController;


@interface HistDetailViewController : UIViewController
<
MFMailComposeViewControllerDelegate
>
{
   UIImageView             *backImageView;
   UIImageView             *pictImageView;
   
   UILabel                 *pictDescription;

   UILabel                 *playDateDescription;
   UILabel                 *playTimeDescription;
   UILabel                 *oponentDescription;
   
   GameHistory             *theGameHistory;
   ZaSliderViewController  *mainViewController;
}

@property  (nonatomic, retain)  IBOutlet  UIImageView             *backImageView;
@property  (nonatomic, retain)  IBOutlet  UIImageView             *pictImageView;

@property  (nonatomic, retain)  IBOutlet  UILabel                 *pictDescription;

@property  (nonatomic, retain)  IBOutlet  UILabel                 *playDateDescription;
@property  (nonatomic, retain)  IBOutlet  UILabel                 *playTimeDescription;
@property  (nonatomic, retain)  IBOutlet  UILabel                 *oponentDescription;

@property  (nonatomic, retain)            GameHistory             *theGameHistory;
@property  (nonatomic, retain)            ZaSliderViewController  *mainViewController;

- (IBAction)mailImageAction;
- (IBAction)replayAction;

//---------------------------

- (id)initWithMainViewController:(UIViewController *)vc
                     gameHistory:(GameHistory *)gh
                         nibName:(NSString *)nibNameOrNil
                          bundle:(NSBundle *)nibBundleOrNil;


- (void)mailImage;

@end
