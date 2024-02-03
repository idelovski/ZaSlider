//
//  ZaSliderViewController.m
//  ZaSlider
//
//  Created by Igor Delovski on 15.09.2010.
//  Copyright Igor Delovski, Delovski d.o.o. 2010. All rights reserved.
//

#import  "ZaSliderViewController.h"
#import  "ZaSliderViewController+Layout.h"

#import "ZaSliderAppDelegate.h"
#import "NetworkingController.h"
#import "GameState.h"
#import "GameHistory.h"
#import "QuickPrefsViewController.h"
#import "MenuViewController.h"
#import "HelpViewController.h"


@implementation ZaSliderViewController

@synthesize  theMenuViewController, theSliderViewController, theHistoryViewController;
@synthesize  thePrefsViewController, navController;
@synthesize  netController, builtInAlbum, custImageAlbum, usedImageSource;
@synthesize  rawImage, actIndicatorView, currentImageKey, builtInAlbumImageIndex;
@synthesize  gamesHistory, gamesHistoryDirty /*, gamesHistoryFlushed*/;

/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   [self loadAndAddMenuView];
   
   /*
   [startButton useNewPinkishStyle];
   
   [historyButton useNewPinkishStyle];
   [prefsButton useNewPinkishStyle];
   [addPhotoButton useNewPinkishStyle];
   [netSearchButton useNewPinkishStyle];
   */
   
   // NSLog (@"viewDidLoad");
   // NetworkingController  *tmpNetController = [[NetworkingController alloc] initWithMainViewController:self];
   // NSLog (@"Ptr: %p, Obj: %@", tmpNetController, tmpNetController);   
   
   if (![self.navigationController isToolbarHidden])
      [self.navigationController setToolbarHidden:YES animated:YES];

   if (!builtInAlbum)  {
      builtInAlbum = [[ImageAlbum alloc] initWithBuiltInAlbumName:nil];
      
      [self loadSavedAlbums];
      
      [self loadGamesHistory];
      
      NSNotificationCenter  *nc = [NSNotificationCenter defaultCenter];
      
      // remove it in -dealloc
      
      [nc addObserver:self
             selector:@selector(saveCustomAlbums)
                 name:UIApplicationWillTerminateNotification
               object:nil];
#ifndef _SKIP_SAVED_GAME_      
      [self performSelector:@selector(checkForSavedGame) withObject:nil afterDelay:.01];
#endif
   }
}

- (void)viewDidLayoutSubviews
{
   [super viewDidLayoutSubviews];
   
   [self layoutViewComponents];
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
   
   if (self.custImageAlbum)  {
      [self saveCustomAlbums];
      self.custImageAlbum = nil;
      custAlbumFlushed = YES;
      NSLog (@"Custom Album Flushed!");
   }
   if (self.builtInAlbum)
      [self.builtInAlbum flushScreenSizedImages];
   
   if (self.gamesHistory && [self.gamesHistory retainCount] == 1)  {
      if (gamesHistoryDirty)
         [self saveGamesHistory];
      self.gamesHistory = nil;
      gamesHistoryFlushed = YES;
   }
}

/*
- (void)viewDidUnload
{
   // Release any retained subviews of the main view.
   // e.g. self.myOutlet = nil;
   [self unloadAndRemoveMenuView];
}
*/

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   
   [self loadAndAddMenuView];
   
   if (![self.navigationController isNavigationBarHidden])
      [self.navigationController setNavigationBarHidden:YES animated:YES];
#ifdef _FREEMEM_
   ZaSliderAppDelegate  *appDelegate = (ZaSliderAppDelegate *)[[UIApplication sharedApplication] delegate];
   
   [appDelegate handleCheckMemoryWithDescription:@"ZaSliderViewController-viewWillAppear:" showAlert:NO];
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];

   // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
}

