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
#import "FriendListViewController.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "AppDelegate.h"
#import "SFHFKeychainUtils.h"

@interface TecentViewController (){
    TencentOAuth* _tencentOAuth;
    NSMutableArray* _permissions;
}
- (void)closeSelf;
@end

@implementation TecentViewController

- (void)viewDidUnload
{
    _tencentOAuth = nil;
    _permissions = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
    CustomBackButton *backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:NSLocalizedString(@"back", nil)];
    [backButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _permissions =  [NSArray arrayWithObjects:
                     @"get_user_info",@"add_share", @"add_topic",@"add_one_blog", @"list_album",
                     @"upload_pic",@"list_photo", @"add_album", @"check_page_fans", @"get_fanslist", nil];
	
	
	_tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"100311436"
											andDelegate:self];
	_tencentOAuth.redirectURI = @"www.qq.com";
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
//    BOOL success = [_tencentOAuth getFansList];
//    NSLog(@"%i", success);
    [[ContainerUtility sharedInstance]setAttribute:[NSNumber numberWithBool:YES] forKey:kTencentUserLoggedIn];
    if([self.fromController isEqual:@"PostViewController"]){
        [self.navigationController popViewControllerAnimated:YES];
    } else if([self.fromController isEqual:@"SearchFriendViewController"]){
//        [self processSinaData];
    } else{
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kAppKey, @"app_key", _tencentOAuth.openId, @"source_id", @"2", @"source_type", nil];
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
                        [[ContainerUtility sharedInstance] setAttribute:[NSNumber numberWithBool:YES] forKey:kUserLoggedIn];
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate refreshRootView];
                    }
                } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                    
                }];
            } else {
                FillFormViewController *viewController = [[FillFormViewController alloc]initWithNibName:@"FillFormViewController" bundle:nil];
                viewController.thirdPartyId = _tencentOAuth.openId;
                viewController.thirdPartyType = @"2";
                [self.navigationController pushViewController:viewController animated:YES];
                
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"<<<<<<%@>>>>>", error);
        }];
    }
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
