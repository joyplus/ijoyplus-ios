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
@property (nonatomic, strong)UILabel *contentLabel;
@property (nonatomic, strong)UIScrollView *scrollView;
@property (nonatomic, strong)UILabel *titleLabel;

@end

@implementation CommentDetailViewController
@synthesize titleContent;
@synthesize content;
@synthesize titleLabel, contentLabel, scrollView;

- (void)viewDidUnload
{
    [super viewDidUnload];
    closeBtn = nil;
    titleContent = nil;
    content = nil;
    titleLabel = nil;
    contentLabel = nil;
    scrollView = nil;
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
    
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(40, 0, 470, self.view.frame.size.height)];
    scrollView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:scrollView];
    
    self.bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 470, 750)];
    [scrollView addSubview:self.bgImage];
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(456, 0, 50, 50);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 20, 210, 40)];
    titleLabel.backgroundColor = [UIColor yellowColor];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textColor = CMConstants.grayColor;
    [scrollView addSubview:titleLabel];
    
    contentLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    contentLabel.backgroundColor = [UIColor blueColor];
    contentLabel.numberOfLines = 0;
    contentLabel.font = [UIFont systemFontOfSize:15];
    contentLabel.textColor = CMConstants.grayColor;
    [scrollView addSubview:contentLabel];

    [self.view addGestureRecognizer:self.swipeRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    titleLabel.text = titleContent;
    CGSize contentSize = [self calculateContentSize:content width:410];
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, contentSize.height + 500)];
    self.bgImage.frame = CGRectMake(self.bgImage.frame.origin.x, self.bgImage.frame.origin.y, self.bgImage.frame.size.width, contentSize.height + 500);
    self.bgImage.image = [[UIImage imageNamed:@"comment_background@2x.jpg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
    contentLabel.frame = CGRectMake(30, 80, 410, contentSize.height + 50);
    contentLabel.text = content;
}

- (CGSize)calculateContentSize:(NSString *)strcontent width:(int)width
{
    CGSize constraint = CGSizeMake(width, 20000.0f);
    CGSize size = [strcontent sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    return size;
}

- (void)closeBtnClicked
{
    [[AppDelegate instance].rootViewController.stackScrollViewController removeViewToViewInSlider:VideoDetailViewController.class];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
