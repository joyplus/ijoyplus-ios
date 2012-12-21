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

#define EPISODE_NUMBER_IN_ROW 10

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

@implementation RootViewController
@synthesize menuViewController, stackScrollViewController;
@synthesize prodUrl, prodId, prodName;
@synthesize videoDetailDelegate;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
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
    
    UIImageView *bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background"]];
    bgImageView.frame = CGRectMake(rootView.frame.origin.x, rootView.frame.origin.y-2, rootView.frame.size.width, 750);
    [rootView addSubview:bgImageView];
	
	leftMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height/2, self.view.frame.size.height)];
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[menuViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[stackScrollViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[menuViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[stackScrollViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)showSuccessModalView:(int)closeTime
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
    view.tag = 3268142;
    [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    UIImageView *temp = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"success_img"]];
    temp.frame = CGRectMake(0, 0, 324, 191);
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
    temp.frame = CGRectMake(0, 0, 324, 191);
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
    temp.frame = CGRectMake(0, 0, 324, 191);
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
    closeBtn.frame = CGRectMake(735, 80, 40, 42);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(removeOverlay) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:closeBtn];
    
    shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(555, 280, 80, 32);
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"share_btn_disabled"] forState:UIControlStateDisabled];
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"share_btn"] forState:UIControlStateNormal];
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"share_btn_pressed"] forState:UIControlStateHighlighted];
    [shareBtn setEnabled:NO];
    [shareBtn addTarget:self action:@selector(sendWeibo) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:shareBtn];
    
    contentTextView = [[UITextView alloc]initWithFrame:CGRectMake(270, 150, 360, 110)];
    contentTextView.font = [UIFont systemFontOfSize:14];
    contentTextView.delegate = self;
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
    closeBtn.frame = CGRectMake(675, 80, 40, 42);
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
        NSString *content = [NSString stringWithFormat:@"#%@# %@", self.prodName, contentTextView.text];
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

