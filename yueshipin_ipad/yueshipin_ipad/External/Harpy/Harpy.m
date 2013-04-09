//
//  Harpy.m
//  Harpy
//
//  Created by Arthur Ariel Sabintsev on 11/14/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import "Harpy.h"
#import "HarpyConstants.h"
#import "CMConstants.h"
#import "MBProgressHUD.h"

#define kHarpyCurrentVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey]

@interface Harpy () 

+ (void)showAlertWithAppStoreVersion:(NSString*)appStoreVersion;
+ (void)showNoUpdateAlert;
@end

@implementation Harpy

#pragma mark - Public Methods
+ (void)checkVersion:(UIView *)view
{

    MBProgressHUD *HUD = (MBProgressHUD *)[view viewWithTag:63857392];
    HUD.layer.zPosition = 10;
    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:HUD];
    }
    HUD.tag = 63857392;
    HUD.frame = CGRectMake(HUD.frame.origin.x, HUD.frame.origin.y, HUD.frame.size.width, HUD.frame.size.height);
    HUD.labelText = @"检查中...";
    HUD.opacity = 0.5;
    [HUD show:YES];
    // Asynchronously query iTunes AppStore for publically available version
    NSString *storeString = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%i", APPIRATER_APP_ID];
    NSURL *storeURL = [NSURL URLWithString:storeString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:storeURL];
    [request setHTTPMethod:@"GET"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
       
        if ( [data length] > 0 && !error ) { // Success
            
            NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

            dispatch_async(dispatch_get_main_queue(), ^{
                
                // All versions that have been uploaded to the AppStore
                NSArray *versionsInAppStore = [[appData valueForKey:@"results"] valueForKey:@"version"];
                [HUD hide:YES];
                if ( ![versionsInAppStore count] ) { // No versions of app in AppStore
                    
                    return;
                    
                } else {

                    NSString *currentAppStoreVersion = [versionsInAppStore objectAtIndex:0];
                    NSLog(@"%@", kHarpyCurrentVersion);
                    if ([kHarpyCurrentVersion isEqualToString:currentAppStoreVersion]) {
                        [Harpy showNoUpdateAlert];
                    }
                    else {
                        [Harpy showAlertWithAppStoreVersion:currentAppStoreVersion];
                    }

                }
              
            });
        } else {
            [HUD hide:YES];
        }
        
    }];
}

#pragma mark - Private Methods
+ (void)showNoUpdateAlert
{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kHarpyAlertViewTitle
                                                        message:@"已经是最新版了。"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

+ (void)showAlertWithAppStoreVersion:(NSString *)currentAppStoreVersion
{
    
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if ( harpyForceUpdate ) { // Force user to update app
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kHarpyAlertViewTitle
                                                            message:[NSString stringWithFormat:@"最新版%@(%@)已上线，快去更新吧。", appName, currentAppStoreVersion]
                                                           delegate:self
                                                  cancelButtonTitle:kHarpyUpdateButtonTitle
                                                  otherButtonTitles:nil, nil];
        
        [alertView show];
        
    } else { // Allow user option to update next time user launches your app
        
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kHarpyAlertViewTitle
                                                            message:[NSString stringWithFormat:@"最新版%@(%@)已上线，快去更新吧。", appName, currentAppStoreVersion]
                                                           delegate:self
                                                  cancelButtonTitle:kHarpyCancelButtonTitle
                                                  otherButtonTitles:kHarpyUpdateButtonTitle, nil];
        
        [alertView show];
        
    }
    
}

#pragma mark - UIAlertViewDelegate Methods
+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if ( harpyForceUpdate ) {

        NSString *iTunesString = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%i", APPIRATER_APP_ID];
        NSURL *iTunesURL = [NSURL URLWithString:iTunesString];
        [[UIApplication sharedApplication] openURL:iTunesURL];
        
    } else {

        switch ( buttonIndex ) {
                
            case 0:{ // Cancel / Not now
        
                // Do nothing
                
            } break;
                
            case 1:{ // Update
                
                NSString *iTunesString = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%i", APPIRATER_APP_ID];
                NSURL *iTunesURL = [NSURL URLWithString:iTunesString];
                [[UIApplication sharedApplication] openURL:iTunesURL];
                
            } break;
                
            default:
                break;
        }
        
    }

    
}

@end