#ifdef _NIJE_
- (void)viewWillDisappear:(BOOL)animated
{
   [super viewWillDisappear:animated];

   // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}
#endif

- (void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   
   [theSliderViewController release];
   [theHistoryViewController release];
   [thePrefsViewController release];
   
   [navController release];
   [netController release];
   
   [builtInAlbum release];
   [custImageAlbum release];
   
   [rawImage release];
   [usedImageSource release];
   [actIndicatorView release];
   
   [currentImageKey release];
   [gamesHistory release];
   
   [super dealloc];
}

#pragma mark -

- (void)loadMenuView  // used from -loadAndAddMenuView
{
   if (!self.theMenuViewController)  {
      MenuViewController  *tmpMenuViewController = [[MenuViewController alloc] initWithMainViewController:self];
      self.theMenuViewController = tmpMenuViewController;
      
      [tmpMenuViewController release];
   }
}

- (void)loadAndAddMenuView
{
   if (!self.theMenuViewController)  {
      [self loadMenuView];
   
      [self.view addSubview:self.theMenuViewController.view];
   }
}   

- (void)unloadAndRemoveMenuView
{
   if (self.theMenuViewController)  {
      if ([self.theMenuViewController.view superview])
         [self.theMenuViewController.view removeFromSuperview];
      self.theMenuViewController = nil;
   }
}   

#pragma mark -

// gets called here in -viewDidLoad

- (void)loadSavedAlbums
{
   ImageAlbum  *newAlbum = [ImageAlbum loadFromPath:id_PathInDocumentDirectory(nil)
                                       andAlbumName:kCustomAlbumName];
   
   self.custImageAlbum = newAlbum;
   
#ifdef  _FILES_LOG_
   NSLog (@"Loaded album from disk, %d items.", [newAlbum.albumMediaItems count]);
#endif
   
   custAlbumFlushed = NO;
}

// gets called here 

- (void)saveCustomAlbums
{
   if (self.custImageAlbum && self.custImageAlbum.dirtyFlag)
      [self.custImageAlbum saveToPath:id_PathInDocumentDirectory(nil)];
}

#pragma mark -

- (void)loadGamesHistory
{
   NSMutableArray  *ghArray = [GameHistory loadGameHistoryArrayFromPath:id_PathInDocumentDirectory(nil)];
   
   if (ghArray)
      self.gamesHistory = ghArray;
   else
      self.gamesHistory = [NSMutableArray array];
   
#ifdef  _FILES_LOG_
   NSLog (@"Loaded history from disk, %d items.", [ghArray count]);
#endif
   
   gamesHistoryFlushed = gamesHistoryDirty = NO;
}

// gets called here 

- (void)saveGamesHistory
{
   if (self.gamesHistory && !gamesHistoryFlushed && gamesHistoryDirty)
      [GameHistory saveGameHistoryArray:self.gamesHistory toPath:id_PathInDocumentDirectory(nil)];
   gamesHistoryDirty = NO;
}

#pragma mark -

- (void)handleTermination
{
   if (self.theSliderViewController && self.theSliderViewController.ourGameController)  {
      GameController  *tmpGC = self.theSliderViewController.ourGameController;
      if (tmpGC.gcGamePhase == kGameInProgress)  {
         GameState  *tmpGameState = [tmpGC currentGameStateWithImageKey:self.currentImageKey
                                                    orBuiltInAlbumIndex:self.builtInAlbumImageIndex];
         
         [tmpGameState saveToPath:id_PathInDocumentDirectory(nil) fileName:kSavedGameName];
#ifdef  _FILES_LOG_
         NSLog (@"Here we save stuff!");
#endif
      }
      else
         [GameState deleteFileName:kSavedGameName atPath:id_PathInDocumentDirectory(nil)];
   }
   
   [self saveGamesHistory];
}

- (void)checkForSavedGame
{
   GameState  *savedState = [GameState loadFromPath:id_PathInDocumentDirectory(nil) andFileName:kSavedGameName];
   MediaItem  *tmpMediaItem;
   
   if (savedState)  {
      UIImage  *useImage = nil;

#ifdef _NIJE_
      if (savedState.imageKey)
         useImage = [[ImageCache sharedImageCache] imageForKey:savedState.imageKey];
      
      if (!useImage)  {
         useImage = [self.builtInAlbum imageAtIndex:savedState.builtInAlbumIndex];
         savedState.imageKey = nil;  // In case image was lost in the meantime...
      }
      
      if (!useImage)
         return;     // Forget about it all...
#endif
      
      if (!theSliderViewController)
         theSliderViewController = [[SliderViewController alloc] initWithMainViewController:self
                                                                           initialGameState:savedState
                                                                               initialImage:useImage
                                                                         showingTileNumbers:gGPrefsRec.pfShowNumbers
                                                                            andSideElements:gGPrefsRec.pfSideElems];
      
      // theSliderViewController.gsToStartWith = savedState;
      // theSliderViewController.sliderImage = useImage;
      
      if (!theSliderViewController.view)  {
         // Chicken & egg situation - should never drop in here...
         theSliderViewController.ourGameController = [[GameController alloc] initWithGameState:savedState
                                                                                   sliderImage:nil/*useImage*/
                                                                                        inView:theSliderViewController.view];
      }
      
      tmpMediaItem = [self mediaItemForImageKey:savedState.imageKey orBuiltInIndex:savedState.builtInAlbumIndex];

      if (tmpMediaItem && !tmpMediaItem.smallImage)
         tmpMediaItem.smallImage = [self imageForImageKey:savedState.imageKey orBuiltInIndex:savedState.builtInAlbumIndex];

      [self startNewGameWithMediaItem:tmpMediaItem imageKey:savedState.imageKey builtInIndex:savedState.builtInAlbumIndex];
      
      [GameState deleteFileName:kSavedGameName atPath:id_PathInDocumentDirectory(nil)];
   }
}

#pragma mark -
#pragma mark Actions
#pragma mark -

- (IBAction)startButtonAction:(id)sender
{
   NSString   *tmpImageKey;
   NSInteger   tmpImageIndex;
   
   self.netController = nil;   // Just in case we cancelled before!
   
   // If set in prefs, show quickPrefs, otherwise continue starting the game immediately
   
   if (![self shouldPrepareGameWithPrefsReturningImageKey:&tmpImageKey orReturningIndex:&tmpImageIndex])
      [self prepareToStartNewGameWithImageKey:tmpImageKey builtInIndex:tmpImageIndex];
}

// Thanks iOS 13.
// ViewWillDisappear, ViewDidDisappear, ViewWillAppear and  ViewDidAppear won't get called on a presenting view controller on iOS 13 which uses a new modal presentation that doesn't cover the whole screen.


- (IBAction)historyButtonAction:(id)sender
{
   self.netController = nil;   // Just in case we cancelled before!

   if (custAlbumFlushed)
      [self loadSavedAlbums];
   if (gamesHistoryFlushed)
      [self loadGamesHistory];
   
   if (!theHistoryViewController)
      theHistoryViewController = [[HistoryViewController alloc] initWithMainViewController:self
                                                                              historyArray:self.gamesHistory
                                                                                   nibName:@"HistoryViewController"
                                                                                    bundle:nil];
   // NSString  *sysVersion = [[UIDevice currentDevice] systemVersion];
   
   NSProcessInfo             *processInfo = [[NSProcessInfo alloc] init];
   NSOperatingSystemVersion   osVersion = [processInfo operatingSystemVersion];
   
   if (osVersion.majorVersion > 12)  {
      [theHistoryViewController viewWillAppear:YES];
      self.navigationController.hidesBarsOnTap = FALSE;
   }

   [self.navigationController pushViewController:theHistoryViewController animated:YES];

   if (osVersion.majorVersion > 12)
      [theHistoryViewController viewDidAppear:YES];
}

- (IBAction)startNetworkedPlayAction:(id)sender
{
   NetworkingController  *tmpNetController = [[NetworkingController alloc] initWithMainViewController:self];
   /*
    NetworkingController  *tmpNetController = [NetworkingController alloc];
   NSLog (@"Ptr: %p, Obj: %@", tmpNetController, tmpNetController);
   // tmpNetController = [tmpNetController initWithMainViewController:self];
   tmpNetController = [tmpNetController init];
   NSLog (@"Ptr: %p, Obj: %@", tmpNetController, tmpNetController);
   
   tmpNetController.mainViewController = self;
   tmpNetController.netControllerState = kNCStateBeginning;
   */
   self.netController = tmpNetController;
   [tmpNetController release];
   
   [self.netController startPeerSearch];
}

- (IBAction)prefsButtonAction:(id)sender
{
   ZaSliderAppDelegate  *appDelegate = (ZaSliderAppDelegate *)[[UIApplication sharedApplication] delegate];
   
   [appDelegate putBackgroundImage];

   self.netController = nil;   // Just in case we cancelled before!

   if (!self.thePrefsViewController)  {
      PrefsViewController  *tmpVC = [[PrefsViewController alloc] initWithMainViewController:self
                                                                                    nibName:@"PrefsViewController"
                                                                                     bundle:nil];
      self.thePrefsViewController = tmpVC;
      [tmpVC release];
   }
   
   [UIView beginAnimations:@"ViewFlip" context:nil];
   [UIView setAnimationDuration:1.25];
   [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
   
   UIViewController          *coming = nil;
   UIViewController          *going = nil;
   UIViewAnimationTransition  trans;
   
   coming = self.thePrefsViewController;
   going  = self.theMenuViewController;
   trans = UIViewAnimationTransitionFlipFromLeft;
   
   [UIView setAnimationTransition:trans forView:self.view cache:YES];
   
   [coming viewWillAppear:YES];
   [going  viewWillDisappear:YES];
   
   [going.view removeFromSuperview];
   // [self.view addSubview:coming.view];
   [self.view insertSubview:coming.view aboveSubview:self.theMenuViewController.view];  // 2024
   
   [going  viewDidDisappear:YES];
   [coming viewDidAppear:YES];
   
   [UIView commitAnimations];
   
   self.theMenuViewController = nil;
}

- (IBAction)helpButtonAction:(id)sender
{
   UIViewController  *vc = (UIViewController *)sender;
   
   HelpViewController  *helpDialog = [[HelpViewController alloc] initWithNibName:nil
                                                                          bundle:nil];
   
   [vc presentModalViewController:helpDialog animated:YES];
   [helpDialog release];

   /*
   UIAlertView  *alertView = [[UIAlertView alloc] initWithTitle:@"Game Help"
                                                        message:@"Play smart and you will win."
                                                       delegate:nil
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles:nil];
   [alertView show];
   [alertView release];
   */
}

#pragma mark -
#pragma mark Helpers
#pragma mark -

- (void)randomImageReturningImageKey:(NSString **)retImageKey      // if it has the key
                    orReturningIndex:(NSInteger *)retIndex         // otherwise return idx
{
   if (custAlbumFlushed)
      [self loadSavedAlbums];
   
   [builtInAlbum randomImageWithOtherAlbum:self.custImageAlbum
                         returningImageKey:retImageKey
                          orReturningIndex:retIndex
                     andReturningMediaItem:nil];
}   

- (BOOL)isImageAvailableForImageKey:(NSString *)imageKey   // if it has the key
                orBuiltInAlbumIndex:(NSInteger)idx         // otherwise use idx
{
   if ([self imageForImageKey:imageKey orBuiltInIndex:idx])
      return (YES);
   
   return (NO);
}

// call QuickPrefs if needed, return NO if not

- (BOOL)shouldPrepareGameWithPrefsReturningImageKey:(NSString **)retImageKey      // if it has the key
                                   orReturningIndex:(NSInteger *)retIndex         // otherwise return idx

{
   BOOL  netModeFlag = self.netController ? YES : NO;
   
   memmove (&gGCurPrefsRec, &gGPrefsRec, sizeof(PreferenceRecord));   // dst,src,size
   
   [self randomImageReturningImageKey:retImageKey orReturningIndex:retIndex];
   
   if (gGPrefsRec.pfShowSettingsBeforeGame)  {
      QuickPrefsViewController  *tmpQPVController = [[QuickPrefsViewController alloc] initWithMainViewController:self
                                                                                                        imageKey:*retImageKey
                                                                                               builtInAlbumIndex:*retIndex
                                                                                                   inNetworkMode:netModeFlag
                                                                                                         nibName:@"QuickPrefsViewController"
                                                                                                          bundle:nil];
      [self presentModalViewController:tmpQPVController animated:YES];
      [tmpQPVController release];
      
      return (YES);
   }
   
   return (NO);
}

- (void)prepareToStartNewGameWithImageKey:(NSString *)imgKey builtInIndex:(NSInteger)idx
{
   MediaItem   *tmpMediaItem;
   
   if (!theSliderViewController)
      theSliderViewController = [[SliderViewController alloc] initWithMainViewController:self
                                                                        initialGameState:nil
                                                                            initialImage:nil
                                                                      showingTileNumbers:gGPrefsRec.pfShowNumbers
                                                                         andSideElements:gGCurPrefsRec.pfSideElems];
   
   if (custAlbumFlushed)
      [self loadSavedAlbums];
   
   tmpMediaItem = [self mediaItemForImageKey:imgKey orBuiltInIndex:idx];
   
   if (tmpMediaItem && !tmpMediaItem.smallImage)
      tmpMediaItem.smallImage = [self imageForImageKey:imgKey orBuiltInIndex:idx];
   
   [self startNewGameWithMediaItem:tmpMediaItem imageKey:imgKey builtInIndex:idx];
}

// produce the album, produce SliderViewController, add image to the album, create small image and create tiles

- (void)startNewGameWithMediaItem:(MediaItem *)mediaItemOrNil  // nil if the image is beeing created in the background
                         imageKey:(NSString *)imgKey
                     builtInIndex:(NSUInteger)idx
{
   self.currentImageKey        = imgKey;
   self.builtInAlbumImageIndex = idx;
   
   [theSliderViewController viewWillAppear:NO];
   [theMenuViewController viewWillDisappear:NO];
   [self.view addSubview:theSliderViewController.view];
   [self.theMenuViewController.view removeFromSuperview];
   [theSliderViewController viewDidAppear:NO];
   [theMenuViewController viewDidDisappear:NO];

   self.theMenuViewController = nil;
   
   if (mediaItemOrNil)  {
      ImageAlbum  *tmpAlbum;
      
      if (imgKey)
         tmpAlbum = self.custImageAlbum;
      else
         tmpAlbum = self.builtInAlbum;
      
      [tmpAlbum changeImageWithMediaItem:mediaItemOrNil
                      withGameController:theSliderViewController.ourGameController
                       tileImageDelegate:self];
   }
}

- (void)acceptAndStoreNewImage:(UIImage *)theImage withImageKey:(NSString *)imgKeyOrNil
{
   if (!self.custImageAlbum)  {
      if (custAlbumFlushed)
         [self loadSavedAlbums];
      else  {
         ImageAlbum  *newImageAlbum = [[ImageAlbum alloc] initWithAlbumName:kCustomAlbumName];
         self.custImageAlbum = newImageAlbum;
         [newImageAlbum release];
      }
   }
   
   NSInteger  useSideElems = self.netController ? self.netController.initialGameState.sideElements : gGPrefsRec.pfSideElems;
   BOOL       shouldShowNumbers = self.netController ? YES : gGPrefsRec.pfShowNumbers;
   
   if (!theSliderViewController)
      theSliderViewController = [[SliderViewController alloc] initWithMainViewController:self
                                                                        initialGameState:nil
                                                                            initialImage:nil
                                                                      showingTileNumbers:shouldShowNumbers
                                                                         andSideElements:useSideElems];

   if (!theSliderViewController.view)  {
      // Chicken & egg situation - should never drop in here...
      theSliderViewController.ourGameController = [[GameController alloc] initWithNumberOfSideElements:gGPrefsRec.pfSideElems
                                                                                                 image:nil
                                                                                                inView:theSliderViewController.view];
   }
   [custImageAlbum addImage:theImage
                 reusingKey:imgKeyOrNil
                imageSource:self.usedImageSource
         withGameController:theSliderViewController.ourGameController
          tileImageDelegate:self
      andSmallImageDelegate:self];
   
   // Store image to the iPhones main Photo Album
   
   if ([self.usedImageSource isEqualToString:kImageSourceCamera] && gGPrefsRec.pfStoreCameraImages)
      if (!self.netController && !imgKeyOrNil)
         UIImageWriteToSavedPhotosAlbum (theImage, nil, nil, nil);
}  

#pragma mark -
#pragma mark Utilities for other classes
#pragma mark -

- (void)changeGameImage
{
   NSString    *tmpImageKey;
   NSInteger    tmpImageIndex;
   MediaItem   *tmpMediaItem;
   UIImage     *gameImage;
   ImageAlbum  *tmpAlbum;
   TileView    *tmpTileView = nil;
   NSUInteger   totalElems = theSliderViewController.ourGameController.sideElements * theSliderViewController.ourGameController.sideElements;
   int          i = 0;
   
   if (custAlbumFlushed)
      [self loadSavedAlbums];
   
   do  {
      gameImage = [builtInAlbum randomImageWithOtherAlbum:self.custImageAlbum
                                               returningImageKey:&tmpImageKey
                                                orReturningIndex:&tmpImageIndex
                                           andReturningMediaItem:&tmpMediaItem];
   }  while (i<3 && (self.currentImageKey == tmpImageKey) && (self.builtInAlbumImageIndex == tmpImageIndex));

   if (!gameImage)  {
      NSLog (@"No gameImage!");
      return;
   }
   
   for (int i=0; i<totalElems; i++)  {
      tmpTileView = [theSliderViewController.ourGameController.allTiles objectAtIndex:i];
      // if (tmpTileView.tileType != kEmptyTile)  {
         tmpTileView.picView.image = nil;
      // }
      if (tmpTileView.tileType == kEmptyTile)  {
         // tmpTileView.picView.hidden = YES;
         tmpTileView.picView.alpha = .05f;
      }
      else  if (tmpTileView.indexLabel.hidden)  {
         tmpTileView.indexLabel.hidden = NO;
         tmpTileView.highliteView.hidden = NO;
      }
   }

   if (tmpImageKey)
      tmpAlbum = self.custImageAlbum;
   else
      tmpAlbum = self.builtInAlbum;
   
   [tmpAlbum changeImageWithMediaItem:tmpMediaItem
                   withGameController:theSliderViewController.ourGameController
                    tileImageDelegate:self];

   self.currentImageKey        = tmpImageKey;
   self.builtInAlbumImageIndex = tmpImageIndex;
}

// Add param that makes sure we have the image

- (MediaItem *)mediaItemForImageKey:(NSString *)imageKey     // if it has the key
                     orBuiltInIndex:(NSInteger)idx           // otherwise use idx
{
   MediaItem   *retMediaItem = nil;

   if (imageKey)
      retMediaItem = [self.custImageAlbum mediaItemForKey:imageKey returningIndex:nil];
   else  {
      if (idx >= [self.builtInAlbum.albumMediaItems count])
         idx = 0;
      retMediaItem = [self.builtInAlbum.albumMediaItems objectAtIndex:idx];
   }
   
   return (retMediaItem);
}

- (UIImage *)imageForImageKey:(NSString *)imageKey     // if it has the key
               orBuiltInIndex:(NSInteger)idx           // otherwise use idx
{
   MediaItem   *tmpMediaItem;
   ImageAlbum  *tmpAlbum;
   NSUInteger   imgIndex = idx;
   
   if (imageKey)  {
      if (custAlbumFlushed)
         [self loadSavedAlbums];
      tmpAlbum = self.custImageAlbum;
      tmpMediaItem = [self.custImageAlbum mediaItemForKey:imageKey returningIndex:&imgIndex];
      if (!tmpMediaItem)
         return (nil);
   }
   else
      tmpAlbum = self.builtInAlbum;
   
   return ([tmpAlbum imageAtIndex:imgIndex]);
}

- (UIImage *)prevImageForKey:(NSString *)inKey
           builtInAlbumIndex:(NSInteger)inIdx
           returningImageKey:(NSString **)retImageKey      // if it has the key
            orReturningIndex:(NSInteger *)retIndex         // otherwise return idx
{
   // ImageAlbum  *tmpAlbum = nil;
   MediaItem   *tmpMediaItem = nil;

   if (custAlbumFlushed)
      [self loadSavedAlbums];

   NSUInteger   builtImgCount  = [self.builtInAlbum.albumMediaItems count];
   NSUInteger   customImgCount = [self.custImageAlbum.albumMediaItems count];
   NSUInteger   custIdx = 0;

   if (inKey)  {
      tmpMediaItem = [self.custImageAlbum mediaItemForKey:inKey returningIndex:&custIdx];
      if (custIdx > 0)  {
         custIdx--;
         tmpMediaItem = [self.custImageAlbum.albumMediaItems objectAtIndex:custIdx];
         *retImageKey = tmpMediaItem.imgKey;
         *retIndex = 0;
      }
      else  {
         inKey = nil;
         inIdx = builtImgCount;  // one too many!
      }
   }
   
   if (!inKey)  {  // Can't be just 'else'
      inIdx--;
      *retImageKey = nil;
      *retIndex = 0;
      if ((inIdx < 0) && customImgCount)  {
         tmpMediaItem = [self.custImageAlbum.albumMediaItems objectAtIndex:customImgCount-1];
         *retImageKey = tmpMediaItem.imgKey;
      }
      else  {
         if ((inIdx < 0))
            inIdx = builtImgCount - 1;
         tmpMediaItem = [self.builtInAlbum.albumMediaItems objectAtIndex:inIdx];
         *retIndex = inIdx;
      }
   }
      
   if (tmpMediaItem && !tmpMediaItem.smallImage)
      tmpMediaItem.smallImage = [self imageForImageKey:*retImageKey orBuiltInIndex:*retIndex];
      
   if (tmpMediaItem)
      return (tmpMediaItem.smallImage);
   
   return (nil);
}

- (UIImage *)nextImageForKey:(NSString *)inKey
           builtInAlbumIndex:(NSInteger)inIdx
           returningImageKey:(NSString **)retImageKey      // if it has the key
            orReturningIndex:(NSInteger *)retIndex         // otherwise return idx
{
   // ImageAlbum  *tmpAlbum = nil;
   MediaItem   *tmpMediaItem = nil;
   
   if (custAlbumFlushed)
      [self loadSavedAlbums];
   
   NSUInteger   builtImgCount  = [self.builtInAlbum.albumMediaItems count];
   NSUInteger   customImgCount = [self.custImageAlbum.albumMediaItems count];
   NSUInteger   custIdx = 0;
   
   if (inKey)  {
      tmpMediaItem = [self.custImageAlbum mediaItemForKey:inKey returningIndex:&custIdx];
      if (custIdx < customImgCount-1)  {
         custIdx++;
         tmpMediaItem = [self.custImageAlbum.albumMediaItems objectAtIndex:custIdx];
         *retImageKey = tmpMediaItem.imgKey;
         *retIndex = 0;
      }
      else  {
         inKey = nil;
         inIdx = -1;  // one below!
      }
   }
   
   if (!inKey)  {  // Can't be just 'else'
      inIdx++;
      *retImageKey = nil;
      *retIndex = 0;
      if ((inIdx > builtImgCount-1) && customImgCount)  {
         tmpMediaItem = [self.custImageAlbum.albumMediaItems objectAtIndex:0];
         *retImageKey = tmpMediaItem.imgKey;
      }
      else  {
         if ((inIdx > builtImgCount-1))
            inIdx = 0;
         tmpMediaItem = [self.builtInAlbum.albumMediaItems objectAtIndex:inIdx];
         *retIndex = inIdx;
      }
   }
   
   if (tmpMediaItem && !tmpMediaItem.smallImage)
      tmpMediaItem.smallImage = [self imageForImageKey:*retImageKey orBuiltInIndex:*retIndex];
   
   if (tmpMediaItem)
      return (tmpMediaItem.smallImage);
   
   return (nil);
}

#pragma mark -
#pragma mark Game Completion & History

- (GameHistory *)addGameToHistory:(GameController *)finishedGame
                finishedInSeconds:(NSUInteger)ourSecs
                 opponentsSeconds:(NSUInteger)opSecs
{
#ifdef  _FILES_LOG_
   NSLog (@"Adding game to history!");
#endif
   
   NSString  *opponentName = nil;
   BOOL       coopMode = NO;
   
   if (self.netController && self.netController.initialGameState)  {
      opponentName = self.netController.initialGameState.opponentName;
      coopMode = self.netController.initialGameState.coopMode;
   }
   
   GameHistory  *newGameHistory = [[GameHistory alloc] initWithImageKey:self.currentImageKey
                                                      builtInAlbumIndex:self.builtInAlbumImageIndex
                                                           sideElements:finishedGame.sideElements
                                                           opponentName:opponentName
                                                               coopMode:coopMode
                                                    asFinishedInSeconds:ourSecs
                                                       opponentsSeconds:opSecs];  // one day, have it in there
   
   if (gamesHistoryFlushed)
      [self loadGamesHistory];
   [self.gamesHistory insertObject:newGameHistory atIndex:0];
   
   if ([self.gamesHistory count] > kMaxGamesInHistory)
      [self.gamesHistory removeObjectAtIndex:[self.gamesHistory count]-1];
   
   gamesHistoryDirty = YES;
   
   return ([newGameHistory autorelease]);
}

- (BOOL)removeGameFromHistory:(GameHistory *)gh
{
   if (gamesHistoryFlushed)
      [self loadGamesHistory];
   if ([self.gamesHistory containsObject:gh])  {
      [self.gamesHistory removeObject:gh];
      gamesHistoryDirty = YES;
      
      return (YES);
   }
   
   return (NO);
}

#pragma mark -
#pragma mark Comming Back From Other ViewControllers

- (void)dismissModalPreferencesViewControllerWithImageKey:(NSString *)imgKey builtInIndex:(NSInteger)idx
{
   [self dismissModalViewControllerAnimated:YES];
   
   if (imgKey || idx >= 0)  {  // when called from cancel action
      if (!self.netController)
         [self prepareToStartNewGameWithImageKey:imgKey builtInIndex:idx];
      else  {
         self.netController.imgKey          = imgKey;
         self.netController.builtInAlbumIdx = idx;
         [self.netController sendImageInfo];
      }
   }
}

- (void)navigateBackToMainViewController:(GameHistory *)gh
{
   [self.navigationController popToViewController:self animated:YES];

   if (gh)  {
      NSString    *tmpImageKey = gh.imageKey;
      NSInteger    tmpImageIndex = gh.builtInAlbumIndex;
      MediaItem   *tmpMediaItem;
      // ImageAlbum  *tmpAlbum;
      
      theSliderViewController = [[SliderViewController alloc] initWithMainViewController:self
                                                                        initialGameState:nil
                                                                            initialImage:nil
                                                                      showingTileNumbers:gGPrefsRec.pfShowNumbers
                                                                         andSideElements:gGPrefsRec.pfSideElems];
      
      if (custAlbumFlushed)
         [self loadSavedAlbums];
      
      tmpMediaItem = [self mediaItemForImageKey:tmpImageKey orBuiltInIndex:tmpImageIndex];
      
      if (tmpMediaItem && !tmpMediaItem.smallImage)
         tmpMediaItem.smallImage = [self imageForImageKey:tmpImageKey orBuiltInIndex:tmpImageIndex];
      
      [self startNewGameWithMediaItem:tmpMediaItem imageKey:tmpImageKey builtInIndex:tmpImageIndex];
   }
}

- (void)finishAndReleaseGameControllers
{
   self.netController = nil;
   self.theSliderViewController.ourGameController = nil;
   self.theSliderViewController = nil;
}

#pragma mark -
#pragma mark UINavigationControllerDelegate

#ifdef _USELESS_AFTER_IOS15_
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
   NSLog (@"navigationController:... call viewWillAppear:");
   [viewController viewWillAppear:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
   NSLog (@"navigationController:... call viewDidAppear:");
   [viewController viewDidAppear:animated];
}
#endif

#pragma mark -
#pragma mark Services for the networking controller

- (void)asClientStartGameWithImage:(UIImage *)commonImage forKey:(NSString *)key withBuiltInIndex:(NSUInteger)idx
{
   MediaItem  *tmpMediaItem = nil;
   // the image is maybe new, or not, do something about it!
   // add the image to the cashe and start new game, waiting for the opponents move
   // see -finishedAddingNewImage:
   
   // use -acceptAndStoreNewImage:img
   if (!commonImage)
      tmpMediaItem = [self mediaItemForImageKey:key orBuiltInIndex:idx];
   
   if (commonImage && !tmpMediaItem)
      // We have bug here - servers slide elems (in initialGameState) is not used!
      [self acceptAndStoreNewImage:commonImage withImageKey:key];
   else  {
      if (!theSliderViewController)
         theSliderViewController = [[SliderViewController alloc] initWithMainViewController:self
                                                                           initialGameState:nil
                                                                               initialImage:nil
                                                                         showingTileNumbers:YES
                                                                            andSideElements:self.netController.initialGameState.sideElements];
      
      if (custAlbumFlushed)
         [self loadSavedAlbums];
   }

   if (tmpMediaItem && !tmpMediaItem.smallImage)
      tmpMediaItem.smallImage = [self imageForImageKey:key orBuiltInIndex:idx];

#ifdef  _NETTALK_LOG_
   NSLog (@"asClientStartGameWithImage: %@[%d] (mi=%@)", key, idx, tmpMediaItem ? @"Yes" : @"No");
#endif
   
   [self startNewGameWithMediaItem:tmpMediaItem imageKey:key builtInIndex:idx];
}

- (void)asServerStartGameWithKey:(NSString *)key withBuiltInIndex:(NSUInteger)idx
{
   // memmove (&gGCurPrefsRec, &gGPrefsRec, sizeof(PreferenceRecord));   // dst,src,size
   
   gGCurPrefsRec.pfSideElems = self.netController.initialGameState.sideElements;

   /*
   MediaItem   *tmpMediaItem;
   
   if (!theSliderViewController)
      theSliderViewController = [[SliderViewController alloc] initWithMainViewController:self
                                                                        initialGameState:nil
                                                                            initialImage:nil
                                                                         andSideElements:self.netController.initialGameState.sideElements];
   
   if (custAlbumFlushed)
      [self loadSavedAlbums];
      
   tmpMediaItem = [self mediaItemForImageKey:key orBuiltInIndex:idx];
   
   if (!tmpMediaItem.smallImage)
      tmpMediaItem.smallImage = [self imageForImageKey:key orBuiltInIndex:idx];
   
   [self startNewGameWithMediaItem:tmpMediaItem imageKey:key builtInIndex:idx];
   */
   [self prepareToStartNewGameWithImageKey:key builtInIndex:idx];
}

- (void)postOurMoveFromLocIndex:(NSUInteger)fromLocIndex toLocIndex:(NSUInteger)toLocIndex
{
   if (self.netController)
      [self.netController sendMovePacketWithFromLocIndex:fromLocIndex toLocIndex:toLocIndex];
}

- (void)asResponseMoveFromLocIndex:(NSUInteger)fromLocIndex toLocIndex:(NSUInteger)toLocIndex
{
   BOOL  successFlag = NO;
   
   if (theSliderViewController)
      successFlag = [theSliderViewController asResponseMoveTileFromLocIndex:fromLocIndex toLocIndex:toLocIndex];
   if (!successFlag)
      NSLog (@"asResponseMoveFromLocIndex:toLocIndex: FAIL!");
}

- (void)postOurTouchAtLocIndex:(NSUInteger)locIndex  // -1 to cancel the touch
{
   if (self.netController)
      [self.netController sendTouchPacketWithLocIndex:locIndex];
}

- (void)asResponseTouchLocIndex:(NSUInteger)locIndex
{
   BOOL  successFlag = NO;
   
   if (theSliderViewController)
      successFlag = [theSliderViewController asResponseTouchTileLocIndex:locIndex];
   if (!successFlag)
      NSLog (@"asResponseTouchLocIndex: FAIL!");
}

- (void)postOurTimeAtFinish:(NSUInteger)secondsInGame
{
   if (self.netController)
      [self.netController sendTimePacketWithSecondsInGame:secondsInGame];
}

- (void)asResponseCompareOpponentsTime:(NSUInteger)timeInSeconds
{
   // BOOL  successFlag = NO;
   
   if (theSliderViewController)
      [theSliderViewController asResponseCompareOpponentsTime:timeInSeconds];
}

- (void)postQuitMessage
{
   if (self.netController)
      [self.netController sendQuitPacket];
}

- (void)asResponseHandleOpponentsQuit
{
   // BOOL  successFlag = NO;
   
   if (theSliderViewController)
      [theSliderViewController asResponseHandleOpponentsQuit];
}

- (void)asResponseHandleOpponentsPing
{
   // BOOL  successFlag = NO;
   
   if (theSliderViewController)
      [theSliderViewController asResponseHandleOpponentsPing];
}

#pragma mark -
#pragma mark Add Photo handling

- (IBAction)addNewPhoto:(id)sender
{
   self.netController = nil;   // Just in case we cancelled before!

   if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])  {
      UIActionSheet  *tmpSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Pick a new photo for the game!"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Take new picture", /*@"Pick from Camera Roll",*/ @"Photo Album", nil];
      
      // [tmpSheet showInView:self.view];
      [tmpSheet showInView:self.view];  // self.parentViewController.tabBarController.view
      
      [tmpSheet release];
   }
   else
      [self performSelector:@selector(selectExistingPicture) withObject:nil afterDelay:.1];
