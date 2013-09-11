//
//  TpModeViewController.m
//  joylink
//
//  Created by joyplus1 on 13-4-27.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "TpModeViewController.h"
#import "CommonHeader.h"
#import "TpSettingViewController.h"
#import "TpTouchView.h"

#define REMOTE_TOOLBAR_TAG 2111
#define VOLUME_TOOLBAR_VIEW 2112
#define ROUND_CONTROLLER_TAG 2113
#define TOUCHE_VIEW_TAG 3211
#define SCREEN_SHOT_IMAGE_TAG 3212
#define HUD_TAG 3213

@interface TpModeViewController ()<UITextFieldDelegate>

@property (nonatomic, strong)UITextField *hiddenTextField;

@end

@implementation TpModeViewController
@synthesize hiddenTextField;

- (void)viewDidUnload
{
    [super viewDidUnload];
    hiddenTextField = nil;
    [AppDelegate instance].screenshotImage = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RELOAD_SCREENSHOT object:nil];
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
	self.title = @"触控模式";
    [self showBackBtnForNavController];
    [self addRemoteToolBar];
    [self addCenterControl];
    [self addRemoteBackButton];
    [self addToolsBtnOnNavbar];
    
    hiddenTextField = [[UITextField alloc]initWithFrame:CGRectZero];
    hiddenTextField.delegate = self;
    hiddenTextField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:hiddenTextField];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showScreenshot) name:RELOAD_SCREENSHOT object:nil];
    [self serverIsConnected];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addToolsBtnOnNavbar
{
    UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
    firstButton.tag = SCREENSHOT_BTN_TAG;
    firstButton.frame = CGRectMake(self.view.frame.size.height - 44 * 2, -5, 44, 44);
    [firstButton setBackgroundImage:[UIImage imageNamed:@"screenshot1"] forState:UIControlStateNormal];
    [firstButton setBackgroundImage:[UIImage imageNamed:@"screenshot_active"] forState:UIControlStateHighlighted];
    [firstButton addTarget:self action:@selector(screenshotBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:firstButton];
    
    UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
    secondButton.tag = CLEAR_BTN_TAG;
    secondButton.frame = CGRectMake(self.view.frame.size.height - 44, -5, 44, 44);
    [secondButton setBackgroundImage:[UIImage imageNamed:@"clear1"] forState:UIControlStateNormal];
    [secondButton setBackgroundImage:[UIImage imageNamed:@"clear_active"] forState:UIControlStateHighlighted];
    [secondButton addTarget:self action:@selector(clearBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:secondButton];
    
//    UIButton *thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    thirdButton.tag = SETTING_BTN_TAG;
//    thirdButton.frame = CGRectMake(self.view.frame.size.width - 44, -5, 44, 44);
//    [thirdButton setBackgroundImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
//    [thirdButton setBackgroundImage:[UIImage imageNamed:@"setting_active"] forState:UIControlStateHighlighted];
//    [thirdButton addTarget:self action:@selector(settingBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationController.navigationBar addSubview:thirdButton];
}

- (void)addCenterControl
{
    TpTouchView *touchView =  [[TpTouchView alloc]initWithFrame:CGRectMake(NAVIGATION_BAR_HEIGHT + 5, 15, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT - 61 - 5, TOUCH_SCREEN_WIDTH)];
    touchView.tag = TOUCHE_VIEW_TAG;
    touchView.backgroundColor = [UIColor clearColor];
    
    UIImageView *screenshot = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, touchView.frame.size.width, touchView.frame.size.height)];
    screenshot.tag = SCREEN_SHOT_IMAGE_TAG;
    [touchView addSubview:screenshot];
    
    UIImageView *bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, touchView.frame.size.width, touchView.frame.size.height)];
    bgImage.image = [[UIImage imageNamed:@"touch_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [touchView addSubview:bgImage];
    [self.view addSubview:touchView];
}

- (void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addRemoteToolBar
{
    UIView *remoteToolBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, NAVIGATION_BAR_HEIGHT, self.bounds.size.width - NAVIGATION_BAR_HEIGHT)];
    remoteToolBar.tag = REMOTE_TOOLBAR_TAG;
    remoteToolBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:remoteToolBar];
    
    float positionX = remoteToolBar.frame.size.height/3.0;
    UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
    firstButton.frame = CGRectMake(0, 0, 44, 39);
    firstButton.center = CGPointMake(firstButton.center.x, positionX*0.5);
    [firstButton setBackgroundImage:[UIImage imageNamed:@"home"] forState:UIControlStateNormal];
    [firstButton setBackgroundImage:[UIImage imageNamed:@"home_active"] forState:UIControlStateHighlighted];
    [firstButton addTarget:self action:@selector(homeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:firstButton];
    
    UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
    secondButton.frame = CGRectMake(0, 0, 44, 39);
    secondButton.center = CGPointMake(secondButton.center.x, positionX * 1.5);
    [secondButton setBackgroundImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
    [secondButton setBackgroundImage:[UIImage imageNamed:@"keyboard_active"] forState:UIControlStateHighlighted];
    [secondButton addTarget:self action:@selector(keyboardBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:secondButton];
    
    UIButton *fourthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    fourthBtn.frame = CGRectMake(0, 0, 44, 39);
    fourthBtn.center = CGPointMake(fourthBtn.center.x, positionX * 2.5);
    [fourthBtn setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [fourthBtn setBackgroundImage:[UIImage imageNamed:@"menu_active"] forState:UIControlStateHighlighted];
    [fourthBtn addTarget:self action:@selector(menuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:fourthBtn];
}

- (void)addRemoteBackButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(self.bounds.size.height - 61, 0, 61, 262);
    button.center = CGPointMake(button.center.x, self.view.frame.size.width/2 - 18);
    [button setBackgroundImage:[UIImage imageNamed:@"tp_back"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"tp_back_active"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(remoteBackBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)homeBtnClicked
{
    if (![self serverIsConnected]) {
        return;
    }
    RemoteAction *action = [ActionFactory getSimpleActionByEvent:KEYCODE_HOME];
    [action trigger];
}

- (void)keyboardBtnClicked
{
    if (![self serverIsConnected]) {
        return;
    }
    if([hiddenTextField isFirstResponder]){
        [hiddenTextField resignFirstResponder];
    } else {
        [hiddenTextField becomeFirstResponder];
    }
}

- (void)menuBtnClicked
{
    if (![self serverIsConnected]) {
        return;
    }
    RemoteAction *action = [ActionFactory getSimpleActionByEvent:KEYCODE_MENU];
    [action trigger];
}

- (void)remoteBackBtnClicked
{
    if (![self serverIsConnected]) {
        return;
    }
    RemoteAction *action = [ActionFactory getMessageAction:SEND_KEY_CODE];
    NSString *msg = [NSString stringWithFormat:@"{\"keycode\":%d}", KEYCODE_BACK];
    [action trigger:msg];
}

- (void)settingBtnClicked
{
    UIViewController *viewController = [[TpSettingViewController alloc]init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)screenshotBtnClicked
{
    if (![self serverIsConnected]) {
        return;
    }
    MBProgressHUD *HUD = (MBProgressHUD *)[self.view viewWithTag:HUD_TAG];
    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
    }
    HUD.tag = HUD_TAG;
    HUD.opacity = 1;
    HUD.labelText = @"加载中...";
    [HUD show:YES];
    
    UIView *touchView = [self.view viewWithTag:TOUCHE_VIEW_TAG];
    RemoteAction *action = [ActionFactory getMessageAction:SCREEN_SHOT];
    NSString *localIp =  [CommonMethod getIPAddress];
    float screenwidth = touchView.frame.size.width;
    float screenheight = touchView.frame.size.height;
    NSString *sendMsg = [NSString stringWithFormat:@"%@:%f:%f", localIp, screenwidth, screenheight];
    [action trigger:sendMsg];
}

- (void)showScreenshot
{
    MBProgressHUD *HUD = (MBProgressHUD *)[self.view viewWithTag:HUD_TAG];
    [HUD hide:YES];
    UIView *touchView = [self.view viewWithTag:TOUCHE_VIEW_TAG];
    UIImageView *screenshot = (UIImageView *)[touchView viewWithTag:SCREEN_SHOT_IMAGE_TAG];
    screenshot.image = [AppDelegate instance].screenshotImage;
}

- (void)clearBtnClicked
{
    UIView *touchView = [self.view viewWithTag:TOUCHE_VIEW_TAG];
    UIImageView *screenshot = (UIImageView *)[touchView viewWithTag:SCREEN_SHOT_IMAGE_TAG];
    screenshot.image = nil;
    [AppDelegate instance].screenshotImage = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
