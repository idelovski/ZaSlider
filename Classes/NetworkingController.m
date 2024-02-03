//
//  NetworkingController.m
//  ZaSlider
//
//  Created by Igor Delovski on 17.10.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import "NetworkingController.h"

#import "OnlinePeerBrowser.h"

#import "GamePacket.h"
#import "GameState.h"
#import "GameController.h"
#import "ZaSliderViewController.h"
#import "SliderViewController.h"


@implementation NetworkingController

@synthesize  mainViewController, /*theGameController,*/ initialGameState;
@synthesize  netControllerState, netClientServerStatus, netCompetingStatus;
@synthesize  theGKSession, gkPeerID, publishedNetService, foundNetService;
@synthesize  theOLSession, olsListener, sentMessagesArchive, ourServingAddressAsData, remoteAddressAsData;
@synthesize  receivedMsgSerialNo, imgKey, builtInAlbumIdx, opponentName, actionSheet, progressView, bitteWartenAlert;

- (id)initWithMainViewController:(ZaSliderViewController *)mainVC
{
   if (self = [super init])  {
      self.mainViewController = mainVC;
      // self.theGameController = mainVC.theSliderViewController.ourGameController;  // Maybe we don't need this!
      
      self.netControllerState = kNCStateBeginning;
      self.sentMessagesArchive = [[NSMutableArray alloc] init];
   }
   
   return (self);
}

- (void)dealloc
{
   [mainViewController release];
   // [theGameController release];
   [initialGameState release];
   
   if (theGKSession)  {
      theGKSession.available = NO;
      [theGKSession disconnectFromAllPeers];
      [theGKSession setDataReceiveHandler: nil withContext: nil];
      theGKSession.delegate = nil;
      [theGKSession release];
   }
   
   [gkPeerID release];
   
   if (self.publishedNetService)  {
      
      // What about this?  [self.publishedNetService stop];
      
      self.publishedNetService.delegate = nil;
      [publishedNetService release];
   }
   if (self.foundNetService)  {
      self.foundNetService.delegate = nil;
      [foundNetService release];
   }
   
   [theOLSession release];
   [olsListener release];
   [sentMessagesArchive release];
   [ourServingAddressAsData release];
   [remoteAddressAsData release];
   
   [imgKey release];
   [actionSheet release];
   [opponentName release];
   [progressView release];
   if (bitteWartenAlert)
      [self dismissBitteWartenAlert];
   [bitteWartenAlert release];
      
   [super dealloc];
}

#pragma mark -

- (GameState *)initialGameStateWithSideElems:(NSInteger)sideElems cooperationMode:(BOOL)coopMode andOpponent:(NSString *)theOpponentName
{
   GameState  *tmpGameState = [[GameState alloc] initWithImageKey:self.imgKey
                                                builtInAlbumIndex:self.builtInAlbumIdx
                                                     sideElements:sideElems
                                                         coopMode:coopMode
                                                 andSecondsInGame:0];
   
   tmpGameState.opponentName = theOpponentName;

   // Here comes Other params like showArrow etc.

   return ([tmpGameState autorelease]);
}

#pragma mark -
#pragma mark Start Network Association

// Let's start searching for opponent!

- (void)startPeerSearch
{
   NSLog (@"startPeerSearch");

   GKPeerPickerController  *picker;
   
   [self resetDieState];

   picker = [[GKPeerPickerController alloc] init]; // note: picker is released in various picker delegate methods when picker use is done.

   picker.delegate = self;
   picker.connectionTypesMask = GKPeerPickerConnectionTypeOnline | GKPeerPickerConnectionTypeNearby;

   [picker show];
   
   // things will be resolved in PeerPicker Delegate methods
}

// We have opponent here!
// This initiates handshake - dieRoll that decides who is first (server) and who follows shuffle as remote client 

- (void)startNewNetworkedGame  // used from -onlineSessionReadyForUse:
{
#ifdef _NETTALK_LOG_
   NSLog (@"startNewNetworkedGame");
#endif
   // [self resetBoard];
   peerAcknowledgedFlag = NO;
   [self sendDieRoll];
}

- (void)resetDieState  // originaly used from -handleDieRollAcknowledged and -handleReceivedData
{
#ifdef _NETTALK_LOG_
   NSLog (@"resetDieState");
#endif   
   dieRollReceivedFlag     = NO;
   dieRollAcknowledgedFlag = NO;
   
   ourDieRollValue = kDiceNotRolled;
   opponentDieRollValue = kDiceNotRolled;
}

#pragma mark -
#pragma mark Initial Negotiations
#pragma mark -

- (void)sendDieRoll
{
#ifdef _NETTALK_LOG_
   NSLog (@"sendDieRoll");
#endif
   GamePacket  *rollPacket;

   netControllerState = kNCStateRollingDice;
   
   if (ourDieRollValue == kDiceNotRolled) {
      rollPacket = [[GamePacket alloc] initDieRollPacket];
      ourDieRollValue = rollPacket.theDieRoll;
      // outLabel.text = @"o.Roll N";
   }
   else  {
      // Nekako si mislim da ovo nije potrebno
      rollPacket = [[GamePacket alloc] initDieRollPacketWithRoll:ourDieRollValue];
      // outLabel.text = @"o.Roll Y";
   }
   
   [self sendPacket:rollPacket];
   [rollPacket release];
   
}

// ---------------------------------------------------------------------------------------------------------------------

- (void)sendPlayerInfo  // by both
{
   NSString  *playerName = [[UIDevice currentDevice] name];
   
#ifdef _NETTALK_LOG_
   NSLog (@"sendPlayerInfo - playerName: %@", playerName);
#endif
   
   // Later put it into: self.initialGameState.opponentName
   
   PlayerInfoPacket  *pliPacket = [[PlayerInfoPacket alloc] initWithPlayerName:playerName];
   
   [self sendPlayerInfoPacket:pliPacket];
}

- (void)sendPlayerInfoAcknowledgedPacket  // by both
{
#ifdef _NETTALK_LOG_
   NSLog (@"sendPlayerInfoAcknowledgedPacket");
#endif
   /*
   GamePacket  *ackPacket = [[GamePacket alloc] initPlayerAckPacket];
   [self sendPacket:ackPacket];
   [ackPacket release];
   */
   
   [self sendSimpleAckPacketOfType:kSimplePacketTypePlayerAck];
   
   peerAcknowledgedFlag = YES;
}

// ---------------------------------------------------------------------------------------------------------------------

// Think about timeout here, if we don't hear from client in 1 minute or so, give up and reset evrything.

- (void)resolveCommonImage  // from -handlePlayerAcknowledged
{
#ifdef _NETTALK_LOG_
   NSLog (@"resolveCommonImage");
#endif
   GamePacket  *imgReqPacket;
   
   netControllerState = kNCStateResolvingImage;
   
   if (netClientServerStatus == kClientServerStatusClient)  {
      
      imgReqPacket = [[GamePacket alloc] initImgInfoRequestPacket];
      [self sendPacket:imgReqPacket];
      [imgReqPacket release];
      // outLabel.text = @"o.Req Clnt";
   }
   else  {
      // outLabel.text = @"o.Req Srv";
      NSString    *tmpImageKey;
      NSInteger    tmpImageIndex;
      
      if ([self.mainViewController shouldPrepareGameWithPrefsReturningImageKey:&tmpImageKey orReturningIndex:&tmpImageIndex])
         [self sendBitteWarten];
      
      // self.imgKey          = tmpImageKey;
      // self.builtInAlbumIdx = tmpImageIndex;
   }
}

