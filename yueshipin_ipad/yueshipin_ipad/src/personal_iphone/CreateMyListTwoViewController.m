//
//  CreateMyListTwoViewController.m
//  yueshipin
//
//  Created by 08 on 13-1-5.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "CreateMyListTwoViewController.h"
#import "FindViewController.h"
#import "SearchResultsViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Scale.h"

@interface CreateMyListTwoViewController ()

@end

@implementation CreateMyListTwoViewController
@synthesize tableList = tableList_;
@synthesize listArr = listArr_;
@synthesize infoDic = infoDic_;
@synthesize topicId = topicId_;
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
	// Do any additional setup after loading the view.
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    bg.frame = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:bg];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 40, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"top_return_common.png"] forState:UIControlStateNormal];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    self.title = [infoDic_ objectForKey:@"name"];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton addTarget:self action:@selector(Done:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, 37, 30);
    [rightButton setImage:[UIImage imageNamed:@"top_icon_common_writing_complete"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"top_icon_common_writing_complete_s"] forState:UIControlStateHighlighted];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    UIView *whiteBg = [[UIView alloc] initWithFrame:CGRectMake(12, 10, 296, 45)];
    whiteBg.backgroundColor = [UIColor whiteColor];
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton addTarget:self action:@selector(AddMore:) forControlEvents:UIControlEventTouchUpInside];
    [moreButton setFrame:CGRectMake(5, 7, 284, 30)];
    [moreButton setBackgroundImage:[UIImage imageNamed:@"icon_add videos.png"] forState:UIControlStateNormal];
     [moreButton setBackgroundImage:[UIImage imageNamed:@"icon_add videos_s.png"] forState:UIControlStateHighlighted];
    [whiteBg addSubview:moreButton];
    [self.view addSubview:whiteBg];
    
    tableList_ = [[UITableView alloc] initWithFrame:CGRectMake(12, 55, 296, 350) style:UITableViewStylePlain];
    tableList_.dataSource = self;
    tableList_.delegate = self;
    tableList_.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableList_.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tableList_];
    
    if (listArr_ == nil) {
         listArr_ = [NSMutableArray arrayWithCapacity:10];
    }
   
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(update:) name:@"Update CreateMyListTwoViewController" object:nil];
}

-(void)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)update:(id)sender{
   listArr_ = [(NSNotification *)sender object];
   [self.tableList reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [listArr_ count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 95;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    SearchResultsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SearchResultsViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *item = [listArr_ objectAtIndex:indexPath.row];
    cell.label.text = [item objectForKey:@"prod_name"];
    NSString *starsStr = [item objectForKey:@"star"];
    if (starsStr == nil) {
        starsStr =  [item objectForKey:@"stars"];
    }
    cell.actors.text = [NSString stringWithFormat:@"主演：%@",starsStr];
    cell.area.text = [NSString stringWithFormat:@"地区：%@",[item objectForKey:@"area"]];
    [cell.imageview setImageWithURL:[NSURL URLWithString:[item objectForKey:@"prod_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    NSString *type = [item objectForKey:@"prod_type" ];
    if ([type isEqualToString:@"1" ]) {
        cell.type.text = @"类型：电影";
    }
    else if ([type isEqualToString:@"2" ]){
        cell.type.text = @"类型：电视剧";
    }

    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        [listArr_ removeObjectAtIndex:indexPath.row];
         [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)Done:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
    if (infoDic_ == nil) {
        infoDic_ = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    [infoDic_ setObject:listArr_ forKey:@"items"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Update MineViewController" object:infoDic_];

}
-(void)AddMore:(id)sender{
    FindViewController *findViewController = [[FindViewController alloc] init];
    findViewController.selectedArr = listArr_;
    findViewController.topicId = topicId_;
    findViewController.title = self.title;
    [self.navigationController pushViewController:findViewController animated:YES];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
