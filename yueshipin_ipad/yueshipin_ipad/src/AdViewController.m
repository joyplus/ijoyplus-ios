//
//  AdViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "AdViewController.h"
#import "CommonHeader.h"
#import "SDImageCache.h"
@interface AdViewController ()

@end

@implementation AdViewController

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        
    }
    return self;
}

- (void)adImageBtnClicked
{
    [MobClick event:ADV_IMAGE_CLICKED_EVENT];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppDelegate instance].advTargetUrl]];
}

- (void)setAdvImage:(NSString *)imagePath
{
    UIImageView *adImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 428, 750)];
    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    adImageView.image = [UIImage imageWithData:data];
    [self.view addSubview:adImageView];
    
    UIButton *adImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    adImageBtn.frame = adImageView.frame;
    [adImageBtn addTarget:self action:@selector(adImageBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:adImageBtn];
}


@end
