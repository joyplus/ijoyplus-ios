//
//  GroupImageViewController.h
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "GenericBaseViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PlayMusicViewController : GenericBaseViewController

@property (nonatomic, strong)NSArray *mediaArray;
@property (nonatomic)int startIndex;
@property (nonatomic)BOOL showPlaying;
@end
