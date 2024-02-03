//
//  SliderViewController.m
//  ZaSlider
//
//  Created by Igor Delovski on 15.09.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import  "SliderViewController.h"
#import  "SliderViewController+Layout.h"

#import  "ZaSliderViewController.h"
#import  "PrefsViewController.h"
#import  "GameState.h"
#import  "GameHistory.h"
#import  "GradView.h"


@implementation SliderViewController

@synthesize  gameView, backImageView;
@synthesize  middleBarLabel, tileIdBarLabel, tileIdBarBadge, bottomToolBar, doneButton, restartButton, helpButton;
@synthesize  goSignView, stopSignView, pauseSignView;
@synthesize  ourGameController, touchedTileView, doubleTappedTileView, sliderImage;
@synthesize  inManualMovement, /*prefsVController,*/ mainViewController, shuffleCnt, gsToStartWith, accRefDate, lastMsgDate;
@synthesize  gameTimer, sideElemsToStartWith, shouldShowTileNumbers;

- (id)initWithMainViewController:(UIViewController *)vc
                initialGameState:(GameState *)gs
                    initialImage:(UIImage *)imgOrNil
              showingTileNumbers:(BOOL)shouldShow
                 andSideElements:(NSInteger)sideElems
{
   if (self = [super initWithNibName:@"SliderViewController" bundle:nil])  {
      self.mainViewController = (ZaSliderViewController *)vc;
      
      self.gsToStartWith = gs;
      self.sliderImage = imgOrNil;
      self.sideElemsToStartWith = sideElems;
      self.shouldShowTileNumbers = shouldShow;
   }

   return (self);
}

 - (void)viewDidLoad
{
   [super viewDidLoad];
   
   lastInterfaceOrientation = UIDeviceOrientationPortrait;
   
   [self setupBarLabel:self.middleBarLabel withStartText:@"" andFontSize:30.f];  // was 00:00
   [self setupBarLabel:self.tileIdBarLabel withStartText:@"" andFontSize:22.f];
   [self resetCloseBarButton];
   [self setupHelpButton];
}

- (void)setupGameView
{
   if (!self.ourGameController)  {
      if (self.gsToStartWith /*&& self.sliderImage*/)  {
         self.ourGameController = [[GameController alloc] initWithGameState:self.gsToStartWith
                                                                sliderImage:self.sliderImage
                                                                     inView:self.gameView];
         self.gsToStartWith = nil;
      }
      else
         self.ourGameController = [[GameController alloc] initWithNumberOfSideElements:self.sideElemsToStartWith
                                                                                 image:self.sliderImage
                                                                                inView:self.gameView];
   }
   
   if (self.ourGameController.gcGamePhase == kGameStarting)  // If it wasn't read from saved game
      [self startShuffling];
   else  if (!self.gameTimer)
      self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(onGameTimer) userInfo:nil repeats:YES];
   
   [self hideRestartBarButton];
   [self handleBarLabelsWithTileIdText:nil];

   [self setupSignViews];  // last thing to do, adds subViews on top of everything else
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)viewDidLayoutSubviews
{
   [super viewDidLayoutSubviews];
   
   [self layoutViewComponents];
   
   if (!self.ourGameController)
      [self setupGameView];
}

- (BOOL)canBecomeFirstResponder
{
   return (YES);
}

- (void)didReceiveMemoryWarning
{
   // Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];
   
   // Release any cached data, images, etc that aren't in use.
}

/*
- (void)viewDidUnload
{
   // Release any retained subviews of the main view.
   // e.g. self.myOutlet = nil;
   // self.infoButton = nil;
   // self.ourGameController = nil;
   
   self.doubleTappedTileView = nil;
   
   self.middleBarLabel = nil;
   self.tileIdBarLabel = nil;
   self.bottomToolBar = nil;
   self.tileIdBarBadge = nil;

   if (self.gameTimer)  {
      [self.gameTimer invalidate];
      self.gameTimer = nil;
   }
}
*/

- (void)viewDidAppear:(BOOL)animated
{
   UIAccelerometer  *accel = [UIAccelerometer sharedAccelerometer];
   UIApplication    *app   = [UIApplication sharedApplication];

   NSLog (@"S viewDidAppear: game = %@", self.ourGameController ? @"YES" : @"NO");

   [super viewDidAppear:animated];
   
   // if (!self.ourGameController)
   //    [self setupGameView];
   
   [self becomeFirstResponder];
   
   if (inModalDialog)  {
      inModalDialog = NO;
      return;
   }
   
   if (!app.isIdleTimerDisabled)
      app.idleTimerDisabled = YES;
   
   [self resetCloseBarButton];
   
   // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
   
   accel.updateInterval = .2;
   accel.delegate = self;
   
   xTresholdToken = 0;
   yTresholdToken = -1;  // So it doesn' drom when it's shown for the first time

   // Maybe not a good place
   // if (!self.gameTimer && (self.ourGameController.gcGamePhase == kGameInProgress))
   //    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(onGameTimer) userInfo:nil repeats:YES]; 
}

- (void)viewWillDisappear:(BOOL)animated
{
   UIAccelerometer  *accel = [UIAccelerometer sharedAccelerometer];
   UIApplication    *app   = [UIApplication sharedApplication];

   [super viewWillDisappear:animated];
   
   [self resignFirstResponder];
   
   if (inModalDialog)
      return;

   if (app.isIdleTimerDisabled)
      app.idleTimerDisabled = NO;

   // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];

   accel.delegate = nil;

   if (self.gameTimer)  {
      [self.gameTimer invalidate];
      self.gameTimer = nil;
   }
   
   if (self.ourGameController.gcGamePhase == kGameShuffling)
      [NSObject cancelPreviousPerformRequestsWithTarget:self];
   [[ImageCache sharedImageCache] cancelAllCachingOperations];
}

