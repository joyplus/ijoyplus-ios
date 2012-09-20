//
//  FollowedUserViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "FollowedUserViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "CMConstants.h"
#import "CustomBackButtonHolder.h"
#import "CustomBackButton.h"
#import "HomeViewController.h"

#define LEFT_GAP 25
#define AVATAR_IMAGE_WIDTH 55

@interface FollowedUserViewController (){
    NSMutableArray *userArray;
}
- (void)closeSelf;
- (void)cancelFollow;
- (void)viewUser;
@end

@implementation FollowedUserViewController

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
    self.title = NSLocalizedString(@"my_followed_people", nil);
    CustomBackButtonHolder *backButtonHolder = [[CustomBackButtonHolder alloc]initWithViewController:self];
    CustomBackButton* backButton = [backButtonHolder getBackButton:NSLocalizedString(@"go_back", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    userArray = [[NSMutableArray alloc]initWithObjects:@"Joyce", @"Steven", @"Scott", @"Zhou", nil ];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int num = ceil(userArray.count / 3.0);
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    int num = 3;
    if(userArray.count < (indexPath.row+1) * 3){
        num = userArray.count - indexPath.row * 3;
    }
    for (int i = 0; i < num; i ++){
        UIImageView *avatarImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, AVATAR_IMAGE_WIDTH, AVATAR_IMAGE_WIDTH)];
        [avatarImageView setImageWithURL:[NSURL URLWithString:@"http://img5.douban.com/view/photo/thumb/public/p1686249659.jpg"] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        avatarImageView.layer.cornerRadius = 27.5;
        avatarImageView.layer.masksToBounds = YES;
        if(i == 0){
            avatarImageView.center = CGPointMake(LEFT_GAP + AVATAR_IMAGE_WIDTH / 2, LEFT_GAP + AVATAR_IMAGE_WIDTH / 2);
        } else if (i == 1){
            avatarImageView.center = CGPointMake(self.view.frame.size.width / 2, LEFT_GAP + AVATAR_IMAGE_WIDTH / 2);
        } else {
            avatarImageView.center = CGPointMake(self.view.frame.size.width - LEFT_GAP - AVATAR_IMAGE_WIDTH / 2, LEFT_GAP + AVATAR_IMAGE_WIDTH / 2);
        }
        [cell.contentView addSubview:avatarImageView];
        
        UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        imageBtn.frame = avatarImageView.frame;
        [imageBtn addTarget:self action:@selector(viewUser) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:imageBtn];
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        nameLabel.text = [userArray objectAtIndex:indexPath.row * 3 + num - 1];
        [nameLabel sizeToFit];
        nameLabel.center = CGPointMake(avatarImageView.center.x, avatarImageView.center.y + AVATAR_IMAGE_WIDTH / 2 + 10);
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = [UIFont systemFontOfSize:15];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:nameLabel];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame = CGRectMake(0, 0, 95, 25);
        btn.center = CGPointMake(avatarImageView.center.x, nameLabel.center.y + 25);
        [btn setTitle:NSLocalizedString(@"cancel_follow", nil) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(cancelFollow) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 295 / 2;
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

- (void)closeSelf
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)cancelFollow
{
    
}

- (void)viewUser
{
    HomeViewController *viewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
//    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    [self.navigationController pushViewController:viewController animated:YES];
    
}

@end
