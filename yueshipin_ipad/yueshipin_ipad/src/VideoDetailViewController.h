//
//  VideoDetailViewController.h
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-29.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "GenericBaseViewController.h"
#import "SinaWeibo.h"

@interface VideoDetailViewController : GenericBaseViewController  <SinaWeiboDelegate, SinaWeiboRequestDelegate>{
        SinaWeibo *_sinaweibo;
        NSDictionary *video;
}
@property (strong, nonatomic)NSString *prodId;
- (void)shareBtnClicked;
- (NSString *)parseVideoUrl:(NSDictionary *)tempVideo;
- (void)addListBtnClicked;
@end
