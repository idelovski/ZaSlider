- (void)moveTile:(TileView *)tileView toLocationIndex:(int)aLocation fast:(BOOL)fastFlag
{
   NSTimeInterval  aniDuration = fastFlag ? 0.05 : 0.25;
   
   if ([[ImageCache sharedImageCache] operationsInProgress])
      aniDuration = .01;
   
   [UIView beginAnimations:@"Shuffle" context:nil];
   [UIView setAnimationDuration:aniDuration];
   
   if (fastFlag)  {
      [UIView setAnimationDelegate:self];
      [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
   }
   
   tileView.curLocIndex = aLocation;   // sets frame property inside
   
   [UIView commitAnimations];
   // [tileView updateArrowPoint];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
   // CGRect        tmpRect;
   // BOOL          finishedFlag = [finished boolValue];
   NSUInteger       numberOfTiles = self.ourGameController.sideElements * self.ourGameController.sideElements;
   
   // if (finishedFlag)
      // NSLog (@"animationDidStop with ID: %@!", animationID);
   
   CGFloat  nextAniDelay = [[ImageCache sharedImageCache] operationsInProgress] ? 0.3 : 0.01;
      
   if ([animationID isEqualToString:@"Shuffle"])  {
      if ((shuffleCnt < numberOfTiles*3) ||
          (self.ourGameController.emptyTileLocIndex != (numberOfTiles-1)) ||
          [self allTilesAtCorrectLocation] ||
          ![self allTilesHaveImages])
         [self performSelector:@selector(startOneShuffleMove) withObject:nil afterDelay:nextAniDelay];
      else
         self.view.userInteractionEnabled = YES;         
   }
}

// Second version:

- (void)moveTile:(TileView *)tileView toLocationIndex:(int)aLocation fast:(BOOL)fastFlag
{
   NSTimeInterval  aniDuration = fastFlag ? 0.05 : 0.25;
   
   if (![[ImageCache sharedImageCache] operationsInProgress])  {
      
      [UIView beginAnimations:@"Shuffle" context:nil];
      [UIView setAnimationDuration:aniDuration];
      
      if (fastFlag)  {
         [UIView setAnimationDelegate:self];
         [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
      }
   }
   
   tileView.curLocIndex = aLocation;   // sets frame property inside
   
   if (![[ImageCache sharedImageCache] operationsInProgress])
      [UIView commitAnimations];
   else
      [self performSelector:@selector(startOneShuffleMove) withObject:nil afterDelay:.3];
}