- (void)sendImageInfo  // by server
{
#ifdef _NETTALK_LOG_
   NSLog (@"sendImageInfo");
#endif
   NSString    *tmpImageKey;
   NSInteger    tmpImageIndex;
   
   if (!gGPrefsRec.pfShowSettingsBeforeGame)  {  // because we already have these decided!
   
      [self.mainViewController randomImageReturningImageKey:&tmpImageKey orReturningIndex:&tmpImageIndex];
   
      self.imgKey          = tmpImageKey;
      self.builtInAlbumIdx = tmpImageIndex;
   }
   else  {
      tmpImageKey   = self.imgKey;
      tmpImageIndex = self.builtInAlbumIdx;
   }
   
   self.initialGameState = [self initialGameStateWithSideElems:gGCurPrefsRec.pfSideElems
                                               cooperationMode:gGCurPrefsRec.pfCooperationMode
                                                   andOpponent:self.opponentName];
   
   ImageInfoPacket  *imiPacket = [[ImageInfoPacket alloc] initWithImageKey:tmpImageKey
                                                       orBuiltInAlbumIndex:tmpImageIndex
                                                       andPreferenceRecord:&gGCurPrefsRec];
   
   [self sendImageInfoPacket:imiPacket];
}

- (void)sendImageData  // by server
{
#ifdef _NETTALK_LOG_
   NSLog (@"sendImageData");
#endif
   UIImage  *tmpImage = [self.mainViewController imageForImageKey:self.imgKey orBuiltInIndex:self.builtInAlbumIdx];
      
   ImageDataPacket  *imiPacket = [[ImageDataPacket alloc] initWithImage:tmpImage ImageKey:self.imgKey orBuiltInAlbumIndex:self.builtInAlbumIdx];
   
   [self sendImageDataPacket:imiPacket];
}

- (void)sendImageDataRequest  // by client
{
#ifdef _NETTALK_LOG_
   NSLog (@"sendImageDataRequest");
#endif
   GamePacket  *imgReqPacket = [[GamePacket alloc] initImgDataRequestPacket];
   
   [self sendPacket:imgReqPacket];
   [imgReqPacket release];
}

- (void)sendImgAcknowledgedPacket  // by client
{
#ifdef _NETTALK_LOG_
   NSLog (@"sendImgAcknowledgedPacket");
#endif

   /*
   GamePacket  *ackPacket = [[GamePacket alloc] initImgAckPacket];
   [self sendPacket:ackPacket];
   [ackPacket release];
   */
   
   [self sendSimpleAckPacketOfType:kSimplePacketTypeImgAck];

   imageAcknowledgedFlag = YES;
   if (netClientServerStatus == kClientServerStatusClient)  {
      netControllerState = kNCStateReadyAsClient;
      if (initialGameState.coopMode)
         netCompetingStatus = kCompetingStatusCooperate;     // Come together
      else
         netCompetingStatus = kCompetingStatusOpponentTurn;     // First move goes to the opponent
   }
   else  {
      NSLog (@"sendImgAcknowledgedPacket - As Server, shouldn't be here!?!");
   }
}

// ---------------------------------------------------------------------------------------------------------------------

#pragma mark -

- (void)sendBitteWarten  // by server
{
#ifdef _NETTALK_LOG_
   NSLog (@"sendBitteWarten");
#endif
   GamePacket  *wartenPacket;
   
   // netControllerState = kNCStateResolvingImage;  maybe we need that quick prefs visible state or something
   
   if (netClientServerStatus == kClientServerStatusServer)  {
      
      wartenPacket = [[GamePacket alloc] initBitteWartenPacket];
      [self sendPacket:wartenPacket];
      [wartenPacket release];
      // outLabel.text = @"o.Req Clnt";
      bitteWartenAcknowledgedFlag = NO;
   }
   else  {
      NSLog (@"sendBitteWarten - but we're the client!");
   }
}

- (void)handleBitteWarten  // by client
{
#ifdef _NETTALK_LOG_
   NSLog (@"handleBitteWarten");
#endif
   netControllerState = kNCStateWaiting;
   
   [self showBitteWartenAlert];
   
}

// ---------------------------------------------------------------------------------------------------------------------

#pragma mark -

// This should start new networked game, send img if needed, shuffling then and coordinating the shuffle between both peers
// change its name to something better, startNetworkedShuffle...
// ... and we need some delegate that will receive the picture, store it and send it to tiles
//  if (dieRollReceivedFlag == YES && dieRollAcknowledgedFlag == YES)
//     [self handleDieRollAcknowledged];
//

- (void)handleDieRollAcknowledged  // called from -handleReceivedData, nakon dieRoll Ack
{
   netControllerState = kNCStateResolvingImage;
   
   // we can't call -resetDieState here!
   
   if (ourDieRollValue == opponentDieRollValue)  {
      [self resetDieState];
      [self sendDieRoll];
      netClientServerStatus = kClientServerStatusUndecided;
      // feedbackLabel.text = NSLocalizedString(@"Rolling", @"Rolling");
#ifdef _NETTALK_LOG_
      NSLog (@"handleDieRollAcknowledged - Draw");
#endif
   }
   else if (ourDieRollValue < opponentDieRollValue)  {
      netClientServerStatus = kClientServerStatusClient;
      // feedbackLabel.text = NSLocalizedString(@"Opponent's Turn", @"Opponent's Turn");
      [self resetDieState];  // So we don't end up here again
#ifdef _NETTALK_LOG_
      NSLog (@"handleDieRollAcknowledged - Client");
#endif
   }
   else  {
      netClientServerStatus = kClientServerStatusServer;
      // feedbackLabel.text = NSLocalizedString(@"Your Turn", @"Your Turn");
      [self resetDieState];  // So we don't end up here again
#ifdef _NETTALK_LOG_
      NSLog (@"handleDieRollAcknowledged - Server");
#endif
   }
   
   if (netClientServerStatus != kClientServerStatusUndecided)
      [self sendPlayerInfo];
}

- (void)handlePlayerAcknowledged  // by both
{
#ifdef _NETTALK_LOG_
   NSLog (@"handlePlayerAcknowledged");
#endif
   // We need this delay so running animations finish, otherwise we crash!
   
   if ((netClientServerStatus == kClientServerStatusServer) && gGPrefsRec.pfShowSettingsBeforeGame)
      [self performSelector:@selector(resolveCommonImage) withObject:nil afterDelay:.1];
   else
      [self resolveCommonImage];  // if we serve, we decide the image, client just waits!
}

- (void)handleBitteWartenAcknowledged  // by server
{
#ifdef _NETTALK_LOG_
   NSLog (@"handleBitteWartenAcknowledged");
#endif
   bitteWartenAcknowledgedFlag = YES;
}

- (void)handleImgAcknowledged  // by server
{
#ifdef _NETTALK_LOG_
   NSLog (@"handleImgAcknowledged");
#endif
   
   netControllerState = kNCStateReadyAsServer;    // I am Server
   if (initialGameState.coopMode)
      netCompetingStatus = kCompetingStatusCooperate;     // Come together
   else
      netCompetingStatus = kCompetingStatusMyTurn;   // First move is mine

   [self.mainViewController asServerStartGameWithKey:self.imgKey withBuiltInIndex:self.builtInAlbumIdx];
}

#pragma mark -
#pragma mark Game Play Messages
#pragma mark -

