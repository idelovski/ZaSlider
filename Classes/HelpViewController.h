//
//  HelpViewController.h
//  ZaSlider
//
//  Created by Igor Delovski on 08.04.2011.
//  Copyright 2011 Igor Delovski, Delovski d.o.o. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HelpViewController : UIViewController

@property (nonatomic, retain)  IBOutlet  UIScrollView  *scrollView;
@property (nonatomic, retain)  IBOutlet  UIImageView   *imgView;
@property (nonatomic, retain)  IBOutlet  UIToolbar     *bottomToolBar;

- (IBAction)closeHelpView;

@end
