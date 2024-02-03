//
//  OnlineListener.m
//  TicTacToe
//
//  Created by Igor Delovski on 13.08.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

// TODO:
// Create init method that takes a delegate!

#import "OnlineListener.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <CFNetwork/CFSocketStream.h>

#pragma mark CFNetwork C Callbacks

static void  onlineListenerAcceptCallback (CFSocketRef           theSocket,
                                           CFSocketCallBackType  theType,
                                           CFDataRef             theAddress,
                                           const void           *data,
                                           void                 *info)
{
   OnlineListener  *listener = (OnlineListener *)info;
   id               listenerDelegate = listener.delegate;
   
#ifdef _NETTALK_LOG_
   NSLog (@"onlineListenerAcceptCallback()");
#endif

   if (theType == kCFSocketAcceptCallBack)  {
      CFSocketNativeHandle  nativeSocket = *(CFSocketNativeHandle *)data;
      uint8_t               name[SOCK_MAXADDRLEN];
      socklen_t             namelen = SOCK_MAXADDRLEN;
      NSData               *peer = nil;
      
      if (!getpeername(nativeSocket, (struct sockaddr *)name, &namelen))
         peer = [NSData dataWithBytes:name length:namelen];
      
      CFReadStreamRef   readStream  = NULL;
      CFWriteStreamRef  writeStream = NULL;
      
      CFStreamCreatePairWithSocket (kCFAllocatorDefault, nativeSocket, &readStream, &writeStream);
      
      if (readStream && writeStream)  {
         CFReadStreamSetProperty  (readStream,  kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
         CFWriteStreamSetProperty (writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
         
         listener.remoteAddress = (NSData *)theAddress;
         
         if (listenerDelegate && [listenerDelegate respondsToSelector:@selector(acceptConnectionForListener:inputStream:outputStream:)])
            [listenerDelegate acceptConnectionForListener:listener
                                              inputStream:(NSInputStream *)readStream
                                             outputStream:(NSOutputStream *)writeStream];
      }
      else  {
         close (nativeSocket);

         if (listenerDelegate && [listenerDelegate respondsToSelector:@selector(onlineListener:encounteredError:)])  {
            NSError  *err = [[NSError alloc] initWithDomain:kOnlineListenerErrorDomain code:kOnlineListenerErrorStreamError userInfo:nil];
            [listenerDelegate onlineListener:listener encounteredError:err];
            [err release];
         }
      }
      
      if (readStream)
         CFRelease (readStream);
      if (writeStream)
         CFRelease (writeStream);
   }
}
                                           
#pragma mark -

@implementation OnlineListener

@synthesize  delegate, port, ourAddress, remoteAddress;

#pragma mark Listener Methods

- (BOOL)startListening:(NSError **)err
{
   return ([self startListeningAtAddress:nil error:err]);
#ifdef _NIJE_
#ifdef _NETTALK_LOG_
   NSLog (@"startListening:");
#endif

   CFSocketContext  socketCtx = { 0, self, NULL, NULL, NULL };
   
   socketRef = CFSocketCreate (kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP,
                            kCFSocketAcceptCallBack, (CFSocketCallBack)onlineListenerAcceptCallback, &socketCtx);
   
   if (!socketRef)  {
      if (err)
         *err = [[[NSError alloc] initWithDomain:kOnlineListenerErrorDomain
                                           code:kOnlineListenerErrorNoSocketAvailable
                                       userInfo:nil] autorelease];
      return (NO);
   }
   
   int  ret = 1, structLen = sizeof(struct sockaddr_in);
   
   setsockopt (CFSocketGetNative(socketRef), SOL_SOCKET, SO_REUSEADDR, (void *)&ret, sizeof(int));
   
   struct sockaddr_in  addr4;
   memset (&addr4, 0, structLen);
   
   addr4.sin_len = structLen;
   addr4.sin_family = AF_INET;
   addr4.sin_port   = 0;
   addr4.sin_addr.s_addr = htonl (INADDR_ANY);
   
   NSData  *address4 = [NSData dataWithBytes:&addr4 length:structLen];
   
   if (CFSocketSetAddress(socketRef, (CFDataRef)address4) != kCFSocketSuccess)  {
      if (err)
         *err = [[[NSError alloc] initWithDomain:kOnlineListenerErrorDomain
                                           code:kOnlineListenerErrorCouldntBindToAddress
                                       userInfo:nil] autorelease];
      if (socketRef)
         CFRelease (socketRef);
      return (NO);
   }
   
   self.ourAddress = [(NSData *)CFSocketCopyAddress(socketRef) autorelease];
   memcpy (&addr4, [self.ourAddress bytes], [self.ourAddress length]);  // or memmove()

   self.port = ntohs (addr4.sin_port);
   
   CFRunLoopRef        cfrl = CFRunLoopGetCurrent ();
   CFRunLoopSourceRef  src4 = CFSocketCreateRunLoopSource (kCFAllocatorDefault, socketRef, 0);
   CFRunLoopAddSource (cfrl, src4, kCFRunLoopCommonModes);
   CFRelease (src4);
   
   return (YES);
#endif
}

- (BOOL)startListeningAtAddress:(NSData *)addrAsData error:(NSError **)err
{
#ifdef _NETTALK_LOG_
   NSLog (@"startListeningToAddress:error:");
#endif
   
   CFSocketContext  socketCtx = { 0, self, NULL, NULL, NULL };
   
   socketRef = CFSocketCreate (kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP,
                               kCFSocketAcceptCallBack, (CFSocketCallBack)onlineListenerAcceptCallback, &socketCtx);
   
   if (!socketRef)  {
      if (err)
         *err = [[[NSError alloc] initWithDomain:kOnlineListenerErrorDomain
                                           code:kOnlineListenerErrorNoSocketAvailable
                                       userInfo:nil] autorelease];
      return (NO);
   }
   
   int  ret = 1, structLen = sizeof(struct sockaddr_in);
   
   setsockopt (CFSocketGetNative(socketRef), SOL_SOCKET, SO_REUSEADDR, (void *)&ret, sizeof(int));
   
   if (!addrAsData)  {
      struct sockaddr_in  addr4;
      memset (&addr4, 0, structLen);
      
      addr4.sin_len = structLen;
      addr4.sin_family = AF_INET;
      addr4.sin_port   = 0;
      addr4.sin_addr.s_addr = htonl (INADDR_ANY);
      
      addrAsData = [NSData dataWithBytes:&addr4 length:structLen];
   }
      
   if (CFSocketSetAddress(socketRef, (CFDataRef)addrAsData) != kCFSocketSuccess)  {
      if (err)
         *err = [[[NSError alloc] initWithDomain:kOnlineListenerErrorDomain
                                            code:kOnlineListenerErrorCouldntBindToAddress
                                        userInfo:nil] autorelease];
      if (socketRef)
         CFRelease (socketRef);
      return (NO);
   }
   
   self.ourAddress = [(NSData *)CFSocketCopyAddress(socketRef) autorelease];

   struct sockaddr_in  addr4;
   memcpy (&addr4, [self.ourAddress bytes], [self.ourAddress length]);  // or memmove()
   
   self.port = ntohs (addr4.sin_port);
   
   CFRunLoopRef        cfrl = CFRunLoopGetCurrent ();
   CFRunLoopSourceRef  src4 = CFSocketCreateRunLoopSource (kCFAllocatorDefault, socketRef, 0);
   CFRunLoopAddSource (cfrl, src4, kCFRunLoopCommonModes);
   CFRelease (src4);
   
   return (YES);
}

#pragma mark -

- (void)stopListening
{
   if (socketRef)  {
#ifdef _NETTALK_LOG_
      NSLog (@"stopListening");
#endif
      CFSocketInvalidate (socketRef);
      CFRelease (socketRef);
      
      socketRef = NULL;
   }
}

- (void)dealloc
{
   [self stopListening];
   
   [ourAddress release];
   [remoteAddress release];
   
   [super dealloc];
}


@end