- (void)sendMovePacketWithFromLocIndex:(NSUInteger)fromLocIndex toLocIndex:(NSUInteger)toLocIndex
{
#ifdef _NETTALK_LOG_
   NSLog (@"sendMovePacketWithFromLocIndex:toLocIndex: [%d,%d]", fromLocIndex, toLocIndex);
#endif
   
   /*
   GamePacket  *movePacket = [[GamePacket alloc] initMovePacketWithFromLocIndex:fromLocIndex andToLocIndex:toLocIndex];
   [self sendPacket:movePacket];
   [movePacket release];
   */
   SimpleGamePacket  simplePacket;
   bzero (&simplePacket, sizeof(SimpleGamePacket));
   
   simplePacket.packetType = kSimplePacketTypeMove;
   
   simplePacket.fromLocIndex = fromLocIndex;
   simplePacket.toLocIndex   = toLocIndex;
   
   [self sendSimplePacket:&simplePacket];
   moveAcknowledgedFlag = NO;
}

- (void)handleMoveFromLocIndex:(NSUInteger)fromLocIndex toLocIndex:(NSUInteger)toLocIndex
{
#ifdef _NETTALK_LOG_
   NSLog (@"handleMoveFromLocIndex:toLocIndex: [%d,%d]", fromLocIndex, toLocIndex);
#endif
   
   [self.mainViewController asResponseMoveFromLocIndex:fromLocIndex toLocIndex:toLocIndex];
   [self sendMoveAcknowledgedPacket];
}

- (void)sendMoveAcknowledgedPacket
{
#ifdef _NETTALK_LOG_
   NSLog (@"sendMoveAcknowledgedPacket");
#endif
   
   /*
   GamePacket  *ackPacket = [[GamePacket alloc] initMoveAckPacket];
   [self sendPacket:ackPacket];
   [ackPacket release];
    */   
   [self sendSimpleAckPacketOfType:kSimplePacketTypeMoveAck];

   // moveAcknowledgedFlag = YES;
}

// ---------------------------------------------------------------------------------------------------------------------

#pragma mark -

- (void)sendTouchPacketWithLocIndex:(NSUInteger)locIndex
{
   NSLog (@"sendTouchPacketWithLocIndex: [%d]", locIndex);
   
   /*
   GamePacket  *touchPacket = [[GamePacket alloc] initTouchPacketWithLocIndex:locIndex];
   [self sendPacket:touchPacket];
   [touchPacket release];
   */
   SimpleGamePacket  simplePacket;
   bzero (&simplePacket, sizeof(SimpleGamePacket));
   
   simplePacket.packetType = kSimplePacketTypeTouch;
   
   simplePacket.fromLocIndex = locIndex;
   simplePacket.toLocIndex   = 0;
   
   [self sendSimplePacket:&simplePacket];
   
   touchAcknowledgedFlag = NO;
}

- (void)handleTouchLocIndex:(NSUInteger)locIndex
{
#ifdef _NETTALK_LOG_
   NSLog (@"handleTouchLocIndex: [%d]", locIndex);
#endif
   
   [self.mainViewController asResponseTouchLocIndex:locIndex];
   [self sendTouchAcknowledgedPacket];
}

- (void)sendTouchAcknowledgedPacket
{
#ifdef _NETTALK_LOG_
   NSLog (@"sendTouchAcknowledgedPacket");
#endif
   [self sendSimpleAckPacketOfType:kSimplePacketTypeTouchAck];

   // touchAcknowledgedFlag = YES;
}

#pragma mark -

// ---------------------------------------------------------------------------------------------------------------------

- (void)sendTimePacketWithSecondsInGame:(NSUInteger)secsInGame
{
#ifdef _NETTALK_LOG_
   NSLog (@"sendTimePacketWithSecondsInGame: [%d]", secsInGame);
#endif
   
   SimpleGamePacket  simplePacket;
   bzero (&simplePacket, sizeof(SimpleGamePacket));
   
   simplePacket.packetType = kSimplePacketTypeTime;
   
   simplePacket.fromLocIndex = secsInGame;
   
   [self sendSimplePacket:&simplePacket];
   timeAcknowledgedFlag = NO;
}

- (void)handleOpponentsTime:(NSUInteger)timeInGame
{
#ifdef _NETTALK_LOG_
   NSLog (@"handleOpponentsTime: [%d]", timeInGame);
#endif
   
   [self.mainViewController asResponseCompareOpponentsTime:timeInGame];
   [self sendTimeAcknowledgedPacket];
}

- (void)sendTimeAcknowledgedPacket
{
#ifdef _NETTALK_LOG_
   NSLog (@"sendTimeAcknowledgedPacket");
#endif
   [self sendSimpleAckPacketOfType:kSimplePacketTypeTouchAck];
   // touchAcknowledgedFlag = YES;
}

#pragma mark -

// ---------------------------------------------------------------------------------------------------------------------

- (void)sendQuitPacket
{
   if (self.netControllerState == kNCStateDone)
      return;
#ifdef _NETTALK_LOG_
   NSLog (@"sendQuitPacket");
#endif
   
   SimpleGamePacket  simplePacket;
   bzero (&simplePacket, sizeof(SimpleGamePacket));
   
   simplePacket.packetType = kSimplePacketTypeQuit;
   
   [self sendSimplePacket:&simplePacket];
   // quitAcknowledgedFlag = NO;  we don't need to ack this, he's gone anyway
}

- (void)handleOpponentsQuit
{
#ifdef _NETTALK_LOG_
   NSLog (@"handleOpponentsQuit");
#endif
   
   [self.mainViewController asResponseHandleOpponentsQuit];
   // [self sendQuitAcknowledgedPacket];
}

#ifdef _NIJE_
- (void)sendQuitAcknowledgedPacket
{
#ifdef _NETTALK_LOG_
   NSLog (@"sendQuitAcknowledgedPacket");
#endif
   [self sendSimpleAckPacketOfType:kSimplePacketTypeTouchAck];
   // quitAcknowledgedFlag = YES;
}
#endif

#pragma mark -

// ---------------------------------------------------------------------------------------------------------------------

- (void)sendPingPacket
{
   if (self.netControllerState == kNCStateDone)
      return;
#ifdef _NETTALK_LOG_
   NSLog (@"sendPingPacket");
#endif
   
   SimpleGamePacket  simplePacket;
   bzero (&simplePacket, sizeof(SimpleGamePacket));
   
   simplePacket.packetType = kSimplePacketTypePing;
   
   [self sendSimplePacket:&simplePacket];
   pingAcknowledgedFlag = NO;
}

- (void)handleOpponentsPing
{
#ifdef _NETTALK_LOG_
   NSLog (@"handleOpponentsPing");
#endif
   
   [self.mainViewController asResponseHandleOpponentsPing];  // Update time, so we don't need to send our ping
   [self sendPingAcknowledgedPacket];
}

- (void)sendPingAcknowledgedPacket
{
#ifdef _NETTALK_LOG_
   NSLog (@"sendPingAcknowledgedPacket");
#endif
   [self sendSimpleAckPacketOfType:kSimplePacketTypePingAck];
   // pingAcknowledgedFlag = YES;
}

#pragma mark -
#pragma mark Low Level Send
#pragma mark -

// Dispatcher - Blue or WiFi, msgData must start with MessageHeader

// HERE:

// extract header from msgData so we have msgCnt that we can use to keep recent messages in case we need to resend them
// keep 32 messages in history, need methods to add a message, check if that id already exists, etc.
// plus we need special messages that ask the other party to resend stuff (that msg should not go to history, maybe by
// checking its type or that message should not have the id or something like that...

