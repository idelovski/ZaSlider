//
//  HistoryViewController.h
//  ZaSlider
//
//  Created by Igor Delovski on 11.10.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  ZaSliderViewController;

@interface HistoryViewController : UIViewController 
<UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource>  {
   UITableView             *histTableView;
   NSMutableArray          *histArray;          // of GameHistory
   ZaSliderViewController  *parentVController;  // Caller
   
   // internal
   
   BOOL               swipeEditingFlag;
}

@property  (nonatomic, retain)  IBOutlet  UITableView             *histTableView;
@property  (nonatomic, retain)            NSMutableArray          *histArray;
@property  (nonatomic, retain)            ZaSliderViewController  *parentVController;

- (id)initWithMainViewController:(UIViewController *)vc
                    historyArray:(NSMutableArray *)ha
                         nibName:(NSString *)nibNameOrNil
                          bundle:(NSBundle *)nibBundleOrNil;
- (void)closeHistory;

@end
