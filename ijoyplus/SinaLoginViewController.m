//
//  SinaLoginViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SinaLoginViewController.h"
#import "CustomBackButton.h"
#import "CustomBackButtonHolder.h"
#import "CacheUtility.h"
#import "CMConstants.h"
#import "FillFormViewController.h"
#import "ContainerUtility.h"
#import "FriendListViewController.h"

@interface SinaLoginViewController (){
    MBProgressHUD *HUD;
}

- (void)linkToUser;
- (void) didLogInUser;
- (void)processSinaData;
- (void)processSinaFriendData:(id) responseObject;
- (void)closeSelf;
@end

@implementation SinaLoginViewController

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
    CustomBackButtonHolder *backButtonHolder = [[CustomBackButtonHolder alloc]initWithViewController:self];
    CustomBackButton* backButton = [backButtonHolder getBackButton:NSLocalizedString(@"go_back", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    WBEngine *engine = [[WBEngine sharedClient]initWithAppKey:kSinaWeiboAppKey appSecret:kSinaWeiboAppSecret];
    [engine setRootViewController:self];
    [engine setDelegate:self];
    [engine setRedirectURI:@"http://"];
    [engine setIsUserExclusive:NO];
	WBAuthorizeWebView *webView = [[WBEngine sharedClient] logIn];
    [self.view addSubview:webView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    NSNumber *num = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:kSinaUserLoggedIn];
    if([num boolValue]){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - WBEngineDelegate Methods

#pragma mark Authorize

- (void)engineAlreadyLoggedIn:(WBEngine *)engine
{
    
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
    //    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil
    //													   message:@"登录成功！"
    //													  delegate:self
    //											 cancelButtonTitle:@"确定"
    //											 otherButtonTitles:nil];
    //[alertView setTag:kWBAlertViewLogInTag];
	//[alertView show];
    [[ContainerUtility sharedInstance]setAttribute:[NSNumber numberWithBool:YES] forKey:kSinaUserLoggedIn];
    [[ContainerUtility sharedInstance]setAttribute:[[WBEngine sharedClient] accessToken] forKey:kSinaWeiboAccessToken];
    [[ContainerUtility sharedInstance]setAttribute:[[WBEngine sharedClient] userID] forKey:kSinaWeiboUID];
    
    [[CacheUtility sharedCache] setSinaWeiboEngineer:engine];
    
    NSLog(@"<<<<<<Sina Login Successfully>>>>>>");
//    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // [HUD setDimBackground:YES];
    [self linkToUser];
    
    if([self.fromController isEqual:@"PostViewController"]){
        [self.navigationController popViewControllerAnimated:YES];
    } else if([self.fromController isEqual:@"SearchFriendViewController"]){
        FriendListViewController *viewController = [[FriendListViewController alloc]initWithNibName:@"FriendListViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    } else{
        FillFormViewController *viewController = [[FillFormViewController alloc]initWithNibName:@"FillFormViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)engine:(WBEngine *)engine didFailToLogInWithError:(NSError *)error
{
    NSLog(@"didFailToLogInWithError: %@", error);
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil
													   message:@"登录失败！"
													  delegate:nil
											 cancelButtonTitle:@"确定"
											 otherButtonTitles:nil];
	[alertView show];
    
}

- (void)engineDidLogOut:(WBEngine *)engine
{
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil
													   message:@"登出成功！"
													  delegate:self
											 cancelButtonTitle:@"确定"
											 otherButtonTitles:nil];
    //[alertView setTag:kWBAlertViewLogOutTag];
	[alertView show];
    
}

- (void)engineNotAuthorized:(WBEngine *)engine
{
    NSLog(@"engineNotAuthorized");
}

- (void)engineAuthorizeExpired:(WBEngine *)engine
{
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil
													   message:@"请重新登录！"
													  delegate:nil
											 cancelButtonTitle:@"确定"
											 otherButtonTitles:nil];
	[alertView show];
    
}

#pragma mark - Handle sina response
- (void) didFailToLogInWithError:(NSError *)error{
    // [self.navController dismissModalViewControllerAnimated:YES];
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [HUD setLabelText:NSLocalizedString(@"Please try again.", nil)];
    
    [HUD hide:YES afterDelay:3];
}

#pragma mark - Private Methods
- (void)linkToUser {
    [self didLogInUser];
    //    [self didFailToLogInWithError:error];
}
- (void) didLogInUser{
    // user has logged in - we need to fetch all of their Facebook data before we let them in
    [HUD setLabelText:NSLocalizedString(@"Login Successfully!", nil)];
    
    [HUD hide:YES afterDelay:3];
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    [self processSinaData];
}

- (void)processSinaData {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[WBEngine sharedClient] accessToken], @"access_token",
                                [[WBEngine sharedClient] userID], @"uid",
                                nil];
    
    [[AFSinaWeiboAPIClient sharedClient] getPath:@"users/show.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        
        NSString *displayName = [result objectForKey:@"screen_name"];
        NSString *largeAvatarURL = [result objectForKey:@"avatar_large"];
        NSString *description = [result objectForKey:@"description"];

    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"<<<<<<%@>>>>>", error);
    }];
    
    [[AFSinaWeiboAPIClient sharedClient] getPath:@"friendships/friends/bilateral.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self processSinaFriendData:responseObject];
        
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"<<<<<<%@>>>>>", error);
    }];
    
}

- (void)processSinaFriendData:(id) responseObject {
    NSArray *sinaFriends = [responseObject valueForKeyPath:@"users"];
    NSMutableArray *sinaIDs = [[NSMutableArray alloc] initWithCapacity:[sinaFriends count]];
    for (NSDictionary *friendData in sinaFriends) {
        NSLog(@"<<<<<<Find sina friends: %@>>>>>>", [friendData objectForKey:@"screen_name"]);
        
        [sinaIDs addObject:[[friendData objectForKey:@"id"] stringValue]];
    }
    
    // cache friend data
    [[CacheUtility sharedCache] setSinaFriends:sinaIDs];
    
    
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