- (void)sendGamePacketAsData:(NSData *)msgData givingBackProgressInfo:(BOOL)needProgressInfo
{
   NSError  *error = nil;
   
   if (theGKSession)  {
      if (![theGKSession sendDataToAllPeers:msgData withDataMode:GKSendDataReliable error:&error])  {
         // You will do real error handling
         NSLog (@"Error sending data: %@", [error localizedDescription]);
      }
   }
   else  if (theOLSession)  {
      if (![theOLSession sendData:msgData givingBackProgressInfo:needProgressInfo error:&error])  {
         NSLog (@"Error sending data: %@", [error localizedDescription]);
      }
      [self storeSentMessageData:msgData];
      // outCntLabel.text = [NSString stringWithFormat:@"%d", theOLSession.totalBytesOut];
   }
   else
      NSLog (@"No session!");
}

static short  gGMsgCounter = 0;

- (void)sendSimplePacket:(SimpleGamePacket *)aPacketPtr
{
   MessageHeader     msgHead;
   // NSMutableData    *msgData = [[NSMutableData alloc] init];
   NSMutableData    *allData = [[NSMutableData alloc] init];
      
   msgHead.msgSize = htonl (sizeof(SimpleGamePacket));
   if (aPacketPtr->packetType == kSimplePacketTypePleaseResend)
      msgHead.msgCoreType = kMsgCoreTypeStructResendReq;
   else  {
      msgHead.msgSerialNo = htons (++gGMsgCounter);
      msgHead.msgCoreType = kMsgCoreTypeStruct;
   }
   aPacketPtr->fromLocIndex = htonl (aPacketPtr->fromLocIndex);
   aPacketPtr->toLocIndex   = htonl (aPacketPtr->toLocIndex);
   
   // [msgData appendBytes:aPacketPtr length:sizeof(SimpleGamePacket)];
   
   [allData appendBytes:&msgHead length:sizeof(MessageHeader)];
   // [allData appendData:msgData];
   [allData appendBytes:aPacketPtr length:sizeof(SimpleGamePacket)];
   
   [self sendGamePacketAsData:allData givingBackProgressInfo:NO];
   
   // [msgData release];
   [allData release];
}

- (void)sendSimpleAckPacketOfType:(SimpleGamePacketType)spType
{
   SimpleGamePacket  simplePacket;
   bzero (&simplePacket, sizeof(SimpleGamePacket));
   
   simplePacket.packetType = spType;
   
   [self sendSimplePacket:&simplePacket];   
}

- (void)archiveAndSendPacket:(id)aPacket forKey:(NSString *)packetKey givingBackProgressInfo:(BOOL)reqProgressFlag
{
   MessageHeader     msgHead;
   NSMutableData    *msgData = [[NSMutableData alloc] init];
   NSMutableData    *allData = [[NSMutableData alloc] init];
   NSKeyedArchiver  *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:msgData];
   
   NSDictionary     *msgDict = [NSDictionary dictionaryWithObject:aPacket forKey:packetKey];
   
   [archiver encodeObject:msgDict forKey:kGamePacketArchiveKey];
   [archiver finishEncoding];
   
   msgHead.msgSize = htonl ([msgData length]);
   msgHead.msgSerialNo = htons (++gGMsgCounter);
   msgHead.msgCoreType = kMsgCoreTypeData;

   [allData appendBytes:&msgHead length:sizeof(MessageHeader)];
   [allData appendData:msgData];

   [self sendGamePacketAsData:allData givingBackProgressInfo:reqProgressFlag];
   
   [archiver release];
   [msgData release];
   [allData release];
}

- (void)sendPacket:(GamePacket *)packet
{
   [self archiveAndSendPacket:packet forKey:kDictMessageGamePacketKey givingBackProgressInfo:NO];
#ifdef _NIJE_
   NSMutableData    *data = [[NSMutableData alloc] init];
   NSKeyedArchiver  *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];

   NSDictionary     *msgDict = [NSDictionary dictionaryWithObject:packet forKey:kDictMessageGamePacketKey];
   
   [archiver encodeObject:msgDict forKey:kGamePacketArchiveKey];
   [archiver finishEncoding];
   
   [self sendPacketDictionaryAsData:data givingBackProgressInfo:NO];
   
   [archiver release];
   [data release];
#endif
}

- (void)sendPlayerInfoPacket:(PlayerInfoPacket *)iPacket
{
   [self archiveAndSendPacket:iPacket forKey:kDictMessagePlayerInfoKey givingBackProgressInfo:NO];
#ifdef _NIJE_
   NSMutableData    *data = [[NSMutableData alloc] init];
   NSKeyedArchiver  *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
   
   NSDictionary     *msgDict = [NSDictionary dictionaryWithObject:iPacket forKey:kDictMessagePlayerInfoKey];
   
   [archiver encodeObject:msgDict forKey:kGamePacketArchiveKey];
   [archiver finishEncoding];
   
   [self sendPacketDictionaryAsData:data givingBackProgressInfo:NO];
   
   [archiver release];
   [data release];
#endif
}

- (void)sendImageInfoPacket:(ImageInfoPacket *)iPacket
{
   [self archiveAndSendPacket:iPacket forKey:kDictMessageImageInfoKey givingBackProgressInfo:NO];
#ifdef _NIJE_
   NSMutableData    *data = [[NSMutableData alloc] init];
   NSKeyedArchiver  *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
   
   NSDictionary     *msgDict = [NSDictionary dictionaryWithObject:iPacket forKey:kDictMessageImageInfoKey];
   
   [archiver encodeObject:msgDict forKey:kGamePacketArchiveKey];
   [archiver finishEncoding];
   
   [self sendPacketDictionaryAsData:data givingBackProgressInfo:NO];
   
   [archiver release];
   [data release];
#endif
}

- (void)sendImageDataPacket:(ImageDataPacket *)iPacket
{
   [self archiveAndSendPacket:iPacket forKey:kDictMessageImageDataKey givingBackProgressInfo:YES];
#ifdef _NIJE_
   NSMutableData    *data = [[NSMutableData alloc] init];
   NSKeyedArchiver  *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
   
   NSDictionary     *msgDict = [NSDictionary dictionaryWithObject:iPacket forKey:kDictMessageImageDataKey];
   
   [archiver encodeObject:msgDict forKey:kGamePacketArchiveKey];
   [archiver finishEncoding];
   
   [self sendPacketDictionaryAsData:data givingBackProgressInfo:YES];
   
   [archiver release];
   [data release];
#endif
}

#pragma mark -
#pragma mark Low Level Receive
#pragma mark -

// Here we check for three (so far) types of items in the dict: imgInfo, imgData and gamePacket

