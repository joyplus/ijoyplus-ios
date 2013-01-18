//
//  McDownload.m
//  McDownload
//
//  Created by Hao Tan on 11-11-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "McDownload.h"

#define kTHDownLoadTask_TempSuffix  @".TempDownload"

@interface McDownload () <NSURLConnectionDelegate>

@property (atomic)int errorNum;
@property (nonatomic, strong)NSLock *theLock;
@end

@implementation McDownload
@synthesize idNum;
@synthesize subidNum;
@synthesize status;
@synthesize delegate;
@synthesize overwrite;
@synthesize url;
@synthesize fileName;
@synthesize filePath;
@synthesize fileSize;
@synthesize downloadItem;
@synthesize errorNum;
@synthesize theLock;

- (void)start
{   
    //    //未指定文件名
    //    if (!fileName)
    //    {
    //        NSString *urlStr = [url absoluteString];
    //        fileName = [urlStr lastPathComponent];
    //        if ([fileName length] > 32) fileName = [fileName substringFromIndex:[fileName length]-32];
    //    }
    
    //未指定路径
    if (!filePath){
        NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [documentPaths objectAtIndex:0];
        filePath = documentsDir;
    }
    
    
    //目标地址与缓存地址
    destinationPath=[filePath stringByAppendingPathComponent:fileName];
	temporaryPath=[destinationPath stringByAppendingFormat:kTHDownLoadTask_TempSuffix];
    
    //处理如果文件已经存在的情况
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]){
        if (overwrite){
            [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:nil];
        }else{
            if ([delegate respondsToSelector:@selector(downloadProgressChange:progress:)])
                [delegate downloadProgressChange:self progress:1.0];
            if ([delegate respondsToSelector:@selector(downloadFinished:)])
                [delegate downloadFinished:self];
            return;
        }
    }
    
    //缓存文件不存在，则创建缓存文件
    if (![[NSFileManager defaultManager] fileExistsAtPath:temporaryPath]){
        BOOL createSucces = [[NSFileManager defaultManager] createFileAtPath:temporaryPath contents:nil attributes:nil];
        if (!createSucces){
            if ([delegate respondsToSelector:@selector(downloadFaild:didFailWithError:)]){
                NSError *error = [NSError errorWithDomain:@"Temporary File can not be create!" code:111 userInfo:nil];
                [delegate downloadFaild:self didFailWithError:error];
            }
            return;
        }
    }
    
    //设置fileHandle
    [fileHandle closeFile];
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:temporaryPath];
    offset = [fileHandle seekToEndOfFile];
    NSString *range = [NSString stringWithFormat:@"bytes=%llu-",offset];
    
    //设置下载的一些属性
    if(url){
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request addValue:range forHTTPHeaderField:@"Range"];
        [connection cancel];
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    } else {
        for (NSString *tempUrl in downloadItem.urlArray) {
            int nowDate = [[NSDate date] timeIntervalSince1970];
            NSString *formattedUrl = tempUrl;
            if([tempUrl rangeOfString:@"{now_date}"].location != NSNotFound){
                formattedUrl = [tempUrl stringByReplacingOccurrencesOfString:@"{now_date}" withString:[NSString stringWithFormat:@"%i", nowDate]];
            }
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:formattedUrl]];
            [request addValue:range forHTTPHeaderField:@"Range"];
            [NSURLConnection connectionWithRequest:request delegate:self];
        }
    }
}

- (void)stop
{
    [connection cancel];
    connection = nil;
    [fileHandle closeFile];
    fileHandle = nil;
}

- (void)stopAndClear
{
    [self stop];
    [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:temporaryPath error:nil];
    
    if ([delegate respondsToSelector:@selector(downloadProgressChange:progress:)]){
        [delegate downloadProgressChange:self progress:0];
    }
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)aconnection didReceiveResponse:(NSURLResponse *)response
{
    @synchronized(url){
        if(url == nil){
            NSDictionary *headerFields = [(NSHTTPURLResponse *)response allHeaderFields];
            NSString *contentLength = [NSString stringWithFormat:@"%@", [headerFields objectForKey:@"Content-Length"]];
            if (contentLength.intValue > 100) {
                NSLog(@"download url = %@", aconnection.originalRequest.URL);
                connection = aconnection;
                url = aconnection.originalRequest.URL;
                downloadItem.url = url.absoluteString;
                [downloadItem save];
                [self proceedDownloading:response];
            } else {
                [self checkIfAllError:nil];
            }
        } else {
            if(downloadItem.urlArray.count > 1){
                [aconnection cancel];
            } else {
                [self proceedDownloading:response];
            }
        }
    }
}

- (void)proceedDownloading:(NSURLResponse *)response
{
    if ([response expectedContentLength] != NSURLResponseUnknownLength){
        fileSize = (unsigned long long)[response expectedContentLength]+offset;
    }
    if ([delegate respondsToSelector:@selector(downloadBegin:didReceiveResponseHeaders:)]){
        [delegate downloadBegin:self didReceiveResponseHeaders:response];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)aData
{
    if (url) {
        [fileHandle writeData:aData];
        offset = [fileHandle offsetInFile];
        
        if ([delegate respondsToSelector:@selector(downloadProgressChange:progress:)]){
            double progress = offset*1.0/fileSize;
            [delegate downloadProgressChange:self progress:progress];
        }
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self checkIfAllError:error];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (url) {
        [fileHandle closeFile];
        [[NSFileManager defaultManager] moveItemAtPath:temporaryPath toPath:destinationPath error:nil];
        if ([delegate respondsToSelector:@selector(downloadFinished:)]) {
            [delegate downloadFinished:self];
        }
    }
}

- (void)checkIfAllError:(NSError *)error
{
    [theLock lock];
    errorNum++;
    if (errorNum == downloadItem.urlArray.count || downloadItem.urlArray.count == 1) {
        [fileHandle closeFile];
        if ([delegate respondsToSelector:@selector(downloadFaild:didFailWithError:)])
        {
            if(error == nil){
                downloadItem.downloadStatus = @"error938";
            } else {
                downloadItem.downloadStatus = @"error";
            }
            [downloadItem save];
            [delegate downloadFaild:self didFailWithError:error];
        }
    }
    [theLock unlock];
}

@end
