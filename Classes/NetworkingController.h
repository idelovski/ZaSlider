//
//  NetworkingController.h
//  ZaSlider
//
//  Created by Igor Delovski on 17.10.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

#import "OnlineSession.h"
#import "OnlineListener.h"

// Place this somewhere...

typedef enum  ClientServerStatuses  {
   kClientServerStatusUndecided,
   kClientServerStatusClient,
   kClientServerStatusServer
} ClientServerStatus;

typedef enum  CompetingStatuses  {
   kCompetingStatusUndefined,
   kCompetingStatusCooperate,   // both are playing together
   kCompetingStatusMyTurn,
   kCompetingStatusOpponentTurn
} CompetingStatus;

typedef enum  NetCtrlStates  {
   kNCStateBeginning,         // expected in -onlineSessionReadyForUse to call -startNewNetworkedGame
   kNCStateRollingDice,       // set in -sendDieRoll
   kNCStateWaiting,           // waiting for other player to set up the game
   kNCStateResolvingImage,    // 
   kNCStateReadyAsServer,     // we can start shuffling
   kNCStateReadyAsClient,     // we wait
   kNCStateInterrupted,
   kNCStateDone
} NetCtrlState;

#define   kMaxMessagesInArchive  16

#pragma mark -

@class  ZaSliderViewController, GameController, GamePacket;
@class  GameInfoPacket, ImageInfoPacket, ImageDataPacket, PlayerInfoPacket, GameState;

@interface NetworkingController : NSObject

<GKPeerPickerControllerDelegate,
GKSessionDelegate,
NSNetServiceDelegate,
UIAlertViewDelegate,
OnlineSessionDelegate,
OnlineListenerDelegate>
{
   ZaSliderViewController  *mainViewController;
//    GameController          *theGameController;
   GameState               *initialGameState;

   GKSession               *theGKSession;
   NSString                *gkPeerID;

   NetCtrlState             netControllerState;        // state of net controller
   ClientServerStatus       netClientServerStatus;
   CompetingStatus          netCompetingStatus;

   NSInteger                ourDieRollValue;
   NSInteger                opponentDieRollValue;

   BOOL                     dieRollReceivedFlag;
   BOOL                     dieRollAcknowledgedFlag;  // we can eliminate this
   BOOL                     peerAcknowledgedFlag;
   BOOL                     imageAcknowledgedFlag;    // we have the image
   BOOL                     moveAcknowledgedFlag;     // we moved, go on
   BOOL                     touchAcknowledgedFlag;    // we touched, go on
   BOOL                     bitteWartenAcknowledgedFlag;  // something...
   BOOL                     timeAcknowledgedFlag;         // they have our time, declare winner
   // BOOL                     quitAcknowledgedFlag;     // bye, bye
   // BOOL                     pleaseResendAckFlag;      // please resend from last i have
   BOOL                     pingAcknowledgedFlag;

   NSNetService            *publishedNetService;
   NSNetService            *foundNetService;

   OnlineSession           *theOLSession;
   OnlineListener          *olsListener;
   
   NSMutableArray          *sentMessagesArchive;      // If we need to resend them
   
   NSData                  *ourServingAddressAsData;
   NSData                  *remoteAddressAsData;
   NSUInteger               receivedMsgSerialNo;      // counter for received messages
   NSUInteger               attemptedRetrys;          // reconnection retrys
   
   NSString                *imgKey;
   NSUInteger               builtInAlbumIdx;
   NSString                *opponentName;
   
   UIActionSheet           *actionSheet;
   UIProgressView          *progressView;
   UIAlertView             *bitteWartenAlert;
}

@property (nonatomic, retain)  ZaSliderViewController  *mainViewController;
// @property (nonatomic, retain)  GameController          *theGameController;
@property (nonatomic, retain)  GameState               *initialGameState;    // how to start net game

@property (nonatomic)          NetCtrlState             netControllerState;
@property (nonatomic)          ClientServerStatus       netClientServerStatus;
@property (nonatomic)          CompetingStatus          netCompetingStatus;


@property (nonatomic, retain)  GKSession               *theGKSession;
@property (nonatomic, copy)    NSString                *gkPeerID;
@property (nonatomic, retain)  NSNetService            *publishedNetService;
@property (nonatomic, retain)  NSNetService            *foundNetService;
@property (nonatomic, retain)  OnlineSession           *theOLSession;
@property (nonatomic, retain)  OnlineListener          *olsListener;
@property (nonatomic, retain)  NSMutableArray          *sentMessagesArchive;

@property (nonatomic, retain)  NSData                  *ourServingAddressAsData;
@property (nonatomic, retain)  NSData                  *remoteAddressAsData;
@property (nonatomic)          NSUInteger               receivedMsgSerialNo;

@property (nonatomic, retain)  NSString                *imgKey;
@property (nonatomic)          NSUInteger               builtInAlbumIdx;
@property (nonatomic, retain)  NSString                *opponentName;

