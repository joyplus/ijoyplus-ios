//
//  DownloadHandler.m
//  yueshipin
//
//  Created by joyplus1 on 12-12-27.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "DownloadHandler.h"
#import "AppDelegate.h"

@implementation DownloadHandler

@synthesize downloadUrls;
@synthesize item;

- (void)main
{
//    BOOL added = NO;
//    for (NSString *urlstr in self.downloadUrls) {
//        NSLog(@"%@", urlstr);
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self.downloadUrls objectAtIndex:0]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:1];
//        NSError *error = nil;
//        NSURLResponse *theResponse = nil;
//        NSURLConnection *connectiton = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:YES];
//        [connectiton start];
//        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&error];
//        if (error == nil && data != nil) {
//            added = YES;
//            self.item.url = urlstr;
//            [item save];
//            [[AppDelegate instance] addToDownloaderArray:item];
//        }
//    }
//    if(!added){
//        self.item.url = nil;
//        [self.item save];
//        [[AppDelegate instance] addToDownloaderArray:item];
//    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%@", response);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

@end
