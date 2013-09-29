//
//  GroupImageViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "RemoteViewController.h"
#import "CommonHeader.h"
#import "MoveView.h"
#import "UpDownScrollView.h"
#import "LeftRightScrollView.h"
#import "TPRemoteViewController.h"

#define INPUT_VIEW_HEIGHT 80

@interface RemoteViewController ()
@property (nonatomic, strong) MoveView *moveView;
@property (nonatomic, strong) UpDownScrollView *scrollUpDownView;
@property (nonatomic, strong) LeftRightScrollView *scrollLeftRightView;
@property (nonatomic, strong) UIView *deadView;
@property (nonatomic, strong) UIView *inputView;
@property (nonatomic, strong) UITextView *textView;
@end

@implementation RemoteViewController
@synthesize moveView, scrollLeftRightView, scrollUpDownView, deadView;
@synthesize inputView, textView;

- (void)viewDidUnload
{
    [super viewDidUnload];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [super showNavigationBar:@"遥控器"];
    
    UIBarButtonItem* sureBtnItem = [[UIBarButtonItem alloc]initWithTitle:@"TP" style:UIBarButtonItemStyleDone target:self action:@selector(changeToTPMode)];
    self.navBar.topItem.rightBarButtonItem = sureBtnItem;
    [self addRemoteToolBar];
    [super showToolbar];
    
    moveView = [[MoveView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + TOOLBAR_HEIGHT, self.bounds.size.width * 0.8, (self.bounds.size.height - TOOLBAR_HEIGHT*2 - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT) * 0.85)];
    moveView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:moveView];
    
    scrollUpDownView = [[UpDownScrollView alloc]initWithFrame:CGRectMake(moveView.frame.size.width, moveView.frame.origin.y, self.bounds.size.width - moveView.frame.size.width, moveView.frame.size.height)];
    scrollUpDownView.backgroundColor = [UIColor redColor];
    [self.view addSubview:scrollUpDownView];
    
    scrollLeftRightView = [[LeftRightScrollView alloc]initWithFrame:CGRectMake(moveView.frame.origin.x, moveView.frame.origin.y + moveView.frame.size.height,  moveView.frame.size.width, (self.bounds.size.height - TOOLBAR_HEIGHT*2 - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT - moveView.frame.size.height + 5))];
    scrollLeftRightView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:scrollLeftRightView];
    
    deadView = [[UIView alloc]initWithFrame:CGRectMake(moveView.frame.origin.x + moveView.frame.size.width, moveView.frame.origin.y + moveView.frame.size.height, scrollUpDownView.frame.size.width, scrollLeftRightView.frame.size.height)];
    deadView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:deadView];
    
    inputView = [[UIView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + TOOLBAR_HEIGHT, self.bounds.size.width, 0)];
    [inputView setHidden:YES];
    inputView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:inputView];
    
    textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 10, inputView.frame.size.width - 90, 60)];
    [textView setHidden:YES];
    textView.returnKeyType = UIReturnKeyDone;
    textView.backgroundColor = [UIColor lightGrayColor];
    textView.font = [UIFont systemFontOfSize:18];
    textView.layer.cornerRadius = 5;
    textView.layer.borderWidth = 1;
    textView.layer.borderColor = [UIColor blackColor].CGColor;
    textView.layer.masksToBounds = YES;
    [inputView addSubview:textView];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendBtn.tag = 1001;
    [sendBtn setHidden:YES];
    sendBtn.frame = CGRectMake(self.bounds.size.width - 70, 10, 60, 30);
    [sendBtn setTitle:@"Input" forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(inputViewBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:sendBtn];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    deleteBtn.tag = 1002;
    [deleteBtn setHidden:YES];
    deleteBtn.frame = CGRectMake(self.bounds.size.width - 70, 40, 60, 30);
    [deleteBtn setTitle:@"Delete" forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(inputViewBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:deleteBtn];

}

- (void)inputViewBtnClicked:(UIButton *)btn
{
    [textView resignFirstResponder];
    if (btn.tag == 1001) {
        RemoteAction *action = [ActionFactory getSendInputMsgAction:SEND_INPUT_MSG];
        [action trigger:textView.text];
        textView.text = @"";
    } else {
        RemoteAction *action = [ActionFactory getSimpleActionByEvent:DEL_INPUT_MSG];
        [action trigger];
    }
}

- (void)addRemoteToolBar
{
    UIToolbar *remoteToolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT-1, self.bounds.size.width, TOOLBAR_HEIGHT)];
    [remoteToolBar setNeedsDisplay];
    [self.view addSubview:remoteToolBar];
    
    UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
    firstButton.frame = CGRectMake(10, 0, 40, 40);
    [firstButton setBackgroundImage:[UIImage imageNamed:@"menu_icon_blue"] forState:UIControlStateNormal];
    [firstButton setBackgroundImage:[UIImage imageNamed:@"menu_icon_blue_pressed"] forState:UIControlStateHighlighted];
    [firstButton addTarget:self action:@selector(firstButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:firstButton];
    
    UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
    secondButton.frame = CGRectMake(60, 0, 40, 40);
    [secondButton setBackgroundImage:[UIImage imageNamed:@"home_icon_blue"] forState:UIControlStateNormal];
    [secondButton setBackgroundImage:[UIImage imageNamed:@"home_icon_blue_pressed"] forState:UIControlStateHighlighted];
    [secondButton addTarget:self action:@selector(secondButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:secondButton];
    
    UIButton *thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    thirdButton.frame = CGRectMake(110, 0, 40, 40);
    [thirdButton setBackgroundImage:[UIImage imageNamed:@"back_icon_blue"] forState:UIControlStateNormal];
    [thirdButton setBackgroundImage:[UIImage imageNamed:@"back_icon_blue_pressed"] forState:UIControlStateHighlighted];
    [thirdButton addTarget:self action:@selector(thirdButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:thirdButton];
    
    UIButton *fourthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fourthButton.frame = CGRectMake(170, 0, 40, 40);
    [fourthButton setBackgroundImage:[UIImage imageNamed:@"keyboard_icon"] forState:UIControlStateNormal];
    [fourthButton setBackgroundImage:[UIImage imageNamed:@"keyboard_icon_pressed"] forState:UIControlStateHighlighted];
    [fourthButton addTarget:self action:@selector(fourthButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:fourthButton];
    
    UIButton *fifthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fifthButton.frame = CGRectMake(220, 0, 40, 40);
    [fifthButton setBackgroundImage:[UIImage imageNamed:@"setting_icon"] forState:UIControlStateNormal];
    [fifthButton setBackgroundImage:[UIImage imageNamed:@"setting_icon_pressed"] forState:UIControlStateHighlighted];
    [fifthButton addTarget:self action:@selector(fourthButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:fifthButton];
    
    UIButton *sixthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sixthButton.frame = CGRectMake(270, 0, 40, 40);
    [sixthButton setBackgroundImage:[UIImage imageNamed:@"mark_icon"] forState:UIControlStateNormal];
    [sixthButton setBackgroundImage:[UIImage imageNamed:@"mark_icon_pressed"] forState:UIControlStateHighlighted];
    [sixthButton addTarget:self action:@selector(showFavorite) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:sixthButton];
}

- (void)changeToTPMode
{
    TPRemoteViewController *viewController = [[TPRemoteViewController alloc]init];
    viewController.view.frame = [[UIScreen mainScreen] bounds];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)firstButtonClicked
{
    [textView resignFirstResponder];
    RemoteAction *action = [ActionFactory getSimpleActionByEvent:SEND_KEY_MENU];
    [action trigger];
}

- (void)secondButtonClicked
{
    [textView resignFirstResponder];
    RemoteAction *action = [ActionFactory getSimpleActionByEvent:SEND_KEY_HOME];
    [action trigger];
}

- (void)thirdButtonClicked
{
    [textView resignFirstResponder];
    RemoteAction *action = [ActionFactory getSimpleActionByEvent:SEND_KEY_BACK];
    [action trigger];
}

- (void)fourthButtonClicked
{
    [textView resignFirstResponder];
    if (inputView.hidden) {
        [inputView setHidden:NO];
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
            inputView.frame = CGRectMake(inputView.frame.origin.x, inputView.frame.origin.y, inputView.frame.size.width, INPUT_VIEW_HEIGHT);
        } completion:^(BOOL finished) {
            for (UIView *subview in inputView.subviews) {
                subview.alpha = 1;
                [subview setHidden:NO];
            }
        }];
    } else {
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
            for (UIView *subview in inputView.subviews) {
                subview.alpha = 0;
            }
        } completion:^(BOOL finished) {            
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
                inputView.frame = CGRectMake(inputView.frame.origin.x, inputView.frame.origin.y, inputView.frame.size.width, 0);
            } completion:^(BOOL finished) {
                [inputView setHidden:YES];
                for (UIView *subview in inputView.subviews) {
                    [subview setHidden:YES];
                }
                
            }];
        }];
    }
}

- (void)fifthButtonClicked
{
    [textView resignFirstResponder];
}


- (void)backButtonClicked
{
    [super homeButtonClicked];
}

@end
