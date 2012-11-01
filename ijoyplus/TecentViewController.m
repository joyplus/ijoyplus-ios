//
//  TecentViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "TecentViewController.h"
#import "CustomBackButton.h"
#import "FillFormViewController.h"
#import "ContainerUtility.h"
#import "CMConstants.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "AppDelegate.h"
#import "SFHFKeychainUtils.h"

@interface TecentViewController (){
    TencentOAuth* _tencentOAuth;
    NSMutableArray* _permissions;
    FillFormViewController *fillFormViewController;
    CustomBackButton *backButton;
}
- (void)closeSelf;
@end

@implementation TecentViewController

- (void)viewDidUnload
{
    [super viewDidUnload];
    _tencentOAuth = nil;
    [_permissions removeAllObjects];
    _permissions = nil;
    fillFormViewController = nil;
    backButton = nil;
}

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
    self.title = NSLocalizedString(@"tecent_login", nil);
    backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:NSLocalizedString(@"back", nil)];
    [backButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _permissions =  [NSArray arrayWithObjects:
                     @"get_user_info",@"add_share", @"add_topic",@"add_one_blog", @"list_album",
                     @"upload_pic",@"list_photo", @"add_album", @"check_page_fans", @"get_fanslist", nil];
	
	
	_tencentOAuth = [[TencentOAuth alloc] initWithAppId:kTecentAppId andDelegate:self];
	_tencentOAuth.redirectURI = @"www.qq.com";
    _tencentOAuth.sessionDelegate = self;
	self.view = [_tencentOAuth authorize:_permissions inSafari:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    NSNumber *num = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:kTencentUserLoggedIn];
    if([num boolValue]){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)tencentDidLogin
{
    [self saveAuthorizeDataToKeychain];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: _tencentOAuth.openId, @"source_id", @"2", @"source_type", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathUserValidate parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [_tencentOAuth getUserInfo];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"<<<<<<%@>>>>>", error);
    }];
    [[ContainerUtility sharedInstance]setAttribute:[NSNumber numberWithBool:YES] forKey:kTencentUserLoggedIn];
    if([self.fromController isEqual:@"PostViewController"]){
        [self.navigationController popViewControllerAnimated:YES];
    } else if([self.fromController isEqual:@"SearchFriendViewController"]){
//        [self processSinaData];
    } else{
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: _tencentOAuth.openId, @"source_id", @"2", @"source_type", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathUserValidate parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if([responseCode isEqualToString:kSuccessResCode]){
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                            nil];
                [[AFServiceAPIClient sharedClient] getPath:kPathUserView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                    NSString *responseCode = [result objectForKey:@"res_code"];
                    if(responseCode == nil){
                        [[ContainerUtility sharedInstance]setAttribute:[result valueForKey:@"id"] forKey:kUserId];
                        [[ContainerUtility sharedInstance]setAttribute:[result valueForKey:@"nickname"] forKey:kUserNickName];
                        [[ContainerUtility sharedInstance]setAttribute:[result valueForKey:@"username"] forKey:kUserName];
                        [[ContainerUtility sharedInstance]setAttribute:[result valueForKey:@"phone"] forKey:kPhoneNumber];
                        [[ContainerUtility sharedInstance]setAttribute:[NSNumber numberWithBool:YES] forKey:kUserLoggedIn];
                        _tencentOAuth.accessToken = nil;
                        _tencentOAuth = nil;
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate refreshRootView];
                    }
                } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                    
                }];
            } else {
                fillFormViewController = [[FillFormViewController alloc]initWithNibName:@"FillFormViewController" bundle:nil];
                fillFormViewController.thirdPartyId = _tencentOAuth.openId;
                fillFormViewController.thirdPartyType = @"2";
                [self.navigationController pushViewController:fillFormViewController animated:YES];
                
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"<<<<<<%@>>>>>", error);
        }];
    }
}


- (void)getUserInfoResponse:(APIResponse*) response
{
    NSString *url = [response.jsonResponse objectForKey:@"figureurl_1"];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: url, @"url", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathUserUpdatePicUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
    }];
}


- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAuthorizeDataToKeychain
{
    [SFHFKeychainUtils storeUsername:@"tecentOpenId" andPassword:_tencentOAuth.openId forServiceName:@"tecentlogin" updateExisting:YES error:nil];
	[SFHFKeychainUtils storeUsername:@"tecentAccessToken" andPassword:_tencentOAuth.accessToken forServiceName:@"tecentlogin" updateExisting:YES error:nil];
//	[SFHFKeychainUtils storeUsername:kWBKeychainExpireTime andPassword:[NSString stringWithFormat:@"%lf", expireTime] forServiceName:@"tecentlogin" updateExisting:YES error:nil];
}

@end
