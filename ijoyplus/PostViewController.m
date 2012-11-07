//
//  PostViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "PostViewController.h"
#import "CustomBackButton.h"
#import "UIUtility.h"
#import "CMConstants.h"
#import "ContainerUtility.h"
#import "SinaLoginViewController.h"
#import "TecentViewController.h"
#import "AFSinaWeiboAPIClient.h"
#import "CacheUtility.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "CustomPlaceHolderTextView.h"
#import "TecentViewController.h"
#import "SFHFKeychainUtils.h"
#import "AFHTTPClient.h"

#define  TEXT_MAX_COUNT 140

@interface PostViewController (){
    BOOL btn1Selected;
    BOOL btn2Selected;
    SinaLoginViewController *viewController;
    TecentViewController *tecentViewController;
    TencentOAuth *_tencentOAuth;
}
@property (weak, nonatomic) IBOutlet UILabel *textCount;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet CustomPlaceHolderTextView *textView;
- (void)startObservingNotifications;
- (void)stopObservingNotifications;
- (void)didReceiveTextDidChangeNotification:(NSNotification*)notification;
- (void)updateCount;
@end

@implementation PostViewController
@synthesize textCount;
@synthesize tipLabel;
@synthesize textView;
@synthesize sinaBtn;
@synthesize qqBtn;
@synthesize program;


- (void)viewDidUnload
{
    [super viewDidUnload];
    _tencentOAuth = nil;
    tecentViewController = nil;
    viewController = nil;
    self.program = nil;
    [self setTextView:nil];
    [self setTextCount:nil];
    [self stopObservingNotifications];
    [self setTipLabel:nil];
    [self setSinaBtn:nil];
    [self setQqBtn:nil];
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
    self.title = NSLocalizedString(@"share", nil);
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    CustomBackButton *backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:NSLocalizedString(@"back", nil)];
    [backButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"post", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(post)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self.sinaBtn setFrame: CGRectMake(67, 130, 20, 20)];
    [self.sinaBtn addTarget:self action:@selector(sinaLoginScreen)forControlEvents:UIControlEventTouchUpInside];
    [self.qqBtn setFrame: CGRectMake(101, 129, 24, 23)];
    [self.qqBtn addTarget:self action:@selector(tencentLoginScreen)forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    if([WBEngine sharedClient].isLoggedIn && ![WBEngine sharedClient].isAuthorizeExpired){
        btn1Selected = YES;
        [self.sinaBtn setBackgroundImage:[UIImage imageNamed:@"sina_normal"] forState:UIControlStateNormal];
    } else {
        btn1Selected = NO;
        [self.sinaBtn setBackgroundImage:[UIImage imageNamed:@"sina_inactive"] forState:UIControlStateNormal];
    }
    if([self checkTencentAuth]){
        btn2Selected = YES;
        [self.qqBtn setBackgroundImage:[UIImage imageNamed:@"qq_normal"] forState:UIControlStateNormal];
    } else {
        btn2Selected = NO;
        [self.qqBtn setBackgroundImage:[UIImage imageNamed:@"qq_press"] forState:UIControlStateNormal];
    }
    self.textCount.text = [NSString stringWithFormat:@"%i", TEXT_MAX_COUNT];
    [self updateCount];
    [self startObservingNotifications];
    [self.textView becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)startObservingNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextDidChangeNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
}

- (void)stopObservingNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)didReceiveTextDidChangeNotification:(NSNotification*)notification
{
    [self updateCount];
}

- (void)updateCount
{
    NSUInteger count = [self.textView.text length];
    self.textCount.text = [NSString stringWithFormat:@"%d", TEXT_MAX_COUNT-count];
    
    if(count > TEXT_MAX_COUNT){
        self.tipLabel.text = NSLocalizedString(@"tip_text", nil);
        self.textCount.textColor = [UIColor redColor];
        self.textCount.text =  [NSString stringWithFormat:@"%d", -TEXT_MAX_COUNT+count];
    }
    
}