- (void)showDramaDownloadView:(NSString *)downloadingProdid title:(NSString *)title totalNumber:(int)totalNumber
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
    view.tag = 3268142;
    [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    UIImageView *frame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"popup_bg"]];
    frame.frame = CGRectMake(0, 0, 580, 265);
    frame.center = CGPointMake(view.center.x, view.center.y);
    [view addSubview:frame];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 500, 40)];
    nameLabel.font = CMConstants.titleFont;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = title;
    [nameLabel sizeToFit];
    nameLabel.center = CGPointMake(frame.frame.size.width/2, 40);
    [frame addSubview:nameLabel];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(755, 258, 40, 42);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(removeOverlay) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:closeBtn];
    
    dramaPageNum = ceil(totalNumber / 30.0);
    for (int i = 0; i < dramaPageNum; i++) {
        UIButton *pageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        pageBtn.frame = CGRectMake(255 + i * (61 + 10), 320, 61, 27);
        pageBtn.tag = 1001 + i;
        [pageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [pageBtn setTitle:[NSString stringWithFormat:@"%i-%i", i*30+1, (int)fmin((i+1)*30, totalNumber)] forState:UIControlStateNormal];
        if(i == 0){
            [pageBtn setBackgroundImage:[UIImage imageNamed:@"drama_tab_pressed"] forState:UIControlStateNormal];
        } else {
            [pageBtn setBackgroundImage:[UIImage imageNamed:@"drama_tab"] forState:UIControlStateNormal];
        }
        [pageBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [pageBtn setBackgroundImage:[UIImage imageNamed:@"drama_tab_pressed"] forState:UIControlStateHighlighted];
        [pageBtn addTarget:self action:@selector(pageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:pageBtn];
    }
    
    UIScrollView *episodeView = [[UIScrollView alloc]initWithFrame:CGRectZero];
    episodeView.tag = 3268143;
    episodeView.scrollEnabled = NO;
    episodeView.backgroundColor = [UIColor clearColor];
    [episodeView setPagingEnabled:YES];
    episodeView.frame = CGRectMake(255, 360, 520, 200);
    episodeView.contentSize = CGSizeMake(520*dramaPageNum, episodeView.frame.size.height);
    episodeView.contentOffset = CGPointMake(0, 0);
    [view addSubview:episodeView];
    
    NSString *subquery = [NSString stringWithFormat:@"WHERE item_id = '%@'", downloadingProdid];
    NSArray *downloadingItems = [SubdownloadItem findByCriteria:subquery];
    for (int i = 0; i < totalNumber; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i+1;
        int pageNum = floor(i/(EPISODE_NUMBER_IN_ROW*3.0));
        [btn setFrame:CGRectMake(pageNum*520 + (i % EPISODE_NUMBER_IN_ROW) * 52, floor((i%(EPISODE_NUMBER_IN_ROW*3))*1.0/ EPISODE_NUMBER_IN_ROW) * 39, 47, 38)];
        if (i < EPISODE_NUMBER_IN_ROW-1) {
            [btn setTitle:[NSString stringWithFormat:@"0%i", i+1] forState:UIControlStateNormal];
        } else {
            [btn setTitle:[NSString stringWithFormat:@"%i", i+1] forState:UIControlStateNormal];
        }
        [btn.titleLabel setFont:[UIFont systemFontOfSize:18]];
        btn.contentEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
        btn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        [btn setBackgroundImage:[UIImage imageNamed:@"drama_download"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"drama_download_choose"] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        for (SubdownloadItem *subitem in downloadingItems) {
            if(subitem.subitemId.intValue == i+1){
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"drama_download_choose"] forState:UIControlStateNormal];
                break;
            }
        }
        [btn addTarget:self action:@selector(dramaDownload:)forControlEvents:UIControlEventTouchUpInside];
        [episodeView addSubview:btn];
    }    
    
    [self.view addSubview:view];
}

- (void)dramaDownload:(UIButton *)btn
{
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"drama_download_choose"] forState:UIControlStateNormal];
    [self.videoDetailDelegate downloadDrama:btn.tag];
}

- (void)pageBtnClicked:(UIButton *)btn
{
    UIView *view = (UIView *)[self.view viewWithTag:3268142];
    for (int i = 0; i < dramaPageNum; i++) {
        UIButton *tabBtn = (UIButton *)[view viewWithTag:1001 + i];
        [tabBtn setBackgroundImage:[UIImage imageNamed:@"drama_tab"] forState:UIControlStateNormal];
    }
    [btn setBackgroundImage:[UIImage imageNamed:@"drama_tab_pressed"] forState:UIControlStateNormal];

    UIScrollView *episodeView = (UIScrollView *)[view viewWithTag:3268143];
    [episodeView setContentOffset:CGPointMake(520*(btn.tag - 1001), 0)];
}

