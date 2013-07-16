//
//  IpadBunDingViewController.m
//  yueshipin
//
//  Created by lily on 13-7-11.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "IpadBunDingViewController.h"
#import "ContainerUtility.h"
#import "BundingTVManager.h"
#import "CMConstants.h"
#import "MBProgressHUD.h"
@interface IpadBunDingViewController ()
@property BOOL isConnected;
@end

@implementation IpadBunDingViewController
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
    
    UIImageView *bg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.frame.size.height)];
    bg.image = [UIImage imageNamed:@"left_background@2x.jpg"];
    [self.view addSubview:bg];
    
    NSString *tempUserId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:@"kUserId"];
    NSDictionary * data = (NSDictionary *)[[ContainerUtility sharedInstance] attributeForKey:[NSString stringWithFormat:@"%@_isBunding",tempUserId]];
    NSNumber *isbunding = [data objectForKey:KEY_IS_BUNDING];
    //isbunding =  [NSNumber numberWithInt:1];
    if (![isbunding boolValue] || self.showBunding) {
        [self showBundingView];
    }
    else{
        [self showUnBundingView];
    }
    
    userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:@"kUserId"];
    
    if (self.showBunding) {
        strData = [strData stringByReplacingOccurrencesOfString:@"joy" withString:@""];
        NSString * sendChannel = [NSString stringWithFormat:@"/screencast/CHANNEL_TV_%@",strData];
        [[BundingTVManager shareInstance] connecteServerWithChannel:sendChannel];
        [BundingTVManager shareInstance].sendClient.delegate = self;
    }
    else{
        if (![BundingTVManager shareInstance].isConnected)
        {
            [[BundingTVManager shareInstance] connecteServer];
        }
    }
    
    
    
	// Do any additional setup after loading the view.
}
-(void)viewWillDisappear:(BOOL)animated{
   [BundingTVManager shareInstance].sendClient.delegate = (id)[BundingTVManager shareInstance];
}
-(void)showBundingView{
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 513, 750)];
    bg.image = [UIImage imageNamed:@"ipad_confirm_bunding_Bg"];
    [self.view addSubview:bg];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(140, 500, 234, 43);
    confirmButton.tag = 2000001;
    //confirmButton.enabled = NO;
    [confirmButton setBackgroundImage:[UIImage imageNamed:@"ipad_confirm_bunding_button"] forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmButton];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(140, 600, 234, 43);
    cancelButton.tag = 2000003;
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"ipad_bunding_cancel"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
}

-(void)showUnBundingView{
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 513, 750)];
    bg.image = [UIImage imageNamed:@"ipad_cancel_bunding_Bg"];
    [self.view addSubview:bg];
    
    UIButton* unBundingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    unBundingButton.frame = CGRectMake(140, 500, 234, 43);
    [unBundingButton setBackgroundImage:[UIImage imageNamed:@"ipad_confirm_unbunding_button"] forState:UIControlStateNormal];
    [unBundingButton addTarget:self action:@selector(unbundingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:unBundingButton];
}

-(void)confirmButtonPressed{
    
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
            
        }
    }
    
    NSString * sendChannel = [NSString stringWithFormat:@"CHANNEL_TV_%@",strData];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"31", @"push_type",
                          userId, @"user_id",
                          sendChannel, @"tv_channel",
                          nil];
    
    [[BundingTVManager shareInstance] sendMsg:data];
    [MobClick event:KEY_BINDING];
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
    
//    timer = [NSTimer scheduledTimerWithTimeInterval:KEY_MAX_RESPOND_TIME
//                                             target:self
//                                           selector:@selector(dismissHUDView)
//                                           userInfo:nil
//                                            repeats:NO];
}

-(void)cancelButtonPressed{
    
    //[self dismissModalViewControllerAnimated:YES];
    [self close];
}

-(void)unbundingBtnClick:(UIButton *)sender
{
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil
                                                       message:@"您确定解除与电视端的绑定吗？"
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:@"确认", nil];
    [alertView show];
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
        [self close];
    }
    else if ([[messageDict objectForKey:@"push_type"] isEqualToString:@"33"]
             && [[messageDict objectForKey:@"user_id"] isEqualToString:userId])
    {
        [MobClick event:KEY_UNBINDED];
        //添加已绑定数据缓存
        NSDictionary * dic = (NSDictionary *)[[ContainerUtility sharedInstance] attributeForKey:[NSString stringWithFormat:@"%@_isBunding",userId]];
        [[ContainerUtility sharedInstance] setAttribute:[NSDictionary dictionaryWithObjectsAndKeys:[dic objectForKey:KEY_MACADDRESS],KEY_MACADDRESS,[NSNumber numberWithBool:NO],KEY_IS_BUNDING, nil]
                                                 forKey:[NSString stringWithFormat:@"%@_isBunding",userId]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"bundingTVSucceeded" object:nil];
        
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
//                                                         message:@"已断开与电视端的绑定"
//                                                        delegate:nil
//                                               cancelButtonTitle:@"确定"
//                                               otherButtonTitles:nil, nil];
//        [alert show];
        
    }
}

- (void)connectedToServer
{
    self.isConnected = YES;
    
    UIButton *bundingBtn = (UIButton *)[self.view viewWithTag:2000001];
    if (bundingBtn) {
         bundingBtn.enabled = YES;
    }
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex)
    {
        NSDictionary * dic = (NSDictionary *)[[ContainerUtility sharedInstance] attributeForKey:[NSString stringWithFormat:@"%@_isBunding",userId]];
        NSString * sendChannel = [NSString stringWithFormat:@"CHANNEL_TV_%@",[dic objectForKey:KEY_MACADDRESS]];
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"33", @"push_type",
                              userId, @"user_id",
                              sendChannel, @"tv_channel",
                              nil];
        
        [[BundingTVManager shareInstance] sendMsg:data];
        [BundingTVManager shareInstance].isUserUnbind = YES;
        //添加已绑定数据缓存
        [MobClick event:KEY_UNBINDED];
        [[ContainerUtility sharedInstance] setAttribute:[NSDictionary dictionaryWithObjectsAndKeys:[dic objectForKey:KEY_MACADDRESS],KEY_MACADDRESS,[NSNumber numberWithBool:NO],KEY_IS_BUNDING, nil]
                                                 forKey:[NSString stringWithFormat:@"%@_isBunding",userId]];
        [self close];

    }
    
}
-(void)close{
    [[NSNotificationCenter defaultCenter] postNotificationName:CLOSE object:nil];

}
@end