- (void)dealloc
{
   // Timer
   if (gameTimer)  {
      [gameTimer invalidate];
      [gameTimer release];
   }

   [middleBarLabel release];
   [tileIdBarLabel release];
   [tileIdBarBadge release];
   [bottomToolBar release];
   [doneButton release];
   [restartButton release];
   [helpButton release];
   
   [goSignView release];
   [stopSignView release];
   [pauseSignView release];
   
   [ourGameController release];
   [touchedTileView release];
   [doubleTappedTileView release];
   [sliderImage release];
   
   [gsToStartWith release];
   // [prefsVController release];
   [mainViewController release];
   [accRefDate release];
   [lastMsgDate release];
   
   [super dealloc];
}

#pragma mark -

- (void)setupBarLabel:(UILabel *)label withStartText:(NSString *)startText andFontSize:(CGFloat)fSize
{
   // [label setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:30.0]];
   [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:fSize]];
   label.backgroundColor = [UIColor clearColor];
   // label.textColor = [UIColor orangeColor];
   label.textColor = [UIColor whiteColor];
   label.text = startText;
   label.textAlignment = UITextAlignmentCenter;
   label.alpha = 1.f;

   CATransform3D  scalingTransform = CATransform3DIdentity;
   
   scalingTransform = CATransform3DScale (scalingTransform, 0.9f, 1.f, 1.f);
   label.layer.transform = scalingTransform;
}

- (void)handleBarLabelsWithTileIdText:(NSString *)tileIdTextOrNil
{
   if (!self.tileIdBarBadge)  {
      self.tileIdBarBadge = [[OvalBadgeView alloc] initWithFrame:CGRectInset(self.tileIdBarLabel.frame, 1.f, 1.f)
                                               cornerRadius:5.f
                                                   andColor:[UIColor whiteColor]];
      [self.view insertSubview:self.tileIdBarBadge belowSubview:self.tileIdBarLabel];
   }
   
   if (!tileIdTextOrNil)  {
      self.tileIdBarLabel.text = @"";
      self.tileIdBarBadge.hidden = YES;
   }
   else  {
      self.tileIdBarLabel.text = tileIdTextOrNil;
      self.tileIdBarBadge.hidden = NO;
   }
}

- (void)resetCloseBarButton
{
   if (self.doneButton && self.ourGameController)
      self.doneButton.title = (self.ourGameController.gcGamePhase == kGameOver) ? @"Close" : @"Give Up";
}

- (void)setupHelpButton
{
   inModalDialog = NO;

   UIBarButtonItem  *barButton = [[UIBarButtonItem alloc] initWithTitle:@"?"
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(showHelp)];
   
   self.helpButton = barButton;
   [barButton release];
}

- (void)hideRestartBarButton
{
   // NSUInteger  itemsInToolBar = [self.bottomToolBar.items count];
   
   if (self.helpButton)  {
      NSMutableArray  *tmpItems = [self.bottomToolBar.items mutableCopy];
      if (!self.restartButton)
         self.restartButton = [tmpItems objectAtIndex:2];
      [tmpItems removeObjectAtIndex:2];
      [tmpItems addObject:self.helpButton];
      // self.bottomToolBar.items = tmpItems;
      [self.bottomToolBar setItems:tmpItems animated:YES];
      [tmpItems release];
   }
}

- (void)showRestartBarButton
{
   // NSUInteger  itemsInToolBar = [self.bottomToolBar.items count];
   
   if (self.restartButton)  {
      NSMutableArray  *tmpItems = [self.bottomToolBar.items mutableCopy];
      
      [tmpItems removeObjectAtIndex:2];
      [tmpItems addObject:self.restartButton];
      // self.bottomToolBar.items = tmpItems;
      [self.bottomToolBar setItems:tmpItems animated:YES];
      [tmpItems release];
   }
}

- (void)setupSignViews
{
   UIImage      *tmpImage;
   UIImageView  *imageView;
   
   CGRect        signRect, frameRect = self.view.frame;
   
   tmpImage  = [UIImage imageNamed:@"go_03.png"];
   imageView = [[UIImageView alloc] initWithImage:tmpImage];
   // imageView.frame = self.bounds;
   [self.view addSubview:imageView];
   imageView.hidden = YES;
   self.goSignView = imageView;
   [imageView release];
   
   tmpImage  = [UIImage imageNamed:@"stop_03.png"];
   imageView = [[UIImageView alloc] initWithImage:tmpImage];
   // imageView.frame = self.bounds;
   [self.view addSubview:imageView];
   imageView.hidden = YES;
   self.stopSignView = imageView;
   [imageView release];

   tmpImage  = [UIImage imageNamed:@"pause_03.png"];
   imageView = [[UIImageView alloc] initWithImage:tmpImage];
   // imageView.frame = self.bounds;
   [self.view addSubview:imageView];
   imageView.hidden = YES;
   self.pauseSignView = imageView;
   [imageView release];
   
   signRect.size = tmpImage.size;
   signRect.origin.x = (frameRect.size.width - signRect.size.width) / 2.f;
   signRect.origin.y = (frameRect.size.height - signRect.size.height - 44.f) / 2.f;
   
   self.goSignView.frame = signRect;
   self.stopSignView.frame = signRect;
   self.pauseSignView.frame = signRect;

   if (self.mainViewController.netController.netCompetingStatus == kCompetingStatusOpponentTurn)
      self.stopSignView.hidden = NO;
}

- (void)hideAllSignViews
{
   self.goSignView.hidden = YES;
   self.stopSignView.hidden = YES;
   self.pauseSignView.hidden = YES;
}

- (void)hideGoSignView
{
   self.goSignView.hidden = YES;
}

#pragma mark -

- (IBAction)stopButtonAction:(id)sender
{
   if (self.ourGameController.gcGamePhase == kGameOver)
      [self closeSlider];
   else  {
      UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:@"End game"
                                                       message:@"Are you sure you want to stop playing this round?"
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"Give Up", nil];
      [alert show];
      [alert release];
   }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
   if (buttonIndex)
      [self closeSlider];
}

- (void)closeSlider
{
   if (self.mainViewController.netController)
      [self.mainViewController postQuitMessage];  // to others on the network

   [self viewWillDisappear:NO];
   [self.mainViewController viewWillAppear:NO];
   [self.view removeFromSuperview];
   [self viewDidDisappear:NO];
   [self.mainViewController viewDidAppear:NO];

   self.ourGameController.gcGamePhase = kGameOver;
      
   [self.mainViewController finishAndReleaseGameControllers];
}

