//
//  HistoryViewController.m
//  ZaSlider
//
//  Created by Igor Delovski on 11.10.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import  "HistoryViewController.h"
#import  "HistoryViewController+Layout.h"

#import  "ZaSliderAppDelegate.h"
#import  "ZaSliderViewController.h"
#import  "GameHistory.h"
#import  "HistDetailViewController.h"


@implementation HistoryViewController

@synthesize  histTableView, histArray, parentVController;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithMainViewController:(UIViewController *)vc
                    historyArray:(NSMutableArray *)ha
                         nibName:(NSString *)nibNameOrNil
                          bundle:(NSBundle *)nibBundleOrNil
{
   if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])  {
      self.histArray = ha;
      self.parentVController = (ZaSliderViewController *)vc;
   }
   
   return (self);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   return ([self initWithMainViewController:nil historyArray:nil nibName:nibNameOrNil bundle:nibBundleOrNil]);
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
   [super viewDidLoad];
   
   // self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
   
   // self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:.76f
   //                                                                     green:.33f
   //                                                                      blue:0.f
   //                                                                     alpha:1.f];
   
   if (!self.navigationItem.rightBarButtonItem)  {

#ifdef _NIJE_
      UIBarButtonItem  *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(closeHistory)];
      
      self.navigationItem.leftBarButtonItem = barButton;
      [barButton release];
#endif

      self.navigationItem.rightBarButtonItem = self.editButtonItem;
            
      self.navigationItem.title = @"History";
   }
   
   // self.histTableView.allowsSelection = NO;
}

- (void)viewDidLayoutSubviews
{
   [super viewDidLayoutSubviews];
   
   [self layoutViewComponents];
}

