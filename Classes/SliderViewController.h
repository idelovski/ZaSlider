//
//  SliderViewController.h
//  ZaSlider
//
//  Created by Igor Delovski on 15.09.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TileView.h"
#import "GameController.h"
#import "NetworkingController.h"
#import "PrefsViewController.h"

@class  GameState, GameHistory, ZaSliderViewController, OvalBadgeView;


@interface SliderViewController : UIViewController <UIAccelerometerDelegate, UIAlertViewDelegate> {
   UILabel          *middleBarLabel;
   UILabel          *tileIdBarLabel;
   OvalBadgeView    *tileIdBarBadge;
   UIToolbar        *bottomToolBar;
   UIBarButtonItem  *doneButton;         // Give Up / Close
   UIBarButtonItem  *restartButton;      // Start Over
   UIBarButtonItem  *helpButton;         // Question Mark
   
   UIImageView      *backImageView;
   UIView           *gameView;

   UIImageView      *goSignView;
   UIImageView      *stopSignView;
   UIImageView      *pauseSignView;
   GameController   *ourGameController;
   TileView         *touchedTileView;
   TileView         *doubleTappedTileView;
   UIImage          *sliderImage;
   
   GameState        *gsToStartWith;
   NSInteger         sideElemsToStartWith;
   NSInteger         shouldShowTileNumbers;
   NSTimer          *gameTimer;
   
   // PrefsViewController     *prefsVController;
   ZaSliderViewController  *mainViewController;
   
   // UIAcceleration      *recentAacceleration;
   NSDate          *accRefDate;  // related to tile numbers orientation
   NSDate          *lastMsgDate;  // related to tile numbers orientation
   // NSUInteger       secondsInGame;     // increment on timer
   NSInteger        xTresholdToken;    // -1, 0, 1
   NSInteger        yTresholdToken;    // -1, 0, 1
   NSInteger        shuffleCnt;        // number of animations so far 
   BOOL             inManualMovement;  // fingered by user, avoid gravitational moves
   BOOL             inModalDialog;     // keep the view alive while in help
   CGFloat          labelAngleInUse;   // current angle used for labels
   UIInterfaceOrientation   lastInterfaceOrientation;  // set with labelAngleInUse

   // Network play related internals
   
   NSInteger        firstWrongTileLocIdxForThisTurn;   // what we started with
}

// @property (nonatomic, retain) IBOutlet UIButton        *stopButton;
// @property (nonatomic, retain) IBOutlet UIButton        *infoButton;
@property (nonatomic, retain) IBOutlet UILabel          *middleBarLabel;
@property (nonatomic, retain) IBOutlet UILabel          *tileIdBarLabel;
@property (nonatomic, retain) IBOutlet OvalBadgeView    *tileIdBarBadge;  // Outlet !???

@property (nonatomic, retain) IBOutlet UIToolbar        *bottomToolBar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem  *doneButton;
@property (nonatomic, retain)          UIBarButtonItem  *restartButton;  // can't be IBOutlet
@property (nonatomic, retain)          UIBarButtonItem  *helpButton;     // can't be IBOutlet

@property (nonatomic, retain) IBOutlet UIView           *gameView;
@property (nonatomic, retain) IBOutlet UIImageView      *backImageView;

@property (nonatomic, retain)          UIImageView      *goSignView;
@property (nonatomic, retain)          UIImageView      *stopSignView;
@property (nonatomic, retain)          UIImageView      *pauseSignView;

@property (nonatomic, retain)          GameController   *ourGameController;
@property (nonatomic, retain)          NSTimer          *gameTimer;
@property (nonatomic, retain)          TileView         *touchedTileView;     // so we know to ignore other fingers
@property (nonatomic, retain)          TileView         *doubleTappedTileView;
@property (nonatomic, retain)          UIImage          *sliderImage;

@property (assign)                     NSInteger         sideElemsToStartWith;
@property (assign)                     NSInteger         shouldShowTileNumbers;

@property (nonatomic, retain)          GameState        *gsToStartWith;

// @property (nonatomic, retain)          PrefsViewController     *prefsVController;
@property (nonatomic, retain)          ZaSliderViewController  *mainViewController;

// @property (assign)                     NSUInteger       secondsInGame;
@property (nonatomic, retain)          NSDate          *accRefDate;
@property (nonatomic, retain)          NSDate          *lastMsgDate;
@property (assign)                     NSInteger        shuffleCnt;
@property (assign)                     BOOL             inManualMovement;

- (id)initWithMainViewController:(UIViewController *)vc
                initialGameState:(GameState *)gs
                    initialImage:(UIImage *)imgOrNil
              showingTileNumbers:(BOOL)shouldShow
                 andSideElements:(NSInteger)sideElems;


- (void)setupBarLabel:(UILabel *)label withStartText:(NSString *)startText andFontSize:(CGFloat)fSize;
- (void)handleBarLabelsWithTileIdText:(NSString *)tileIdTextOrNil;
- (void)resetCloseBarButton;
- (void)setupHelpButton;
- (void)hideRestartBarButton;
- (void)showRestartBarButton;
- (void)setupSignViews;
- (void)hideAllSignViews;
- (void)hideGoSignView;

- (IBAction)stopButtonAction:(id)sender;
- (IBAction)restartGameAction:(id)sender;

- (void)closeSlider;

- (NSInteger)firstTileAtWrongLocationUpdatingArrow:(BOOL)updateArrowFlag;
- (NSInteger)showArrowAtFirstTileAtWrongLocation;
- (BOOL)allTilesAtCorrectLocation;
- (BOOL)allTilesAtCorrectLocationUpToTileLocIndex:(NSInteger)locIndex;
- (BOOL)allTilesHaveImages;
- (void)showEmptyTilesImage;

- (void)testEndOfGameRound;
- (void)declareEndOfGameRound:(GameHistory *)gh;

- (void)startShuffling;
- (void)startOneShuffleMove;

- (void)handleShake;

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)animateTileLandedHome:(TileView *)tv;

- (void)rotateAllLabelToAngle:(NSNumber *)angleAsNumber;
- (void)rotateOneLabelToAngle:(NSMutableDictionary *)paramDictionary;

// Network game

- (BOOL)networkedPlay;       // we are not alone
- (BOOL)remoteShuffling;     // when we are client
- (BOOL)netCompetition;      // networked game in competition mode
- (BOOL)waitingForOpponent;  // are we waiting for the oponents move?
- (void)swapTurns;

- (BOOL)asResponseMoveTileFromLocIndex:(NSInteger)fromLocIndex toLocIndex:(NSInteger)toLocIndex;
- (BOOL)asResponseTouchTileLocIndex:(NSInteger)locIndex;
- (void)asResponseCompareOpponentsTime:(NSUInteger)timeInSeconds;
- (void)asResponseHandleOpponentsQuit;
- (void)asResponseHandleOpponentsPing;

@end
