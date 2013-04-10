//
//  UnbundingViewController.m
//  yueshipin
//
//  Created by 08 on 13-4-9.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "UnbundingViewController.h"
#import "ContainerUtility.h"
#import <Parse/Parse.h>
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
    leftButton.frame = CGRectMake(0, 0, 49, 30);
    leftButton.backgroundColor = [UIColor clearColor];
    [leftButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bunding_background.png"]];
    bgImage.frame = CGRectMake(76, 40, 168, 103);
    [self.view addSubview:bgImage];
    
    UILabel * tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 170, 320, 20)];
    tipsLabel.text = @"您已在电视端上成功绑定悅视频";
    tipsLabel.textAlignment = UITextAlignmentCenter;
    tipsLabel.font = [UIFont systemFontOfSize:18];
    tipsLabel.backgroundColor = [UIColor clearColor];
    tipsLabel.textColor = [UIColor colorWithRed:82/255.f green:82/255.f blue:82/255.f alpha:1];
    [self.view addSubview:tipsLabel];
    
    UIButton * bundingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bundingBtn.frame = CGRectMake(35 , 265, 250, 38);
    [bundingBtn setBackgroundImage:[UIImage imageNamed:@"unbunding.png"] forState:UIControlStateNormal];
    [bundingBtn setBackgroundImage:[UIImage imageNamed:@"unbunding_f.png"] forState:UIControlStateHighlighted];
    [bundingBtn addTarget:self
                   action:@selector(unbundingBtnClick)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bundingBtn];
    
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

#pragma mark -
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (0 == buttonIndex)
    {
        
    }
    else
    {
        NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:@"kUserId"];
        
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"5", @"push_type",
                              userId, @"user_id",
                              nil];
        
        PFPush *push = [[PFPush alloc] init];
        [push setData:data];
        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (YES == succeeded
                && nil == error)
            {
                //添加已绑定数据缓存
                [[ContainerUtility sharedInstance] setAttribute:[NSNumber numberWithBool:NO]
                                                         forKey:[NSString stringWithFormat:@"%@_isBunding",userId]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"bundingTVSucceeded" object:nil];
            }
            else
            {
                NSLog(@"%@",error);
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                                 message:@"取消绑定电视端失败,请重试"
                                                                delegate:nil
                                                       cancelButtonTitle:@"确定"
                                                       otherButtonTitles:nil, nil];
                [alert show];
            }
            
        }];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
