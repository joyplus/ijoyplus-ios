//
//  BundingViewController.m
//  yueshipin
//
//  Created by 08 on 13-4-9.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "BundingViewController.h"
#import "ContainerUtility.h"
#import <Parse/Parse.h>
@interface BundingViewController ()

@end

@implementation BundingViewController
@synthesize strData;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, 49, 30);
    leftButton.backgroundColor = [UIColor clearColor];
    [leftButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bunding_bg.png"]];
    bgImage.frame = CGRectMake(76, 40, 168, 103);
    [self.view addSubview:bgImage];
    
    UILabel * tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(63, 170, 195, 38)];
    tipsLabel.text = @"即将在电视端上绑定悅视频，请确认是否本人操作";
    tipsLabel.textAlignment = UITextAlignmentCenter;
    tipsLabel.font = [UIFont systemFontOfSize:20];
    tipsLabel.backgroundColor = [UIColor clearColor];
    tipsLabel.textColor = [UIColor colorWithRed:82/255.f green:82/255.f blue:82/255.f alpha:1];
    [self.view addSubview:tipsLabel];
    
    UIButton * bundingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bundingBtn.frame = CGRectMake(70 , 230, 250, 38);
    [bundingBtn setBackgroundImage:[UIImage imageNamed:@"confirm_bunding.png"] forState:UIControlStateNormal];
    [bundingBtn setBackgroundImage:[UIImage imageNamed:@"confirm_bunding_f.png"] forState:UIControlStateHighlighted];
    [bundingBtn addTarget:self
                   action:@selector(bundingBtnClick)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bundingBtn];
    
    UIButton * unbundingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    unbundingBtn.frame = CGRectMake(70 , 282, 250, 38);
    [unbundingBtn setBackgroundImage:[UIImage imageNamed:@"cancel_bunding.png"] forState:UIControlStateNormal];
    [unbundingBtn setBackgroundImage:[UIImage imageNamed:@"cancel_bunding_f.png"] forState:UIControlStateHighlighted];
    [unbundingBtn addTarget:self
                   action:@selector(unbundingBtnClick)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:unbundingBtn];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)bundingBtnClick
{
    if (nil == strData)
        return;
    NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:@"kUserId"];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"3", @"push_type",
                          userId, @"user_id",
                          nil];
    
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:strData];
    [push setData:data];
    [push sendPushInBackground];
    
    //添加已绑定数据缓存
    [[ContainerUtility sharedInstance] setAttribute:[NSNumber numberWithBool:YES]
                                             forKey:[NSString stringWithFormat:@"%@_isBunding",userId]];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)unbundingBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