- (IBAction)restartGameAction:(id)sender
{
   // -handleShake can call this metod too!
   
   if (self.ourGameController.gcGamePhase != kGameOver)
      return;
   
   if (self.gameTimer)  {
      [self.gameTimer invalidate];
      self.gameTimer = nil;
   }
   self.shuffleCnt = 0;
   
   self.ourGameController.gcGamePhase = kGameStarting;
   self.ourGameController.secondsInGame = 0;
   
   [self setupBarLabel:self.middleBarLabel withStartText:@"" andFontSize:30.f];  // was 00:00
   [self setupBarLabel:self.tileIdBarLabel withStartText:@"" andFontSize:22.f];
   [self resetCloseBarButton];

   [self hideRestartBarButton];
   [self hideAllSignViews];
   [self.mainViewController changeGameImage];
   [self startShuffling];
}

#pragma mark -

- (void)showHelp
{
   inModalDialog = YES;
   
	[self.mainViewController helpButtonAction:self];  // must be VC as param
}

#pragma mark -

- (void)moveTile:(TileView *)tileView toLocationIndex:(int)aLocation fast:(BOOL)fastFlag
{
   NSTimeInterval  aniDuration = /*fastFlag ? 0.05 :*/ kMoveAnimationDuration;
   // NSInteger       oldLocIndex = tileView.curLocIndex;    // this becomes empty after the move
   
   if (!fastFlag)  {
      [UIView beginAnimations:@"Shuffle" context:tileView];
      [UIView setAnimationDuration:aniDuration];
      if (tileView.curLocIndex != aLocation)  {   // We don't need to check if tile is comming home because it already is home
         [UIView setAnimationDelegate:self];
         [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
      }
   }
   
   tileView.curLocIndex = aLocation;   // sets frame property inside
   
   if (!fastFlag)
      [UIView commitAnimations];
#ifdef _NIJE_
   else  {
      // Move this down into exchange method!
      NSInteger  numberOfTiles = self.ourGameController.sideElements * self.ourGameController.sideElements;
      CGFloat    nextAniDelay = [[ImageCache sharedImageCache] operationsInProgress] ? 0.5 : 0.1;
      
      if ([self networkedPlay])
         nextAniDelay += 0.1;

      if ((shuffleCnt < numberOfTiles*3) ||
          (/*self.ourGameController.emptyTileLocIndex*/oldLocIndex != (numberOfTiles-1)) ||
          [self allTilesAtCorrectLocation] ||
          ![self allTilesHaveImages])  {
         // NSLog (@"moveTile:toLocationIndex:fastFlag: OldLoc:%d, NewLoc: %d, Empty: %d", oldLocIndex, aLocation, self.ourGameController.emptyTileLocIndex);
         // [NSObject cancelPreviousPerformRequestsWithTarget:self];
         [self performSelector:@selector(startOneShuffleMove) withObject:nil afterDelay:nextAniDelay];
      }
      else  {
         // self.view.userInteractionEnabled = YES;
         self.ourGameController.gcGamePhase = kGameInProgress;
         if (!self.gameTimer)
            self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(onGameTimer) userInfo:nil repeats:YES];
      }
   }
#endif
}

- (void)exchangeTileWithEmptyTile:(TileView *)tileView whenShuffling:(BOOL)fastFlag asResponseToPeer:(BOOL)responseFlag
{
   NSInteger  tileLocIndex = tileView.curLocIndex;  // this becomes empty after the move
   NSInteger  emptyLocIndex = self.ourGameController.emptyTileLocIndex;
   
   TileView   *emptyTileView = [self.ourGameController.allTiles objectAtIndex:emptyLocIndex];

   [self moveTile:tileView toLocationIndex:emptyLocIndex fast:fastFlag];
   self.ourGameController.emptyTileLocIndex = tileLocIndex;
   emptyTileView.curLocIndex = tileLocIndex;
   [self.ourGameController.allTiles exchangeObjectAtIndex:emptyLocIndex withObjectAtIndex:tileLocIndex];

   if (!responseFlag)
      [self.mainViewController postOurMoveFromLocIndex:tileLocIndex toLocIndex:emptyLocIndex];
   
   if (fastFlag)  {
      NSInteger  numberOfTiles = self.ourGameController.sideElements * self.ourGameController.sideElements;
      CGFloat    nextAniDelay = ([[ImageCache sharedImageCache] operationsInProgress] ? 0.5 : 0.1);
      
      if ([self networkedPlay])
         nextAniDelay += 0.1;

      if ((shuffleCnt < numberOfTiles*3) ||
          (tileLocIndex != (numberOfTiles-1)) ||
          [self allTilesAtCorrectLocation] ||
          ![self allTilesHaveImages])  {
         // NSLog (@"moveTile:toLocationIndex:fastFlag: OldLoc:%d, NewLoc: %d, Empty: %d", oldLocIndex, aLocation, self.ourGameController.emptyTileLocIndex);
         // [NSObject cancelPreviousPerformRequestsWithTarget:self];
         [self performSelector:@selector(startOneShuffleMove) withObject:nil afterDelay:nextAniDelay];
      }
      else  {
         // self.view.userInteractionEnabled = YES;
         self.ourGameController.gcGamePhase = kGameInProgress;
         if (!self.gameTimer)
            self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(onGameTimer) userInfo:nil repeats:YES];
         if ([self netCompetition])  {
            firstWrongTileLocIdxForThisTurn = [self firstTileAtWrongLocationUpdatingArrow:NO];
#ifdef  _MOVEMENT_LOG_
            NSLog (@"Starting with firstWrong: %d", firstWrongTileLocIdxForThisTurn);
#endif
         }
      }
   }
}

