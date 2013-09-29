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
@synthesize homeDelegate;

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
    [self addMenuView:-NAVIGATION_BAR_HEIGHT];
    [self addContententView:-NAVIGATION_BAR_HEIGHT];
    self.title = @"我的照片";
    [self showMenuBtnForNavController];
	self.mediaType = 1;
    [super loadLocalMediaFiles];
    
    [self showBackBtnForNavController];
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, self.bounds.size.width, self.bounds.size.height - NAVIGATION_BAR_HEIGHT - 24)];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.backgroundColor = [UIColor clearColor];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.showsVerticalScrollIndicator = NO;
    [self addInContentView:table];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
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
    return ceil(self.groupMediaArray.count/2.0) ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.frame = CGRectMake(17, 10, 135, 135);
        btn1.tag = 3001;
        [btn1 setBackgroundImage:[UIImage imageNamed:@"folder_default"] forState:UIControlStateNormal];
        [btn1 setBackgroundImage:[UIImage imageNamed:@"folder_active"] forState:UIControlStateHighlighted];
        [btn1 addTarget:self action:@selector(imageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn1];
        
        UIImageView *imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(25, 18, 119, 119)];
        imageView1.tag = 1001;
        [cell.contentView addSubview:imageView1];
        UILabel *name1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 145, 135, 30)];
        name1.center = CGPointMake(imageView1.center.x, name1.center.y);
        name1.tag = 2001;
        name1.textColor = CMConstants.textColor;
        name1.backgroundColor = [UIColor clearColor];
        name1.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:name1];
        
        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn2.frame = CGRectMake(17 + 16 + 135, 10, 135, 135);
        btn2.tag = 3002;
        [btn2 setBackgroundImage:[UIImage imageNamed:@"folder_default"] forState:UIControlStateNormal];
        [btn2 setBackgroundImage:[UIImage imageNamed:@"folder_active"] forState:UIControlStateHighlighted];
        [btn2 addTarget:self action:@selector(imageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn2];
        
        UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(25 + 16 + 135, 18, 119, 119)];
        imageView2.tag = 1002;
        [cell.contentView addSubview:imageView2];
        
        UILabel *name2 = [[UILabel alloc]initWithFrame:name1.frame];
        name2.center = CGPointMake(imageView2.center.x, name2.center.y);
        name2.textColor = CMConstants.textColor;
        name2.tag = 2002;
        name2.backgroundColor = [UIColor clearColor];
        name2.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:name2];
    }
    int index = indexPath.row * 2;
    if (index < self.groupMediaArray.count) {        
        GroupMediaObject *media = [self.groupMediaArray objectAtIndex:index];
        UIImageView *imageView1  = (UIImageView *)[cell viewWithTag:1001];
        imageView1.image = media.groupImage;
        UILabel *name1  = (UILabel *)[cell viewWithTag:2001];
        name1.text = media.groupName;
    }
    UIImageView *imageView2  = (UIImageView *)[cell viewWithTag:1002];
    UILabel *name2  = (UILabel *)[cell viewWithTag:2002];
    UILabel *btn2  = (UILabel *)[cell viewWithTag:3002];
    if (index + 1 < self.groupMediaArray.count) {
        GroupMediaObject *media = [self.groupMediaArray objectAtIndex:index+1];
        imageView2.image = media.groupImage;
        name2.text = media.groupName;
        [imageView2 setHidden:NO];
        [name2 setHidden:NO];
        [btn2 setHidden:NO];
    } else {
        [imageView2 setHidden:YES];
        [name2 setHidden:YES];
        [btn2 setHidden:YES];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 175;
}

- (void)imageBtnClicked:(UIButton *)btn
{
    int i = btn.tag - 3001;
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    int index = indexPath.row * 2 + i;
    if (index < self.groupMediaArray.count) {
        GroupMediaObject *media = [self.groupMediaArray objectAtIndex:index];
        ImageGridViewController *viewController = [[ImageGridViewController alloc]init];
        viewController.mediaObjectArray = media.mediaObjectArray;
        viewController.groupName = media.groupName;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)backButtonClicked
{
    [homeDelegate closeChildWindow:self];
}



@end
