//
//  CreateListTwoViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CreateListTwoViewController.h"
#import "CommonHeader.h"
#import "AddSearchViewController.h"
#define LEFT_GAP 50
@interface CreateListTwoViewController ()

@end

@implementation CreateListTwoViewController
@synthesize titleContent;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setAddBtn:nil];
    [self setDeleteBtn:nil];
    [self setCloseBtn:nil];
    [self setLineImage:nil];
    [super viewDidUnload];
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
    self.titleLabel.frame = CGRectMake(LEFT_GAP, 35, 310, 27);
    self.titleLabel.font = [UIFont boldSystemFontOfSize:26];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = CMConstants.titleBlueColor;
    self.titleLabel.layer.shadowColor = [UIColor colorWithRed:141/255.0 green:182/255.0 blue:213/255.0 alpha:1].CGColor;
    self.titleLabel.layer.shadowOffset = CGSizeMake(1, 1);
    
    self.lineImage.frame = CGRectMake(LEFT_GAP, 80, 400, 2);
    self.lineImage.image = [UIImage imageNamed:@"dividing"];
   
    self.closeBtn.frame = CGRectMake(470, 20, 40, 42);
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.addBtn.frame = CGRectMake(LEFT_GAP, 100, 105, 31);
    [self.addBtn setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [self.addBtn setBackgroundImage:[UIImage imageNamed:@"add_pressed"] forState:UIControlStateHighlighted];
    [self.addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.deleteBtn.frame = CGRectMake(LEFT_GAP + 115, 100, 105, 31);
    [self.deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [self.deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete_pressed"] forState:UIControlStateHighlighted];
    [self.deleteBtn addTarget:self action:@selector(deleteBtnClicked) forControlEvents:UIControlEventTouchUpInside];

}

- (void)viewWillAppear:(BOOL)animated
{
    self.titleLabel.text = self.titleContent;
}

- (void)addBtnClicked
{
    AddSearchViewController *viewController = [[AddSearchViewController alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:NO];
}

- (void)deleteBtnClicked
{
    [self deleteList];
}


- (void)deleteList
{
    NSString *topId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kTopicId];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: topId, @"topic_id", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathTopDelete parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if([responseCode isEqualToString:kSuccessResCode]){
            [[AppDelegate instance].rootViewController showSuccessModalView:1.5];
        } else {
            [[AppDelegate instance].rootViewController showFailureModalView:1.5];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [UIUtility showSystemError:self.view];
    }];
}

@end
