//
//  CreateListOneViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CreateListOneViewController.h"
#import "CreateListTwoViewController.h"
#import "CommonHeader.h"
#define LEFT_GAP 50
@interface CreateListOneViewController ()

@end

@implementation CreateListOneViewController

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
    
    self.titleImage.frame = CGRectMake(LEFT_GAP, 35, 110, 27);
    self.titleImage.image = [UIImage imageNamed:@"create_list_title"];
    
    self.closeBtn.frame = CGRectMake(470, 20, 40, 42);
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleFieldBg.frame = CGRectMake(LEFT_GAP, 100, 400, 39);
    self.titleFieldBg.image = [UIImage imageNamed:@"box_title"];
    
    self.titleField.frame = CGRectMake(LEFT_GAP+5, 103, 390, 33);
    self.titleField.placeholder = @"标题";
    self.titleField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNextBtnImage:) name:UITextFieldTextDidChangeNotification object:self.titleField];
    
    self.contentBgImage.frame = CGRectMake(LEFT_GAP, 140, 400, 102);
    self.contentBgImage.image = [UIImage imageNamed:@"box_content"];
    
    self.contentText.frame = CGRectMake(LEFT_GAP+5, 145, 390, 92);
    self.contentText.placeholder = @"简介（可选）";
    
    self.nextBtn.frame = CGRectMake(390, 250, 62, 39);
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"next_disabled"] forState:UIControlStateDisabled];
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"next_pressed"] forState:UIControlStateHighlighted];
    [self.nextBtn setEnabled:NO];
    [self.nextBtn addTarget:self action:@selector(nextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitleImage:nil];
    [self setTitleField:nil];
    [self setContentBgImage:nil];
    [self setContentText:nil];
    [self setNextBtn:nil];
    [self setCloseBtn:nil];
    [self setTitleFieldBg:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.titleField];
    [super viewDidUnload];
}

- (void)changeNextBtnImage:(NSNotification *)notificaiton
{
    UITextField *textField = notificaiton.object;
    if(textField.text.length > 0){
        [self.nextBtn setEnabled:YES];
    } else {
        [self.nextBtn setEnabled:NO];
    }
}

- (void)nextBtnClicked:(id)sender
{
    [self.nextBtn setEnabled:NO];
    [self.titleField resignFirstResponder];
    [self.contentText resignFirstResponder];
    if(self.titleField.text.length > 0){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.titleField.text, @"name", self.contentText.text, @"content", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathNew parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if(responseCode == nil){
                CreateListTwoViewController *viewController = [[CreateListTwoViewController alloc]initWithNibName:@"CreateListTwoViewController" bundle:nil];
                [[ContainerUtility sharedInstance]setAttribute:[result objectForKey:@"topic_id"] forKey:kTopicId];
                viewController.titleContent = self.titleField.text;
                [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
            } else {
                [[AppDelegate instance].rootViewController showListFailureModalView:1.5];
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            [UIUtility showSystemError:self.view];
        }];
    }
}
@end