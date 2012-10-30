//
//  PostViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "RecommandViewController.h"
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

#define  TEXT_MAX_COUNT 140

@interface RecommandViewController (){
    BOOL btn1Selected;
    SinaLoginViewController *viewController;
}
@property (weak, nonatomic) IBOutlet UILabel *textCount;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet CustomPlaceHolderTextView *textView;
- (void)startObservingNotifications;
- (void)stopObservingNotifications;
- (void)didReceiveTextDidChangeNotification:(NSNotification*)notification;
- (void)updateCount;
@end

@implementation RecommandViewController
@synthesize textCount;
@synthesize tipLabel;
@synthesize textView;
@synthesize programId;
@synthesize programName;
@synthesize sinaBtn;

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
    viewController = nil;
    self.title = NSLocalizedString(@"recommand_toolbar", nil);
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    CustomBackButton *backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:NSLocalizedString(@"back", nil)];
    [backButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"submit", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(post)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    [self.sinaBtn setBackgroundImage:[UIImage imageNamed:@"sina_inactive"] forState:UIControlStateNormal];
    [self.sinaBtn addTarget:self action:@selector(sinaLoginScreen)forControlEvents:UIControlEventTouchUpInside];
    textView.placeholder = @"请输入推荐理由";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.sinaBtn = nil;
    self.programId = nil;
    self.programName = nil;
    [self setTextView:nil];
    [self setTextCount:nil];
    [self stopObservingNotifications];
    [self setTipLabel:nil];
    [self setSinaBtn:nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    self.textCount.text = [NSString stringWithFormat:@"%i", TEXT_MAX_COUNT];
    [self updateCount];
    [self startObservingNotifications];
    [self.textView becomeFirstResponder];
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
        HUD.labelText = @"推荐理由不能为空！";
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.5];
        return;
    }
    
    if(btn1Selected){
        NSString *content = [NSString stringWithFormat:@"#%@# %@", self.programName, self.textView.text];
        [[WBEngine sharedClient] sendWeiBoWithText:content image:nil];
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.programId, @"prod_id",
                                self.textView.text, @"reason",
                                nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathProgramRecommend parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if([responseCode isEqualToString:kSuccessResCode]){
        } else {

        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {

    }];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = NSLocalizedString(@"recommand_success", nil);
    [HUD showWhileExecuting:@selector(postSuccess) onTarget:self withObject:nil animated:YES];
}

- (void)postSuccess
{
    sleep(1.5);
    [self performSelectorOnMainThread:@selector(closeSelf) withObject:nil waitUntilDone:YES];
}
@end
