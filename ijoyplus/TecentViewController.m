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
#import "UIUtility.h"
#import "MBProgressHUD.h"
#import "PopularUserViewController.h"

@interface TecentViewController (){
    TencentOAuth* _tencentOAuth;
    NSMutableArray* _permissions;
    FillFormViewController *fillFormViewController;
    CustomBackButton *backButton;
    MBProgressHUD *HUD;
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
    HUD = nil;
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

- (void)tencentDidLogin
{
    [self saveAuthorizeDataToKeychain];
    [_tencentOAuth getUserInfo];
}

- (void)getUserInfoResponse:(APIResponse*) response
{
    NSString *url = [response.jsonResponse objectForKey:@"figureurl_1"];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: url, @"url", nil];
    if([self.fromController isEqual:@"PostViewController"]){
        //update url
        [[AFServiceAPIClient sharedClient] postPath:kPathUserUpdatePicUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        }];
        [self.navigationController popViewControllerAnimated:YES];
    } else if([self.fromController isEqual:@"SearchFriendViewController"]){
        //        [self processSinaData];
    } else{
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: _tencentOAuth.openId, @"source_id", @"2", @"source_type", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathUserValidate parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if([responseCode isEqualToString:kSuccessResCode]){
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: nil];
                [[AFServiceAPIClient sharedClient] getPath:kPathUserView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                    NSString *responseCode = [result objectForKey:@"res_code"];
                    if(responseCode == nil){
                        [[ContainerUtility sharedInstance]setAttribute:[result valueForKey:@"id"] forKey:kUserId];
                        [[ContainerUtility sharedInstance]setAttribute:[result valueForKey:@"nickname"] forKey:kUserNickName];
                        [[ContainerUtility sharedInstance]setAttribute:[result valueForKey:@"username"] forKey:kUserName];
                        [[ContainerUtility sharedInstance]setAttribute:[NSNumber numberWithBool:YES] forKey:kUserLoggedIn];
                        if(![StringUtility stringIsEmpty:[result valueForKey:@"phone"]]){
                            [[ContainerUtility sharedInstance]setAttribute:[result valueForKey:@"phone"] forKey:kPhoneNumber];
                        }                        
                        //update url
                        [[AFServiceAPIClient sharedClient] postPath:kPathUserUpdatePicUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                        }];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                    
                }];
            } else {
                [self createNewUser:response.jsonResponse];
                
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"<<<<<<%@>>>>>", error);
        }];
    }
}

- (void)createNewUser:(NSDictionary *)userDict
{
        NSString *nickname = [userDict objectForKey:@"nickname"];
        NSString *email = [NSString stringWithFormat:@"%@@qq.com", _tencentOAuth.openId];
        NSString *sourceId = _tencentOAuth.openId;
        NSDictionary *newparameters = [NSDictionary dictionaryWithObjectsAndKeys: email, @"username", @"P@ssword1", @"password", nickname, @"nickname", sourceId, @"source_id", @"2", @"source_type", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathAccountUpdateProfile parameters:newparameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if([responseCode isEqualToString:kSuccessResCode]){
                // login success
                [self performSelectorOnMainThread:@selector(postRegister) withObject:nil waitUntilDone:NO];
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: nil];
                [[AFServiceAPIClient sharedClient] getPath:kPathUserView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                    NSString *responseCode = [result objectForKey:@"res_code"];
                    if(responseCode == nil){
                        [[ContainerUtility sharedInstance]setAttribute:[result valueForKey:@"id"] forKey:kUserId];
                    }
                } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                }];
                
                NSString *url = [userDict objectForKey:@"figureurl_1"];
                parameters = [NSDictionary dictionaryWithObjectsAndKeys: url, @"url", nil];
                [[AFServiceAPIClient sharedClient] postPath:kPathUserUpdatePicUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                }];
                [[ContainerUtility sharedInstance]setAttribute:nickname forKey:kUserNickName];
                [[ContainerUtility sharedInstance] setAttribute:[NSNumber numberWithBool:YES] forKey:kUserLoggedIn];
            } else {
                [self performSelectorOnMainThread:@selector(showError) withObject:nil waitUntilDone:NO];
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            [UIUtility showSystemError:self.view];
        }];
}

- (void)postRegister
{
    PopularUserViewController *popularUserViewController = [[PopularUserViewController alloc]initWithNibName:@"PopularUserViewController" bundle:nil];
    [self.navigationController pushViewController:popularUserViewController animated:YES];
}

- (void)showError
{
    [UIUtility showSystemError:self.view];
}


- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAuthorizeDataToKeychain
{
    [SFHFKeychainUtils storeUsername:@"tecentOpenId" andPassword:_tencentOAuth.openId forServiceName:@"tecentlogin" updateExisting:YES error:nil];
	[SFHFKeychainUtils storeUsername:@"tecentAccessToken" andPassword:_tencentOAuth.accessToken forServiceName:@"tecentlogin" updateExisting:YES error:nil];
	[SFHFKeychainUtils storeUsername:@"tecentExpireTime" andPassword:[NSString stringWithFormat:@"%f", [_tencentOAuth.expirationDate timeIntervalSince1970]] forServiceName:@"tecentlogin" updateExisting:YES error:nil];
}

@end
