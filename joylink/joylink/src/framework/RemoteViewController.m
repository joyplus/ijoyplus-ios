//
//  NewRemoteViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-4-23.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "RemoteViewController.h"
#import "CommonHeader.h"
#import "CustomNavigationViewController.h"
#import "TpModeViewController.h"

@interface RemoteViewController () <UITextFieldDelegate>

@property (nonatomic, strong)UITextField *hiddenTextField;

@end

@implementation RemoteViewController
@synthesize hiddenTextField;

- (void)viewDidUnload
{
    [super viewDidUnload];
    hiddenTextField = nil;
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)shouldAutorotate {
    
    return NO;
    
}

-(NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showNavigationBar:@"遥控器"];
    [self showBackBtn];
    [self addRemoteToolBar];    
    [self addCenterControl];
    [self addRemoteBackButton];
    
    hiddenTextField = [[UITextField alloc]initWithFrame:CGRectZero];
    hiddenTextField.delegate = self;
    hiddenTextField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:hiddenTextField];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentTextFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    [self serverIsConnected];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [hiddenTextField resignFirstResponder];
}

- (void)addRemoteToolBar
{
    UIView *remoteToolBar = [[UIView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, self.bounds.size.width, TOOLBAR_HEIGHT)];
    remoteToolBar.tag = REMOTE_TOOLBAR_TAG;
    remoteToolBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:remoteToolBar];
    
    float positionX = remoteToolBar.frame.size.width/4.0;
    UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
    firstButton.frame = CGRectMake(0, 0, 44, 39);
    firstButton.center = CGPointMake(positionX*0.5 + 10, firstButton.center.y);
    [firstButton setBackgroundImage:[UIImage imageNamed:@"home"] forState:UIControlStateNormal];
    [firstButton setBackgroundImage:[UIImage imageNamed:@"home_active"] forState:UIControlStateHighlighted];
    [firstButton addTarget:self action:@selector(homeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:firstButton];
    
    UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
    secondButton.frame = CGRectMake(0, 0, 44, 39);
    secondButton.center = CGPointMake(positionX * 1.5 + 5, secondButton.center.y);
    [secondButton setBackgroundImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
    [secondButton setBackgroundImage:[UIImage imageNamed:@"keyboard_active"] forState:UIControlStateHighlighted];
    [secondButton addTarget:self action:@selector(keyboardBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:secondButton];
    
    UIButton *thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    thirdButton.frame = CGRectMake(0, 0, 44, 39);
    thirdButton.center = CGPointMake(positionX * 2.5 - 5, thirdButton.center.y);
    [thirdButton setBackgroundImage:[UIImage imageNamed:@"touch"] forState:UIControlStateNormal];
    [thirdButton setBackgroundImage:[UIImage imageNamed:@"touch_active"] forState:UIControlStateHighlighted];
    [thirdButton addTarget:self action:@selector(tpModeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:thirdButton];
    
    UIButton *fourthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    fourthBtn.frame = CGRectMake(0, 0, 44, 39);
    fourthBtn.center = CGPointMake(positionX * 3.5 - 10, thirdButton.center.y);
    [fourthBtn setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [fourthBtn setBackgroundImage:[UIImage imageNamed:@"menu_active"] forState:UIControlStateHighlighted];
    [fourthBtn addTarget:self action:@selector(menuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:fourthBtn];
}

- (void)homeBtnClicked
{
    if (![self serverIsConnected]) {
        return;
    }
    RemoteAction *action = [ActionFactory getMessageAction:SEND_KEY_CODE];
    NSString *msg = [NSString stringWithFormat:@"{\"keycode\":%d}", KEYCODE_HOME];
    [action trigger:msg];
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
    RemoteAction *action = [ActionFactory getMessageAction:SEND_KEY_CODE];
    NSString *msg = [NSString stringWithFormat:@"{\"keycode\":%d}", KEYCODE_MENU];
    [action trigger:msg];
}

- (void)tpModeButtonClicked
{
    TpModeViewController *viewController = [[TpModeViewController alloc]init];
    CustomNavigationViewController *navViewController = [[CustomNavigationViewController alloc]initWithRootViewController:viewController];
    [self presentViewController:navViewController animated:YES completion:nil];
}

// should not in here and implemented in subclasses
- (void)addCenterControl
{
}

- (void)addRemoteBackButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,  self.bounds.size.height - 61 - 24, 262, 61);
    button.center = CGPointMake(self.view.center.x, button.center.y);
    [button setBackgroundImage:[UIImage imageNamed:@"remote_back"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"remote_back_active"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(remoteBackBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
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

- (void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)contentTextFieldChanged:(NSNotification *)notification
{
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([StringUtility stringIsEmpty:string]) {
        RemoteAction *action = [ActionFactory getSimpleActionByEvent:DEL_INPUT_MSG];
        [action trigger];
    } else {
        RemoteAction *action = [ActionFactory getSendInputMsgAction:SEND_INPUT_MSG];
        [action trigger:string];
    }
    return YES;
}
@end