#ifdef _FREEMEM_
   ZaSliderAppDelegate  *appDelegate = (ZaSliderAppDelegate *)[[UIApplication sharedApplication] delegate];
   
   [appDelegate handleCheckMemoryWithDescription:@"ZaSliderViewController-addNewPhoto:" showAlert:NO];
#endif
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
   if (actionSheet)  {
#ifdef  _NETTALK_LOG_
      NSLog (@"Button %d pressed.", buttonIndex);
#endif      
      if (buttonIndex == [actionSheet cancelButtonIndex])
         return;
      
      else  if (buttonIndex == [actionSheet destructiveButtonIndex]+1)
         [self performSelector:@selector(getCameraPicture) withObject:nil afterDelay:.1];
      // else  if (buttonIndex == [actionSheet destructiveButtonIndex]+2)
      //    [self performSelector:@selector(getAlbumPicture) withObject:nil afterDelay:.1];
      else  if (buttonIndex == [actionSheet destructiveButtonIndex]+2)
         [self performSelector:@selector(selectExistingPicture) withObject:nil afterDelay:.1];
   }
}

#pragma mark -
#pragma mark Camera

- (void)getCameraPicture
{
   self.usedImageSource = kImageSourceCamera;
   
   [self coreGetCameraPicture:UIImagePickerControllerSourceTypeCamera];
}