- (void)handleReceivedData:(NSData *)allData
{
   MessageHeader     msgHead;
   NSInteger         expectedMessageId = self.receivedMsgSerialNo + 1;
   
   [allData getBytes:&msgHead length:sizeof(MessageHeader)];
   
   msgHead.msgSerialNo = ntohs (msgHead.msgSerialNo);
   
   if (msgHead.msgCoreType != kMsgCoreTypeStructResendReq)  {
      if (!self.receivedMsgSerialNo || (msgHead.msgSerialNo == expectedMessageId))
         self.receivedMsgSerialNo = msgHead.msgSerialNo;
      else  {
         // Here we need a flag that we're already expecting older messages, so anything that comes between should be ignored.
         if (msgHead.msgSerialNo > expectedMessageId)  {
            [self sendPleaseResendFromId:expectedMessageId];
            NSLog (@"Please resend, came: %d, expected: %d", msgHead.msgSerialNo, expectedMessageId);
            [self.theOLSession clearQueuedIncomingData];  // Probablly not needed.
         }
         else
            NSLog (@"Lower Msg ID then last one. Duplicate? Came: %d, expected: %d", msgHead.msgSerialNo, expectedMessageId);
         return;
      }
   }

   if ((msgHead.msgCoreType == kMsgCoreTypeStruct) || (msgHead.msgCoreType == kMsgCoreTypeStructResendReq))  {
      SimpleGamePacket  simplePacket;
      [allData getBytes:&simplePacket range:NSMakeRange(sizeof(MessageHeader), ntohl(msgHead.msgSize))];
      simplePacket.fromLocIndex = ntohl(simplePacket.fromLocIndex);
      simplePacket.toLocIndex   = ntohl(simplePacket.toLocIndex);
      [self handleReceivedSimplePacket:&simplePacket];
   }
   else  if (msgHead.msgCoreType == kMsgCoreTypeData)  {
      char  *dataPtr = (char *)[allData bytes] + sizeof(MessageHeader);
      
      NSData  *data = [NSData dataWithBytes:dataPtr length:ntohl(msgHead.msgSize)];

      // Dictionary actually here...
      // Keys in it: kDictMessageImageInfoKey, kDictMessageImageDataKey, kDictMessageGamePacketKey
      
      NSKeyedUnarchiver  *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
      NSDictionary       *msgDict    = [unarchiver decodeObjectForKey:kGamePacketArchiveKey];
      GamePacket         *plainPacket;
      PlayerInfoPacket   *plriPacket;  // just player name
      ImageInfoPacket    *infoPacket;   // just info
      ImageDataPacket    *dataPacket;   // actual image
      // GameInfoPacket     *giPacket;     // side elems etc...
      
      if (plainPacket = [msgDict objectForKey:kDictMessageGamePacketKey])
         [self handleReceivedPacket:plainPacket];
      
      if (plriPacket = [msgDict objectForKey:kDictMessagePlayerInfoKey])
         [self handleReceivedPlayerInfoPacket:plriPacket];
      
      if (infoPacket = [msgDict objectForKey:kDictMessageImageInfoKey])
         [self handleReceivedImageInfoPacket:infoPacket];
      
      if (dataPacket = [msgDict objectForKey:kDictMessageImageDataKey])
         [self handleReceivedImageDataPacket:dataPacket];
      
      // if (giPacket = [msgDict objectForKey:kDictMessageGameInfoKey])
      //    [self handleReceivedGameInfoPacket:giPacket];
      
      [unarchiver release];
   }
   else
      NSLog (@"handleReceivedData - unknown dataType!");
}

- (void)handleReceivedSimplePacket:(SimpleGamePacket *)aPacket  // simple game packet, moves and touches
{
   switch (aPacket->packetType)  {
      case  kSimplePacketTypeMove:
         [self handleMoveFromLocIndex:aPacket->fromLocIndex
                           toLocIndex:aPacket->toLocIndex];
         break;
      case  kSimplePacketTypeTouch:
         [self handleTouchLocIndex:aPacket->fromLocIndex];
         break;
         
      case  kSimplePacketTypeTime:
         [self handleOpponentsTime:aPacket->fromLocIndex];
         break;
         
      case  kSimplePacketTypePlayerAck:
         [self handlePlayerAcknowledged];
         break;
      case  kSimplePacketTypeImgAck:
         [self handleImgAcknowledged];
         break;
      case  kSimplePacketTypeMoveAck:
         moveAcknowledgedFlag = YES;
         break;
      case  kSimplePacketTypeTouchAck:
         touchAcknowledgedFlag = YES;
         break;
      case  kSimplePacketTypeTimeAck:
         timeAcknowledgedFlag = YES;
         break;
         
      case  kSimplePacketTypeQuit:
         [self handleOpponentsQuit];
         break;
         
      case  kSimplePacketTypePleaseResend:
         [self handlePleaseResendWithMsgId:aPacket->fromLocIndex];
         break;

      case  kSimplePacketTypeBadLuck:
         [self handleOpponentsQuit];  // What else?
         break;

      case  kSimplePacketTypePing:
         [self handleOpponentsPing];
         break;
      case  kSimplePacketTypePingAck:
         pingAcknowledgedFlag = YES;
         break;
   }
}

- (void)handleReceivedPacket:(GamePacket *)gPacket  // basic game packet, moves and stuff
{
   switch (gPacket.packType)  {
         
      case  kPacketTypeDieRoll:
         // inLabel.text = @"i.Roll";
         // inCntLabel.text = [NSString stringWithFormat:@"%d%@", olSession.totalBytesIn, [olSession readLeftoverInfo]];
         opponentDieRollValue = gPacket.theDieRoll;
         // outLabel.text = @"o.Ack";
         GamePacket  *ackPacket = [[GamePacket alloc] initAckPacketWithDieRoll:opponentDieRollValue];
         [self sendPacket:ackPacket];
         [ackPacket release];
         dieRollReceivedFlag = YES;
#ifdef _NETTALK_LOG_
         NSLog (@"handleReceivedPacket: - kPacketTypeDieRoll");
#endif
         break;
         
      case  kPacketTypeAck:
         // inLabel.text = @"i.Ack";
         // inCntLabel.text = [NSString stringWithFormat:@"%d%@", olSession.totalBytesIn, [olSession readLeftoverInfo]];
         if (gPacket.theDieRoll != ourDieRollValue) {
            NSLog(@"Ack packet doesn't match opponentDieRoll (mine: %d, send: %d", gPacket.theDieRoll, ourDieRollValue);
            // Never trust the connection. This shouldn't ever happen, but if it does, it's probably an
            // indication of a cheat. In a real program, you would take steps here - either end the game
            // and inform the user why, or force a re-roll.
            //
            // We're just going to log it and move on with our lives.
         }
#ifdef _NETTALK_LOG_
         else
            NSLog (@"handleReceivedPacket: - kPacketTypeAck");
#endif
         dieRollAcknowledgedFlag = YES;
         break;
                  
      case  kPacketTypeBitteWarten:
         [self handleBitteWarten];
         break;
         
      case  kPacketTypeBitteWartenAck:
         [self handleBitteWartenAcknowledged];
         break;
         
      case  kPacketTypeImgInfoRequest:
         if (!gGPrefsRec.pfShowSettingsBeforeGame)  // because server is in that quickPrefs dialog, so do it later
            [self sendImageInfo];
         // so, if we show the prefs, then mainViewController should call -sendImageInfo
         break;
         
      case  kPacketTypeImgDataRequest:
         [self sendImageData];
         break;
                  
      case  kPacketTypeMove:  // Not Really used
         
         [self handleMoveFromLocIndex:gPacket.fromLocIndex toLocIndex:gPacket.toLocIndex];

         // HERE!
         // NEED TO MOVE TILES WITH INFORMATION WE GOT:
         // gPacket.fromLocIndex  & gPacket.toLocIndex
         
         // inLabel.text = @"i.Move";
         // inCntLabel.text = [NSString stringWithFormat:@"%d%@", olSession.totalBytesIn, [olSession readLeftoverInfo]];
         
         // UIButton  *theButton = (UIButton *)[self.view viewWithTag:packet.space];
         // [theButton setImage:(piece == kPlayerPieceO) ? xPieceImage : oPieceImage forState:UIControlStateNormal];
         // state = kGameStateMyTurn;
         // feedbackLabel.text = NSLocalizedString(@"Your Turn", @"Your Turn");
         // [self checkForGameEnd];
         
         // NSLog (@"handleReceivedPacket: - kPacketTypeMove");
         break;
         
      case  kPacketTypeTouch:  // Not Really used
         [self handleTouchLocIndex:gPacket.fromLocIndex];
         break;
         
      case  kPacketTypeReset:
         // OH! When will this happen? New Round??
         
         // inLabel.text = @"i.Reset";
         // inCntLabel.text = [NSString stringWithFormat:@"%d%@", olSession.totalBytesIn, [olSession readLeftoverInfo]];
         // if (state == kGameStateDone)
         //    [self resetDieState];
#ifdef _NETTALK_LOG_
         NSLog (@"handleReceivedPacket: - kPacketTypeReset");
#endif
         break;
         
      default:
         NSLog (@"handleReceivedPacket: UNKNOWN PACKET - [%d]", gPacket.packType);
         // inLabel.text = [NSString stringWithFormat:@"i.UNK(%d)", packet.packType];
         // inCntLabel.text = [NSString stringWithFormat:@"%d%@", olSession.totalBytesIn, [olSession readLeftoverInfo]];
         break;
   }
   
   if (dieRollReceivedFlag == YES && dieRollAcknowledgedFlag == YES)
      [self handleDieRollAcknowledged];
}

