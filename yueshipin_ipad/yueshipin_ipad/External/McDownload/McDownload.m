//
//  McDownload.m
//  McDownload
//
//  Created by Hao Tan on 11-11-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "McDownload.h"

#define kTHDownLoadTask_TempSuffix  @".TempDownload"

@implementation McDownload
@synthesize idNum;
@synthesize isStop;
@synthesize delegate;
@synthesize overwrite;
@synthesize url;
@synthesize fileName;
@synthesize filePath;
@synthesize fileSize;

- (id)initWithUrl:(NSURL *)aUrl
{
    self = [super init];
    if (self)
    {
        url = aUrl;
    }
    return self;
}

- (void)start
{
    //当url为空的时间，返回失败
    if (!url)
    {
        if ([delegate respondsToSelector:@selector(downloadFaild:didFailWithError:)]) 
        {
            NSError *error = [NSError errorWithDomain:@"Url can not be nil!" code:110 userInfo:nil];
            [delegate downloadFaild:self didFailWithError:error];
        }
    }
    
    //未指定文件名
    if (!fileName)
    {
        NSString *urlStr = [url absoluteString];
        fileName = [urlStr lastPathComponent];
        if ([fileName length] > 32) fileName = [fileName substringFromIndex:[fileName length]-32];
    }
    
    //未指定路径
    if (!filePath) 
    {
        NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [documentPaths objectAtIndex:0];
        filePath = documentsDir;
    }
    
    
    //目标地址与缓存地址
    destinationPath=[filePath stringByAppendingPathComponent:fileName];
	temporaryPath=[destinationPath stringByAppendingFormat:kTHDownLoadTask_TempSuffix];
    
    //处理如果文件已经存在的情况
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) 
    {
        if (overwrite) 
        {
            [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:nil];
        }else
        {
            if ([delegate respondsToSelector:@selector(downloadProgressChange:progress:)])
                [delegate downloadProgressChange:self progress:1.0];
            if ([delegate respondsToSelector:@selector(downloadFinished:)]) 
                [delegate downloadFinished:self];
            return;
        }
    }
    
    //缓存文件不存在，则创建缓存文件
    if (![[NSFileManager defaultManager] fileExistsAtPath:temporaryPath]) 
    {
        BOOL createSucces = [[NSFileManager defaultManager] createFileAtPath:temporaryPath contents:nil attributes:nil];
        if (!createSucces)
        {
            if ([delegate respondsToSelector:@selector(downloadFaild:didFailWithError:)]) 
            {
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
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request addValue:range forHTTPHeaderField:@"Range"];
    [connection cancel];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    self.isStop = NO;
}

- (void)stop
{
    [connection cancel];
    connection = nil;
    [fileHandle closeFile];
    fileHandle = nil;
    self.isStop = YES;
}

- (void)stopAndClear
{
    [self stop];
    [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:temporaryPath error:nil];
    
    if ([delegate respondsToSelector:@selector(downloadProgressChange:progress:)])
    {
        [delegate downloadProgressChange:self progress:0];
    }
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response expectedContentLength] != NSURLResponseUnknownLength) 
        fileSize = (unsigned long long)[response expectedContentLength]+offset;

    
	if ([delegate respondsToSelector:@selector(downloadBegin:didReceiveResponseHeaders:)]) 
    {
		[delegate downloadBegin:self didReceiveResponseHeaders:response];
	}
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)aData
{
    [fileHandle writeData:aData];
    offset = [fileHandle offsetInFile];
    
    if ([delegate respondsToSelector:@selector(downloadProgressChange:progress:)])
    {
        double progress = offset*1.0/fileSize;
        [delegate downloadProgressChange:self progress:progress];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [fileHandle closeFile];
    if ([delegate respondsToSelector:@selector(downloadFaild:didFailWithError:)]) 
    {
		[delegate downloadFaild:self didFailWithError:error];
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [fileHandle closeFile];
    [[NSFileManager defaultManager] moveItemAtPath:temporaryPath toPath:destinationPath error:nil];
	if ([delegate respondsToSelector:@selector(downloadFinished:)]) 
    {        
		[delegate downloadFinished:self];
	}
}

@end
