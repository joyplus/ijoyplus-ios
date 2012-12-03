//
//  MyListViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-29.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "MyListViewController.h"
#import "SubsearchViewController.h"
#define LEFT_GAP 50

@interface MyListViewController (){
    UIButton *createBtn;
    UIImageView *lineImage;
    UIButton *deleteBtn;
}

@end

@implementation MyListViewController


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
	table.frame = CGRectMake(25, 120, 460, self.view.frame.size.height - 350);
    
    lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(LEFT_GAP, 70, 400, 2)];
    lineImage.image = [UIImage imageNamed:@"dividing"];
    [self.view addSubview:lineImage];
    
    createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    createBtn.frame = CGRectMake(LEFT_GAP, 80, 105, 31);
    [createBtn setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [createBtn setBackgroundImage:[UIImage imageNamed:@"add_pressed"] forState:UIControlStateHighlighted];
    [createBtn addTarget:self action:@selector(createBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];
    
    deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(LEFT_GAP + createBtn.frame.size.width + 10, 80, 105, 31);
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete_pressed"] forState:UIControlStateHighlighted];
    [deleteBtn addTarget:self action:@selector(deleteBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteBtn];
}

- (void)createBtnClicked
{
    SubsearchViewController *viewController = [[SubsearchViewController alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:NO];
}

- (void)deleteBtnClicked
{
    if(topsArray.count > 0){
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil
                                                           message:@"删除悦单也会同时移除悦单中的影片，确定要删除吗？"
                                                          delegate:self
                                                 cancelButtonTitle:@"取消"
                                                 otherButtonTitles:@"确定", nil];
        [alertView show];
    } else {
        [self deleteVideo];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex > 0) {
        [self deleteVideo];
    }
}

- (void)deleteVideo
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.topId, @"topic_id", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathTopDelete parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if([responseCode isEqualToString:kSuccessResCode]){
            [[AppDelegate instance].rootViewController showSuccessModalView:1.5];
            [[AppDelegate instance].rootViewController.stackScrollViewController removeViewInSlider];
        } else {
            [[AppDelegate instance].rootViewController showFailureModalView:1.5];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [UIUtility showSystemError:self.view];
    }];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"commitEditingStyle");
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [topsArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    
}


@end