- (BOOL)tryXSlopeMove:(NSInteger)xDirection whenShuffling:(BOOL)fastFlag  // dir -1 or 1
{
   int  extraLuck = fastFlag ? !(arc4random() % 5) : 1;  //  When shuffling, avoid going back where you've been...
   
   for (int i=0; i<[self.ourGameController.allTiles count]; i++)  {
      TileView  *tileView = [self.ourGameController.allTiles objectAtIndex:i];
      if ([self.ourGameController tileCanMoveByXToEmptyTileFromIndex:tileView.curLocIndex inDirection:xDirection])  {
         if (extraLuck || (tileView.prevLocIndex != self.ourGameController.emptyTileLocIndex))  {
            [self exchangeTileWithEmptyTile:tileView whenShuffling:fastFlag asResponseToPeer:NO];
            if (self.ourGameController.gcGamePhase == kGameInProgress)
               [self testEndOfGameRound];

            return (YES);
         }
      }
   }
   return (NO);
}

- (BOOL)tryYSlopeMove:(NSInteger)yDirection whenShuffling:(BOOL)fastFlag  // -1 or 1
{
   int  extraLuck = fastFlag ? !(arc4random() % 5) : 1;  //  When shuffling, avoid going back where you've been...

   for (int i=0; i<[self.ourGameController.allTiles count]; i++)  {
      TileView  *tileView = [self.ourGameController.allTiles objectAtIndex:i];
      if ([self.ourGameController tileCanMoveByYToEmptyTileFromIndex:tileView.curLocIndex inDirection:yDirection])  {
         if (extraLuck || (tileView.prevLocIndex != self.ourGameController.emptyTileLocIndex))  {
            [self exchangeTileWithEmptyTile:tileView whenShuffling:fastFlag asResponseToPeer:NO];
            if (self.ourGameController.gcGamePhase == kGameInProgress)
               [self testEndOfGameRound];
         
            return (YES);
         }
      }
   }
   return (NO);
}

#pragma mark -

- (NSInteger)firstTileAtWrongLocationUpdatingArrow:(BOOL)updateArrowFlag
{
   NSUInteger  totalElems = [self.ourGameController.allTiles count];
   NSUInteger  firstWrongTileLocIndex = totalElems;
   NSUInteger  firstWrongTileCurLocIndex = totalElems;
   TileView   *tileView = nil;
   // check each tile if it's in the right place
   
   if (updateArrowFlag)
      [self handleBarLabelsWithTileIdText:nil];
   
   for (int i=0; i<totalElems; i++)  {
      tileView = [self.ourGameController.allTiles objectAtIndex:i];
      if (tileView.locIndex != tileView.curLocIndex)  {
         if (tileView.locIndex < firstWrongTileLocIndex)  {
            firstWrongTileLocIndex = tileView.locIndex;
            firstWrongTileCurLocIndex = i;
         }
      }
      if (self.shouldShowTileNumbers)  {
         if (updateArrowFlag)
            [tileView hideArrow];
      }
      else  {
         tileView.indexLabel.hidden = YES;
         tileView.highliteView.hidden = YES;
         tileView.arrowView.hidden = YES;
      }
   }
   
   if (updateArrowFlag && (firstWrongTileCurLocIndex < totalElems))  {
      tileView = [self.ourGameController.allTiles objectAtIndex:firstWrongTileCurLocIndex];
      if (self.shouldShowTileNumbers)
         [tileView showArrow];
      [self handleBarLabelsWithTileIdText:[NSString stringWithFormat:@"%d", tileView.locIndex+1]];
   }
   
   return (firstWrongTileLocIndex);
}

- (NSInteger)showArrowAtFirstTileAtWrongLocation
{
   return ([self firstTileAtWrongLocationUpdatingArrow:YES]);
}

- (BOOL)allTilesAtCorrectLocation
{
/*
   // check each tile if it's in the right place
   
   for (int i=0; i<[self.ourGameController.allTiles count]; i++)  {
      TileView  *tileView = [self.ourGameController.allTiles objectAtIndex:i];
      if (tileView.tileType != kEmptyTile && tileView.locIndex != tileView.curLocIndex)
         return (NO);
   }
   
   return (YES);
*/
   return ([self allTilesAtCorrectLocationUpToTileLocIndex:[self.ourGameController.allTiles count]]);
}

- (BOOL)allTilesAtCorrectLocationUpToTileLocIndex:(NSInteger)locIndex
{
   BOOL  retVal = YES;
#ifdef  _MOVEMENT_LOG_
   NSLog (@"allTilesAtCorrectLocationUpToTileLocIndex: %d", locIndex);
#endif

   NSUInteger  totalElems = [self.ourGameController.allTiles count];
   // check each tile if it's in the right place
   
   // [self showArrowAtFirstTileAtWrongLocation];
   
   NSInteger  firstTileAtWrongLocIdx = [self firstTileAtWrongLocationUpdatingArrow:YES];
   
   for (int i=0; i<locIndex && i<totalElems; i++)  {
      TileView  *tileView = [self.ourGameController.allTiles objectAtIndex:i];
      if (tileView.locIndex != tileView.curLocIndex)  {
#ifdef  _SHUFFLING_LOG_
         NSLog (@"Tile %d at wrong location.", tileView.curLocIndex);
#endif
         retVal = NO;
         break;
      }
      if ((locIndex != totalElems) && (tileView.locIndex != i))  {
         retVal = NO;
         break;
      }
   }
   
   if ([self netCompetition] && (firstTileAtWrongLocIdx > firstWrongTileLocIdxForThisTurn))  {
#ifdef  _MOVEMENT_LOG_
      NSLog (@"About to swap turns, firstWrong Before: %d, firstWrong Now: %d", firstWrongTileLocIdxForThisTurn, firstTileAtWrongLocIdx);
#endif
      [self swapTurns];
      firstWrongTileLocIdxForThisTurn = firstTileAtWrongLocIdx;
   }
#ifdef  _MOVEMENT_LOG_
   else
      NSLog (@"NOT TO SWAP TURNS, firstWrong Before: %d, firstWrong Now: %d", firstWrongTileLocIdxForThisTurn, firstTileAtWrongLocIdx);
#endif
   
   return (retVal);
}

