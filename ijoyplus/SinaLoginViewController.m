//
//  SinaLoginViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SinaLoginViewController.h"
#import "CustomBackButton.h"
#import "CacheUtility.h"
#import "CMConstants.h"
#import "FillFormViewController.h"
#import "ContainerUtility.h"
#import "FriendListViewController.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "AppDelegate.h"
#import "SFHFKeychainUtils.h"

@interface SinaLoginViewController (){
    WBAuthorizeWebView *webView;
    WBEngine *webEngine;
    FillFormViewController *fillFormViewController;
    CustomBackButton *backButton;
    FriendListViewController *friendListViewController;
}

- (void)processSinaData;
- (void)processSinaFriendData:(id) responseObject;
- (void)closeSelf;
@end

@implementation SinaLoginViewController

- (void)viewDidUnload
{
    [super viewDidUnload];
    webEngine = nil;
    webView = nil;
    backButton = nil;
    fillFormViewController = nil;
    friendListViewController = nil;;
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
    self.title = NSLocalizedString(@"sina_weibo_login", nil);
    backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:NSLocalizedString(@"back", nil)];
    [backButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    webEngine = [[WBEngine sharedClient]initWithAppKey:kSinaWeiboAppKey appSecret:kSinaWeiboAppSecret];
    [webEngine setRootViewController:self];
    [webEngine setDelegate:self];
    [webEngine setRedirectURI:@"http://"];
    [webEngine setIsUserExclusive:NO];
    
    webView = [webEngine logIn];
    [self.view addSubview:webView];
    webView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    if([WBEngine sharedClient].isLoggedIn && ![WBEngine sharedClient].isAuthorizeExpired){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - WBEngineDelegate Methods

#pragma mark Authorize

- (void)engineAlreadyLoggedIn:(WBEngine *)engine
{
    [engine logOut];
    if ([engine isUserExclusive])
    {
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil
                                                           message:@"请先登出！"
                                                          delegate:nil
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil];
        [alertView show];
        
    }
}

- (void)engineDidLogIn:(WBEngine *)engine
{
    [[ContainerUtility sharedInstance]setAttribute:[[WBEngine sharedClient] accessToken] forKey:kSinaWeiboAccessToken];
    [[ContainerUtility sharedInstance]setAttribute:[[WBEngine sharedClient] userID] forKey:kSinaWeiboUID];
    [[ContainerUtility sharedInstance]setAttribute:[NSNumber numberWithBool:YES] forKey:kUserLoggedIn];
    
    if([self.fromController isEqual:@"PostViewController"]){
        [self.navigationController popViewControllerAnimated:YES];
    } else if([self.fromController isEqual:@"SearchFriendViewController"]){
        [self processSinaData];
    } else{
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", [[WBEngine sharedClient] userID], @"source_id", @"1", @"source_type", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathUserValidate parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if([responseCode isEqualToString:kSuccessResCode]){
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                            kAppKey, @"app_key",
                                            nil];
                [[AFServiceAPIClient sharedClient] getPath:kPathUserView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                    NSString *responseCode = [result objectForKey:@"res_code"];
                    if(responseCode == nil){
                        [[ContainerUtility sharedInstance]setAttribute:[result valueForKey:@"id"] forKey:kUserId];
                        [[ContainerUtility sharedInstance]setAttribute:[result valueForKey:@"nickname"] forKey:kUserNickName];
                        [[ContainerUtility sharedInstance]setAttribute:[result valueForKey:@"username"] forKey:kUserName];
                        [[ContainerUtility sharedInstance]setAttribute:[result valueForKey:@"phone"] forKey:kPhoneNumber];
                        [[ContainerUtility sharedInstance]setAttribute:[NSNumber numberWithBool:YES] forKey:kUserLoggedIn];
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate refreshRootView];
                    }
                } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                    
                }];
            } else {
                fillFormViewController = [[FillFormViewController alloc]initWithNibName:@"FillFormViewController" bundle:nil];
                fillFormViewController.thirdPartyId = [[WBEngine sharedClient] userID];
                fillFormViewController.thirdPartyType = @"1";
                [self.navigationController pushViewController:fillFormViewController animated:YES];
               
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {

            NSLog(@"<<<<<<%@>>>>>", error);
        }];
    }
}

- (void)engine:(WBEngine *)engine didFailToLogInWithError:(NSError *)error
{
    NSLog(@"didFailToLogInWithError: %@", error);    
}

- (void)engineDidLogOut:(WBEngine *)engine
{
    NSLog(@"engineLoggedout");
    
}

- (void)engineNotAuthorized:(WBEngine *)engine
{
    NSLog(@"engineNotAuthorized");
}

- (void)engineAuthorizeExpired:(WBEngine *)engine
{
    NSLog(@"engineAuthorizeExpired");
    
}

#pragma mark - Handle sina response
- (void) didFailToLogInWithError:(NSError *)error{

}

#pragma mark - Private Methods
- (void)processSinaData {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[WBEngine sharedClient] accessToken], @"access_token",
                                [[WBEngine sharedClient] userID], @"uid",
                                nil];
    
//    [[AFSinaWeiboAPIClient sharedClient] getPath:@"users/show.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
//        
//        NSString *displayName = [result objectForKey:@"screen_name"];
//        NSString *largeAvatarURL = [result objectForKey:@"avatar_large"];
//        NSString *description = [result objectForKey:@"description"];
//
//    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"<<<<<<%@>>>>>", error);
//    }];
    
    [[AFSinaWeiboAPIClient sharedClient] getPath:@"friendships/friends/bilateral.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *sinaFriends = [responseObject valueForKeyPath:@"users"];
        [[CacheUtility sharedCache]setSinaFriends:sinaFriends];
        NSMutableString *friendIds = [[NSMutableString alloc]init];
        for (NSDictionary *friendData in sinaFriends) {
            [friendIds appendFormat:@"%@,", [[friendData objectForKey:@"id"] stringValue]];
        }
        [friendIds appendString:@"0"];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", @"1", @"source_type", friendIds, @"source_ids", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathGenUserThirdPartyUsers parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if(responseCode == nil){
                
            } else {
                
            }
            friendListViewController = [[FriendListViewController alloc]initWithNibName:@"FriendListViewController" bundle:nil];
            friendListViewController.sourceType = @"1";
            [self.navigationController pushViewController:friendListViewController animated:YES];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];    
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