- (void)getAlbumPicture
{
   self.usedImageSource = kImageSourceSavedPhotosAlbum;
   
   [self coreGetCameraPicture:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
}

- (void)coreGetCameraPicture:(UIImagePickerControllerSourceType)srcType
{
   UIImagePickerController  *picker = [[UIImagePickerController alloc] init];
   
   picker.delegate = self;
   picker.allowsEditing = NO;
   picker.sourceType = srcType;
   // this apperas to be default
   // picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];  -> there is kUTTypeMovie
   
   [self presentModalViewController:picker animated:YES];
   
   [picker release];
}

- (void)selectExistingPicture
{
   self.usedImageSource = kImageSourcePhotoLibrary;
   
   if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])  {
      UIImagePickerController  *picker = [[UIImagePickerController alloc] init];
      
      picker.delegate = self;
      picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
      picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
      
      [self presentViewController:picker animated:YES completion:nil];
      
      // [self presentModalViewController:picker animated:YES];
      
      [picker release];
   }
   else  {
      UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:@"Error accessing photo library!"
                                                       message:@"Device does not support a photo library"
                                                      delegate:nil
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:nil];
      [alert show];
      [alert release];
   }
}

#pragma mark -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   UIImage  *newImage = [[info objectForKey:@"UIImagePickerControllerOriginalImage"] retain];
   
   // [[picker parentViewController] dismissModalViewControllerAnimated:YES];
   // [self dismissModalViewControllerAnimated:YES];
   // [picker dismissModalViewControllerAnimated:YES];
   
   UIActivityIndicatorView  *tmpActIndicator = [[UIActivityIndicatorView alloc]
                                                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
   
   self.actIndicatorView = tmpActIndicator;
   
   [tmpActIndicator release];
   
   self.actIndicatorView.hidden = NO;
   self.actIndicatorView.center = self.view.center;
   
   [self.view addSubview:self.actIndicatorView];
   [self.actIndicatorView startAnimating];
   
   self.view.userInteractionEnabled = NO;
   
   [picker dismissViewControllerAnimated:YES completion:nil];
   
   [self performSelector:@selector(finishedAddingNewImage:) withObject:newImage afterDelay:.9];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
   // [self dismissModalViewControllerAnimated:YES];
   [picker dismissViewControllerAnimated:YES completion:nil];
} 

