//
//  PlayVideoViewController.h
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-25.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "GenericBaseViewController.h"
#import "MediaObject.h"

@interface PlayVideoViewController : GenericBaseViewController
@property (nonatomic, strong)NSString *videoUrl;
@property (nonatomic, strong)MediaObject *media;
@end
