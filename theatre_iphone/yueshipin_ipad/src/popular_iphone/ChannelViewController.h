//
//  ChannelViewController.h
//  theatreiphone
//
//  Created by Rong on 13-5-13.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SegmentControlView.h"
#import "VideoTypeSegment.h"
@interface ChannelViewController : UIViewController<VideoTypeSegmentDelegate>{
    UIButton *titleButton_;
    int typeSelectIndex_;
}
@property(nonatomic, strong)UIButton *titleButton;
@property(nonatomic, strong)SegmentControlView *segV;
@property(nonatomic,strong)VideoTypeSegment *videoTypeSeg;
@end
