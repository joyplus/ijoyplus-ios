//
//  SendWeiboViewController.m
//  yueshipin
//
//  Created by 08 on 13-1-7.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "SendWeiboViewController.h"
#import "UIImage+Scale.h"
#import "AppDelegate.h"
#import "AFSinaWeiboAPIClient.h"
#import "CMConstants.h"
#import "ContainerUtility.h"
#import "ServiceConstants.h"
#import "AFServiceAPIClient.h"
@interface SendWeiboViewController ()

@end

@implementation SendWeiboViewController
@synthesize infoDic = infoDic_;
@synthesize textView = textView_;
@synthesize sinaWeibo = sinaWeibo_;

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
    
    //[self initSinaWei];
    [self loadViewResource];
}

-(void)loadViewResource{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage scaleFromImage:[UIImage imageNamed:@"top_bg_common.png"] toSize:CGSizeMake(320, 44)] forBarMetrics:UIBarMetricsDefault];
    
    UIImageView *backGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    backGround.frame = CGRectMake(0, 0, 320, kFullWindowHeight);
    [self.view addSubview:backGround];
    
    UIImageView *shareImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"share_bg.png"]];
    shareImageView.frame = CGRectMake(20, 25, 40, 25);
    [self.view addSubview:shareImageView];
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sina_btn_pressed.png"]];
    logo.frame = CGRectMake(20, 150, 34, 33);
    [self.view addSubview:logo];
    
    self.title = [infoDic_ objectForKey:@"prod_name"];
    textView_ = [[UITextView alloc] initWithFrame:CGRectMake(20, 50, 280, 80)];
    textView_.text = [NSString stringWithFormat:@"我刚看了#%@#，分享一下吧。",[infoDic_ objectForKey:@"name"]];
    [textView_ becomeFirstResponder];
    UIButton *share = [UIButton buttonWithType:UIButtonTypeCustom];
    share.frame = CGRectMake(220, 150, 80, 32);
    [share setBackgroundImage:[UIImage imageNamed:@"share_btn.png"] forState:UIControlStateNormal];
    [share setBackgroundImage:[UIImage imageNamed:@"share_btn_pressed.png"] forState:UIControlStateHighlighted];
    [share addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:textView_];
    [self.view addSubview:share];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 40, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"top_return_common.png"] forState:UIControlStateNormal];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
}
-(void)share:(id)sender{
    
    [textView_ resignFirstResponder];
    NSString *content = textView_.text ;
    if ([content length] >0) {
        if (content.length > 140) {
            content = [content substringToIndex:140];
        }
        if([content rangeOfString:@"\n"].location != NSNotFound){
            content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        }
        sinaWeibo_ = [AppDelegate instance].sinaweibo;
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:sinaWeibo_.accessToken, @"access_token", content, @"status", [infoDic_ objectForKey:@"prod_pic_url"], @"url", nil];
        [[AFSinaWeiboAPIClient sharedClient] postPath:kSinaWeiboUpdateWithImageUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self removeOverlay];
            [self showSuccessModalView:1.5];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            [self removeOverlay];
            [self showFailureModalView:1.5];
        }];


    }
    
}

- (void)showSuccessModalView:(int)closeTime
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    view.tag = 3268142;
    [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    UIImageView *temp = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"success_img"]];
    temp.frame = CGRectMake(0, 0, 200, 100);
    temp.center = view.center;
    [view addSubview:temp];
    [self.view addSubview:view];
    [NSTimer scheduledTimerWithTimeInterval:closeTime target:self selector:@selector(removeOverlay) userInfo:nil repeats:NO];
}
- (void)showFailureModalView:(int)closeTime
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    view.tag = 3268142;
    [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    UIImageView *temp = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"failure_img"]];
    temp.frame = CGRectMake(0, 0, 200, 100);
    temp.center = view.center;
    [view addSubview:temp];
    [self.view addSubview:view];
    [NSTimer scheduledTimerWithTimeInterval:closeTime target:self selector:@selector(removeOverlay) userInfo:nil repeats:NO];
}
- (void)removeOverlay
{
    UIView *view = (UIView *)[self.view viewWithTag:3268142];
    for(UIView *subview in view.subviews){
        [subview removeFromSuperview];
    }
    [view removeFromSuperview];
    view = nil;
}
-(void)back:(id)sender{
    [self dismissModalViewControllerAnimated:YES];

}
/*
#pragma mark - SinaWeibo Delegate
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo{
    
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              sinaweibo.accessToken, @"AccessTokenKey",
                              sinaweibo.expirationDate, @"ExpirationDateKey",
                              sinaweibo.userID, @"UserIDKey",
                              sinaweibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [sinaweibo requestWithURL:@"users/show.json"
                       params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];
    
     //[self loadViewResource];
}
- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo{
    NSLog(@"sinaweiboDidLogOut");
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo{
    NSLog(@"sinaweiboLogInDidCancel");

}
- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error{
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"网络数据错误，请重新登陆。"
                                                       delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}
- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error{
    NSLog(@"sinaweiboAccessTokenInvalidOrExpired %@", error);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"Token已过期，请重新登陆。"
                                                       delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}
#pragma mark - SinaWeiboRequest Delegate

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)userInfo{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        NSString *username = [userInfo objectForKey:@"screen_name"];
        [[ContainerUtility sharedInstance] setAttribute:username forKey:kUserNickName];
        NSString *avatarUrl = [userInfo objectForKey:@"avatar_large"];
        [[ContainerUtility sharedInstance] setAttribute:avatarUrl forKey:kUserAvatarUrl];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [userInfo objectForKey:@"idstr"], @"source_id", @"1", @"source_type", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathUserValidate parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if(responseCode == nil){
                NSString *user_id = [result objectForKey:@"user_id"];
                [[AFServiceAPIClient sharedClient] setDefaultHeader:@"user_id" value:user_id];
                [[ContainerUtility sharedInstance] setAttribute:user_id forKey:kUserId];
            } else {
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [userInfo objectForKey:@"idstr"], @"source_id", @"1", @"source_type", avatarUrl, @"pic_url", username, @"nickname", nil];
                [[AFServiceAPIClient sharedClient] postPath:kPathAccountBindAccount parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                    
                } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                    
                }];
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }

}

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        
    }
}
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
