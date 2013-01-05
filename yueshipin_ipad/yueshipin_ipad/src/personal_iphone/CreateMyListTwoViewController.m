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
    
    self.title = [infoDic_ objectForKey:@"name"];
    
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc]
                                     
                                     initWithTitle:@"完成"
                                     
                                     style:UIBarButtonItemStyleBordered
                                     
                                     target:self
                                     
                                     action:@selector(Done:)];
    //rightButton.image=[UIImage imageNamed:@"top_return_common.png"];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UIView *whiteBg = [[UIView alloc] initWithFrame:CGRectMake(12, 10, 296, 45)];
    whiteBg.backgroundColor = [UIColor whiteColor];
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [moreButton addTarget:self action:@selector(AddMore:) forControlEvents:UIControlEventTouchUpInside];
    [moreButton setFrame:CGRectMake(5, 7, 284, 30)];
    [moreButton setBackgroundImage:[UIImage imageNamed:@"icon_add videos.png"] forState:UIControlStateNormal];
     [moreButton setBackgroundImage:[UIImage imageNamed:@"icon_add videos_s.png"] forState:UIControlStateHighlighted];
    [whiteBg addSubview:moreButton];
    [self.view addSubview:whiteBg];
    
    tableList_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 46, 320, 330) style:UITableViewStylePlain];
    tableList_.dataSource = self;
    tableList_.delegate = self;
    tableList_.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableList_];
    
    listArr_ = [NSMutableArray arrayWithCapacity:10];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(update:) name:@"Update CreateMyListTwoViewController" object:nil];
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
    cell.actors.text = [NSString stringWithFormat:@"主演：%@",[item objectForKey:@"star"]];
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

-(void)Done:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [infoDic_ setObject:listArr_ forKey:@"items"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Update MineViewController" object:infoDic_];

}
-(void)AddMore:(id)sender{
    FindViewController *findViewController = [[FindViewController alloc] init];
    findViewController.selectedArr = listArr_;
    findViewController.topicId = topicId_;
    [self.navigationController pushViewController:findViewController animated:YES];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
