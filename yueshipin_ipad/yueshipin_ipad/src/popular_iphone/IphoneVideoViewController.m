//
//  IphoneVideoViewController.m
//  yueshipin
//
//  Created by 08 on 13-1-10.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "IphoneVideoViewController.h"
#import "AppDelegate.h"
#import "SendWeiboViewController.h"
#import "AFSinaWeiboAPIClient.h"
#import "CMConstants.h"
#import "ContainerUtility.h"
#import "ServiceConstants.h"
#import "AFServiceAPIClient.h"
#import "SendWeiboViewController.h"
#import "ActionUtility.h"
#import <QuartzCore/QuartzCore.h>
#define VIEWTAG   123654

@interface IphoneVideoViewController ()

@end

@implementation IphoneVideoViewController
@synthesize mySinaWeibo = _mySinaWeibo;
@synthesize infoDic = _infoDic;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

- (void)showOpSuccessModalView:(float)closeTime with:(int)type
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    view.tag = VIEWTAG;
    [view setBackgroundColor:[UIColor clearColor]];
   
    if (type == ADDFAV) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 80)];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.text = @"您提交的错误我们已经收到，我们会尽快处理，谢谢您的支持.";
        label.center = view.center;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:12];
        label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        label.layer.cornerRadius = 4;
        label.textColor = [UIColor whiteColor];
        [view addSubview:label];
    }
    if (type == DING ) {
         UIImageView *temp = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"operation_is_successful.png"]];
        temp.frame = CGRectMake(0, 0, 92, 27);
        temp.center = view.center;
        [view addSubview:temp];
    }
    
    //[[AppDelegate instance].window addSubview:view];
    [self.view addSubview:view];
    [NSTimer scheduledTimerWithTimeInterval:closeTime target:self selector:@selector(removeOverlay) userInfo:nil repeats:NO];
}
- (void)showOpFailureModalView:(float)closeTime with:(int)type
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    view.tag = VIEWTAG;
    [view setBackgroundColor:[UIColor clearColor]];
    UIImageView *temp = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"operation_fails.png"]];
    if (type == DING) {
        temp.frame = CGRectMake(0, 0, 92, 27);
        temp.center = view.center;
    }
    if (type == ADDFAV) {
        temp.frame = CGRectMake(16, 110, 92, 27);
    }
    [view addSubview:temp];
  
     [self.view addSubview:view];
    [NSTimer scheduledTimerWithTimeInterval:closeTime target:self selector:@selector(removeOverlay) userInfo:nil repeats:NO];
}
- (void)removeOverlay
{
  for(UIView *view in self.view.subviews ){
      if (view.tag == VIEWTAG) {
          [view removeFromSuperview];
          break;
     }
  
  }
    
}


-(void)share:(id)sender{
   
        _mySinaWeibo = [AppDelegate instance].sinaweibo;
        _mySinaWeibo.delegate = self;
        if ([_mySinaWeibo isLoggedIn]) {
            SendWeiboViewController *sendV = [[SendWeiboViewController alloc] init];
            sendV.infoDic = _infoDic;
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:sendV] animated:YES completion:nil];
        }
        else{
            [_mySinaWeibo logIn];
           
        }
    
    
}

#pragma mark - SinaWeibo Delegate
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo{
    
    SendWeiboViewController *sendV = [[SendWeiboViewController alloc] init];
    sendV.infoDic = _infoDic;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:sendV] animated:YES completion:nil];
    
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              sinaweibo.accessToken, @"AccessTokenKey",
                              sinaweibo.expirationDate, @"ExpirationDateKey",
                              sinaweibo.userID, @"UserIDKey",
                              sinaweibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [sinaweibo requestWithURL:@"users/show.json"
                       params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];
    
}
- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo{
    NSLog(@"sinaweiboDidLogOut");
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
    [[ContainerUtility sharedInstance] removeObjectForKey:kUserAvatarUrl];
    [[ContainerUtility sharedInstance] removeObjectForKey:kUserNickName];
    [ActionUtility generateUserId:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SINAWEIBOCHANGED" object:nil];
    }];
    
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo{
    NSLog(@"sinaweiboLogInDidCancel");
    
}
- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error{
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"网络数据错误，请重新登陆。"
                                                       delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}
- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error{
    NSLog(@"sinaweiboAccessTokenInvalidOrExpired %@", error);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"Token已过期，请重新登陆。"
                                                       delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}
#pragma mark - SinaWeiboRequest Delegate

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)userInfo{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        NSString *username = [userInfo objectForKey:@"screen_name"];
        [[ContainerUtility sharedInstance] setAttribute:username forKey:kUserNickName];
        NSString *avatarUrl = [userInfo objectForKey:@"avatar_large"];
        [[ContainerUtility sharedInstance] setAttribute:avatarUrl forKey:kUserAvatarUrl];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"SINAWEIBOCHANGED" object:nil];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [userInfo objectForKey:@"idstr"], @"source_id", @"1", @"source_type", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathUserValidate parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if(responseCode == nil){
                NSString *user_id = [result objectForKey:@"user_id"];
                [[AFServiceAPIClient sharedClient] setDefaultHeader:@"user_id" value:user_id];
                [[ContainerUtility sharedInstance] setAttribute:user_id forKey:kUserId];
            } else {
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [userInfo objectForKey:@"idstr"], @"source_id", @"1", @"source_type", avatarUrl, @"pic_url", username, @"nickname", nil];
                [[AFServiceAPIClient sharedClient] postPath:kPathAccountBindAccount parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                    
                } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                    
                }];
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    
}

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
