//
//  ZaSliderViewController.h
//  ZaSlider
//
//  Created by Igor Delovski on 15.09.2010.
//  Copyright Igor Delovski, Delovski d.o.o. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GradientButton.h"
#import "SliderViewController.h"
#import "HistoryViewController.h"
#import "ImageAlbum.h"

extern PreferenceRecord  gGPrefsRec, gGCurPrefsRec;

@class  GameHistory, NetworkingController, PrefsViewController, MenuViewController;

@interface ZaSliderViewController : UIViewController
<
UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
TileImageCreationDelegate,
SmallImageCreationDelegate
>  {

	MenuViewController       *theMenuViewController;
   SliderViewController     *theSliderViewController;
   HistoryViewController    *theHistoryViewController;
   PrefsViewController      *thePrefsViewController;
   
   UINavigationController   *navController;
   NetworkingController     *netController;
   
   ImageAlbum               *builtInAlbum;
   ImageAlbum               *custImageAlbum;
   
   BOOL                      custAlbumFlushed;
   BOOL                      custAlbumNeeded;
   
   // History
   
   NSMutableArray           *gamesHistory;  // of GameHistory
   BOOL                      gamesHistoryFlushed;
   BOOL                      gamesHistoryDirty;
   
   NSString                 *usedImageSource;

   // Taking photos
   UIImage                  *newImage;  // dvojbeno...
   UIActivityIndicatorView  *actIndicatorView;
   // Internal info, needed when saving games
   NSString                 *currentImageKey;
   NSUInteger                builtInAlbumImageIndex;  // when using built-in image

}

@property (nonatomic, retain)          MenuViewController       *theMenuViewController;
@property (nonatomic, retain)          SliderViewController     *theSliderViewController;
@property (nonatomic, retain)          HistoryViewController    *theHistoryViewController;
@property (nonatomic, retain)          PrefsViewController      *thePrefsViewController;

@property (nonatomic, retain)          UINavigationController   *navController;
@property (nonatomic, retain)          NetworkingController     *netController;

@property (nonatomic, retain)          ImageAlbum               *builtInAlbum;
@property (nonatomic, retain)          ImageAlbum               *custImageAlbum;

@property                              BOOL                      custAlbumNeeded;

@property (nonatomic, retain)          NSString                 *usedImageSource;
@property (nonatomic, retain)          UIImage                  *newImage;
@property (nonatomic, retain)          UIActivityIndicatorView  *actIndicatorView;

@property (nonatomic, retain)          NSString                 *currentImageKey;
@property                              NSUInteger                builtInAlbumImageIndex;

@property (nonatomic, retain)          NSMutableArray           *gamesHistory;
@property                              BOOL                      gamesHistoryDirty;

// Actions, called from MenuView --------

- (void)startButtonAction:(id)sender;
- (void)historyButtonAction:(id)sender;
- (void)startNetworkedPlayAction:(id)sender;
- (void)prefsButtonAction:(id)sender;
- (void)helpButtonAction:(id)sender;

// --------------------------------------

- (void)loadMenuView;
- (void)loadAndAddMenuView;
- (void)unloadAndRemoveMenuView;

- (void)loadSavedAlbums;
- (void)saveCustomAlbums;

- (void)loadGamesHistory;
- (void)saveGamesHistory;

- (void)handleTermination;

- (BOOL)shouldPrepareGameWithPrefsReturningImageKey:(NSString **)retImageKey // call QuickPrefs if needed
                                   orReturningIndex:(NSInteger *)retIndex;   // ... return NO if not
- (void)prepareToStartNewGameWithImageKey:(NSString *)imgKey builtInIndex:(NSInteger)idx;
- (void)startNewGameWithMediaItem:(MediaItem *)mediaItemOrNil imageKey:(NSString *)imgKey builtInIndex:(NSUInteger)idx;

// produce the album, produce SliderViewController, add image to the album, create small image and create tiles

- (void)acceptAndStoreNewImage:(UIImage *)theImage withImageKey:(NSString *)imgKeyOrNil;

- (void)changeGameImage;
- (MediaItem *)mediaItemForImageKey:(NSString *)imageKey     // if it has the key
                     orBuiltInIndex:(NSInteger)idx;          // otherwise use idx
- (UIImage *)imageForImageKey:(NSString *)imageKey     // if it has the key
               orBuiltInIndex:(NSInteger)idx;          // otherwise use idx
- (UIImage *)prevImageForKey:(NSString *)inKey
           builtInAlbumIndex:(NSInteger)inIdx
           returningImageKey:(NSString **)retImageKey      // if it has the key
            orReturningIndex:(NSInteger *)retIndex;        // otherwise return idx
- (UIImage *)nextImageForKey:(NSString *)inKey
           builtInAlbumIndex:(NSInteger)inIdx
           returningImageKey:(NSString **)retImageKey      // if it has the key
            orReturningIndex:(NSInteger *)retIndex;        // otherwise return idx

// Game completion & History

- (GameHistory *)addGameToHistory:(GameController *)finishedGame
                finishedInSeconds:(NSUInteger)ourSecs
                 opponentsSeconds:(NSUInteger)opSecs;
- (BOOL)removeGameFromHistory:(GameHistory *)gh;

// Comming back

- (void)dismissModalPreferencesViewControllerWithImageKey:(NSString *)imgKey builtInIndex:(NSInteger)idx;
- (void)navigateBackToMainViewController:(GameHistory *)gh;
- (void)finishAndReleaseGameControllers;

// Services for the networking controller

- (void)randomImageReturningImageKey:(NSString **)retImageKey      // if it has the key
                    orReturningIndex:(NSInteger *)retIndex;        // otherwise return idx

- (BOOL)isImageAvailableForImageKey:(NSString *)imageKey           // key
                orBuiltInAlbumIndex:(NSInteger)idx;                // otherwise use idx

// Client/Server communication

- (void)asClientStartGameWithImage:(UIImage *)commonImage
                            forKey:(NSString *)key
                  withBuiltInIndex:(NSUInteger)idx;
- (void)asServerStartGameWithKey:(NSString *)key
                withBuiltInIndex:(NSUInteger)idx;

- (void)postOurMoveFromLocIndex:(NSUInteger)fromLocIndex toLocIndex:(NSUInteger)toLocIndex;
- (void)asResponseMoveFromLocIndex:(NSUInteger)fromLocIndex toLocIndex:(NSUInteger)toLocIndex;
- (void)postOurTouchAtLocIndex:(NSUInteger)locIndex;
- (void)asResponseTouchLocIndex:(NSUInteger)locIndex;
- (void)postOurTimeAtFinish:(NSUInteger)secondsInGame;
- (void)asResponseCompareOpponentsTime:(NSUInteger)timeInSeconds;
- (void)postQuitMessage;
- (void)asResponseHandleOpponentsQuit;
- (void)asResponseHandleOpponentsPing;

// Taking photos

- (void)addNewPhoto:(id)sender;
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)getCameraPicture;
- (void)getAlbumPicture;
- (void)coreGetCameraPicture:(UIImagePickerControllerSourceType)srcType;
- (void)selectExistingPicture;

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

- (void)finishedAddingNewImage:(UIImage *)newImage;


@end