- (BOOL)allTilesHaveImages
{
   // check each tile if it has image already attached
   
   for (int i=0; i<[self.ourGameController.allTiles count]; i++)  {
      TileView  *tileView = [self.ourGameController.allTiles objectAtIndex:i];
      if (/*(tileView.tileType != kEmptyTile) &&*/ !tileView.picView.image)
         return (NO);
   }
   
   return (YES);
}

- (void)showEmptyTilesImage
{
   // at the end, show hidden image on emptu tile
   
   for (int i=0; i<[self.ourGameController.allTiles count]; i++)  {
      TileView  *tileView = [self.ourGameController.allTiles objectAtIndex:i];
      if (tileView.tileType == kEmptyTile)  {
         tileView.picView.hidden = NO;
         tileView.picView.alpha = 1.f;
      }
      else  {
         tileView.arrowView.hidden = YES;
         tileView.highliteView.hidden = YES;
         tileView.indexLabel.hidden = YES;
      }
   }
}

- (void)testEndOfGameRound
{
   if (![self allTilesAtCorrectLocation])
      return;
   
   if (self.ourGameController.gcGamePhase != kGameInProgress)
      return;
   
   self.ourGameController.gcGamePhase = kGameOver;
   
   
   if (self.mainViewController.netController)
      [self.mainViewController postOurTimeAtFinish:self.ourGameController.secondsInGame];
   else  {
      [mainViewController addGameToHistory:self.ourGameController
                         finishedInSeconds:self.ourGameController.secondsInGame
                          opponentsSeconds:0];
      
      [self performSelector:@selector(declareEndOfGameRound:) withObject:nil afterDelay:kMoveAnimationDuration/2.f];  // wait for animations to complete
   }
}

- (void)declareEndOfGameRound:(GameHistory *)gh
{
   NSString     *message;
   
   if ([self netCompetition] && gh)  {
      NSUInteger  ourSecs   = gh.weFinishedInSeconds;
      NSUInteger  theirSecs = gh.theyDidItInSeconds;
      
      if (ourSecs < theirSecs)
         message = [NSString stringWithFormat:@"You have just won the game:\n%d vs %d seconds.\nCongratulations!", ourSecs, theirSecs];
      else
         message = @"Your opponent won the game. Better luck next time!";
   }
   else
      message = @"You have just completed the game. Congratulations!";
   
   UIApplication    *app   = [UIApplication sharedApplication];
   
   app.statusBarOrientation = lastInterfaceOrientation;
      
   UIAlertView  *alertView = [[UIAlertView alloc] initWithTitle:@"Game Complete!"
                                                       message:message
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
     
   [alertView show];
   app.statusBarOrientation = UIDeviceOrientationPortrait;
   [alertView release];
   
   [self showEmptyTilesImage];

   [self resetCloseBarButton];
   if (![self networkedPlay])  {
      [self showRestartBarButton];
      [self hideAllSignViews];
   }
}

#pragma mark -
#pragma mark Touches

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   UITouch    *touch = [touches anyObject];
   NSUInteger  tapCount = [touch tapCount];
   
   if ([self netCompetition] && [self waitingForOpponent])
      return;
   
   if (self.inManualMovement || self.touchedTileView)  // already tracking a touch
      return;

   if ((self.ourGameController.gcGamePhase != kGameInProgress) &&
       (self.ourGameController.gcGamePhase != kGamePaused))
      return;
   
   if (self.ourGameController.gcGamePhase == kGameInProgress)  {
      self.inManualMovement = YES;
   
      for (int i=0; i<[self.ourGameController.allTiles count]; i++)  {
         TileView  *tileView = [self.ourGameController.allTiles objectAtIndex:i];
         if ([touch view] == tileView)  {
            [self.mainViewController postOurTouchAtLocIndex:tileView.curLocIndex];
            self.touchedTileView = tileView;
         }
      }
   }

   if (tapCount != 2)  {
      CGPoint  touchPoint = [touch locationInView:self.gameView];  // was self.view

      if (CGRectContainsPoint(bottomToolBar.frame, touchPoint))  {
         if (!self.touchedTileView && ![self netCompetition])  {
            if (self.ourGameController.gcGamePhase == kGameInProgress)  {
               self.ourGameController.gcGamePhase = kGamePaused;
               self.pauseSignView.hidden = NO;
            }
            else if (self.ourGameController.gcGamePhase == kGamePaused)  {
               self.ourGameController.gcGamePhase = kGameInProgress;
               self.pauseSignView.hidden = YES;
            }
         }
      }
      
      return;
   }

   for (int i=0; i<[self.ourGameController.allTiles count]; i++)  {
      TileView  *tileView = [self.ourGameController.allTiles objectAtIndex:i];
      if ([touch view] == tileView)
         if ([self.ourGameController tileCanMoveToEmptyTileFromIndex:tileView.curLocIndex])
            self.doubleTappedTileView = tileView;
   }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
   UITouch *touch = [touches anyObject];
   
   if ([self netCompetition] && [self waitingForOpponent])
      return;
   if (self.ourGameController.gcGamePhase != kGameInProgress)
      return;

   for (int i=0; i<[self.ourGameController.allTiles count]; i++)  {
      TileView  *tileView = [self.ourGameController.allTiles objectAtIndex:i];
      TileView  *emptyTileView = [self.ourGameController.allTiles objectAtIndex:self.ourGameController.emptyTileLocIndex];

      if ([touch view] == tileView && tileView == self.touchedTileView)  {
         if ([self.ourGameController tileCanMoveToEmptyTileFromIndex:tileView.curLocIndex])  {
            CGPoint  touchPoint = [touch locationInView:self.gameView];  // was self.view
            CGFloat  maxX, minX, minY, maxY;

            CGRect   movingTileRect = [GameController rectForLocationIndex:tileView.curLocIndex withSideElements:tileView.sideElements withTileSize:tileView.sizeInPixels];
            CGRect   emptyTileRect = [GameController rectForLocationIndex:emptyTileView.curLocIndex withSideElements:emptyTileView.sideElements withTileSize:emptyTileView.sizeInPixels];

            CGRect   slideRect = CGRectUnion (movingTileRect, emptyTileRect);
            CGFloat  centerPaddingX = tileView.sizeInPixels.width  / 2.f;
            CGFloat  centerPaddingY = tileView.sizeInPixels.height / 2.f;
            
            minX = slideRect.origin.x + centerPaddingX;
            minY = slideRect.origin.y + centerPaddingY;
            maxX = slideRect.origin.x + slideRect.size.width - centerPaddingX;
            maxY = slideRect.origin.y + slideRect.size.height - centerPaddingY;
            
            if (touchPoint.x > maxX)
               touchPoint.x = maxX;
            if (touchPoint.y > maxY)
               touchPoint.y = maxY;
            if (touchPoint.y < minY)
               touchPoint.y = minY;
            if (touchPoint.x < minX)
               touchPoint.x = minX;

            tileView.center = touchPoint;
            
            break;
         }
      }
   }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   UITouch *touch = [touches anyObject];
   BOOL     doubleTapCase = NO, needToCancelRemoteTouch = NO;
   
   self.inManualMovement = NO;
   
   if (self.ourGameController.gcGamePhase != kGameInProgress)
      return;

   TileView  *emptyTileView = [self.ourGameController.allTiles objectAtIndex:self.ourGameController.emptyTileLocIndex];

   for (int i=0; i<[self.ourGameController.allTiles count]; i++)  {
      TileView  *tileView = [self.ourGameController.allTiles objectAtIndex:i];

      if ([touch view] == tileView && tileView == self.touchedTileView)  {
         self.touchedTileView = nil;
         if ([self netCompetition])
            needToCancelRemoteTouch = YES;
         if (tileView == doubleTappedTileView)
            doubleTapCase = YES;
         
         if (doubleTapCase || [self.ourGameController tileCanMoveToEmptyTileFromIndex:tileView.curLocIndex])  {

            int oldLocationIdx = tileView.curLocIndex;
            
            // only move to the new location if the center of the moving tile is
            // inside the empty tile
            CGRect   emptyTileRect = [GameController rectForLocationIndex:emptyTileView.curLocIndex withSideElements:emptyTileView.sideElements withTileSize:emptyTileView.sizeInPixels];

            if (doubleTapCase || CGRectContainsPoint(emptyTileRect, tileView.center))  {
               [self exchangeTileWithEmptyTile:tileView whenShuffling:NO asResponseToPeer:NO];
               needToCancelRemoteTouch = NO;
            }
            else  {
               [self moveTile:tileView toLocationIndex:oldLocationIdx fast:NO];  // move it back!
            }
         }
         if (needToCancelRemoteTouch)
            [self.mainViewController postOurTouchAtLocIndex:-1];
         break;
      }      
   }
   [self testEndOfGameRound];


   self.doubleTappedTileView = nil;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
   self.touchedTileView = nil;
   self.doubleTappedTileView = nil;
   self.inManualMovement = NO;
   
   [self.mainViewController postOurTouchAtLocIndex:-1];
}

