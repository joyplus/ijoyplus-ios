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
#import "DatabaseManager.h"

@interface DownloadUrlFinder ()<NSURLConnectionDelegate>

@property (atomic, strong)NSString *workingUrl;
@property (atomic)int urlIndex;

@end

@implementation DownloadUrlFinder
@synthesize workingUrl;
@synthesize urlIndex;
@synthesize item;
@synthesize mp4DownloadUrlNum;

- (id)init
{
    self = [super init];
    if (self) {
        urlIndex = 0;
        mp4DownloadUrlNum = 0;
    }
    return self;
}

- (void)setupWorkingUrl
{
    if (urlIndex >= 0 && urlIndex < item.urlArray.count) {
        if (urlIndex >= mp4DownloadUrlNum && [item.downloadType isEqualToString:@"mp4"]) {
            item.downloadType = @"m3u8";
            [DatabaseManager update:item];
        }
        NSString *tempUrl = [item.urlArray objectAtIndex:urlIndex];
        NSString *formattedUrl = tempUrl;
        if([tempUrl rangeOfString:@"{now_date}"].location != NSNotFound){
            int nowDate = [[NSDate date] timeIntervalSince1970];
            formattedUrl = [tempUrl stringByReplacingOccurrencesOfString:@"{now_date}" withString:[NSString stringWithFormat:@"%i", nowDate]];
        }
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:formattedUrl]];
        [NSURLConnection connectionWithRequest:request delegate:self];
    } else {
        NSLog(@"no download url");
        item.downloadStatus = @"error";
        [DatabaseManager update:item];
    }
}

- (void)connection:(NSURLConnection *)aconnection didReceiveResponse:(NSURLResponse *)response
{
    @synchronized(workingUrl){
        if(workingUrl == nil){
            NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
            NSDictionary *headerFields = [(NSHTTPURLResponse *)response allHeaderFields];
            NSString *contentLength = [NSString stringWithFormat:@"%@", [headerFields objectForKey:@"Content-Length"]];
            NSString *contentType = [NSString stringWithFormat:@"%@", [headerFields objectForKey:@"Content-Type"]];
            int status_Code = HTTPResponse.statusCode;
            
            if (status_Code >= 200
                && status_Code <= 299)
            {
                NSString * source = self.item.downloadURLSource;
                NSString * fileType = self.item.downloadType;
                if (([source isEqualToString:@"sohu"] && ([fileType isEqualToString:@"m3u8"] || [fileType isEqualToString:@"m3u"]))
                    || (![contentType hasPrefix:@"text/html"]&& contentLength.intValue > 100))
                {
                    workingUrl = aconnection.originalRequest.URL.absoluteString;
                    NSLog(@"working url = %@", workingUrl);
                    item.url = workingUrl;
                    [DatabaseManager update:item];
                    [[AppDelegate instance].padDownloadManager startDownloadingThreads];
                }
                else
                {
                    urlIndex++;
                    [self setupWorkingUrl];
                }
            }
            else
            {
                urlIndex++;
                [self setupWorkingUrl];
            }
        }
        [aconnection cancel];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    urlIndex++;
    [connection cancel];
    [self setupWorkingUrl];
}

@end
