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

@interface UIViewExt : UIView {
}

@end

@implementation UIViewExt

- (UIView *) hitTest: (CGPoint) pt withEvent: (UIEvent *) event 
{   
	UIView* viewToReturn=nil;
	CGPoint pointToReturn;
	UIView* uiRightView = (UIView*)[[self subviews] objectAtIndex:1];
	
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
	[rootView setBackgroundColor:[UIColor redColor]];
	
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
	[self.view setBackgroundColor:[UIColor colorWithPatternImage: [UIImage imageNamed:@"backgroundImage_repeat.png"]]];
	[self.view addSubview:rootView];
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
    frame.center = CGPointMake(view.center.x, view.center.y - 20);
    [view addSubview:frame];
    
    UIImageView *sina = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sina_btn_pressed"]];
    sina.frame = CGRectMake(25, 206, 33, 33);
    [frame addSubview:sina];
    
    UIImageView *tempMovieImage = [[UIImageView alloc]initWithFrame:CGRectMake(270, 460, 114, 162)];
    tempMovieImage.frame = CGRectMake(408, 73, 113, 170);
    [tempMovieImage setImageWithURL:[NSURL URLWithString:self.prodUrl] placeholderImage:[UIImage imageNamed:@""]];
    [frame addSubview:tempMovieImage];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(735, 240, 40, 42);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(removeOverlay) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:closeBtn];
    
    shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(555, 440, 80, 32);
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"share_btn_disabled"] forState:UIControlStateNormal];
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"share_btn_disabled"] forState:UIControlStateHighlighted];
    [shareBtn addTarget:self action:@selector(sendWeibo) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:shareBtn];
    
    contentTextView = [[UITextView alloc]initWithFrame:CGRectMake(270, 310, 360, 110)];
    contentTextView.delegate = self;
    [view addSubview:contentTextView];
    [self.view addSubview:view];
}


- (void)showCommentPopup
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
    view.tag = 3268142;
    [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    UIImageView *frame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"comment_frame"]];
    frame.frame = CGRectMake(0, 0, 424, 265);
    frame.center = CGPointMake(view.center.x, view.center.y - 20);
    [view addSubview:frame];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(675, 240, 40, 42);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(removeOverlay) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:closeBtn];
    
    sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(615, 440, 80, 32);
    [sendBtn setBackgroundImage:[UIImage imageNamed:@"send_btn_disabled"] forState:UIControlStateNormal];
    [sendBtn setBackgroundImage:[UIImage imageNamed:@"send_btn_disabled"] forState:UIControlStateHighlighted];
    [sendBtn addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:sendBtn];
    
    contentTextView = [[UITextView alloc]initWithFrame:CGRectMake(330, 310, 360, 110)];
    contentTextView.delegate = self;
    [view addSubview:contentTextView];
    [self.view addSubview:view];
}

- (void)sendComment{
    if(contentTextView.text.length > 0){
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:self.prodId, @"prod_id", contentTextView.text, @"content", [StringUtility createUUID], @"token", nil];
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

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self changeSendBtnImage:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self changeSendBtnImage:textView];
}

- (void)changeSendBtnImage:(UITextView *)textView
{
    if(textView.text.length > 0){
        [shareBtn setBackgroundImage:[UIImage imageNamed:@"share_btn"] forState:UIControlStateNormal];
        [shareBtn setBackgroundImage:[UIImage imageNamed:@"share_btn_pressed"] forState:UIControlStateHighlighted];
        [sendBtn setBackgroundImage:[UIImage imageNamed:@"send_btn"] forState:UIControlStateNormal];
        [sendBtn setBackgroundImage:[UIImage imageNamed:@"send_btn_pressed"] forState:UIControlStateHighlighted];
    } else {
        [shareBtn setBackgroundImage:[UIImage imageNamed:@"share_btn_disabled"] forState:UIControlStateNormal];
        [shareBtn setBackgroundImage:[UIImage imageNamed:@"share_btn_disabled"] forState:UIControlStateHighlighted];
        [sendBtn setBackgroundImage:[UIImage imageNamed:@"send_btn_disabled"] forState:UIControlStateNormal];
        [sendBtn setBackgroundImage:[UIImage imageNamed:@"send_btn_disabled"] forState:UIControlStateHighlighted];
        
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
    [self presentModalViewController:viewController animated:YES];
}

@end