- (void)handleReceivedPlayerInfoPacket:(PlayerInfoPacket *)pliPacket  // by both
{
   // if (self.initialGameState)
   //    self.initialGameState.opponentName = pliPacket.playerName;
   
   self.opponentName = pliPacket.playerName;
   
   [self sendPlayerInfoAcknowledgedPacket];
}

- (void)handleReceivedImageInfoPacket:(ImageInfoPacket *)imiPacket  // by client
{
   if (bitteWartenAlert)
      [self dismissBitteWartenAlert];

   self.imgKey          = imiPacket.imageKey;
   self.builtInAlbumIdx = imiPacket.builtInAlbumIndex;
   
   self.initialGameState = [self initialGameStateWithSideElems:imiPacket.giSideElems
                                               cooperationMode:imiPacket.giCooperationMode
                                                   andOpponent:self.opponentName];
   
#ifdef _NETTALK_LOG_
   NSLog (@"handleReceivedImageInfoPacket - peerName: %@", self.initialGameState.opponentName);
#endif
   
   if ([self.mainViewController isImageAvailableForImageKey:self.imgKey orBuiltInAlbumIndex:self.builtInAlbumIdx])  {
#ifdef _NETTALK_LOG_
      NSLog (@"handleReceivedImageInfoPacket: imageIsAvailable - %@ [%d]", self.imgKey, self.builtInAlbumIdx);
#endif
      [self sendImgAcknowledgedPacket];
      [self.mainViewController asClientStartGameWithImage:nil forKey:self.imgKey withBuiltInIndex:self.builtInAlbumIdx];
   }
   else  {
      NSLog (@"handleReceivedImageInfoPacket: image NOT Available - %@[%d]", self.imgKey, self.builtInAlbumIdx);
      [self sendImageDataRequest];
   }
}

- (void)handleReceivedImageDataPacket:(ImageDataPacket *)imdPacket  // by client
{
   NSString    *tmpImageKey   = imdPacket.imageKey;
   NSInteger    tmpImageIndex = imdPacket.builtInAlbumIndex;
   UIImage     *tmpNewImage   = imdPacket.theImage;
   
   // Maybe to compare key and idx to saved values...
   
#ifdef _NETTALK_LOG_
   NSLog (@"handleReceivedImageDataPacket: %@[%d]", tmpImageKey, tmpImageIndex);
#endif   
   [self sendImgAcknowledgedPacket];
   
   [self.mainViewController asClientStartGameWithImage:tmpNewImage forKey:tmpImageKey withBuiltInIndex:tmpImageIndex];
}

#pragma mark -

- (void)sendPleaseResendFromId:(NSInteger)lastReceivedMsgId
{
#ifdef _NETTALK_LOG_
   NSLog (@"sendPleaseResendFromId: [%d]", lastReceivedMsgId);
#endif
   
   SimpleGamePacket  simplePacket;
   bzero (&simplePacket, sizeof(SimpleGamePacket));
   
   simplePacket.packetType = kSimplePacketTypePleaseResend;
   simplePacket.fromLocIndex = lastReceivedMsgId;
   
   [self sendSimplePacket:&simplePacket];
   // pleaseResendAckFlag = NO;
}

- (void)handlePleaseResendWithMsgId:(NSInteger)msgId
{
#ifdef _NETTALK_LOG_
   NSLog (@"handlePleaseResend");
#endif
   
   if ([self messageArchiveContainsMessageId:msgId])  {
      [self.theOLSession clearQueuedOutgoingData];
      [self resendArchivedMessagesStartingWithId:msgId];
   }
   // clear out-buffers and resend from the message, otherwise send badLuck message
   else
      [self sendPleaseResendBadLuckPacket];  // Sorry, can't do
}

- (void)sendPleaseResendBadLuckPacket
{
#ifdef _NETTALK_LOG_
   NSLog (@"sendPleaseResendBadLuckPacket");
#endif
   [self sendSimpleAckPacketOfType:kSimplePacketTypeBadLuck];  // Change this call
   // pleaseResendAckFlag = YES;
}

#pragma mark -

// Used from OnlinePeerBrowser

- (void)browserCancelled
{
// #ifdef _NETTALK_LOG_
   NSLog (@"browserCancelled");
// #endif
   
   [self.mainViewController dismissModalViewControllerAnimated:YES];
   
   // newGameButton.hidden = NO;
   // feedbackLabel.text = @"";
}

#pragma mark -
#pragma mark GameKit Peer Picker Delegate Methods

- (void)peerPickerController:(GKPeerPickerController *)picker didSelectConnectionType:(GKPeerPickerConnectionType)type
{
   if (type == GKPeerPickerConnectionTypeOnline)  {
      picker.delegate = nil;
      [picker dismiss];
      [picker autorelease];
      
      OnlineListener  *theListener = [[OnlineListener alloc] init];
      self.olsListener = theListener;
      theListener.delegate = self;
      [theListener release];
      
      NSError  *err;
      
      if (![self.olsListener startListening:&err])
         [self showErrorAletWithTitle:@"Error Starting Listener!" message:@"Unable to start online play."];
      
      if (!self.publishedNetService)  {
         NSNetService  *theService = [[NSNetService alloc] initWithDomain:@"" type:kBonjourType name:@"" port:olsListener.port];
         self.publishedNetService = theService;
         [theService release];
         
         [self.publishedNetService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
         [self.publishedNetService setDelegate:self];
         [self.publishedNetService publish];
      }
      
      OnlinePeerBrowser  *opBrowser = [[OnlinePeerBrowser alloc] initWithNetworkingController:self
                                                                                   nibName:@"OnlinePeerBrowser"
                                                                                    bundle:nil];
      
      [self.mainViewController presentModalViewController:opBrowser animated:YES];
      [opBrowser release];
   }
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type
{
   GKSession  *theSession = [[GKSession alloc] initWithSessionID:kGameKitSessionID displayName:nil sessionMode:GKSessionModePeer];
   
   return ([theSession autorelease]);
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)thePeerID toSession:(GKSession *)theSession
{
   self.gkPeerID = thePeerID;
   
   self.theGKSession = theSession;
   self.theGKSession.delegate = self; 
   
   [self.theGKSession setDataReceiveHandler:self withContext:NULL];
   
   [picker dismiss];
   picker.delegate = nil;
   [picker release];
   
   [self startNewNetworkedGame];
}

#pragma mark -
#pragma mark GameKit Session Delegate Methods

- (void)session:(GKSession *)theSession didFailWithError:(NSError *)error
{
   [self showErrorAletWithTitle:NSLocalizedString(@"Error Connecting!", @"Error Connecting!") 
                        message:NSLocalizedString(@"Unable to establish the connection.",@"Unable to establish the connection.")];
   
   theSession.available = NO;
   [theSession disconnectFromAllPeers];
   theSession.delegate = nil;
   [theSession setDataReceiveHandler:nil withContext:nil];
   
   self.theGKSession = nil;
}

- (void)session:(GKSession *)theSession peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)inState
{
   if (inState == GKPeerStateDisconnected)  {
      self.netControllerState = kNCStateInterrupted;
      
      if (self.netControllerState != kNCStateDone)  {
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Peer Disconnected!", @"Peer Disconnected!") 
                                                         message:NSLocalizedString(@"Your opponent has disconnected, or the connection has been lost",@"Your opponent has disconnected, or the connection has been lost") 
                                                        delegate:self 
                                               cancelButtonTitle:NSLocalizedString(@"Bummer", @"Bummer")
                                               otherButtonTitles:nil];
         [alert show];
         [alert release];
      }
      theSession.available;
      [theSession disconnectFromAllPeers];
      theSession.delegate = nil;
      [theSession setDataReceiveHandler:nil withContext:nil];
      
      self.theGKSession = nil;
   }
}

