//
//  CreateListOneViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SuggestionViewController.h"
#import "CommonHeader.h"
#define LEFT_GAP 50
@interface SuggestionViewController (){
    
}

@end

@implementation SuggestionViewController
@synthesize prodId;

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.titleField];
    [self setTitleImage:nil];
    [self setTitleField:nil];
    [self setContentBgImage:nil];
    [self setContentText:nil];
    [self setNextBtn:nil];
    [self setCloseBtn:nil];
    [self setTitleFieldBg:nil];
    [self setBgImage:nil];
    self.prodId = nil;
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
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    self.bgImage.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.bgImage.image = [UIImage imageNamed:@"detail_bg"];
    
    self.titleImage.frame = CGRectMake(LEFT_GAP, 35, 110, 27);
    self.titleImage.image = [UIImage imageNamed:@"proposal"];
    
    self.closeBtn.frame = CGRectMake(470, 20, 40, 42);
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleFieldBg.frame = CGRectMake(LEFT_GAP, 100, 400, 39);
    self.titleFieldBg.image = [UIImage imageNamed:@"box_title"];
    self.titleFieldBg.layer.borderColor = CMConstants.tableBorderColor.CGColor;
    self.titleFieldBg.layer.borderWidth = 1;
    
    self.titleField.frame = CGRectMake(LEFT_GAP+5, 103, 390, 33);
    self.titleField.placeholder = @"邮箱";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNextBtnImage:) name:UITextFieldTextDidChangeNotification object:self.titleField];
    
    self.contentBgImage.frame = CGRectMake(LEFT_GAP, 140, 400, 102);
    self.contentBgImage.image = [UIImage imageNamed:@"box_content"];
    self.contentBgImage.layer.borderColor = CMConstants.tableBorderColor.CGColor;
    self.contentBgImage.layer.borderWidth = 1;
    
    self.contentText.frame = CGRectMake(LEFT_GAP+5, 145, 390, 92);
    self.contentText.placeholder = @"你的反馈是我们进步的动力。";
    
    self.nextBtn.frame = CGRectMake(390, 250, 62, 39);
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"submit"] forState:UIControlStateNormal];
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"submit_disabled"] forState:UIControlStateDisabled];
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"submit_pressed"] forState:UIControlStateHighlighted];
    [self.nextBtn setEnabled:NO];
    [self.nextBtn addTarget:self action:@selector(nextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNextBtnImage:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeNextBtnImage:(NSNotification *)notificaiton
{
    if(self.contentText.text.length > 0){
        [self.nextBtn setEnabled:YES];
    } else {
        [self.nextBtn setEnabled:NO];
    }
}

- (void)nextBtnClicked:(id)sender
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    [self.titleField resignFirstResponder];
    [self.contentText resignFirstResponder];
    if(self.titleField.text.length > 0){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.titleField.text, @"name", self.contentText.text, @"content", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathNew parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        [[AppDelegate instance].rootViewController showSuccessModalView:1.5];
    }
}

@end
