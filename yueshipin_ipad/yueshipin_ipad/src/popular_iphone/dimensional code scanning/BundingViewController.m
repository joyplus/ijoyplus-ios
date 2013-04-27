//
//  BundingViewController.m
//  yueshipin
//
//  Created by 08 on 13-4-9.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "BundingViewController.h"
#import "ContainerUtility.h"
#import "MBProgressHUD.h"

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
    UIImageView *backGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    backGround.frame = CGRectMake(0, 0, 320, kFullWindowHeight);
    [self.view addSubview:backGround];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, 55, 44);
    leftButton.backgroundColor = [UIColor clearColor];
    [leftButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bunding_background.png"]];
    bgImage.frame = CGRectMake(0, 35, 320, 121);
    [self.view addSubview:bgImage];
    
    UIImageView * tishi = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"queren_wenzi.png"]];
    tishi.frame = CGRectMake(0, 195, 320, 42);
    [self.view addSubview:tishi];
    

    UIButton * bundingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bundingBtn.frame = CGRectMake(65 , 270, 190, 55);
    [bundingBtn setBackgroundImage:[UIImage imageNamed:@"confirm_bunding.png"] forState:UIControlStateNormal];
    [bundingBtn setBackgroundImage:[UIImage imageNamed:@"confirm_bunding_f.png"] forState:UIControlStateHighlighted];
    [bundingBtn addTarget:self
                   action:@selector(bundingBtnClick)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bundingBtn];
    
    UIButton * unbundingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    unbundingBtn.frame = CGRectMake(65 , 335, 190, 55);
    [unbundingBtn setBackgroundImage:[UIImage imageNamed:@"cancel_bunding.png"] forState:UIControlStateNormal];
    [unbundingBtn setBackgroundImage:[UIImage imageNamed:@"cancel_bunding_f.png"] forState:UIControlStateHighlighted];
    [unbundingBtn addTarget:self
                   action:@selector(unbundingBtnClick)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:unbundingBtn];
    
    userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:@"kUserId"];
    
    strData = [strData stringByReplacingOccurrencesOfString:@"joy" withString:@""];
    NSString * sendChannel = [NSString stringWithFormat:@"/screencast/CHANNEL_TV_%@",strData];
    
    [[BundingTVManager shareInstance] connecteServerWithChannel:sendChannel];
    [BundingTVManager shareInstance].sendClient.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [BundingTVManager shareInstance].sendClient.delegate = (id)[BundingTVManager shareInstance];
    if (timer)
    {
        [timer invalidate];
        timer = nil;
    }
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
    NSDictionary * cache = (NSDictionary *)[[ContainerUtility sharedInstance] attributeForKey:[NSString stringWithFormat:@"%@_isBunding",userId]];
    
    if ([[cache objectForKey:KEY_IS_BUNDING] boolValue])
    {
        if ([[cache objectForKey:KEY_MACADDRESS] isEqualToString:strData])
        {
            //若手机端已与该电视端绑定，提示用户
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                             message:@"该设备已绑定"
                                                            delegate:nil
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        else
        {
            //若手机端已与该电视端绑定，提示用户
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                             message:@"请先注销已绑定的悦视频TV版"
                                                            delegate:self
                                                   cancelButtonTitle:@"我知道了"
                                                   otherButtonTitles:nil, nil];
            [alert show];
            return;
            
//            //若手机端已有电视端与其绑定，解绑
//            NSString * sendChannel = [NSString stringWithFormat:@"CHANNEL_TV_%@",[cache objectForKey:KEY_MACADDRESS]];
//            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  @"33", @"push_type",
//                                  userId, @"user_id",
//                                  sendChannel, @"tv_channel",
//                                  nil];
//            
//            [[BundingTVManager shareInstance] sendMsg:data];
//            [BundingTVManager shareInstance].isUserUnbind = YES;
        }
    }
    
    NSString * sendChannel = [NSString stringWithFormat:@"CHANNEL_TV_%@",strData];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"31", @"push_type",
                          userId, @"user_id",
                          sendChannel, @"tv_channel",
                          nil];
    
    [[BundingTVManager shareInstance] sendMsg:data];
    [MobClick event:KEY_IS_BUNDING];
    
    if (nil == HUDView)
    {
        HUDView = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kFullWindowHeight)];
        HUDView.backgroundColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.5];
        HUDView.labelText = @"绑定中...";
        HUDView.labelFont = [UIFont systemFontOfSize:15];
        HUDView.opacity = 0;
        HUDView.userInteractionEnabled = YES;
    }
    [HUDView show:YES];
    [[AppDelegate instance].tabBarView.view addSubview:HUDView];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:KEY_MAX_RESPOND_TIME
                                             target:self
                                           selector:@selector(dismissHUDView)
                                           userInfo:nil
                                            repeats:NO];
}

- (void)unbundingBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissHUDView
{
    [timer invalidate];
    timer = nil;
    
    [HUDView removeFromSuperview];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                     message:@"绑定电视端失败"
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil, nil];
    [alert show];
    
}

#pragma mark -
#pragma mark FayeObjc delegate
- (void) messageReceived:(NSDictionary *)messageDict
{
    if ([[messageDict objectForKey:@"push_type"] isEqualToString:@"31"])
    {
        
    }
    else if ([[messageDict objectForKey:@"push_type"] isEqualToString:@"32"])
    {
        [HUDView removeFromSuperview];
        
        if ([[messageDict objectForKey:@"user_id"] isEqualToString:userId])
        {
            [MobClick event:KEY_BIND_SUCCESS];
            //添加已绑定数据缓存
            [[ContainerUtility sharedInstance] setAttribute:[NSDictionary dictionaryWithObjectsAndKeys:strData,KEY_MACADDRESS,[NSNumber numberWithBool:YES],KEY_IS_BUNDING, nil]
                                                     forKey:[NSString stringWithFormat:@"%@_isBunding",userId]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"bundingTVSucceeded" object:nil];
        }
        else
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                             message:@"绑定电视端失败"
                                                            delegate:nil
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:nil, nil];
            [alert show];
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)connectedToServer
{
    
}

- (void)disconnectedFromServer
{
    [[BundingTVManager shareInstance] reconnectToServer];
    [BundingTVManager shareInstance].sendClient.delegate = self;
}

- (void)socketDidSendMessage:(ZTWebSocket *)aWebSocket
{
    
}

- (void)subscriptionFailedWithError:(NSString *)error
{
    
}
- (void)subscribedToChannel:(NSString *)channel
{
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
