//
//  UnbundingViewController.m
//  yueshipin
//
//  Created by 08 on 13-4-9.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "UnbundingViewController.h"
#import "ContainerUtility.h"
#import "MBProgressHUD.h"

@interface UnbundingViewController ()

@end

@implementation UnbundingViewController

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
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0f green:242/255.0f blue:242/255.0f alpha:1.0f];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, 55, 44);
    leftButton.backgroundColor = [UIColor clearColor];
    [leftButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bunding_background.png"]];
    bgImage.frame = CGRectMake(0, 45, 320, 121);
    [self.view addSubview:bgImage];
    
    UIImageView * tishi = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jiechu_wenzi.png"]];
    tishi.frame = CGRectMake(0, 195, 320, 42);
    [self.view addSubview:tishi];
    
    UIButton * bundingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bundingBtn.frame = CGRectMake(65 , 270, 190, 55);
    [bundingBtn setBackgroundImage:[UIImage imageNamed:@"unbunding.png"] forState:UIControlStateNormal];
    [bundingBtn setBackgroundImage:[UIImage imageNamed:@"unbunding_f.png"] forState:UIControlStateHighlighted];
    [bundingBtn addTarget:self
                   action:@selector(unbundingBtnClick)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bundingBtn];
    
    userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:@"kUserId"];
    
    if (![BundingTVManager shareInstance].isConnected)
    {
        [[BundingTVManager shareInstance] connecteServer];
    }
    
    //[BundingTVManager shareInstance].sendClient.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[BundingTVManager shareInstance].sendClient.delegate = (id)[BundingTVManager shareInstance];
    
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

- (void)unbundingBtnClick
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
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (0 == buttonIndex)
    {
        
    }
    else
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"bundingTVSucceeded" object:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
         
}

#pragma mark -
#pragma mark FayeObjc delegate
- (void) messageReceived:(NSDictionary *)messageDict
{
    
}

- (void)connectedToServer
{
    
}

- (void)disconnectedFromServer
{
    [[BundingTVManager shareInstance] reconnectToServer];
    //[BundingTVManager shareInstance].sendClient.delegate = self;
}

- (void)socketDidSendMessage:(ZTWebSocket *)aWebSocket
{
    
}

@end
