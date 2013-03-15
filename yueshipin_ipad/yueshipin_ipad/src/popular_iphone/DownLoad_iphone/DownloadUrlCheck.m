//
//  DownloadUrlCheck.m
//  yueshipin
//
//  Created by 08 on 13-3-15.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "DownloadUrlCheck.h"

@implementation DownloadUrlCheck
@synthesize infoArr = infoArr_;

-(void)checkDownloadUrl{
    NSString *urlStr = [infoArr_ objectAtIndex:1];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"iphoneAvplayerViewController didFailWithError:%@",error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"连接服务器失败" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    int status_Code = HTTPResponse.statusCode;
    if (status_Code >= 200 && status_Code <= 299) {
        NSDictionary *headerFields = [HTTPResponse allHeaderFields];
        NSString *content_type = [NSString stringWithFormat:@"%@", [headerFields objectForKey:@"Content-Type"]];
        if (![content_type hasPrefix:@"text/html"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DOWNLOAD_MSG" object:infoArr_];
            [connection cancel];
            return;
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"下载地址失效" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
            [alert show];
        
        }
        
    }
    else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"下载地址失效" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alert show];
    
    }
}
@end