#pragma mark -
#pragma mark GameKit Send & Receive Methods

// Vidi sto je ovo zapravo, cija je to delegate metoda...

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)theSession context:(void *)context
{
   [self handleReceivedData:data];
}

#pragma mark -
#pragma mark Net Service Delegate Methods (Publishing)

- (void)netService:(NSNetService *)theNetService didNotPublish:(NSDictionary *)errDict
{
   NSNumber  *errDomain = [errDict valueForKey:NSNetServicesErrorDomain];
   NSNumber  *errCode   = [errDict valueForKey:NSNetServicesErrorCode];
   
   [self showErrorAletWithTitle:@"Unable to connect"
                        message:[NSString stringWithFormat:@"Unable to publish Bonjour service: %@, %@", errDomain, errCode]];
   [theNetService stop];
}

- (void)netServiceDidStop:(NSNetService *)sender
{
#ifdef _NETTALK_LOG_
   NSLog (@"netServiceDidStop:");
#endif
   self.publishedNetService.delegate = nil;
   self.publishedNetService = nil;
   
   if (self.foundNetService)  {
      self.foundNetService.delegate = nil;
      self.foundNetService = nil;
   }
}

#pragma mark -
#pragma mark Net Service Delegate Methods (General)

- (void)handleError:(NSNumber *)errCode withService:(NSNetService *)theService
{
   [self showErrorAletWithTitle:@"A network error occured."
                        message:[NSString stringWithFormat:@"An error occured with service: %@, %@, %@. Error code: %@",
                                 [theService name], [theService type], [theService domain], errCode]];
}

#pragma mark -
#pragma mark Net Service Delegate Methods (Resolving)

- (void)netService:(NSNetService *)theService didNotResolve:(NSDictionary *)errDict
{
   NSNumber  *errDomain = [errDict valueForKey:NSNetServicesErrorDomain];
   NSNumber  *errCode   = [errDict valueForKey:NSNetServicesErrorCode];
   
   [self showErrorAletWithTitle:@"Unable to connect."
                        message:[NSString stringWithFormat:@"Problem connecting with the remote device: %@. Error code: %@",
                                 errDomain, errCode]];
   [theService stop];
}

- (void)netServiceDidResolveAddress:(NSNetService *)theService
{
#ifdef _NETTALK_LOG_
   NSLog (@"netServiceDidResolveAddress: Addresses: %d, port: %d", [theService.addresses count], theService.port);
#endif
   [self.olsListener stopListening];
   self.olsListener = nil;
   
   NSInputStream   *inStream  = nil;
   NSOutputStream  *outStream = nil;
   
   if (![theService getInputStream:&inStream outputStream:&outStream])  {
      [self showErrorAletWithTitle:@"Unable to connect" message:@"Problem connecting with the remote device."];
      return;
   }
   
   if ([theService.addresses count])  {
      self.remoteAddressAsData = [theService.addresses objectAtIndex:0];
   
      OnlineSession  *theSession = [[OnlineSession alloc] initWithInputStream:inStream outputStream:outStream];
      
      theSession.delegate = self;
      self.theOLSession = theSession;
      [theSession release];
   }
   else
      self.remoteAddressAsData = nil;

}

#pragma mark -
#pragma mark Online Session Listener Delegate Methods

- (void)acceptConnectionForListener:(OnlineListener *)theListener
                        inputStream:(NSInputStream *)theInputStream
                       outputStream:(NSOutputStream *)theOutputStream
{
#ifdef _NETTALK_LOG_
   NSLog (@"acceptConnectionForListener:inputStream:outputStream:");
#endif
   
   self.ourServingAddressAsData = theListener.ourAddress;
   self.remoteAddressAsData     = theListener.remoteAddress;
   
   OnlineSession  *theSession = [[OnlineSession alloc] initWithInputStream:theInputStream outputStream:theOutputStream];
   
   theSession.delegate = self;
   self.theOLSession = theSession;
   [theSession release];
}

#pragma mark -
#pragma mark Online Session Delegate Methods

- (void)onlineSessionReadyForUse:(OnlineSession *)theSession
{
#ifdef _NETTALK_LOG_
   NSLog (@"onlineSessionReadyForUse:");
#endif   
   if (self.mainViewController.modalViewController)  {                    // Dismiss peer browser if there is any
      [self.mainViewController dismissModalViewControllerAnimated:NO];    // was YES 
#ifdef _NETTALK_LOG_
      NSLog (@"onlineSessionReadyForUse + dismissModalViewControllerAnimated:");
#endif   
   }
   
   if (self.netControllerState == kNCStateBeginning)  // otherwise, just restarting the damn thing!
      [self startNewNetworkedGame];
}

- (void)onlineSession:(OnlineSession *)session receivedData:(NSData *)data
{
#ifdef _NETTALK_LOG_
   NSLog (@"onlineSession:receivedData:");
#endif
   [self handleReceivedData:data];
}

- (void)onlineSession:(OnlineSession *)session encounteredReadError:(NSError *)err
{
#ifdef _NETTALK_LOG_
   NSLog (@"onlineSession:encounteredReadError:");
#endif

   [self showErrorAletWithTitle:@"Error reading."
                        message:@"Could not read sent packet"];
   self.theOLSession = nil;

   if (self.netControllerState != kNCStateDone)
      [self handleReconnection];
}

- (void)onlineSession:(OnlineSession *)session encounteredWriteError:(NSError *)err
{
#ifdef _NETTALK_LOG_
   NSLog (@"onlineSession:encounteredWriteError:");
#endif
   [self showErrorAletWithTitle:@"Error writing."
                        message:@"Could not send packet"];
   self.theOLSession = nil;

   if (self.netControllerState != kNCStateDone)
      [self handleReconnection];
}

- (void)onlineSessionDisconnected:(OnlineSession *)session
{
#ifdef _NETTALK_LOG_
   NSLog (@"onlineSessionDisconnected:");
#endif
   
   if (self.netControllerState != kNCStateDone)
      [self showErrorAletWithTitle:@"Peer disconnected."
                           message:@"Your opponent disconnected or otherwise could not be reached"];
   self.theOLSession = nil;
   
#ifdef _NIJE_
   // I think we don't need this
   [self resetDieState];
   
   if (self.publishedNetService)
      [self.publishedNetService stop];
#endif
   if (self.netControllerState != kNCStateDone)
      [self handleReconnection];
}