#pragma mark -

// Can't work here....

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
   // Shake is the only type for now
   
   if ([self netCompetition] && [self waitingForOpponent])
      return;

   if (motion == UIEventSubtypeMotionShake)  {
      NSLog (@"Shake!");
      
      [self handleShake];
   }
}

#pragma mark Accelerometer

- (void)updateTilesLabelOrientationWithAcceleration:(UIAcceleration *)acceleration
{
   static  float   xSaved = 0.;
   static  float   ySaved = 0.;
   // static  float   savedAngle = 0.;
   // static  float   proposedAngle = 0.;
   
   BOOL  needToUpdate = NO;

   if (fabs(acceleration.x) < 0.19 && fabs(acceleration.y) < 0.19)  // horizontal position
      return;

   if (fabs(acceleration.x - xSaved) > 0.1)
      needToUpdate = YES;
   if (fabs(acceleration.y - ySaved) > 0.1)
      needToUpdate = YES;
   
   xSaved = acceleration.x;
   ySaved = acceleration.y;
   
   if (!needToUpdate)
      return;
   
   // Erica2nd 598, modified formula from some web example
   
   float  angle = atan2f (acceleration.x, acceleration.y) + M_PI /*/ 2.0*/ + M_PI/4.f;
   float  useAngle = 0.f;
   
   lastInterfaceOrientation = UIDeviceOrientationPortrait;
   
   if (angle > M_PI * 2.f)
      angle -= M_PI * 2.f;
   
   if (angle > M_PI*3.f/2.f)  {
      useAngle = M_PI*3.f/2.f;
      lastInterfaceOrientation = UIDeviceOrientationLandscapeRight;
   }
   else  if (angle > M_PI)  {
      useAngle = M_PI;
      lastInterfaceOrientation = UIDeviceOrientationPortrait;
   }
   else  if (angle > M_PI / 2.f)  {
      useAngle = M_PI / 2.f;
      lastInterfaceOrientation = UIDeviceOrientationLandscapeLeft;
   }

   if (labelAngleInUse == useAngle)
      return;
   
   NSNumber *angleAsNumber = [NSNumber numberWithFloat:useAngle];

   [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rotateAllLabelToAngle:) object:angleAsNumber];
   
   [self performSelector:@selector(rotateAllLabelToAngle:) withObject:angleAsNumber afterDelay:1.];  // wait for animations to complete
}

- (void)rotateAllLabelToAngle:(NSNumber *)angleAsNumber
{
   NSMutableDictionary  *paramDictionary = [NSMutableDictionary dictionary];
   CGFloat               useAngle = [angleAsNumber floatValue];
   
   // if ([self.accRefDate timeIntervalSinceNow] > -1.)  // If the receiver is earlier than the current date and time, the return value is negative.
   //    return;

   [paramDictionary setObject:angleAsNumber forKey:@"angle"];
   [paramDictionary setObject:[NSNumber numberWithInt:0] forKey:@"index"];

   [self performSelector:@selector(rotateOneLabelToAngle:) withObject:paramDictionary afterDelay:.01];

   labelAngleInUse = useAngle;
}