- (void)sinaLoginScreen
{
    btn1Selected = !btn1Selected;
    if([WBEngine sharedClient].isLoggedIn && ![WBEngine sharedClient].isAuthorizeExpired){
        if(btn1Selected){
            [self.sinaBtn setBackgroundImage:[UIImage imageNamed:@"sina_normal"] forState:UIControlStateNormal];
        } else {
            [self.sinaBtn setBackgroundImage:[UIImage imageNamed:@"sina_inactive"]forState:UIControlStateNormal];
        }
    } else{
        viewController = [[SinaLoginViewController alloc]init];
        viewController.fromController = @"PostViewController";
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)tencentLoginScreen
{
    btn2Selected = !btn2Selected;
    if([self checkTencentAuth]){
        if(btn2Selected){
            [self.qqBtn setBackgroundImage:[UIImage imageNamed:@"qq_normal"] forState:UIControlStateNormal];
        } else {
            [self.qqBtn setBackgroundImage:[UIImage imageNamed:@"qq_press"] forState:UIControlStateNormal];
        }
    } else{
        tecentViewController = [[TecentViewController alloc] init];
        tecentViewController.fromController = @"PostViewController";
        [self.navigationController pushViewController:tecentViewController animated:YES];
    }
}

- (void)post
{
    [self.textView resignFirstResponder];
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    if([StringUtility stringIsEmpty:self.textView.text]){
        //        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
        HUD.mode = MBProgressHUDModeText;
        HUD.labelText = @"您想说点什么呢？";
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.5];
        return;
    }
    if(!btn1Selected && !btn2Selected){
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"请选择分享地址！";
        [HUD show:YES];
        [HUD hide:YES afterDelay:2];
        return;
    }
    if(btn1Selected){
        if([WBEngine sharedClient].isLoggedIn && ![WBEngine sharedClient].isAuthorizeExpired){
            NSString *content = [NSString stringWithFormat:@"#%@# %@", [program objectForKey:@"name"], self.textView.text];
            AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:kSinaWeiboBaseUrl]];
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[WBEngine sharedClient].accessToken, @"access_token", content, @"status", nil];
            [client postPath:kSinaWeiboUpdateUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            
            } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            }];
        } else {
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.labelText = @"请点击新浪图标，登陆微博！";
            [HUD show:YES];
            [HUD hide:YES afterDelay:2];
            return;
        }
    }
    if(btn2Selected){
        if([self checkTencentAuth]){
            AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:kTecentBaseURL]];
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:_tencentOAuth.accessToken, @"access_token", kTecentAppId, @"oauth_consumer_key", _tencentOAuth.openId, @"openid", @"json", @"format", @"转自悦视频", @"title",kJoyplusWebSite, @"url", [program objectForKey:@"name"],@"comment", self.textView.text,@"summary", [program objectForKey:@"poster"],@"images", @"4",@"source", nil];
            [client postPath:kTecentAddShare parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                
            } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
        } else {
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.labelText = @"请点击腾讯图标登陆！";
            [HUD show:YES];
            [HUD hide:YES afterDelay:2];
            return;
        }        
    }
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = NSLocalizedString(@"share_success", nil);
    [HUD showWhileExecuting:@selector(postSuccess) onTarget:self withObject:nil animated:YES];
}

- (void)postSuccess
{
    sleep(1.5);
    [self performSelectorOnMainThread:@selector(closeSelf) withObject:nil waitUntilDone:YES];
}

- (BOOL)checkTencentAuth{
    if(_tencentOAuth == nil){
        _tencentOAuth = [[TencentOAuth alloc] initWithAppId:kTecentAppId andDelegate:self];
    }
    NSString *openId = [SFHFKeychainUtils getPasswordForUsername:@"tecentOpenId" andServiceName:@"tecentlogin" error:nil];
    NSString *token = [SFHFKeychainUtils getPasswordForUsername:@"tecentAccessToken" andServiceName:@"tecentlogin" error:nil];
    NSString *expireDateValue = [SFHFKeychainUtils getPasswordForUsername:@"tecentExpireTime" andServiceName:@"tecentlogin" error:nil];
    NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:[expireDateValue doubleValue]];
    _tencentOAuth.openId = openId;
    _tencentOAuth.accessToken = token;
    _tencentOAuth.expirationDate = expireDate;
	if (![_tencentOAuth isSessionValid]) {
		return NO;
	} else {
        return YES;
    }
}

@end