- (void)viewWillAppear:(BOOL)animated
{
   NSLog (@"viewWillAppear: [%@]", self.description);
   [super viewWillAppear:animated];
   
   [self.navigationController setNavigationBarHidden:NO animated:NO];
   
   if (self.histTableView && self.parentVController.gamesHistoryDirty)
      [self.histTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
   NSLog (@"viewDidAppear: [%@]", self.description);
   [super viewDidAppear:animated];
   
   if (self.parentVController.gamesHistoryDirty)
      [self.histTableView reloadData];
#ifdef _FREEMEM_
   ZaSliderAppDelegate  *appDelegate = (ZaSliderAppDelegate *)[[UIApplication sharedApplication] delegate];
   
   [appDelegate handleCheckMemoryWithDescription:@"HistoryViewController-viewDidAppear:" showAlert:NO];
#endif
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
   
   self.histTableView = nil;
}


- (void)dealloc
{
   [histTableView release];
   [histArray release];
   [parentVController release];
   
   [super dealloc];
}

#pragma mark -

- (void)closeHistory
{
   [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -

- (void)setEditing:(BOOL)flag animated:(BOOL)animated
{
#ifdef  _SYS_APIS_LOG_
   NSLog (@"setEditing:(%d) animated:", (int)flag);
#endif
   [super setEditing:flag animated:animated];
   [histTableView setEditing:flag animated:animated];
#ifdef _NIJE_
   // This removes button cell at the end!
   NSIndexPath *idxPath = [NSIndexPath indexPathForRow:[self.histArray count] inSection:0];
   NSArray     *paths = [NSArray arrayWithObject:idxPath];
   
   if (!flag)  {
      if (!swipeEditingFlag)
         [[self histTableView] deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
      swipeEditingFlag = NO;
   }
#endif
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return (1);
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
#ifdef  _SYS_APIS_LOG_
   NSLog (@"tableView:numberOfRowsInSection: %d", section);
#endif
   NSInteger  rows = [self.histArray count];
   
   /*  IF I ADD THAT ADD BUTTON IN THE LAST ROW
   if ([self.histTableView isEditing] && !swipeEditingFlag)
      rows++;
   */
   return (rows);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return (kThumbImageHeight);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString  *reusableCellID = @"HistoryCell";
   
#ifdef  _SYS_APIS_LOG_
   NSLog (@"tableView:cellForRowAtIndexPath: %d", [indexPath row]);
#endif   
   NSInteger         row = [indexPath row];
   UITableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellID];
   
   if (!cell)
      // cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
      //                                reuseIdentifier:reusableCellID] autorelease];
      cell = [ImageAlbum genericCellWithCellIdentifier:reusableCellID needsActivityIndicator:NO];
   
   if (row < [self.histArray count])  {
      GameHistory  *gh = [self.histArray objectAtIndex:row];
      MediaItem    *tmpMediaItem = [self.parentVController mediaItemForImageKey:gh.imageKey orBuiltInIndex:gh.builtInAlbumIndex];
      NSString     *timeStr = [GameHistory secondsToString:gh.weFinishedInSeconds withDescription:NO];
      NSString     *opponentDesc;
      
      if (gh.opponentName)  {
         NSString  *tmpStr = gh.coopMode ? @"With" : @"Against";
         opponentDesc = [NSString stringWithFormat:@"%@ %@", tmpStr, gh.opponentName];
      }
      else
         opponentDesc = @"Single player game";

      [ImageAlbum setupGenericTableViewCell:cell
                                  withImage:tmpMediaItem.imgThumb
                                   mainText:[NSString stringWithFormat:@"(%dx%d) %@", gh.sideElements, gh.sideElements, timeStr]
                                   topTitle:opponentDesc
                                       date:gh.playingDate];
      // [gh description];
   }
   // else
   //    cell.textLabel.text = @"...";
   
   return (cell);
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef  _SYS_APIS_LOG_
   NSLog (@"tableView:editingStyleForRowAtIndexPath: %d", [indexPath row]);
#endif
   
   return (UITableViewCellEditingStyleDelete);
}

#pragma mark -

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef  _SYS_APIS_LOG_
   NSLog (@"tableView:willBeginEditingRowAtIndexPath: %d", [indexPath row]);
#endif
   swipeEditingFlag = YES;
   [self setEditing:YES animated:YES];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef  _SYS_APIS_LOG_
   NSLog (@"tableView:didEndEditingRowAtIndexPath: %d", [indexPath row]);
#endif
   [self setEditing:NO animated:YES];
   swipeEditingFlag = NO;
}

#pragma mark -

-   (void)tableView:(UITableView *)tableView
 commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
  forRowAtIndexPath:(NSIndexPath *)indexPath;
{
#ifdef  _SYS_APIS_LOG_
   NSLog (@"tableView:commitEditingStyle:forRowAtIndexPath: %d", [indexPath row]);
#endif   
   if (editingStyle == UITableViewCellEditingStyleDelete)  {
      GameHistory  *gh = [self.histArray objectAtIndex:[indexPath row]];
      // [tableView beginUpdates];
      if ([self.parentVController removeGameFromHistory:gh])  {
         [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
      }
      // [tableView endUpdates];
   }
   else  if (editingStyle == UITableViewCellEditingStyleInsert)  {
      // We expect indexPat to be for the last row
      NSLog (@"We don't have UITableViewCellEditingStyleInsert!?");
   }
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef  _SYS_APIS_LOG_
   NSLog (@"tableView:didSelectRowAtIndexPath:%d", [indexPath row]);
#endif   
   [self.histTableView deselectRowAtIndexPath:indexPath animated:NO];
   
   HistDetailViewController  *detailVC = [[HistDetailViewController alloc] initWithMainViewController:self.parentVController
                                                                                          gameHistory:[self.histArray objectAtIndex:[indexPath row]]
                                                                                              nibName:@"HistDetailViewController"
                                                                                               bundle:nil];
   
   [self.navigationController pushViewController:detailVC animated:YES];
   [detailVC release];
}


@end