- (void)rotateOneLabelToAngle:(NSMutableDictionary *)paramDictionary
{
   NSNumber  *angleAsNumber = [paramDictionary objectForKey:@"angle"];
   NSNumber  *indexAsNumber = [paramDictionary objectForKey:@"index"];

   CGFloat    useAngle = [angleAsNumber floatValue];
   NSInteger  idx = [indexAsNumber intValue];
   
   CGAffineTransform  transform = CGAffineTransformMakeRotation (useAngle);
   
   TileView  *tileView = [self.ourGameController.allTiles objectAtIndex:idx];
   [tileView.indexLabel setTransform:transform];
   
   if (++idx < [self.ourGameController.allTiles count])  {
      [paramDictionary setObject:[NSNumber numberWithInt:idx] forKey:@"index"];
      [self performSelector:@selector(rotateOneLabelToAngle:) withObject:paramDictionary afterDelay:.02];
   }
}

- (void)accelerometer:(UIAccelerometer *)accel didAccelerate:(UIAcceleration *)acceleration
{
   [self updateTilesLabelOrientationWithAcceleration:acceleration];
   
   if (!self.view.userInteractionEnabled || (self.ourGameController.gcGamePhase != kGameInProgress))
      return;
   
   if (!gGPrefsRec.pfUseAcceleration || self.inManualMovement)
      return;
   if ([self netCompetition] && [self waitingForOpponent])
      return;

   if (acceleration.y < -.75)  // Upright position - no go!
      return;
   
   if (((xTresholdToken > 0) && (acceleration.x < -.1)) || ((xTresholdToken < 0) && (acceleration.x > .1)))
      xTresholdToken = 0;
   if (((yTresholdToken > 0) && (acceleration.y < -.1)) || ((yTresholdToken < 0) && (acceleration.y > .1)))
      yTresholdToken = 0;
   
   if (!xTresholdToken)  {
      if (acceleration.x < -kTurnOnTreshold)  {
         xTresholdToken = -1;
      }
      else  if (acceleration.x > kTurnOnTreshold)  {
         xTresholdToken = 1;
      }
      if (xTresholdToken)  {
         [self tryXSlopeMove:xTresholdToken whenShuffling:NO];
         yTresholdToken = 2;                     // To avoid moves in both directions
      }
   }
   else  if ((acceleration.x > -kTurnOffTreshold) && (acceleration.x < kTurnOffTreshold))
      xTresholdToken = 0;

   if (!yTresholdToken)  {
      if (acceleration.y < -kTurnOnTreshold)  {
         yTresholdToken = -1;
      }
      else  if (acceleration.y > kTurnOnTreshold)  {
         yTresholdToken = 1;
      }
      if (yTresholdToken)  {
         [self tryYSlopeMove:yTresholdToken whenShuffling:NO];
         xTresholdToken = 2;                     // To avoid moves in both directions
      }
   }
   else  if ((acceleration.y > -kTurnOffTreshold) && (acceleration.y < kTurnOffTreshold))
      yTresholdToken = 0;
}


#pragma mark Shuffling

- (void)startShuffling
{
   shuffleCnt = 0;
   // self.view.userInteractionEnabled = NO;
   self.ourGameController.gcGamePhase = kGameShuffling;
   
   if (![self remoteShuffling])
      [self startOneShuffleMove];
}

- (void)startOneShuffleMove
{
   NSUInteger  moveType;
   NSUInteger  directionFlag;
   BOOL        doneSomething = NO;
   
   if (![self remoteShuffling])  while (!doneSomething)  {
      moveType = arc4random() % 2;
      directionFlag = (arc4random() % 2) ? 1 : -1;
      if (moveType)
         doneSomething = [self tryXSlopeMove:directionFlag whenShuffling:YES];
      else
         doneSomething = [self tryYSlopeMove:directionFlag whenShuffling:YES];
      // if (doneSomething)
      //    NSLog (@"startOneShuffleMove - cnt:%d, Type: %s, direction: %d", shuffleCnt, moveType ? "Hor" : "Ver", directionFlag);
   }
   shuffleCnt++;
}

#pragma mark -
#pragma mark Animations
#pragma mark -

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
   // CGRect        tmpRect;
   // BOOL          finishedFlag = [finished boolValue];
   // NSUInteger       numberOfTiles = self.ourGameController.sideElements * self.ourGameController.sideElements;
   
   // if (finishedFlag)
      // NSLog (@"animationDidStop with ID: %@!", animationID);
   
   if ([animationID isEqualToString:@"Shuffle"])  {
      TileView  *tmpTileView = (TileView *)context;
#ifdef _ANIMATIONS_LOG_
      NSLog (@"Shuffle Tile: %d at %d", tmpTileView.locIndex, tmpTileView.curLocIndex);
#endif
      
      if (tmpTileView.locIndex == tmpTileView.curLocIndex)
         if (!tmpTileView.locIndex || [self allTilesAtCorrectLocationUpToTileLocIndex:tmpTileView.locIndex])
            [self animateTileLandedHome:tmpTileView];
   }
   else  if ([animationID isEqualToString:@"Grow"])  {
      TileView  *tmpTileView = (TileView *)context;

#ifdef _ANIMATIONS_LOG_
      NSLog (@"End Grow Tile: %d at %d", tmpTileView.locIndex, tmpTileView.curLocIndex);
      NSLog (@"---------------------");
#endif

      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDuration:kGrowAnimationDuration];
      
      CGAffineTransform transform = CGAffineTransformMakeScale (1., 1.);
      tmpTileView.transform = transform;
      tmpTileView.alpha = 1.;
      
      [UIView commitAnimations];
   }
}

