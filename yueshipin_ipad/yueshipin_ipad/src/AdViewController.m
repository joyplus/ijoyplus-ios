//
//  AdViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "AdViewController.h"
#import "CommonHeader.h"

@interface AdViewController (){
    UIImageView *adImageView;
    UIButton *adImageBtn;
}

@end

@implementation AdViewController

- (void)viewDidUnload
{
    [super viewDidUnload];
    adImageView = nil;
    adImageBtn = nil;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        
        adImageView = [[UIImageView alloc]initWithFrame:frame];
        [adImageView setImageWithURL:[NSURL URLWithString:@"http://cms.csdnimg.cn/article/201305/03/51834e6634ddf.jpg"]];
        [self.view addSubview:adImageView];
        
        adImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        adImageBtn.frame = adImageView.frame;
        [adImageBtn addTarget:self action:@selector(adImageBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:adImageBtn];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)adImageBtnClicked
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@""]];
}


@end
