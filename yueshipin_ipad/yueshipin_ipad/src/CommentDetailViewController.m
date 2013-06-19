//
//  ListViewController.m
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CommentDetailViewController.h"
#import "VideoDetailViewController.h"

@interface CommentDetailViewController (){
    UIButton *closeBtn;
}
@property (nonatomic, strong)UITextView *contentLabel;
@property (nonatomic, strong)UILabel *titleLabel;

@end

@implementation CommentDetailViewController
@synthesize titleContent;
@synthesize content;
@synthesize titleLabel, contentLabel;
@synthesize parentDelegateController;

- (void)viewDidUnload
{
    [super viewDidUnload];
    closeBtn = nil;
    titleContent = nil;
    content = nil;
    titleLabel = nil;
    contentLabel = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(65, 0, 470, 750)];
    self.bgImage.image = [UIImage imageNamed:@"comment_background@2x.jpg"];
    [self.view addSubview:self.bgImage];  
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(456, 0, 50, 50);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 10, 220, 60)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.numberOfLines = 2;
    titleLabel.textColor = CMConstants.grayColor;
    [self.view addSubview:titleLabel];
    
    contentLabel = [[UITextView alloc]initWithFrame:CGRectMake(75, 90, 410, self.view.frame.size.height - 410)];
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.font = [UIFont systemFontOfSize:15];
    contentLabel.textColor = CMConstants.grayColor;
    contentLabel.showsVerticalScrollIndicator = NO;
    contentLabel.editable = NO;
    [self.view addSubview:contentLabel];

    [self.view addGestureRecognizer:self.swipeRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    titleLabel.text = titleContent;
    contentLabel.text = content;
    [self.parentDelegateController hideCloseBtn];
    self.preViewController.moveToLeft = NO;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
   
}
- (void)closeBtnClicked
{   self.preViewController.moveToLeft = YES;
    [parentDelegateController showCloseBtn];
    [[AppDelegate instance].rootViewController.stackScrollViewController removeViewToViewInSlider:VideoDetailViewController.class];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