- (void)handleReconnection
{
   if ((self.netControllerState == kNCStateReadyAsServer) || (self.netControllerState == kNCStateReadyAsClient))  {
      
      if (self.ourServingAddressAsData)  {
#ifdef _NETTALK_LOG_
         NSLog (@"onlineSessionDisconnected: - ourServingAddressAsData");
#endif
         self.netControllerState = kNCStateInterrupted;
         OnlineListener  *theListener = [[OnlineListener alloc] init];
         self.olsListener = theListener;
         theListener.delegate = self;
         [theListener release];
         
         NSError  *err;
         
         if (![self.olsListener startListeningAtAddress:self.ourServingAddressAsData error:&err])
            [self showErrorAletWithTitle:@"Error Starting Listener!" message:@"Unable to start online play."];
      }
      else  if (self.remoteAddressAsData)  {
#ifdef _NETTALK_LOG_
         NSLog (@"onlineSessionDisconnected: - remoteAddressAsData");
#endif
         attemptedRetrys = 0;
         [self performSelector:@selector(tryReconnecting) withObject:nil afterDelay:.2];
      }
   }
}

- (void)tryReconnecting
{
#ifdef _NETTALK_LOG_
   NSLog (@"tryReconnecting %d", attemptedRetrys);
#endif

   if (attemptedRetrys < 12)  {
      
      NSInputStream   *inStream;
      NSOutputStream  *outStream;
      NSError         *err;
      
      BOOL  okFlag = [OnlineSession reconnectToAddress:self.remoteAddressAsData
                                   returningReadStream:&inStream
                                        andWriteStream:&outStream
                                                 error:&err];
      
      if (okFlag)  {
         OnlineSession  *theSession = [[OnlineSession alloc] initWithInputStream:inStream outputStream:outStream];
         
         theSession.delegate = self;
         self.theOLSession = theSession;
         [theSession release];
         
         attemptedRetrys = 0;
      }
      else  {
         attemptedRetrys++;
         [self performSelector:@selector(tryReconnecting) withObject:nil afterDelay:1.];
      }
   }
}

#pragma mark -

// progress delegate - Online Session Delegate

- (void)onlineSession:(OnlineSession *)session writtenBytes:(NSInteger)writtenBytes ofTotalBytes:(NSInteger)totalBytes
{
   if ((writtenBytes < totalBytes) && totalBytes)  {
      if (!self.actionSheet)  {
         self.actionSheet = [[[UIActionSheet alloc] initWithTitle:@"Sending image\n\n\n"
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:nil] autorelease];

         self.progressView = [[[UIProgressView alloc] initWithFrame:CGRectMake(0.0f, 40.0f, 220.0f, 90.0f)] autorelease];
         [progressView setProgressViewStyle: UIProgressViewStyleDefault];
         
         [actionSheet addSubview:progressView];

         [progressView setProgress:(float)writtenBytes / totalBytes];
         [actionSheet showInView:self.mainViewController.view];
         progressView.center = CGPointMake (actionSheet.center.x, progressView.center.y);   
      }
      else  {
         [progressView setProgress:(float)writtenBytes / totalBytes];
      }
   }
   else  if (self.actionSheet)  {
      self.progressView = nil;
      [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
      self.actionSheet = nil;
   }
   NSLog (@"LONG WRITE - Written bytes %d of total bytes: %d", writtenBytes, totalBytes);
}


#pragma mark -
#pragma mark Alert View (Delegate) Methods

- (void)showErrorAletWithTitle:(NSString *)alertTitle
                       message:(NSString *)msg
{
   UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
   [alert show];
   [alert release];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
   // [self resetBoard];  // WTF?!
   
   // newGameButton.hidden = NO;
   
   // DO SOMETHING HERE!
   
   // reset all no not playing or something
}

#pragma mark -
#pragma mark Alert View Methods
#pragma mark -

- (void)attachActivityIndicator
{
   UIView   *aView = self.bitteWartenAlert;
   
   if (self.bitteWartenAlert)  {
      // Activity indicator
      UIActivityIndicatorView  *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
      aiv.center = CGPointMake (aView.bounds.size.width / 2.0f, aView.bounds.size.height / 2.f - 8.f);  // was - 40.f
      [aiv startAnimating];
      [self.bitteWartenAlert addSubview:aiv];
      
      [aiv release];
   }
}

- (void)showBitteWartenAlert
{
   UIAlertView  *baseAlert = [[UIAlertView alloc] initWithTitle:@"Please Wait\n\n\n"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
   
   self.bitteWartenAlert = baseAlert;
   
   [baseAlert show];
   
   [self performSelector:@selector(attachActivityIndicator) withObject:nil afterDelay:.1];
   [baseAlert release];
}

- (void)dismissBitteWartenAlert
{
   [self.bitteWartenAlert dismissWithClickedButtonIndex:0 animated:YES];
   self.bitteWartenAlert = nil;
}

#pragma mark -
#pragma mark Message HistoryViewController
#pragma mark -
// ---------------------------------------------------------------------------------------------------------------------

- (void)storeSentMessageData:(NSData *)msgData
{
   MessageHeader  msgHead;
   
   [msgData getBytes:&msgHead length:sizeof(MessageHeader)];

   if ((msgHead.msgCoreType != kMsgCoreTypeStructResendReq) && ![self messageArchiveContainsMessageId:ntohs(msgHead.msgSerialNo)])  {
      [self.sentMessagesArchive addObject:msgData];
   
      if ([self.sentMessagesArchive count] > kMaxMessagesInArchive)
         [self.sentMessagesArchive removeObjectAtIndex:0];
   }
}

- (void)clearSentMessageData
{
   [self.sentMessagesArchive removeAllObjects];
}

- (NSInteger)idOfMessageAtIndex:(NSInteger)idx
{
   NSInteger  messagesCnt = [self.sentMessagesArchive count];
   
   if (!messagesCnt || idx < 0 || idx >= messagesCnt)
      return (0);
   
   MessageHeader  msgHead;
   NSData        *oneMsg = [self.sentMessagesArchive objectAtIndex:idx];
   
   [oneMsg getBytes:&msgHead length:sizeof(MessageHeader)];
   
   return (ntohs(msgHead.msgSerialNo));
}

- (NSInteger)idOfFirstMessageInArchive
{
   return ([self idOfMessageAtIndex:0]);
}

- (NSInteger)idOfLastMessageInArchive
{
   return ([self idOfMessageAtIndex:[self.sentMessagesArchive count] - 1]);
}

- (BOOL)messageArchiveContainsMessageId:(NSInteger)msgId
{
   if ((msgId <= [self idOfLastMessageInArchive]) &&
       (msgId >= [self idOfFirstMessageInArchive]))
      return (YES);
   
   return (NO);
}

#ifdef _NIJE_
- (BOOL)messageIsAlreadyInArchive:(NSData *)msgData
{
   MessageHeader  msgHead;
   
   [msgData getBytes:&msgHead length:sizeof(MessageHeader)];
      
   return ([self messageArchiveContainsMessageId:ntohs(msgHead.msgSerialNo)]);
}
#endif

#pragma mark -

- (NSInteger)resendArchivedMessagesStartingWithId:(NSInteger)startMsgId
{
   NSInteger      messagesCnt = [self.sentMessagesArchive count];
   NSInteger      sentMsgCnt  = 0;
   MessageHeader  msgHead;
   
   if (!messagesCnt)
      return (0);
   
   for (int i=0; i<messagesCnt; i++)  {
      NSData  *oneMsg = [self.sentMessagesArchive objectAtIndex:i];
      [oneMsg getBytes:&msgHead length:sizeof(MessageHeader)];
      if (ntohs(msgHead.msgSerialNo) >= startMsgId)  {
         sentMsgCnt++;
         [self sendGamePacketAsData:oneMsg givingBackProgressInfo:NO];
      }
   }
   
   return (sentMsgCnt);
}

@end
