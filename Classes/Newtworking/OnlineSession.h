//
//  OnlineSession.h
//  TicTacToe
//
//  Created by Igor Delovski on 13.08.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  kOnlineSessionErrorDomain   @"Online Session Domain"
#define  kFailedToSendDataErrorCode  1000
#define  kDataReadErrorCode          1001

#define  kNoSocketAvailable          1002   // extra by me
#define  kCouldntConnectToAddress    1003
#define  kStreamError                1004


#define  kBufferSize                  512

@class OnlineSession;

@protocol OnlineSessionDelegate

- (void)onlineSessionReadyForUse:(OnlineSession *)session;

@optional

- (void)onlineSession:(OnlineSession *)session receivedData:(NSData *)data;
- (void)onlineSession:(OnlineSession *)session encounteredReadError:(NSError *)err;
- (void)onlineSession:(OnlineSession *)session encounteredWriteError:(NSError *)err;
- (void)onlineSessionDisconnected:(OnlineSession *)session;

- (void)onlineSession:(OnlineSession *)s writtenBytes:(NSInteger)wb ofTotalBytes:(NSInteger)tb;

@end


@interface OnlineSession : NSObject  <NSStreamDelegate> {
   id               delegate;
   
   NSInputStream   *inStream;
   NSOutputStream  *outStream;
   
   BOOL             writeReady;
   BOOL             readReady;
   
   NSMutableArray  *packetQueue;
   NSData          *readLeftover;
   NSData          *writeLeftover;
   
   // My extra
   NSUInteger       totalBytesIn, totalBytesOut;
   
   BOOL             startMonitoringWriteProgressFlag;
   BOOL             finalizeMonitoringWriteProgressFlag;
   
   NSInteger        monitoredPartTotalBytes;          // leftover + new packet together
   NSInteger        monitoredPartLeftBytes;           // bytes left to be sent
}

@property  (nonatomic, assign)  id<OnlineSessionDelegate>  delegate;
@property                       NSUInteger                 totalBytesIn;
@property                       NSUInteger                 totalBytesOut;

- (id)initWithInputStream:(NSInputStream *)theInStream outputStream:(NSOutputStream *)theOutStream;
// - (BOOL)sendData:(NSData *)data error:(NSError **)err;
- (BOOL)sendData:(NSData *)data givingBackProgressInfo:(BOOL)needsProgressInfo error:(NSError **)err;
- (BOOL)isReadyForUse;
- (NSString *)readLeftoverInfo;
- (void)clearQueuedOutgoingData;
- (void)clearQueuedIncomingData;

- (void)handleMonitoringWriteProgressWithLengthToSend:(NSInteger)sendLength andWrittenBytes:(NSInteger)writtenBytes;
- (void)informDelegateAboutProgressWithTotalBytes:(NSInteger)bytesToWrite andWrittenBytes:(NSInteger)writtenBytes;

+ (BOOL)reconnectToAddress:(NSData *)addrAsData
       returningReadStream:(NSInputStream **)retInStream
            andWriteStream:(NSOutputStream **)retOutStream
                     error:(NSError **)err;
@end