- (void)finishedAddingNewImage:(UIImage *)newImage
{
   [self acceptAndStoreNewImage:newImage withImageKey:nil];
   
   [self.actIndicatorView stopAnimating];
   [self.actIndicatorView removeFromSuperview];
   self.actIndicatorView = nil;
   
   self.view.userInteractionEnabled = YES;
      
   [newImage release];
   
   [self startNewGameWithMediaItem:nil imageKey:nil builtInIndex:0];
#ifdef _FREEMEM_
   ZaSliderAppDelegate  *appDelegate = (ZaSliderAppDelegate *)[[UIApplication sharedApplication] delegate];
   
   [appDelegate handleCheckMemoryWithDescription:@"ZaSliderViewController-finishedAddingNewImage:" showAlert:NO];
#endif
}

#pragma mark -
#pragma mark Delegates
#pragma mark -

- (void)imageCacheDidFinishCreatingTileImage:(UIImage *)tileImage forKey:(NSString *)key withTileLocIndex:(NSUInteger)idx;
{
   for (TileView  *ourTile in self.theSliderViewController.ourGameController.allTiles)  {
      if (ourTile.locIndex == idx)
         ourTile.picView.image = tileImage;
   }
}

// We're gonna need this to set thumb image anyway!!!!  25_09_2010

