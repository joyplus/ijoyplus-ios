
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

- (void)setPlayer:(AVPlayer*)player
{
	[(AVPlayerLayer*)[self layer] setPlayer:player];
}

/* Specifies how the video is displayed within a player layer’s bounds. 
	(AVLayerVideoGravityResizeAspect is default) */
- (void)setVideoFillMode:(NSString *)fillMode
{
	AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
	playerLayer.videoGravity = fillMode;
    // Workaround a bug in iOS 5.0
    float avFoundationVersion = [[[NSBundle bundleForClass:[AVPlayerLayer class]] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey] floatValue];
    if (avFoundationVersion < 292.24f)
    {
        @try
        {
            NSString *contentLayerKeyPath = [NSString stringWithFormat:@"%1$@%2$@.%3$@%2$@", @"player", [@"layer" capitalizedString], @"content"]; // playerLayer.contentLayer
            CALayer *contentLayer = [playerLayer valueForKeyPath:contentLayerKeyPath];
            if ([contentLayer isKindOfClass:[CALayer class]])
                [contentLayer addAnimation:[CABasicAnimation animation] forKey:@"sublayerTransform"];
        }
        @catch (NSException *exception)
        {
        }
        self.bounds = self.bounds;
    }

}

@end
