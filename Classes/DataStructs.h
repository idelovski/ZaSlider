/*
 *  DataStructs.h
 *  ZaSlider
 *
 *  Created by Igor Delovski on 05.10.2010.
 *  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
 *
 */

#pragma mark Saved File Names

// ---------------------------------------

#define kCustomAlbumName   @"CustomAlbum"
#define kSavedGameName     @"SavedGameSolo"
#define kSavedGameNetName  @"SavedGameNet"

// ---------------------------------------

#pragma mark Acceleration treshold points

// ---------------------------------------

#define  kTurnOnTreshold   .39
#define  kTurnOffTreshold  .15

// ---------------------------------------

#define  kMoveAnimationDuration  .25
#define  kGrowAnimationDuration  .07

// ---------------------------------------
#pragma mark Preferences

// ---------------------------------------

#define  kStringYES              @"YES"
#define  kStringNO               @"NO"

#define  kUDSideElemsKey         @"elems"
#define  kUDUseAccelerometerKey  @"accel"
#define  kUDShowNumbersKey       @"numb"
// #define  kUDShowArrowKey         @"arrow"
#define  kUDCoopModeKey          @"coop"
#define  kUDShowSettingsKey      @"ssett"
#define  kUDStoreNewImagesKey    @"store"

// ---------------------------------------

typedef struct  _prefs  {
   BOOL       pfUseAcceleration;
   BOOL       pfShowNumbers;
   BOOL       pfShowArrowNotUsed;         // Change to alow single tap
   BOOL       pfCooperationMode;
   BOOL       pfShowSettingsBeforeGame;
   BOOL       pfStoreCameraImages;        // store to iPhone's album
   
   NSInteger  pfSideElems;     // between 3 and 6
} PreferenceRecord;

// ---------------------------------------
#pragma mark ImageSource
// ---------------------------------------

#define  kImageSourceCamera             @"Camera"
#define  kImageSourceSavedPhotosAlbum   @"Saved Photos Album"
#define  kImageSourcePhotoLibrary       @"Photo Library"
#define  kImageSourceBuiltInAlbum       @"Game Photos"

// ---------------------------------------
#pragma mark GameState
// ---------------------------------------

#define  kGameFileSuffixAndExtension  @"GameState.saved"

// Most of these are used for GameHistory encoding too!

#define  kGSOpponentNameKey             @"name"
#define  kGSImageKeyKey                 @"image"
#define  kGSTileLocationsKey            @"tileLoc"
#define  kGSPlayingDateKey              @"date"

#define  kGSAlbumIndexKey               @"index"
#define  kGSSideElementsKey             @"elems"
#define  kGSEmptyTileLocKey             @"empty"
#define  kGSSecondsInGameKey            @"secs"
#define  kGSOpponentsSecondsKey         @"opsecs"
#define  kGSCoopModeGameKey             @"coop"

#define  kGSUsingNumbersKey             kUDShowNumbersKey
#define  kGSUsingArrowKey               kUDShowArrowKey

#pragma mark -

// ---------------------------------------
#pragma mark GameHistory
// ---------------------------------------

#define  kHistoryFileSuffixAndExtension  @"GameHistory.saved"

// ---------------------------------------
#pragma mark GameController
// ---------------------------------------

typedef enum  {
	kEmptyTile,
	kActiveTile
} TileType;

typedef enum  {
	kGameStarting,
	kGameShuffling,
	kGameInMakeover,  // changing picture
	kGameInProgress,
	kGamePaused,
	kGameOver
} GamePhase;

typedef struct  {
	int       locIndex;
	TileType  tileType;
} TileInfo;

#define  kTopOffset    0  // was 4
#define  kLeftOffset   0  // was 4
#define  kBotOffset   26


// ---------------------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Networking
#pragma mark -

#define  kGameKitSessionID  @"hr.delovski.Slider01.session"
#define  kBonjourType       @"_delovskiSlider01._tcp."
#define  kDiceNotRolled   INT_MAX

#define  rollTheDie()    (arc4random() % 10000)

// ---------------------------------------
//                           MessageHeader
// ---------------------------------------

