/*
 This module is licenced under the BSD license.
 
 Copyright (C) 2011 by raw engineering <nikhil.jain (at) raweng (dot) com, reefaq.mohammed (at) raweng (dot) com>.
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  RootView.m
//  StackScrollView
//
//  Created by Reefaq on 2/24/11.
//  Copyright 2011 raw engineering . All rights reserved.
//

#import "RootViewController.h"
#import "MenuViewController.h"
#import "StackScrollViewController.h"
#import "AFSinaWeiboAPIClient.h"
#import "CustomTextField.h"
#import "SSCheckBoxView.h"
#import "DatabaseManager.h"

#define EPISODE_NUMBER_IN_ROW   5
#define TOP_VIEW_TAG            (54321)

@interface UIViewExt : UIView {
}

@end

@implementation UIViewExt

- (UIView *) hitTest: (CGPoint) pt withEvent: (UIEvent *) event
{
	UIView* viewToReturn=nil;
	CGPoint pointToReturn;
	UIView* uiRightView = (UIView*)[[self subviews] objectAtIndex:2];
	
	if ([[uiRightView subviews] objectAtIndex:0]) {
		
		UIView* uiStackScrollView = [[uiRightView subviews] objectAtIndex:0];
		
		if ([[uiStackScrollView subviews] objectAtIndex:1]) {
			
			UIView* uiSlideView = [[uiStackScrollView subviews] objectAtIndex:1];
			
			for (UIView* subView in [uiSlideView subviews]) {
				CGPoint point  = [subView convertPoint:pt fromView:self];
				if ([subView pointInside:point withEvent:event]) {
					viewToReturn = subView;
					pointToReturn = point;
				}
			}
		}
	}
	if(viewToReturn != nil) {
		return [viewToReturn hitTest:pointToReturn withEvent:event];
	}
	return [super hitTest:pt withEvent:event];
}

@end

@interface RootViewController ()
@property (nonatomic, strong)NSMutableSet *checkboxes;

@end

@implementation RootViewController
@synthesize menuViewController, stackScrollViewController;
@synthesize prodUrl, prodId, prodName, prodType;
@synthesize videoDetailDelegate, checkboxes;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect frame = [UIScreen mainScreen].bounds;
	rootView = [[UIViewExt alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, self.view.frame.size.height)];
	rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth + UIViewAutoresizingFlexibleHeight;
	[rootView setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background@2x.jpg"]];
    bgImageView.frame = CGRectMake(rootView.frame.origin.x, rootView.frame.origin.y-2, rootView.frame.size.width, 750);
    [rootView addSubview:bgImageView];
	
	leftMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, LEFT_MENU_DIPLAY_WIDTH, self.view.frame.size.height)];
	leftMenuView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	menuViewController = [[MenuViewController alloc] initWithFrame:CGRectMake(0, 0, leftMenuView.frame.size.width, leftMenuView.frame.size.height)];
	[menuViewController.view setBackgroundColor:[UIColor clearColor]];
	[menuViewController viewWillAppear:FALSE];
	[menuViewController viewDidAppear:FALSE];
	[leftMenuView addSubview:menuViewController.view];
	
	rightSlideView = [[UIView alloc] initWithFrame:CGRectMake(LEFT_MENU_DIPLAY_WIDTH, 0, rootView.frame.size.width - leftMenuView.frame.size.width, rootView.frame.size.height)];
	rightSlideView.autoresizingMask = UIViewAutoresizingFlexibleWidth + UIViewAutoresizingFlexibleHeight;
	stackScrollViewController = [[StackScrollViewController alloc] init];
	[stackScrollViewController.view setFrame:CGRectMake(0, 0, rightSlideView.frame.size.width, rightSlideView.frame.size.height)];
	[stackScrollViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth + UIViewAutoresizingFlexibleHeight];
	[stackScrollViewController viewWillAppear:FALSE];
	[stackScrollViewController viewDidAppear:FALSE];
	[rightSlideView addSubview:stackScrollViewController.view];
	
	[rootView addSubview:leftMenuView];
	[rootView addSubview:rightSlideView];
	[self.view addSubview:rootView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentTextViewChanged:) name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentTextFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[menuViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[stackScrollViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[menuViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[stackScrollViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark -
#pragma mark - 私有函数

- (void)topViewTouchDown
{
    [[self.view viewWithTag:TOP_VIEW_TAG] removeFromSuperview];
}

#pragma mark - 
#pragma mark - 对外接口
- (void)addTopView:(UIView *)tView
{
    UIView * bgTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    bgTopView.backgroundColor = [UIColor clearColor];
    bgTopView.tag = TOP_VIEW_TAG;
    
    UIButton * bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bgBtn.frame = bgTopView.frame;
    bgBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
    [bgBtn addTarget:self
              action:@selector(topViewTouchDown)
    forControlEvents:UIControlEventTouchDown];
    
    tView.center = bgBtn.center;
    
    [bgTopView addSubview:bgBtn];
    [bgTopView addSubview:tView];
    [self.view addSubview:bgTopView];
    //[rootView bringSubviewToFront:bgTopView];
}
- (void)showSuccessModalView:(int)closeTime
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
    view.tag = 3268142;
    [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    UIImageView *temp = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"success_img"]];
    temp.frame = CGRectMake(0, 0, 446, 174);
    temp.center = view.center;
    [view addSubview:temp];
    [self.view addSubview:view];
    [NSTimer scheduledTimerWithTimeInterval:closeTime target:self selector:@selector(removeOverlay) userInfo:nil repeats:NO];
}

- (void)showFailureModalView:(int)closeTime
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
    view.tag = 3268142;
    [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    UIImageView *temp = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"failure_img"]];
    temp.frame = CGRectMake(0, 0, 446, 174);
    temp.center = view.center;
    [view addSubview:temp];
    [self.view addSubview:view];
    [NSTimer scheduledTimerWithTimeInterval:closeTime target:self selector:@selector(removeOverlay) userInfo:nil repeats:NO];
}

- (void)showListFailureModalView:(int)closeTime
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
    view.tag = 3268142;
    [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    UIImageView *temp = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"top_error"]];
    temp.frame = CGRectMake(0, 0, 446, 174);
    temp.center = view.center;
    [view addSubview:temp];
    [self.view addSubview:view];
    [NSTimer scheduledTimerWithTimeInterval:closeTime target:self selector:@selector(removeOverlay) userInfo:nil repeats:NO];
}

- (void)showSharePopup
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
    view.tag = 3268142;
    [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    UIImageView *frame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"share_frame"]];
    frame.frame = CGRectMake(0, 0, 545, 265);
    frame.center = CGPointMake(view.center.x, view.center.y - 180);
    [view addSubview:frame];
    
    UIImageView *sina = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sina_btn_pressed"]];
    sina.frame = CGRectMake(25, 206, 33, 33);
    [frame addSubview:sina];
    
    UIImageView *tempMovieImage = [[UIImageView alloc]initWithFrame:CGRectMake(270, 460, 114, 162)];
    tempMovieImage.frame = CGRectMake(408, 73, 113, 170);
    [tempMovieImage setImageWithURL:[NSURL URLWithString:self.prodUrl] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    [frame addSubview:tempMovieImage];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(730, 78, 50, 50);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(removeOverlay) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:closeBtn];
    
    shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(555, 280, 80, 32);
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"share_btn_disabled"] forState:UIControlStateDisabled];
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"share_btn"] forState:UIControlStateNormal];
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"share_btn_pressed"] forState:UIControlStateHighlighted];
    [shareBtn setEnabled:YES];
    [shareBtn addTarget:self action:@selector(sendWeibo) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:shareBtn];
    
    contentTextView = [[UITextView alloc]initWithFrame:CGRectMake(270, 150, 360, 110)];
    contentTextView.font = [UIFont systemFontOfSize:14];
    contentTextView.delegate = self;
    contentTextView.text = [NSString stringWithFormat:@"我在用#悦视频#ipad版观看#%@#，推荐给大家哦！更多精彩尽在悦视频，欢迎下载：http://ums.bz/REGLDb/", self.prodName];
    [contentTextView becomeFirstResponder];
    [view addSubview:contentTextView];
    
    maxTextCount = 120;
    UILabel *numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(585, 235, 50, 30)];
    numberLabel.textColor = CMConstants.grayColor;
    numberLabel.backgroundColor = [UIColor clearColor];
    numberLabel.font = [UIFont boldSystemFontOfSize:16];
    numberLabel.text = [NSString stringWithFormat:@"/ %d", maxTextCount];
    [view addSubview:numberLabel];
    
    textCount = [[UILabel alloc]initWithFrame:CGRectMake(528, 235, 50, 30)];
    textCount.textColor = CMConstants.grayColor;
    textCount.textAlignment = NSTextAlignmentRight;
    textCount.backgroundColor = [UIColor clearColor];
    textCount.font = [UIFont boldSystemFontOfSize:16];
    textCount.text = @"0";
    [view addSubview:textCount];
    [self.view addSubview:view];
    [self updateCount];
}

- (void)contentTextViewChanged:(NSNotification *)notification
{
    if (contentTextView.text.length > 0) {
        [shareBtn setEnabled:YES];
        [sendBtn setEnabled:YES];
    } else {
        [shareBtn setEnabled:NO];
        [sendBtn setEnabled:NO];
    }
    [self updateCount];
}

- (void)updateCount
{
    NSUInteger count = [contentTextView.text length];
    if(count > maxTextCount){
        textCount.textColor = [UIColor redColor];
        textCount.text =  [NSString stringWithFormat:@"-%d", -maxTextCount+count];
    } else {
        textCount.textColor = CMConstants.grayColor;
        textCount.text = [NSString stringWithFormat:@"%d", maxTextCount-count];
    }
    
}


- (void)showCommentPopup
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
    view.tag = 3268142;
    [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    UIImageView *frame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"comment_frame"]];
    frame.frame = CGRectMake(0, 0, 424, 265);
    frame.center = CGPointMake(view.center.x, view.center.y - 180);
    [view addSubview:frame];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(675, 80, 50, 50);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(removeOverlay) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:closeBtn];
    
    sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(615, 280, 80, 32);
    [sendBtn setBackgroundImage:[UIImage imageNamed:@"send_btn_disabled"] forState:UIControlStateDisabled];
    [sendBtn setBackgroundImage:[UIImage imageNamed:@"send_btn"] forState:UIControlStateNormal];
    [sendBtn setBackgroundImage:[UIImage imageNamed:@"send_btn_pressed"] forState:UIControlStateHighlighted];
    [sendBtn addTarget:self action:@selector(sendComment:) forControlEvents:UIControlEventTouchUpInside];
    [sendBtn setEnabled:NO];
    [view addSubview:sendBtn];
    
    contentTextView = [[UITextView alloc]initWithFrame:CGRectMake(330, 150, 360, 110)];
    contentTextView.delegate = self;
    [contentTextView becomeFirstResponder];
    [view addSubview:contentTextView];
    
    maxTextCount = 140;
    UILabel *numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(640, 235, 50, 30)];
    numberLabel.textColor = CMConstants.grayColor;
    numberLabel.backgroundColor = [UIColor clearColor];
    numberLabel.font = [UIFont boldSystemFontOfSize:16];
    numberLabel.text = [NSString stringWithFormat:@"/ %d", maxTextCount];
    [view addSubview:numberLabel];
    
    textCount = [[UILabel alloc]initWithFrame:CGRectMake(583, 235, 50, 30)];
    textCount.textColor = CMConstants.grayColor;
    textCount.textAlignment = NSTextAlignmentRight;
    textCount.backgroundColor = [UIColor clearColor];
    textCount.font = [UIFont boldSystemFontOfSize:16];
    textCount.text = @"0";
    [view addSubview:textCount];
    [self.view addSubview:view];
}

- (void)sendComment:(UIButton *)btn
{
    if(contentTextView.text.length > 0){
        [btn setEnabled:NO];
        NSString *content = contentTextView.text;
        if (content.length > 140) {
            content = [content substringToIndex:140];
        }
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:self.prodId, @"prod_id", content, @"content", [StringUtility createUUID], @"token", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathProgramComment parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if([responseCode isEqualToString:kSuccessResCode]){
                [self removeOverlay];
                [self showSuccessModalView:1.5];
                [self.videoDetailDelegate getTopComments:10];
            } else {
                [self removeOverlay];
                [self showFailureModalView:1.5];
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            [self removeOverlay];
            [self showFailureModalView:1.5];
        }];
    }
}

- (void)sendWeibo
{
    if(contentTextView.text.length > 0){
        SinaWeibo  *_sinaweibo = [AppDelegate instance].sinaweibo;
        NSString *content = contentTextView.text;
        if (content.length > 140) {
            content = [content substringToIndex:140];
        }
        if([content rangeOfString:@"\n"].location != NSNotFound){
            content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        }
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:_sinaweibo.accessToken, @"access_token", content, @"status", self.prodUrl, @"url", nil];
        [[AFSinaWeiboAPIClient sharedClient] postPath:kSinaWeiboUpdateWithImageUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self removeOverlay];
            [self showSuccessModalView:1.5];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            [self removeOverlay];
            [self showFailureModalView:1.5];
        }];
    }
}

- (void)removeOverlay
{
    UIView *view = (UIView *)[self.view viewWithTag:3268142];
    for(UIView *subview in view.subviews){
        [subview removeFromSuperview];
    }
    [view removeFromSuperview];
    view = nil;
}

- (void)pesentMyModalView:(UIViewController *)viewController
{
    [AppDelegate instance].triggeredByPlayer = YES;
    [self presentModalViewController:viewController animated:YES];
}

- (void)showDramaDownloadView:(NSString *)downloadingProdid video:(NSDictionary *)video
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
    view.tag = 3268142;
    [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    UIImageView *frame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"popup_bg"]];
    frame.frame = CGRectMake(0, 0, 477, 317);
    frame.center = CGPointMake(view.center.x, view.center.y);
    [view addSubview:frame];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 400, 40)];
    nameLabel.font = CMConstants.titleFont;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = [video objectForKey:@"name"];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.center = CGPointMake(frame.frame.size.width/2, 28);
    nameLabel.textColor = CMConstants.grayColor;
    [frame addSubview:nameLabel];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(699, 226, 50, 50);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(removeOverlay) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:closeBtn];
    
    NSArray *episodeArray = [video objectForKey:@"episodes"];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    episodeArray = [episodeArray sortedArrayUsingComparator:^(NSDictionary *a, NSDictionary *b) {
        NSNumber *first =  [f numberFromString:[NSString stringWithFormat:@"%@", [a objectForKey:@"name"]]];
        NSNumber *second = [f numberFromString:[NSString stringWithFormat:@"%@", [b objectForKey:@"name"]]];
        if (first && second) {
            return [first compare:second];
        } else {
            return NSOrderedSame;
        }
    }];
    dramaPageNum = ceil(episodeArray.count / 20.0);
    
    UIScrollView *pageView = [[UIScrollView alloc]initWithFrame:CGRectZero];
    pageView.tag = 74378420;
    [pageView setShowsHorizontalScrollIndicator:NO];
    pageView.scrollEnabled = YES;
    pageView.backgroundColor = [UIColor clearColor];
    [pageView setPagingEnabled:YES];
    pageView.frame = CGRectMake(295, 275, 430-4, 30);
    pageView.contentSize = CGSizeMake(pageView.frame.size.width*(dramaPageNum/6+1), pageView.frame.size.height);
    pageView.contentOffset = CGPointMake(0, 0);
    [view addSubview:pageView];

    for (int i = 0; i < dramaPageNum; i++) {
        UIButton *pageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        pageBtn.frame = CGRectMake(i * (63 + 8) + 1, 0, 63, 27);
        pageBtn.tag = 1001 + i;
        [pageBtn setTitle:[NSString stringWithFormat:@"%i-%i", i*20+1, (int)fmin((i+1)*20, episodeArray.count)] forState:UIControlStateNormal];
        if(i == 0){
            [pageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [pageBtn setBackgroundImage:[UIImage imageNamed:@"drama_pressed"] forState:UIControlStateNormal];
        } else {
            [pageBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
//            [pageBtn setBackgroundImage:[UIImage imageNamed:@"drama_tab"] forState:UIControlStateNormal];
        }
        [pageBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [pageBtn setBackgroundImage:[UIImage imageNamed:@"drama_pressed"] forState:UIControlStateHighlighted];
        [pageBtn addTarget:self action:@selector(pageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [pageView addSubview:pageBtn];
    }
    
    UIImageView *episodeViewBg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"episode_view_bg"]];
    episodeViewBg.frame = CGRectMake(0, 0, 437, 200);
    episodeViewBg.center = CGPointMake(view.center.x, view.center.y);
    [view addSubview:episodeViewBg];
    
    UIScrollView *episodeView = [[UIScrollView alloc]initWithFrame:CGRectMake(295, 310, 430, 190)];
    episodeView.tag = 3268143;
    episodeView.delegate = self;
    episodeView.scrollEnabled = YES;
    [episodeView setShowsHorizontalScrollIndicator:NO];
    episodeView.backgroundColor = [UIColor clearColor];
    [episodeView setPagingEnabled:YES];
    episodeView.contentSize = CGSizeMake(episodeView.frame.size.width*dramaPageNum, episodeView.frame.size.height);
    episodeView.contentOffset = CGPointMake(0, 0);
    [view addSubview:episodeView];
    
    episodeViewBg.center = episodeView.center;
    
    NSString *subquery = [NSString stringWithFormat:@"WHERE itemId = '%@'", downloadingProdid];
    NSArray *downloadingItems = [DatabaseManager findByCriteria:SubdownloadItem.class queryString:subquery];
    for (int i = 0; i < episodeArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i+1;
        int pageNum = floor(i/(EPISODE_NUMBER_IN_ROW*4.0));
        [btn setFrame:CGRectMake(6 + pageNum*episodeView.frame.size.width + (i % EPISODE_NUMBER_IN_ROW) * (72 + 15), 0 + floor((i%(EPISODE_NUMBER_IN_ROW*4))*1.0/ EPISODE_NUMBER_IN_ROW) * (44 + 5), 72, 44)];//65, 36
        NSString *name = [NSString stringWithFormat:@"%@", [[episodeArray objectAtIndex:i] objectForKey:@"name"]];
        [btn setTitle:name forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:18]];
        //btn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        [btn setBackgroundImage:[UIImage imageNamed:@"drama_download"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"drama_pressed"] forState:UIControlStateHighlighted];
        //[btn setBackgroundImage:[UIImage imageNamed:@"drama_disabled"] forState:UIControlStateDisabled];
        [btn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        if(![self checkDownloadStatus:episodeArray index:i])
        {
            [btn setEnabled:NO];
        }
        for (SubdownloadItem *subitem in downloadingItems)
        {
            if(subitem.subitemId.intValue == i+1){
                [btn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
                if (subitem.percentage == 100)
                {
                    [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 12, 0)];
                    [btn setBackgroundImage:[UIImage imageNamed:@"drama_download_choose"] forState:UIControlStateDisabled];
                }
                else
                {
                    [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
                    [btn setBackgroundImage:[UIImage imageNamed:@"drama_downloading_icon"] forState:UIControlStateDisabled];
                }
                
                [btn setEnabled:NO];
                break;
            }
        }
        [btn addTarget:self action:@selector(dramaDownload:)forControlEvents:UIControlEventTouchUpInside];
        [episodeView addSubview:btn];
    }    
    
    [self.view addSubview:view];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView; 
{
    if (scrollView.tag == 3268143) {
        int page = floor(scrollView.contentOffset.x/scrollView.frame.size.width);
        if (page >= 0 && page < dramaPageNum) {
            UIScrollView *episodeView = (UIScrollView *)[self.view viewWithTag:74378420];
            [episodeView setContentOffset:CGPointMake(floor(page/6.0) * episodeView.frame.size.width, 0) animated:YES];
            UIView *view = (UIView *)[self.view viewWithTag:3268142];
            UIButton *tabBtn = (UIButton *)[view viewWithTag:1001 + page];
            [self pageBtnClicked:tabBtn];
        }
    }
}

- (void)dramaDownload:(UIButton *)btn
{
   BOOL success = [self.videoDetailDelegate downloadDrama:btn.tag];
    if (success) {
        [btn setEnabled:NO];
        [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        [btn setBackgroundImage:[UIImage imageNamed:@"drama_downloading_icon"] forState:UIControlStateDisabled];
    }
}

- (void)nextBtnClicked:(UIButton *)btn
{
    UIView *view = (UIView *)[self.view viewWithTag:3268142];
    UIScrollView *episodeView = (UIScrollView *)[view viewWithTag:74378420];
    int tempPageNum = (episodeView.contentOffset.x / episodeView.frame.size.width);
    if (btn.tag == 84737481) {
        tempPageNum--;
    } else {
        tempPageNum++;
    }
    if (tempPageNum < 0) {
        tempPageNum = 0;
    } else if(tempPageNum >= dramaPageNum/7){
        tempPageNum = dramaPageNum/7;
    }
    [episodeView setContentOffset:CGPointMake(510*tempPageNum, 0) animated:YES]; ;
}

- (void)pageBtnClicked:(UIButton *)btn
{
    UIView *view = (UIView *)[self.view viewWithTag:3268142];
    for (int i = 0; i < dramaPageNum; i++) {
        UIButton *tabBtn = (UIButton *)[view viewWithTag:1001 + i];
        [tabBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
        [tabBtn setBackgroundImage:nil forState:UIControlStateNormal];
    }
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"drama_pressed"] forState:UIControlStateNormal];
    UIScrollView *episodeView = (UIScrollView *)[view viewWithTag:3268143];
    [episodeView setContentOffset:CGPointMake(episodeView.frame.size.width*(btn.tag - 1001), 0) animated:YES];
}

- (void)showShowDownloadView:(NSString *)downloadingProdid title:(NSString *)title episodeArray:(NSArray *)episodeArray
{
    showEpisodeCount = episodeArray.count;
    showPageNumber = 0;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
    view.tag = 3268142;
    [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    UIImageView *frame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"popup_bg"]];
    frame.frame = CGRectMake(0, 0, 484, 400);
    frame.center = CGPointMake(view.center.x, view.center.y);
    [view addSubview:frame];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 360, 40)];
    nameLabel.font = CMConstants.titleFont;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = title;
    nameLabel.textColor = [UIColor colorWithRed:138.0/255.0 green:138.0/255.0 blue:138.0/255.0 alpha:1];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.center = CGPointMake(frame.frame.size.width/2, 28);
    [frame addSubview:nameLabel];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(702, 255 - 70, 50, 50);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(removeOverlay) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:closeBtn];
    
    UIScrollView *showListView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 336.5, 308.5)];//370, 170)];
    showListView.tag = 3268143;
    showListView.scrollEnabled = NO;
    showListView.backgroundColor = [UIColor clearColor];
    [showListView setPagingEnabled:YES];
    showListView.center = CGPointMake(frame.center.x, frame.center.y + 10);
    showListView.contentSize = showListView.frame.size;
    showListView.contentOffset = CGPointMake(0, 0);
    [view addSubview:showListView];
    NSString *subquery = [NSString stringWithFormat:@"where itemId = %@", downloadingProdid];
    NSArray *downloadingItems = [DatabaseManager findByCriteria:SubdownloadItem.class queryString:subquery];
    UIButton *previousShowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [previousShowBtn setEnabled:NO];
    UIButton *nextShowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [view addSubview:previousShowBtn];
    [view addSubview:nextShowBtn];
    previousShowBtn.frame = CGRectMake(275,  330 - 90, 64, 308.5);
    nextShowBtn.frame = CGRectMake(275 + 336.5 + 74,  330 - 90, 64, 308.5);
    
    [previousShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_left"] forState:UIControlStateNormal];
    [previousShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_left_pressed"] forState:UIControlStateHighlighted];
    [previousShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_left_disabled"] forState:UIControlStateDisabled];
    [previousShowBtn addTarget:self action:@selector(nextShowBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    previousShowBtn.tag = 9001;
    
    [nextShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_right"] forState:UIControlStateNormal];
    [nextShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_right_pressed"] forState:UIControlStateHighlighted];
    [nextShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_right_disabled"] forState:UIControlStateDisabled];
    [nextShowBtn addTarget:self action:@selector(nextShowBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    nextShowBtn.tag = 9002;
        if(episodeArray.count > 5)
        {
            previousShowBtn.enabled = NO;
            nextShowBtn.enabled = YES;
            for (int i = 0; i < episodeArray.count; i++)
            {
                int pageNum = floor(i/5.0);
                NSDictionary *item = [episodeArray objectAtIndex:i];
                UIButton *nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                nameBtn.tag = i + 1;
                [nameBtn setFrame:CGRectMake(pageNum*showListView.frame.size.width, (i%5) * (54.5 + 6) + 6, showListView.frame.size.width, 54.5)];
                NSString *name = [NSString stringWithFormat:@"%@", [item objectForKey:@"name"]];
                if ([item objectForKey:@"name"] == nil) {
                    name = @"";
                }
//                if(name.length > 23){
//                    name = [name substringToIndex:23];
//                }
                [nameBtn setTitle:name forState:UIControlStateNormal];
                [nameBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 50)];
                [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show"] forState:UIControlStateNormal];
                [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show_pressed"] forState:UIControlStateHighlighted];
                nameBtn.titleLabel.font = [UIFont systemFontOfSize:14];
                nameBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                nameBtn.titleLabel.numberOfLines = 2;
                [nameBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateDisabled];
                [nameBtn setTitleColor:[UIColor colorWithRed:138.0/255.0 green:138.0/255.0 blue:138.0/255.0 alpha:1] forState:UIControlStateNormal];
                [nameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [nameBtn addTarget:self action:@selector(showBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                nameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                [nameBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
                if (![self checkDownloadStatus:episodeArray index:i]) {
                    [nameBtn setTitleColor:[UIColor colorWithRed:188.0/255.0 green:188.0/255.0 blue:188.0/255.0 alpha:1] forState:UIControlStateDisabled];
                    [nameBtn setEnabled:NO];
                }
                for (SubdownloadItem *subitem in downloadingItems) {
                    if([subitem.subitemId isEqualToString:[StringUtility md5:[NSString stringWithFormat:@"%@", [item objectForKey:@"name"]]]])
                    {
                        if (subitem.percentage == 100)
                        {
                            [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show_choose"] forState:UIControlStateDisabled];
                        }
                        else
                        {
                            [nameBtn setBackgroundImage:[UIImage imageNamed:@"show_downlioading_icon"] forState:UIControlStateDisabled];
                        }
                        [nameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        
                        [nameBtn setEnabled:NO];
                        break;
                    }
                }
                [showListView addSubview:nameBtn];
            }
        }
        else
        {
            previousShowBtn.enabled = NO;
            nextShowBtn.enabled = NO;
            for(int i = 0; i < episodeArray.count; i++){
                NSDictionary *item = [episodeArray objectAtIndex:i];
                UIButton *nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                nameBtn.tag = i + 1;
                nameBtn.frame = CGRectMake(0, i * (54.5 + 6) + 6, showListView.frame.size.width, 54.5);
                NSString *name = [NSString stringWithFormat:@"%@", [item objectForKey:@"name"]];
                if ([item objectForKey:@"name"] == nil) {
                    name = @"";
                }
//                if(name.length > 23){
//                    name = [name substringToIndex:23];
//                }
                [nameBtn setTitle:name forState:UIControlStateNormal];
                [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show"] forState:UIControlStateNormal];
                [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show_pressed"] forState:UIControlStateHighlighted];
                nameBtn.titleLabel.font = [UIFont systemFontOfSize:14];
                [nameBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateDisabled];
                [nameBtn setTitleColor:[UIColor colorWithRed:138.0/255.0 green:138.0/255.0 blue:138.0/255.0 alpha:1] forState:UIControlStateNormal];
                [nameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [nameBtn addTarget:self action:@selector(showBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                nameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                [nameBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
                if (![self checkDownloadStatus:episodeArray index:i]) {
                    [nameBtn setTitleColor:[UIColor colorWithRed:188.0/255.0 green:188.0/255.0 blue:188.0/255.0 alpha:1] forState:UIControlStateDisabled];
                    [nameBtn setEnabled:NO];
                }
                for (SubdownloadItem *subitem in downloadingItems) {
                    if([subitem.subitemId isEqualToString:[StringUtility md5:[NSString stringWithFormat:@"%@", [item objectForKey:@"name"]]]]){
                        [nameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        if (subitem.percentage == 100)
                        {
                            [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show_choose"] forState:UIControlStateDisabled];
                        }
                        else
                        {
                            [nameBtn setBackgroundImage:[UIImage imageNamed:@"show_downlioading_icon"] forState:UIControlStateDisabled];
                        }
                        [nameBtn setEnabled:NO];
                        break;
                    }
                }
                [showListView addSubview:nameBtn];
            }
        }
    
    [self.view addSubview:view];
}

- (BOOL)checkDownloadStatus:(NSArray *)episodeArray index:(int)index
{
    NSArray *videoUrlArray = [[episodeArray objectAtIndex:index] objectForKey:@"down_urls"];
    if(videoUrlArray.count > 0){
        for(NSDictionary *tempVideo in videoUrlArray){
            NSArray *urlArray =  [tempVideo objectForKey:@"urls"];
//            NSString *source =  [tempVideo objectForKey:@"source"];
            for(NSDictionary *url in urlArray){
                if([@"mp4" isEqualToString:[url objectForKey:@"file"]] || [@"m3u8" isEqualToString:[url objectForKey:@"file"]]){
                    NSString *videoUrl = [url objectForKey:@"url"];
                    NSString *formatUrl = [[videoUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
                    if([formatUrl hasPrefix:@"http://"] || [formatUrl hasPrefix:@"https://"]){
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

- (void)showBtnClicked:(UIButton *)btn
{
    btn.enabled = NO;
    BOOL success = [self.videoDetailDelegate downloadShow:btn.tag - 1];
    if(success){
        //[btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"show_downlioading_icon"] forState:UIControlStateDisabled];
    } else {
        [UIUtility showDownloadFailure:self.view];
    }
}

- (void)updatePageBtnState
{
    UIView *view = (UIView *)[self.view viewWithTag:3268142];
    UIButton *previousShowBtn = (UIButton *)[view viewWithTag:9001];
    UIButton *nextShowBtn = (UIButton *)[view viewWithTag:9002];
    if(showPageNumber > 0 && showPageNumber < ceil(showEpisodeCount / 5.0)-1){
        [previousShowBtn setEnabled:YES];
        [nextShowBtn setEnabled:YES];
    }
    if(showPageNumber == 0){
        [previousShowBtn setEnabled:NO];
        [nextShowBtn setEnabled:YES];
    }
    if(showPageNumber == ceil(showEpisodeCount / 5.0)-1){
        [previousShowBtn setEnabled:YES];
        [nextShowBtn setEnabled:NO];
    }
    if (showEpisodeCount <= 5)
    {
        [previousShowBtn setEnabled:NO];
        [nextShowBtn setEnabled:NO];
    }
}

- (void)nextShowBtnClicked:(UIButton *)btn
{
    if(btn.tag == 9001){
        showPageNumber --;
    } else{
        showPageNumber ++;
    }
    if(showPageNumber < 0){
        showPageNumber = 0;
    }
    if(showPageNumber > ceil(showEpisodeCount / 5.0)-1){
        showPageNumber = ceil(showEpisodeCount / 5.0)-1;
    }
    [self updatePageBtnState];
    UIView *view = (UIView *)[self.view viewWithTag:3268142];
    UIScrollView *showListView = (UIScrollView *)[view viewWithTag:3268143];
    [showListView setContentOffset:CGPointMake(336.5*showPageNumber, 0) animated:YES];
}

- (void)showIntroModalView:(NSString *)introScreenKey introImage:(UIImage *)introImage
{
    NSString *newKey = [NSString stringWithFormat:@"%@_%@", VERSION, introScreenKey];
    NSString *showMenuIntro = [NSString stringWithFormat:@"%@", [[ContainerUtility sharedInstance] attributeForKey:newKey]];
    if (![showMenuIntro isEqualToString:@"1"]) {
        [[ContainerUtility sharedInstance] setAttribute:@"1" forKey:newKey];
        UIView *view = [self.view viewWithTag:3268999];
        if (view == nil) {
            view = [[UIView alloc]initWithFrame:CGRectMake(0, -10, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width + 10)];
            view.tag = 3268999;
            [view setBackgroundColor:[UIColor clearColor]];
            UIImageView *temp = [[UIImageView alloc]initWithImage:introImage];
            temp.frame = view.frame;
            [view addSubview:temp];
            [self.view addSubview:view];
        }
        UITapGestureRecognizer *closeModalViewGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeIntroModalView)];
        closeModalViewGesture.numberOfTapsRequired = 1;
        [view addGestureRecognizer:closeModalViewGesture];
    }
}

- (void)showReportPopup:(NSString *)prodId
{
    if (checkboxes == nil) {
        checkboxes = [[NSMutableSet alloc]initWithCapacity:10];
    } else {
        [checkboxes removeAllObjects];
    }
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
    view.tag = 3268142;
    [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    [self.view addSubview:view];
    
    UIImageView *frame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"report_frame"]];
    frame.frame = CGRectMake(0, 0, 481, 481);
    frame.center = CGPointMake(view.center.x + 20, view.center.y - 80);
    [view addSubview:frame];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(720, 65, 50, 50);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(removeOverlay) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:closeBtn];
    
    for (int i = 0; i < 7; i++) {
        SSCheckBoxView *checkbox1 = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(0, 0, 40, 40) style:kSSCheckBoxViewStyleBox checked:NO];
        checkbox1.tag = 3301 + i;
        [checkbox1 setValue: [NSString stringWithFormat:@"%i", i+1]];
        checkbox1.center = CGPointMake(view.center.x + 200, 154 + 38 * i);
        [checkbox1 setStateChangedTarget:self selector:@selector(checkBoxViewChangedState:)];
        [view addSubview:checkbox1];
    }    
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.tag = 90847223;
    submitBtn.frame = CGRectMake(0, 0, 118, 70);
    submitBtn.center = CGPointMake(view.center.x + 20, view.center.y + 60);
    [submitBtn setBackgroundImage:[UIImage imageNamed:@"submit_btn"] forState:UIControlStateNormal];
    [submitBtn setBackgroundImage:[UIImage imageNamed:@"submit_btn_pressed"] forState:UIControlStateHighlighted];
    [submitBtn addTarget:self action:@selector(reportIssues) forControlEvents:UIControlEventTouchUpInside];
    [submitBtn setEnabled:NO];
    [view addSubview:submitBtn];
    
//    CustomTextField *textField = [[CustomTextField alloc] initWithFrame:CGRectMake(0, 0, 345, 26)];
//    textField.tag = 3234757301;
//    textField.delegate = self;
//    textField.center = CGPointMake(view.center.x + 40, view.center.y + 58);
//    textField.font = [UIFont systemFontOfSize:14];
//    textField.placeholder = @"请输入您对本部影片的意见和建议...";
//    [view addSubview:textField];
    
    UIButton * other = [UIButton buttonWithType:UIButtonTypeCustom];
    other.tag = 90847223;
    other.frame = CGRectMake(0, 0, 395, 47);
    other.center = CGPointMake(view.center.x + 20, view.center.y + 120);
    [other setBackgroundImage:[UIImage imageNamed:@"other_question"] forState:UIControlStateNormal];
    [other setBackgroundImage:[UIImage imageNamed:@"other_question_s"] forState:UIControlStateHighlighted];
    [other addTarget:self action:@selector(jumpToFeedbackOnline) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:other];
}

- (void)jumpToFeedbackOnline
{
    [self removeOverlay];
    
    [menuViewController tableViewSelectIndexPath:[NSIndexPath indexPathForRow:11 inSection:0]];
}

- (void)reportIssues
{
    UIView *view = (UIView *)[self.view viewWithTag:3268142];
    CustomTextField *textField = (CustomTextField *)[view viewWithTag:3234757301];
    NSString *advice = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableString *reasons = [[NSMutableString alloc]init];
    for(NSString *reason in checkboxes){
        [reasons appendFormat:@"%@,", reason];
    }
    NSString *reaonsStr;
    if(reasons.length > 0){
        reaonsStr = [reasons substringToIndex:reasons.length - 1];
    }
    if (advice.length > 0) {
        if (reaonsStr.length > 0) {
            reaonsStr = [reaonsStr stringByAppendingString:@",8"];
        } else {
            reaonsStr = @"8";
        }
    }
    if(reaonsStr.length > 0 || advice.length > 0) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: reaonsStr, @"invalid_type", prodId, @"prod_id", prodName, @"prod_name", prodType, @"prod_type", advice, @"memo", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathProgramInvalid parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        }];
        [self removeOverlay];
        [self showSuccessModalView:1.5];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UIView *view = (UIView *)[self.view viewWithTag:3268142];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y - 200, view.frame.size.width, view.frame.size.height);
    } completion:^(BOOL finished) {        
        [self enabledSubmitBtn];
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UIView *view = (UIView *)[self.view viewWithTag:3268142];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + 200, view.frame.size.width, view.frame.size.height);
    } completion:^(BOOL finished) {
        [self enabledSubmitBtn];        
    }];
}

- (void)contentTextFieldChanged:(NSNotification *)notification
{
     [self enabledSubmitBtn];
}

- (void) checkBoxViewChangedState:(SSCheckBoxView *)cbv
{
    if(cbv.checked){
        if(![checkboxes containsObject:[cbv value]]){
            [checkboxes addObject:[cbv value]];
        }
    } else {
        if([checkboxes containsObject:[cbv value]]){
            [checkboxes removeObject:[cbv value]];
        }
    }
    [self enabledSubmitBtn];
}

- (void)enabledSubmitBtn
{
    UIView *view = (UIView *)[self.view viewWithTag:3268142];
    UIButton *submitBtn = (UIButton *)[view viewWithTag:90847223];
    CustomTextField *textField = (CustomTextField *)[view viewWithTag:3234757301];
    NSString *advice = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (advice.length > 0 || checkboxes.count > 0) {
        [submitBtn setEnabled:YES];
    } else{
        [submitBtn setEnabled:NO];
    }

}

- (void)removeIntroModalView
{
    UIView *modalView = (UIView *)[self.view viewWithTag:3268999];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        for (UIView *subview in modalView.subviews) {
            [subview setAlpha:0];
        }
        [modalView setAlpha:0];
    } completion:^(BOOL finished) {
        [modalView removeFromSuperview];
    }];
}

- (void)showModalView:(UIImage *)image closeTime:(int)closeTime
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
    view.tag = 3268142;
    [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    UIImageView *temp = [[UIImageView alloc]initWithImage:image];
    temp.frame = CGRectMake(0, 0, 324, 191);
    temp.center = view.center;
    [view addSubview:temp];
    [self.view addSubview:view];
    [NSTimer scheduledTimerWithTimeInterval:closeTime target:self selector:@selector(removeOverlay) userInfo:nil repeats:NO];
}
@end
