//
//  MyUncaughtExceptionHandler.m
//  ijoyplus
//
//  Created by joyplus1 on 12-11-8.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "MyUncaughtExceptionHandler.h"
#include <libkern/OSAtomic.h>

#include <execinfo.h>

NSString * const MyUncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";

NSString * const MyUncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";

NSString * const MyUncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t MyUncaughtExceptionCount = 0;

const int32_t MyUncaughtExceptionMaximum = 10;

const NSInteger MyUncaughtExceptionHandlerSkipAddressCount = 4;

const NSInteger MyUncaughtExceptionHandlerReportAddressCount = 5;

@implementation MyUncaughtExceptionHandler

+ (NSArray *)backtrace

{
    
    void* callstack[128];
    
    int frames = backtrace(callstack, 128);
    
    char **strs = backtrace_symbols(callstack, frames);
    
    
    int i;
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    
    for (
         
         
         i = MyUncaughtExceptionHandlerSkipAddressCount;
         
         
         i < MyUncaughtExceptionHandlerSkipAddressCount +
         
         MyUncaughtExceptionHandlerReportAddressCount;
         
         i++)
        
    {
        
        
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
        
    }
    
    free(strs);
    
    
    return backtrace;
    
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex

{
    
    if (anIndex == 0)
        
    {
        
        dismissed = YES;
        
    }
    
}

- (void)handleException:(NSException *)exception

{
    
    UIAlertView *alert =
    
    [[UIAlertView alloc]
     
     initWithTitle:NSLocalizedString(@"Unhandled exception", nil)
     
     message:[NSString stringWithFormat:NSLocalizedString(
                                                          
                                                          @"You can try to continue but the application may be unstable.\n"
                                                          
                                                          @"%@\n%@", nil),
              
              [exception reason],
              
              [[exception userInfo] objectForKey:MyUncaughtExceptionHandlerAddressesKey]]
     
     delegate:self
     
     cancelButtonTitle:NSLocalizedString(@"Quit", nil)
     
     otherButtonTitles:NSLocalizedString(@"Continue", nil), nil]
    
    ;
    
    [alert show];
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!dismissed)
        
    {
        
        for (NSString *mode in (__bridge NSArray *)allModes)
            
        {
            
            CFRunLoopRunInMode((__bridge CFStringRef)mode, 0.001, false);
            
        }
        
    }
    
    CFRelease(allModes);
    
    NSSetUncaughtExceptionHandler(NULL);
    
    signal(SIGABRT, SIG_DFL);
    
    signal(SIGILL, SIG_DFL);
    
    signal(SIGSEGV, SIG_DFL);
    
    signal(SIGFPE, SIG_DFL);
    
    signal(SIGBUS, SIG_DFL);
    
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:MyUncaughtExceptionHandlerSignalExceptionName])
        
    {
        
        kill(getpid(), [[[exception userInfo] objectForKey:MyUncaughtExceptionHandlerSignalKey] intValue]);
        
    }
    
    else
        
    {
        
        [exception raise];
        
    }
    
}

@end

NSString* getAppInfo()

{
    
    NSString *appInfo = [NSString stringWithFormat:@"App : %@ %@(%@)\nDevice : %@\nOS Version : %@ %@\nUDID : %@\n",
                         
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                         
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                         
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                         
                         [UIDevice currentDevice].model,
                         
                         [UIDevice currentDevice].systemName,
                         
                         [UIDevice currentDevice].systemVersion,
                         
                         [UIDevice currentDevice].uniqueIdentifier];
    
    NSLog(@"Crash!!!! %@", appInfo);
    
    return appInfo;
    
}

void MySignalHandler(int signal)

{
    
    int32_t exceptionCount = OSAtomicIncrement32(&MyUncaughtExceptionCount);
    
    if (exceptionCount > MyUncaughtExceptionMaximum)
        
    {
        
        return;
        
    }
    
    
    NSMutableDictionary *userInfo =
    
    [NSMutableDictionary
     
     dictionaryWithObject:[NSNumber numberWithInt:signal]
     
     forKey:MyUncaughtExceptionHandlerSignalKey];
    
    NSArray *callStack = [MyUncaughtExceptionHandler backtrace];
    
    [userInfo
     
     setObject:callStack
     
     forKey:MyUncaughtExceptionHandlerAddressesKey];
    
    [[[MyUncaughtExceptionHandler alloc] init]
     
     performSelectorOnMainThread:@selector(handleException:)
     
     withObject:
     
     [NSException
      
      exceptionWithName:MyUncaughtExceptionHandlerSignalExceptionName
      
      reason:
      
      [NSString stringWithFormat:
       
       NSLocalizedString(@"Signal %d was raised.\n"
                         
                         @"%@", nil),
       
       signal, getAppInfo()]
      
      userInfo:
      
      [NSDictionary
       
       dictionaryWithObject:[NSNumber numberWithInt:signal]
       
       forKey:MyUncaughtExceptionHandlerSignalKey]]
     
     waitUntilDone:YES];
    
}

void InstallMyUncaughtExceptionHandler()

{
    
    signal(SIGABRT, MySignalHandler);
    
    signal(SIGILL, MySignalHandler);
    
    signal(SIGSEGV, MySignalHandler);
    
    signal(SIGFPE, MySignalHandler);
    
    signal(SIGBUS, MySignalHandler);
    
    signal(SIGPIPE, MySignalHandler);
    
}