typedef struct  MessageHeaderStruct  {
   uint32_t  msgSize;        // size without the header, useful only if SimpleGamePacketStruct changes in the future
   uint16_t  msgSerialNo;    // Starts from 1, goes on and on...
   uint8_t   msgCoreType;    // 1 = DataDict, 2 = SimpleStruct
   uint8_t   unused1;
} MessageHeader;

typedef enum  MsgCoreTypes  {
   kMsgCoreTypeData   = 1,
   kMsgCoreTypeStruct = 2,
   kMsgCoreTypeStructResendReq = 3  // Special treatment for resend requests
} MsgCoreType;

// ---------------------------------------
//                        SimpleGamePacket
// ---------------------------------------

typedef struct  SimpleGamePacketStruct  {
   uint8_t   packetType;        // 0 = Move, 1 = Touch
   uint8_t   unused1;

   uint16_t  shortFiller;

   uint32_t  fromLocIndex;      // or x, or last received
   uint32_t  toLocIndex;        // or y
   uint32_t  fuse_int;          // ...
} SimpleGamePacket;

typedef enum  SimpleGamePacketTypes  {
   kSimplePacketTypeMove  = 1,
   kSimplePacketTypeTouch,
   kSimplePacketTypeTime,            // tell the peer our time in seconds

   kSimplePacketTypePlayerAck,       // we received opponents name
   kSimplePacketTypeImgAck,          // we already have the image, also wehen we receive the image
   kSimplePacketTypeMoveAck,         // ok, we moved, go on
   kSimplePacketTypeTouchAck,        // ok, you touched, go on
   kSimplePacketTypeTimeAck,         // ok, got yout time, I can declarethe winner!
   kSimplePacketTypePingAck,         // ok, inform the peer we're alive!

   kSimplePacketTypePing,            // check if other player is out there...
   kSimplePacketTypeQuit,            // inform the peer we're giving up
   kSimplePacketTypePleaseResend,    // some messages were lost, resend
   kSimplePacketTypeBadLuck,         // well, can't resend shit because it's gone...
} SimpleGamePacketType;

// ---------------------------------------
//                              GamePacket
// ---------------------------------------

typedef enum  PacketTypes  {
   kPacketTypeDieRoll,         // determine who goes first
   kPacketTypeAck,             // to acknowledge die roll packet receipt
//   kPacketTypePlayerAck,       // we received opponents name
   kPacketTypeImgInfoRequest,  // tell us about the image
   kPacketTypeImgDataRequest,  // ok, we need the image
//   kPacketTypeImgAck,          // we already have the image, also wehen we receive the image
   kPacketTypeMove,            // send information about a player's move
//   kPacketTypeMoveAck,         // ok, we moved, go on
   kPacketTypeTouch,           // send information about a player's touch down
//   kPacketTypeTouchAck,        // ok, you touched, go on

   kPacketTypeBitteWarten,     // tell the other guy to show that wait dialog
   kPacketTypeBitteWartenAck,  // tell the first guy that we did

   kPacketTypeReset,           // inform the peer that we're starting over
//    kPacketTypeTime,            // tell the peer our time in seconds
} PacketType;

#define  kGPPacketTypeKey   @"type"
#define  kGPRollKey         @"roll"
#define  kGPFromLocIdxKey   @"from"
#define  kGPToLocIdxKey     @"to"

#define  kGPPlayerNameKey   @"playerName"

#define  kGPImageKeyKey     @"imgKey"
#define  kGPAlbumIndexKey   @"aidx"
#define  kGPImageKey        @"imgContent"

// ---------------------------------------
//                       DictionaryMessage
// ---------------------------------------

#define  kGamePacketArchiveKey      @"packetArchive"  // for archiver/unarchiver

#define  kDictMessageGamePacketKey  @"packet"      // moves and events
#define  kDictMessagePlayerInfoKey  @"playerInfo"  // imgKey + imgIdx
#define  kDictMessageImageInfoKey   @"imageInfo"   // imgKey + imgIdx
#define  kDictMessageImageDataKey   @"imageData"   // JPEG rep
// #define  kDictMessageGameInfoKey    @"settings"   // settings and stuff


