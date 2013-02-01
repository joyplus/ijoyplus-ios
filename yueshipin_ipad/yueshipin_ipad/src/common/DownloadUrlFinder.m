//
//  DownloadManager.m
//  yueshipin
//
//  Created by joyplus1 on 13-1-31.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "DownloadUrlFinder.h"
#import "CMConstants.h"
#import "AppDelegate.h"

@interface DownloadUrlFinder ()<NSURLConnectionDelegate>


@property (atomic, strong)NSString *workingUrl;
@property (atomic)int urlIndex;

@end

@implementation DownloadUrlFinder
@synthesize workingUrl;
@synthesize urlIndex;
@synthesize item;

- (void)setupWorkingUrl
{
    if (urlIndex >= 0 && urlIndex < item.urlArray.count) {
        NSString *tempUrl = [item.urlArray objectAtIndex:urlIndex];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:tempUrl]];
        [NSURLConnection connectionWithRequest:request delegate:self];
    } else {
        item.downloadStatus = @"error";
    }
}

- (void)connection:(NSURLConnection *)aconnection didReceiveResponse:(NSURLResponse *)response
{
    @synchronized(workingUrl){
        if(workingUrl == nil){
            NSDictionary *headerFields = [(NSHTTPURLResponse *)response allHeaderFields];
            NSString *contentLength = [NSString stringWithFormat:@"%@", [headerFields objectForKey:@"Content-Length"]];
            NSString *contentType = [NSString stringWithFormat:@"%@", [headerFields objectForKey:@"Content-Type"]];
            if (contentLength.intValue > 100 && ![contentType hasPrefix:@"text/html"]) {
                item.url = [item.urlArray objectAtIndex:urlIndex];
                [item save];
                [[AppDelegate instance].downloadManager startDownloadingThreads];
            } else {
                urlIndex++;
                [self setupWorkingUrl];
            }
        } 
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    urlIndex++;
    [self setupWorkingUrl];
}

@end
