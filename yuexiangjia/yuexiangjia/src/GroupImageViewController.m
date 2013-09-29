//
//  GroupImageViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "GroupImageViewController.h"
#import "CommonHeader.h"
#import "GroupMediaObject.h"
#import "ImageGridViewController.h"

@interface GroupImageViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView *table;

@end

@implementation GroupImageViewController
@synthesize table;

- (void)viewDidUnload
{
    [super viewDidUnload];
    table = nil;
}

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
    
    self.view.backgroundColor = [UIColor whiteColor];
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT - TOOLBAR_HEIGHT)];
//    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.backgroundColor = [UIColor clearColor];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.showsVerticalScrollIndicator = NO;
    [self.view addSubview:table];
    
	self.mediaType = 1;
    [super loadLocalMediaFiles];
    
    [super showNavigationBar:@"我的照片"];
    [super showToolbar];
}

- (void)reloadTableView
{
    [table reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groupMediaArray.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        imageView.tag = 1001;
        imageView.frame = CGRectMake(5, 5, 70, 70);
        [cell.contentView addSubview:imageView];
        
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(90, 20, 200, 30)];
        name.tag = 1002;
        [cell.contentView addSubview:name];
    }
    
    UIImageView *imageView  = (UIImageView *)[cell viewWithTag:1001];
    GroupMediaObject *media = [self.groupMediaArray objectAtIndex:indexPath.row];
    imageView.image = media.groupImage;
    
    UILabel *name  = (UILabel *)[cell viewWithTag:1002];
    name.text = [NSString stringWithFormat:@"%@ (%i)", media.groupName, media.mediaObjectArray.count];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.groupMediaArray.count) {
        GroupMediaObject *media = [self.groupMediaArray objectAtIndex:indexPath.row];
        ImageGridViewController *viewController = [[ImageGridViewController alloc]init];
        viewController.mediaObjectArray = media.mediaObjectArray;
        viewController.groupName = media.groupName;
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:viewController] animated:YES completion:nil];
    }
}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    if (scrollView.contentOffset.y < 0){
//        [super homeButtonClicked];
//    }
//}

- (void)backButtonClicked
{
    [super homeButtonClicked];
}


@end
