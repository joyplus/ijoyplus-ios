//
//  SinaOAuthViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-21.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SinaOAuthViewController.h"

@interface SinaOAuthViewController (){
    UIActivityIndicatorView *spin;
    NSString *access_token;
    NSString *uid;

}
@property (strong, nonatomic) IBOutlet UIWebView *authWebView;

-(void)reload;
@end

@implementation SinaOAuthViewController
@synthesize authWebView;

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
    [self.authWebView setDelegate:self];
    spin=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spin.color=[UIColor darkGrayColor];
    spin.center=CGPointMake(160, 200);
    [self.view addSubview:spin];
    [self reload];
}

-(void)reload
{
    [spin startAnimating];
    NSURL *url=[[NSURL alloc]initWithString:@"https://api.weibo.com/oauth2/authorize?client_id=2512079807&response_type=token&redirect_uri=https://api.weibo.com/oauth2/default.html&display=mobile"];
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:url];
    [self.authWebView loadRequest:request];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [spin stopAnimating];
    NSString *geturl=webView.request.URL.absoluteString;   
    NSRange tokenrange=NSMakeRange(55, 32);
    access_token=[geturl substringWithRange:tokenrange];
    if ([access_token characterAtIndex:1]=='.') {
        NSRange range=[geturl rangeOfString:@"uid"];
        uid=[geturl substringWithRange:NSMakeRange(range.location+4,10)];
        NSLog(@"access_token = %@; uid = %@", access_token, uid);
    }
}


- (void)viewDidUnload
{
    [self setAuthWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
