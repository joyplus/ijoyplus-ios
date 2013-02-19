
#import "AVPlayerDemoPlaybackView.h"
#import <AVFoundation/AVFoundation.h>

/* ---------------------------------------------------------
**  To play the visual component of an asset, you need a view 
**  containing an AVPlayerLayer layer to which the output of an 
**  AVPlayer object can be directed. You can create a simple 
**  subclass of UIView to accommodate this. Use the view’s Core 
**  Animation layer (see the 'layer' property) for rendering.  
**  This class, AVPlayerDemoPlaybackView, is a subclass of UIView  
**  that is used for this purpose.
** ------------------------------------------------------- */

@implementation AVPlayerDemoPlaybackView

+ (Class)layerClass
{
	return [AVPlayerLayer class];
}

- (AVPlayer*)player
{
	return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVQueuePlayer*)player
{
	[(AVPlayerLayer*)[self layer] setPlayer:player];
}

/* Specifies how the video is displayed within a player layer’s bounds. 
	(AVLayerVideoGravityResizeAspect is default) */
- (void)setVideoFillMode:(NSString *)fillMode
{
	AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
	playerLayer.videoGravity = fillMode;
}

@end
