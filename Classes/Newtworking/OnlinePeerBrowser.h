//
//  OnlinePeerBrowser.h
//  TicTacToe
//
//  Created by Igor Delovski on 13.08.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  NetworkingController;


@interface OnlinePeerBrowser : UIViewController
<NSNetServiceBrowserDelegate, NSNetServiceDelegate> {
   // UITableView              *tableView;
   UILabel                  *label01;
   UILabel                  *label02;
   UILabel                  *label03;
   UILabel                  *label04;
   
   UIButton                 *button01;
   UIButton                 *button02;
   UIButton                 *button03;
   UIButton                 *button04;
   
   NSNetServiceBrowser      *netServiceBrowser;
   NSMutableArray           *discoveredServices;
   UIActivityIndicatorView  *actIndicatorView;

   NetworkingController     *netController;
}

// @property  (nonatomic, retain)  IBOutlet  UITableView              *tableView;
@property  (nonatomic, retain)  IBOutlet  UILabel                  *label01;
@property  (nonatomic, retain)  IBOutlet  UILabel                  *label02;
@property  (nonatomic, retain)  IBOutlet  UILabel                  *label03;
@property  (nonatomic, retain)  IBOutlet  UILabel                  *label04;

@property  (nonatomic, retain)  IBOutlet  UIButton                 *button01;
@property  (nonatomic, retain)  IBOutlet  UIButton                 *button02;
@property  (nonatomic, retain)  IBOutlet  UIButton                 *button03;
@property  (nonatomic, retain)  IBOutlet  UIButton                 *button04;

@property  (nonatomic, retain)            NSNetServiceBrowser      *netServiceBrowser;
@property  (nonatomic, retain)            NSMutableArray           *discoveredServices;
@property  (nonatomic, retain)            NetworkingController     *netController;
@property  (nonatomic, retain)            UIActivityIndicatorView  *actIndicatorView;

- (id)initWithNetworkingController:(NetworkingController *)nc
                           nibName:(NSString *)nibNameOrNil
                            bundle:(NSBundle *)nibBundleOrNil;

- (void)reloadData;
- (void)didSelectRow:(NSInteger)theRow;

- (IBAction)peerNameButtonPressed:(id)sender;
- (IBAction)cancel;

@end
