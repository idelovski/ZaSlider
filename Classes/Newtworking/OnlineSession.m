//
//  OnlineSession.m
//  TicTacToe
//
//  Created by Igor Delovski on 13.08.2010.
//  Copyright 2010 Igor Delovski, Delovski d.o.o.. All rights reserved.
//

#import "OnlineSession.h"
#import "PacketCategories.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <CFNetwork/CFSocketStream.h>

@interface OnlineSession()

- (void)sendQueuedData;

@end

#pragma mark -

@implementation OnlineSession

@synthesize  delegate, totalBytesIn, totalBytesOut;

#pragma mark -

- (id)initWithInputStream:(NSInputStream *)theInStream outputStream:(NSOutputStream *)theOutStream
{
#ifdef _NETTALK_LOG_
   NSLog (@"initWithInputStream:outputStream:");
#endif
   
   if (self = [super init])  {
      inStream  = [theInStream retain];
      outStream = [theOutStream retain];
      
      [inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
      [outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
      
      inStream.delegate  = self;
      outStream.delegate = self;
      
      if ([inStream streamStatus] == NSStreamStatusNotOpen)
         [inStream open];
      if ([outStream streamStatus] == NSStreamStatusNotOpen)
         [outStream open];
      
      packetQueue = [[NSMutableArray alloc] init];
   }
   
   return (self);
}

- (void)dealloc
{
   [inStream close];
   [inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
   [inStream setDelegate:nil];
   [inStream release];
   
   [outStream close];
   [outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
   [outStream setDelegate:nil];
   [outStream release];
   
   [packetQueue release];
   [readLeftover release];
   [writeLeftover release];
   
   [super dealloc];
}

#pragma mark -

- (BOOL)sendData:(NSData *)data givingBackProgressInfo:(BOOL)needsProgressInfo error:(NSError **)err
{
   if (needsProgressInfo)
      startMonitoringWriteProgressFlag = YES;
   
   if (!data || ![data length])
      return (NO);
   
   [packetQueue addObject:data];
   
   if ([outStream hasSpaceAvailable])
      [self sendQueuedData];
   
   return (YES);
}

- (BOOL)isReadyForUse
{
   return (readReady && writeReady);
}

- (NSString *)readLeftoverInfo
{
   if (readReady && readLeftover)
      return ([NSString stringWithFormat:@"/%d", [readLeftover length]]);
   
   return (@"-");
}

- (void)clearQueuedOutgoingData
{
   if (writeLeftover)  {
      [writeLeftover release];
      writeLeftover = nil;
   }
   
   [packetQueue removeAllObjects];
}

- (void)clearQueuedIncomingData
{
   // Not sure if this is needed...
}

#pragma mark -

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)evtCode
{
   switch (evtCode)  {
      case  NSStreamEventOpenCompleted:
         
         if (stream == inStream)
            readReady = YES;
         else
            writeReady = YES;
         if ([self isReadyForUse] && [delegate respondsToSelector:@selector(onlineSessionReadyForUse:)])
            [delegate onlineSessionReadyForUse:self];
         break;
         
      case  NSStreamEventHasBytesAvailable:
         if (stream == inStream)  {
            if ([inStream hasBytesAvailable])  {
               NSMutableData  *data = [NSMutableData data];
               
               if (readLeftover)  {
                  NSLog(@"readLeftover");
                  [data appendData:readLeftover];
                  [readLeftover release];
                  readLeftover = nil;
               }
               
               NSInteger       bytesRead;
               static uint8_t  buffer[kBufferSize];
               
               bytesRead = [inStream read:buffer maxLength:kBufferSize];
               if ((bytesRead == -1) && ([delegate respondsToSelector:@selector(onlineSession:encounteredReadError:)]))  {
                  NSError  *err = [[NSError alloc] initWithDomain:kOnlineSessionErrorDomain code:kDataReadErrorCode userInfo:nil];
                  [delegate onlineSession:self encounteredReadError:err];
                  [err release];
               }
               else  if (bytesRead > 0)  {
                  totalBytesIn += bytesRead;
                  [data appendBytes:buffer length:bytesRead];
                  
                  NSArray  *dataPackets = [data splitTransferredPackets:&readLeftover];
                  
                  if (readLeftover)
                     [readLeftover retain];
                  
                  if ([delegate respondsToSelector:@selector(onlineSession:receivedData:)])  {
                     for (NSData *onepacketData in dataPackets)
                        [delegate onlineSession:self receivedData:onepacketData];
                  }
               }
            }
         }
         break;
         
      case  NSStreamEventErrorOccurred:
         if (delegate)  {
            NSError  *err = [stream streamError];
            if (stream == inStream)  {
               if ([delegate respondsToSelector:@selector(onlineSession:encounteredReadError:)])
                  [delegate onlineSession:self encounteredReadError:err];
            }
            else  {
               if ([delegate respondsToSelector:@selector(onlineSession:encounteredWriteError:)])
                  [delegate onlineSession:self encounteredWriteError:err];
            }
         }
         break;
         
      case  NSStreamEventHasSpaceAvailable:
         if (stream == outStream)
            [self sendQueuedData];
         break;
         
      case  NSStreamEventEndEncountered:
         if (delegate && [delegate respondsToSelector:@selector(onlineSessionDisconnected:)])
            [delegate onlineSessionDisconnected:self];
         readReady = writeReady = NO;
         break;
         
      default:
         break;
   }
}

#pragma mark -

- (void)sendQueuedData
{
   if (!writeLeftover && ![packetQueue count])
      return;
   
   NSMutableData  *dataToSend = [NSMutableData data];
   
   if (writeLeftover)  {
      [dataToSend appendData:writeLeftover];
      [writeLeftover release];
      writeLeftover = nil;
   }
   
   [dataToSend appendData:[packetQueue contentsForTransfer]];
   [packetQueue removeAllObjects];
   
   NSUInteger  sendLength = [dataToSend length];
   NSUInteger  writtenBytes = [outStream write:[dataToSend bytes] maxLength:sendLength];
   
   [self handleMonitoringWriteProgressWithLengthToSend:sendLength andWrittenBytes:writtenBytes];
   
   NSLog (@"sendQueuedData: - sendLength: %d, writtenBytes: %d", sendLength, writtenBytes);
   
   if ((writtenBytes == -1) && ([delegate respondsToSelector:@selector(onlineSession:encounteredWriteError:)]))  {
      [delegate onlineSession:self encounteredWriteError:[outStream streamError]];
   }
   else  if (writtenBytes != sendLength)  {
      NSRange  leftoverRange = NSMakeRange (writtenBytes, [dataToSend length] - writtenBytes);
      writeLeftover = [[dataToSend subdataWithRange:leftoverRange] retain];
   }
   
   if (writtenBytes > 0)
      totalBytesOut += writtenBytes;
}

- (void)handleMonitoringWriteProgressWithLengthToSend:(NSInteger)sendLength andWrittenBytes:(NSInteger)writtenBytes
{
   NSInteger  writtenSoFar = writtenBytes;
   
   if (startMonitoringWriteProgressFlag)  {
      startMonitoringWriteProgressFlag = NO;
      if (writtenBytes > 0)  {
         [self informDelegateAboutProgressWithTotalBytes:sendLength andWrittenBytes:writtenSoFar];
         
         monitoredPartTotalBytes = sendLength;
         monitoredPartLeftBytes  = sendLength - writtenBytes;
      }
   }
   else if (finalizeMonitoringWriteProgressFlag)  {
      monitoredPartLeftBytes -= writtenBytes;
      writtenSoFar = monitoredPartTotalBytes - monitoredPartLeftBytes;
      
      [self informDelegateAboutProgressWithTotalBytes:monitoredPartTotalBytes andWrittenBytes:writtenSoFar];
      
      if (writtenSoFar >= monitoredPartTotalBytes)  {
         monitoredPartTotalBytes = monitoredPartLeftBytes = 0;
         finalizeMonitoringWriteProgressFlag = NO;
      }
   }
}

- (void)informDelegateAboutProgressWithTotalBytes:(NSInteger)bytesToWrite andWrittenBytes:(NSInteger)writtenBytes
{
   if (writtenBytes > bytesToWrite)
      writtenBytes = bytesToWrite;
   
   if ([delegate respondsToSelector:@selector(onlineSession:writtenBytes:ofTotalBytes:)])  {
      [delegate onlineSession:self writtenBytes:writtenBytes ofTotalBytes:bytesToWrite];
      finalizeMonitoringWriteProgressFlag = YES;
   }
}

#pragma mark -

static void  sessionConnectCallback (CFSocketRef           theSocket,
                                     CFSocketCallBackType  theType,
                                     CFDataRef             theAddress,
                                     const void           *data,
                                     void                 *info);

static int  gGConnectErrorCode = 0;

+ (BOOL)reconnectToAddress:(NSData *)addrAsData
       returningReadStream:(NSInputStream **)retInStream
            andWriteStream:(NSOutputStream **)retOutStream
                     error:(NSError **)err
{
#ifdef _NETTALK_LOG_
   NSLog (@"reconnectToAddress:error:");
#endif
   
   CFSocketContext  socketCtx = { 0, &gGConnectErrorCode /*self*/, NULL, NULL, NULL };
   
   CFSocketRef  socketRef = CFSocketCreate (kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP,
                                            kCFSocketConnectCallBack, (CFSocketCallBack)sessionConnectCallback, &socketCtx);
   
   if (!socketRef)  {
      if (err)
         *err = [[[NSError alloc] initWithDomain:kOnlineSessionErrorDomain
                                           code:kNoSocketAvailable
                                       userInfo:nil] autorelease];
      return (NO);
   }
   
   // int  ret = 1, structLen = sizeof(struct sockaddr_in);
   
   // setsockopt (CFSocketGetNative(socketRef), SOL_SOCKET, SO_REUSEADDR, (void *)&ret, sizeof(int));
   
   if (CFSocketConnectToAddress(socketRef, (CFDataRef)addrAsData, 1) != kCFSocketSuccess)  {
      if (err)
         *err = [[[NSError alloc] initWithDomain:kOnlineSessionErrorDomain
                                           code:kCouldntConnectToAddress
                                       userInfo:nil] autorelease];
      if (socketRef)
         CFRelease (socketRef);
      return (NO);
   }
   
   // self.ourAddress = [(NSData *)CFSocketCopyAddress(socketRef) autorelease];
   
   // struct sockaddr_in  addr4;
   // memcpy (&addr4, [self.ourAddress bytes], [self.ourAddress length]);  // or memmove()
   
   // self.port = ntohs (addr4.sin_port);
   
   CFRunLoopRef        cfrl = CFRunLoopGetCurrent ();
   CFRunLoopSourceRef  src4 = CFSocketCreateRunLoopSource (kCFAllocatorDefault, socketRef, 0);
   CFRunLoopAddSource (cfrl, src4, kCFRunLoopCommonModes);
   CFRelease (src4);
   
   //
   
   CFSocketNativeHandle  nativeSocket = CFSocketGetNative (socketRef);
   
   NSInputStream   *readStream  = nil;   // was  CFReadStreamRef
   NSOutputStream  *writeStream = nil;   // was  CFWriteStreamRef
   
   CFStreamCreatePairWithSocket (kCFAllocatorDefault, nativeSocket, (CFReadStreamRef *)&readStream, (CFWriteStreamRef *)&writeStream);
   
   if (readStream && writeStream)  {
      CFReadStreamSetProperty  ((CFReadStreamRef)readStream,  kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
      CFWriteStreamSetProperty ((CFWriteStreamRef)writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
      
      // listener.remoteAddress = (NSData *)theAddress;   -> nekako vrati i adresu
      
      *retInStream  = readStream;
      *retOutStream = writeStream;
   }
   else  {
      close (nativeSocket);
      
      *err = [[[NSError alloc] initWithDomain:kOnlineSessionErrorDomain
                                        code:kStreamError
                                    userInfo:nil] autorelease];
   }
   
   if (readStream)
      [readStream autorelease];  // was CFRelease()
   if (writeStream)
      [writeStream autorelease];  // was CFRelease()
   
   return (YES);
}

@end

static void  sessionConnectCallback (CFSocketRef           theSocket,
                                     CFSocketCallBackType  theType,
                                     CFDataRef             theAddress,
                                     const void           *data,
                                     void                 *info)
{
   int  *errCode = (int *)info;
   
#ifdef _NETTALK_LOG_
   NSLog (@"sessionConnectCallback()");
#endif
   
   if (theType == kCFSocketConnectCallBack)  {
      if (info && data)
         *errCode = *((int *)data);
#ifdef _NIJE_
      CFSocketNativeHandle  nativeSocket = CFSocketGetNative (theSocket);
      
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
            NSError  *err = [[NSError alloc] initWithDomain:kOnlineListenerErrorDomain
                                                       code:kOnlineListenerErrorStreamError
                                                   userInfo:nil];
            [listenerDelegate onlineListener:listener encounteredError:err];
            [err release];
         }
      }
      
      if (readStream)
         CFRelease (readStream);
      if (writeStream)
         CFRelease (writeStream);
#endif
   }
}


