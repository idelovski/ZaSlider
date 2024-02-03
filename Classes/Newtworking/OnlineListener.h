//
//  OnlineListener.h
//  TicTacToe
//
//  Created by Igor Delovski on 13.08.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  kOnlineListenerErrorDomain  @"Online Session Listener Error Domain"

#define  kOnlineListenerErrorNoSocketAvailable      1000
#define  kOnlineListenerErrorCouldntBindToAddress   1001
#define  kOnlineListenerErrorStreamError            1002

@class  OnlineListener;

@protocol OnlineListenerDelegate

- (void)acceptConnectionForListener:(OnlineListener *)theListener
                        inputStream:(NSInputStream *)theInputStream
                       outputStream:(NSOutputStream *)theOutputStream;

@optional

- (void)onlineListener:(OnlineListener *)theListener
      encounteredError:(NSError *)err;

@end

#pragma mark -

@interface OnlineListener : NSObject  {
   
   id           delegate;
   uint16_t     port;
   CFSocketRef  socketRef;
   NSData      *ourAddress;
   NSData      *remoteAddress;
   
}

@property  (nonatomic, assign)  id<OnlineListenerDelegate>  delegate;
@property                       uint16_t                    port;
@property  (nonatomic, retain)  NSData                     *ourAddress;
@property  (nonatomic, retain)  NSData                     *remoteAddress;

- (BOOL)startListening:(NSError **)err;
- (BOOL)startListeningAtAddress:(NSData *)addrAsData error:(NSError **)err;
- (void)stopListening;

@end