@property (nonatomic, retain)  UIActionSheet           *actionSheet;
@property (nonatomic, retain)  UIProgressView          *progressView;
@property (nonatomic, retain)  UIAlertView             *bitteWartenAlert;


#pragma mark -

- (id)initWithMainViewController:(ZaSliderViewController *)mainVC;

- (void)startPeerSearch;        // Let's start searching for opponent!
- (void)startNewNetworkedGame;  // used from -onlineSessionReadyForUse: ; we have opponent here!
- (void)resetDieState;          // used from -handleDieRollAcknowledged and -handleReceivedData
- (void)resolveCommonImage;
- (void)sendImageInfo;          // call it after receiving imageInfoRequest or after closing quick prefs

- (void)sendPlayerInfo;   // by both
- (void)sendBitteWarten;  // by server


// - (void)resetDieState;
// - (void)sendPacketDictionaryAsData:(NSData *)msgData;
// - (void)sendPacketDictionaryAsData:(NSData *)msgData givingBackProgressInfo:(BOOL)needProgressInfo;
- (void)sendGamePacketAsData:(NSData *)msgData givingBackProgressInfo:(BOOL)needProgressInfo;

- (void)sendSimplePacket:(SimpleGamePacket *)aPacketPtr;
- (void)sendSimpleAckPacketOfType:(SimpleGamePacketType)spType;

- (void)archiveAndSendPacket:(id)aPacket forKey:(NSString *)packetKey givingBackProgressInfo:(BOOL)reqProgressFlag;
- (void)sendPacket:(GamePacket *)packet;
- (void)sendImageInfoPacket:(ImageInfoPacket *)iPacket;
- (void)sendImageDataPacket:(ImageDataPacket *)iPacket;
- (void)sendPlayerInfoPacket:(PlayerInfoPacket *)iPacket;

- (void)sendDieRoll;
- (void)sendImageDataRequest;
- (void)sendImgAcknowledgedPacket;

// - (void)checkForGameEnd;

- (void)handleReceivedData:(NSData *)data;
- (void)handleReceivedSimplePacket:(SimpleGamePacket *)aPacket;  // simple game packet, moves and touches
- (void)handleReceivedPacket:(GamePacket *)gPacket;  // basic game packet, dieRol, ack, and stuff
// - (void)handleReceivedGameInfoPacket:(GameInfoPacket *)giPacket;  // by client

- (void)handleDieRollAcknowledged;
- (void)handleReceivedPlayerInfoPacket:(PlayerInfoPacket *)pliPacket;  // by both
- (void)handleReceivedImageInfoPacket:(ImageInfoPacket *)imiPacket;
- (void)handleReceivedImageDataPacket:(ImageDataPacket *)imdPacket;
- (void)handleImgAcknowledged;  // by server

- (void)sendMovePacketWithFromLocIndex:(NSUInteger)fromLocIndex toLocIndex:(NSUInteger)toLocIndex;
- (void)handleMoveFromLocIndex:(NSUInteger)fromLocIndex toLocIndex:(NSUInteger)toLocIndex;
- (void)sendMoveAcknowledgedPacket;

- (void)sendTouchPacketWithLocIndex:(NSUInteger)locIndex;
- (void)handleTouchLocIndex:(NSUInteger)locIndex;
- (void)sendTouchAcknowledgedPacket;

- (void)sendTimePacketWithSecondsInGame:(NSUInteger)secsInGame;
- (void)handleOpponentsTime:(NSUInteger)timeInGame;
- (void)sendTimeAcknowledgedPacket;

- (void)sendQuitPacket;
- (void)handleOpponentsQuit;
// - (void)sendQuitAcknowledgedPacket;  // Not needed! He's gone anyway

- (void)sendPingPacket;
- (void)handleOpponentsPing;
- (void)sendPingAcknowledgedPacket;

- (void)sendPleaseResendFromId:(NSInteger)lastReceivedMsgId;
- (void)handlePleaseResendWithMsgId:(NSInteger)msgId;
- (void)sendPleaseResendBadLuckPacket;                  // can't resend, sorry!

- (void)browserCancelled;

#pragma mark -

- (void)handleReconnection;
- (void)tryReconnecting;

#pragma mark -

- (void)showErrorAletWithTitle:(NSString *)alertTitle
                       message:(NSString *)msg;

- (void)showBitteWartenAlert;
- (void)dismissBitteWartenAlert;

#pragma mark -

- (void)storeSentMessageData:(NSData *)msgData;
- (void)clearSentMessageData;
- (NSInteger)idOfMessageAtIndex:(NSInteger)idx;
- (NSInteger)idOfFirstMessageInArchive;
- (NSInteger)idOfLastMessageInArchive;
- (BOOL)messageArchiveContainsMessageId:(NSInteger)msgId;
// - (BOOL)messageIsAlreadyInArchive:(NSData *)msgData;

- (NSInteger)resendArchivedMessagesStartingWithId:(NSInteger)startMsgId;

@end
