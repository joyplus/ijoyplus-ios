//
//  ProgramView.m
//  ijoyplus
//
//  Created by joyplus1 on 12-10-22.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ProgramView.h"

@interface ProgramView (){
    UIActivityIndicatorView *indicatorView;
	UIWebView *webView;
}

@end

@implementation ProgramView

- (id)initWithUrl:(NSString *)url
{
    self = [super init];
    if (self) {
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        [webView setDelegate:self];
        [webView setBackgroundColor:[UIColor whiteColor]];
        //    [self hideGradientBackground:webView];
        //    self.webView.delegate = self;
        
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        [webView setScalesPageToFit:YES];
        [self addSubview:webView];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicatorView setCenter:CGPointMake(160, 240)];
        [self addSubview:indicatorView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
	[indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	[indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    [indicatorView stopAnimating];
}

@end