- (void)animateTileLandedHome:(TileView *)tv
{
   [UIView beginAnimations:@"Grow" context:tv];
   [UIView setAnimationDuration:kGrowAnimationDuration];
   [UIView setAnimationDelegate:self];
   [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
   
   CGAffineTransform transform = CGAffineTransformMakeScale (1.05, 1.05);
   tv.transform = transform;
   tv.alpha = 0.4;
   
#ifdef  _MOVEMENT_LOG_
   NSLog (@"Start Grow Tile: %d at %d", tv.locIndex, tv.curLocIndex);
#endif
   
   [UIView commitAnimations];
}

#pragma mark Shaking

- (void)handleShake
{
   if (self.inManualMovement || ![self allTilesHaveImages])
      return;
   if (self.ourGameController.gcGamePhase == kGameOver)  {
      [self restartGameAction:self];
      return;
   }
   if (!self.view.userInteractionEnabled || (self.ourGameController.gcGamePhase != kGameInProgress))
      return;

   [self.mainViewController changeGameImage];  // Need to report back that it's finished!
   
   // self.ourGameController.gcGamePhase = kGameInMakeover;
}

#pragma mark Timer handling

- (void)onGameTimer
{
   if ([self netCompetition] &&
       (self.mainViewController.netController.netControllerState != kNCStateDone) &&
       (self.mainViewController.netController.netControllerState != kNCStateBeginning) &&
       (self.mainViewController.netController.netControllerState != kNCStateWaiting))  {
      if ([self.lastMsgDate timeIntervalSinceNow] < -10.)   {  // accRefDate, If the receiver is earlier than the current date and time, the return value is negative.
         [self.mainViewController.netController sendPingPacket];
         self.lastMsgDate = [NSDate date];
      }
   }
   
   if ([self netCompetition] && [self waitingForOpponent])
      return;

   if (self.ourGameController.gcGamePhase == kGameInProgress)  {
      middleBarLabel.text = [GameHistory secondsToString:++self.ourGameController.secondsInGame withDescription:NO];
   }
}

#pragma mark -
#pragma mark Network Play
#pragma mark -

- (BOOL)networkedPlay  // we are not alone
{
   if (self.mainViewController.netController)
      return (YES);
   
   return (NO);
}

- (BOOL)remoteShuffling  // we are client
{
   if (self.mainViewController.netController && (self.mainViewController.netController.netClientServerStatus == kClientServerStatusClient))
      return (YES);
   
   return (NO);
}

- (BOOL)netCompetition  // networked game in competition mode
{
   if (self.mainViewController.netController && (self.mainViewController.netController.netCompetingStatus != kCompetingStatusCooperate))
      return (YES);

   return (NO);
}

- (BOOL)waitingForOpponent  // are we waiting for the oponents move?
{
   if (self.mainViewController.netController && (self.mainViewController.netController.netCompetingStatus == kCompetingStatusOpponentTurn))
      return (YES);
   
   return (NO);
}

- (void)swapTurns
{
   if (self.mainViewController.netController)  {
      if (self.mainViewController.netController.netCompetingStatus == kCompetingStatusOpponentTurn)  {
         self.mainViewController.netController.netCompetingStatus = kCompetingStatusMyTurn;
         self.goSignView.hidden = NO;
         self.stopSignView.hidden = YES;
         [self performSelector:@selector(hideGoSignView) withObject:nil afterDelay:.3];
      }
      else  if (self.mainViewController.netController.netCompetingStatus == kCompetingStatusMyTurn)  {
         self.mainViewController.netController.netCompetingStatus = kCompetingStatusOpponentTurn;
         self.stopSignView.hidden = NO;
      }
      else
         NSLog (@"swapTurns but niether my turn nor the opponents turn!");
   }
}

- (BOOL)asResponseMoveTileFromLocIndex:(NSInteger)fromLocIndex toLocIndex:(NSInteger)toLocIndex
{
   TileView  *tileView = [self.ourGameController.allTiles objectAtIndex:fromLocIndex];
   
   tileView.fingerView.hidden = YES;
   
   self.lastMsgDate = [NSDate date];
   
   if (toLocIndex == self.ourGameController.emptyTileLocIndex)  {
      
      BOOL  fastFlag = self.ourGameController.gcGamePhase != kGameInProgress;
      
      [self exchangeTileWithEmptyTile:tileView whenShuffling:fastFlag asResponseToPeer:YES];
      if (self.ourGameController.gcGamePhase == kGameInProgress)
         [self testEndOfGameRound];
      
      return (YES);
   }
   
   return (NO);
}

- (BOOL)asResponseTouchTileLocIndex:(NSInteger)locIndex
{
   NSInteger  numberOfTiles = self.ourGameController.sideElements * self.ourGameController.sideElements;
   
   self.lastMsgDate = [NSDate date];
   
   if (locIndex < 0 || locIndex >= numberOfTiles)  {
      for (int i=0; i<[self.ourGameController.allTiles count]; i++)  {
         TileView  *tileView = [self.ourGameController.allTiles objectAtIndex:i];
         if (!tileView.fingerView.isHidden)
            tileView.fingerView.hidden = YES;
      }
   }
   else  if (locIndex != self.ourGameController.emptyTileLocIndex)  {
      TileView  *tileView = [self.ourGameController.allTiles objectAtIndex:locIndex];

      tileView.fingerView.hidden = NO;
      
      return (YES);
   }
   else
      NSLog (@"asResponseTouchTileLocIndex - strange location: %d", locIndex);
   
   return (NO);
}

#pragma mark -

- (void)asResponseCompareOpponentsTime:(NSUInteger)timeInSeconds
{
   GameHistory  *tmpGH = [mainViewController addGameToHistory:self.ourGameController
                                            finishedInSeconds:self.ourGameController.secondsInGame
                                             opponentsSeconds:timeInSeconds];
   
   [self performSelector:@selector(declareEndOfGameRound:) withObject:tmpGH afterDelay:kMoveAnimationDuration/3.f];  // wait for animations to complete
   
   self.lastMsgDate = [NSDate date];
}

- (void)asResponseHandleOpponentsQuit
{
   // Tell Game Controller Opponent's gone!
   if (self.mainViewController.netController)
      self.mainViewController.netController.netControllerState = kNCStateDone;
   
   self.lastMsgDate = [NSDate date];
}

- (void)asResponseHandleOpponentsPing
{
   self.lastMsgDate = [NSDate date];
}

@end