- (void)showShowDownloadView:(NSString *)title episodeArray:(NSArray *)episodeArray
{
    showEpisodeCount = episodeArray.count;
    showPageNumber = 0;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
    view.tag = 3268142;
    [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    UIImageView *frame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"popup_bg"]];
    frame.frame = CGRectMake(0, 0, 484, 250);
    frame.center = CGPointMake(view.center.x, view.center.y);
    [view addSubview:frame];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 460, 40)];
    nameLabel.font = CMConstants.titleFont;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = title;
    [nameLabel sizeToFit];
    nameLabel.center = CGPointMake(frame.frame.size.width/2, 40);
    [frame addSubview:nameLabel];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(708, 265, 40, 42);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(removeOverlay) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:closeBtn];
    
    UIScrollView *showListView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 370, 170)];
    showListView.tag = 3268143;
    showListView.scrollEnabled = NO;
    showListView.backgroundColor = [UIColor clearColor];
    [showListView setPagingEnabled:YES];
    showListView.center = CGPointMake(frame.center.x, frame.center.y + 30);
    showListView.contentSize = showListView.frame.size;
    showListView.contentOffset = CGPointMake(0, 0);
    [view addSubview:showListView];    
        if(episodeArray.count > 5){
            UIButton *previousShowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [previousShowBtn setEnabled:NO];
            UIButton *nextShowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [view addSubview:previousShowBtn];
            [view addSubview:nextShowBtn];
            previousShowBtn.frame = CGRectMake(290,  330, 32, 161);
            nextShowBtn.frame = CGRectMake(290 + 370 + 45,  330, 32, 161);
            
            [previousShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_left"] forState:UIControlStateNormal];
            [previousShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_left_pressed"] forState:UIControlStateHighlighted];
            [previousShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_left_disable"] forState:UIControlStateDisabled];
            [previousShowBtn addTarget:self action:@selector(nextShowBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            previousShowBtn.tag = 9001;
            
            [nextShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_right"] forState:UIControlStateNormal];
            [nextShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_right_pressed"] forState:UIControlStateHighlighted];
            [nextShowBtn setBackgroundImage:[UIImage imageNamed:@"tab_right_disable"] forState:UIControlStateDisabled];
            [nextShowBtn addTarget:self action:@selector(nextShowBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            nextShowBtn.tag = 9002;
            for (int i = 0; i < episodeArray.count; i++) {
                int pageNum = floor(i/5.0);
                NSDictionary *item = [episodeArray objectAtIndex:i];
                UIButton *nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                nameBtn.tag = i + 1;
                [nameBtn setFrame:CGRectMake(pageNum*showListView.frame.size.width, (i%5) * 32, showListView.frame.size.width, 30)];
                NSString *name = [NSString stringWithFormat:@"%@", [item objectForKey:@"name"]];
                if ([item objectForKey:@"name"] == nil) {
                    name = @"";
                }
                if(name.length > 23){
                    name = [name substringToIndex:23];
                }
                [nameBtn setTitle:name forState:UIControlStateNormal];
                [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show"] forState:UIControlStateNormal];
                [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show_choose"] forState:UIControlStateHighlighted];
                nameBtn.titleLabel.font = [UIFont systemFontOfSize:14];
                [nameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [nameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [nameBtn addTarget:self action:@selector(showBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                nameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                [nameBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
                [showListView addSubview:nameBtn];
            }
        } else {
            for(int i = 0; i < episodeArray.count; i++){
                NSDictionary *item = [episodeArray objectAtIndex:i];
                UIButton *nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                nameBtn.tag = i + 1;
                nameBtn.frame = CGRectMake(0, i * 32, showListView.frame.size.width, 30);
                NSString *name = [NSString stringWithFormat:@"%@", [item objectForKey:@"name"]];
                if ([item objectForKey:@"name"] == nil) {
                    name = @"";
                }
                if(name.length > 23){
                    name = [name substringToIndex:23];
                }
                [nameBtn setTitle:name forState:UIControlStateNormal];
                [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show"] forState:UIControlStateNormal];
                [nameBtn setBackgroundImage:[UIImage imageNamed:@"tab_show_choose"] forState:UIControlStateHighlighted];
                nameBtn.titleLabel.font = [UIFont systemFontOfSize:14];
                [nameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [nameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [nameBtn addTarget:self action:@selector(showBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                nameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                [nameBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
                [showListView addSubview:nameBtn];
            }
        }
    
    [self.view addSubview:view];
}

- (void)showBtnClicked:(UIButton *)btn
{
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"tab_show_choose"] forState:UIControlStateNormal];
    [self.videoDetailDelegate downloadDrama:btn.tag - 1];
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
    }
    if(showPageNumber == ceil(showEpisodeCount / 5.0)-1){
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
    [showListView setContentOffset:CGPointMake(370*showPageNumber, 0) animated:YES];
}
@end