- (void)imageCacheDidFinishCreatingSmallImage:(UIImage *)smallImage thumbnail:(UIImage*)thumbImage forKey:(NSString *)key;
{
   NSUInteger  idx;
   
   if (custAlbumFlushed)  {
      [self loadSavedAlbums];
      // NSLog (@"Possible problem: fresh album, changing thumb!");
   }

   MediaItem  *tmpMediaItem = [self.custImageAlbum mediaItemForKey:key returningIndex:&idx];
   
   if (tmpMediaItem)  {
      tmpMediaItem.smallImage = smallImage;
      tmpMediaItem.imgThumb   = thumbImage;
      
      self.custImageAlbum.dirtyFlag = YES;
      self.currentImageKey = key;

#ifdef _IMGSIZE_LOG_
      NSLog (@"ResultSize: [%.0f,%.0f] O: [%d]", smallImage.size.width, smallImage.size.height, smallImage.imageOrientation);
#endif
   }
}

@end


/*
 - (IBAction)startButtonAction:(id)sender
 {
 NSString    *tmpImageKey;
 NSInteger    tmpImageIndex;
 MediaItem   *tmpMediaItem;
 // ImageAlbum  *tmpAlbum;
 
 if (!theSliderViewController)
 theSliderViewController = [[SliderViewController alloc] initWithMainViewController:self
 initialGameState:nil
 initialImage:nil
 andSideElements:gGPrefsRec.pfSideElems];
 
 if (custAlbumFlushed)
 [self loadSavedAlbums];
 
 UIImage  *gameImage = [builtInAlbum randomImageWithOtherAlbum:self.custImageAlbum
 returningImageKey:&tmpImageKey
 orReturningIndex:&tmpImageIndex
 andReturningMediaItem:&tmpMediaItem];
 
 if (!tmpMediaItem.smallImage)
 tmpMediaItem.smallImage = gameImage;  // WHY???
 
 [self startNewGameWithMediaItem:tmpMediaItem imageKey:tmpImageKey builtInIndex:tmpImageIndex];
 }
*/
