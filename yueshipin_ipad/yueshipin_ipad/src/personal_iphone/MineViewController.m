//
//  mineViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "MineViewController.h"
#import "RecordListCell.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "IphoneSettingViewController.h"
#define RECORD_TYPE 0
#define Fav_TYPE  1
#define PAGESIZE 20
@interface MineViewController ()

@end

@implementation MineViewController
@synthesize segControl = segControl_;
@synthesize bgView = bgView_;
@synthesize recordArr = recordArr_;
@synthesize favArr = favArr_;
@synthesize favShowArr = favShowArr_;
@synthesize redShowArr = redShowArr_;
@synthesize recordTableList = recordTableList_;
@synthesize favTableList = favTableList_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadMyFavsData{
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:PAGESIZE], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathUserFavorities parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        self.favArr = [[NSMutableArray alloc]initWithCapacity:PAGESIZE];
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *tempTopsArray = [result objectForKey:@"favorities"];
            if(tempTopsArray.count > 0){
                
                [ self.favArr addObjectsFromArray:tempTopsArray];
            }
        }
        else {
            
        }

    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if(self.favArr == nil){
            self.favArr = [[NSMutableArray alloc]initWithCapacity:10];
        }
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self loadMyFavsData];
    
    self.title = @"我的";
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc]
                                     
                                     initWithTitle:@"设置"
                                     
                                     style:UIBarButtonItemStyleDone
                                     
                                     target:self
                                     
                                     action:@selector(setting:)];
    rightButton.image=[UIImage imageNamed:@"right_button.png"];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    NSArray *itemsArr = [NSArray arrayWithObjects:@"播放纪录",@"我的收藏",@"我的悦单", nil];
    self.segControl = [[UISegmentedControl alloc] initWithItems:itemsArr];
    self.segControl.frame = CGRectMake(12, 40, 296, 51);
    [self.segControl addTarget:self action:@selector(Selectbutton:) forControlEvents:UIControlEventValueChanged];
    self.segControl.selectedSegmentIndex = 0;
    [self.view addSubview:self.segControl];
    
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(12, 98, 296, 180)];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bgView];
    
    self.recordTableList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 296, 180) style:UITableViewStylePlain];
    self.recordTableList.dataSource = self;
    self.recordTableList.delegate = self;
    self.recordTableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.recordTableList.tag = RECORD_TYPE;
    self.recordTableList.scrollEnabled = NO;
    
    self.favTableList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 296, 180) style:UITableViewStylePlain];
    self.favTableList.dataSource = self;
    self.favTableList.delegate = self;
    self.favTableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.favTableList.tag = Fav_TYPE;
    self.favTableList.scrollEnabled = NO;
}

-(void)setting:(id)sender{
    IphoneSettingViewController *settingViewController = [[IphoneSettingViewController alloc] init];
    [self.navigationController pushViewController:settingViewController animated:YES];

}

-(void)Selectbutton:(id)sender{
    [self.recordTableList removeFromSuperview];
    [self.favTableList removeFromSuperview];
    
    UISegmentedControl *mySegmentedControl=(UISegmentedControl *)sender;
    switch (mySegmentedControl.selectedSegmentIndex) {
        //播放纪录
        case 0:{
                if ([self.recordArr count] <= 3) {
                    redShowArr_ = [NSArray arrayWithArray:self.recordArr];
                }
                else {
                    redShowArr_ = [NSArray arrayWithObjects:[self.recordArr objectAtIndex:0],[self.recordArr objectAtIndex:1],[self.recordArr objectAtIndex:2], nil];
                }
                [self.bgView addSubview:self.recordTableList];
                [self.recordTableList reloadData];
            break;
        }
        //我的收藏
        case 1:{
            if ([self.favArr count] <= 3) {
                favShowArr_ = [NSArray arrayWithArray:self.favArr];
            }
            else {
                favShowArr_ = [NSArray arrayWithObjects:[self.favArr objectAtIndex:0],[self.favArr objectAtIndex:1],[self.favArr objectAtIndex:2], nil];
            }
            [self.bgView addSubview:self.favTableList];
            [self.favTableList reloadData];
            break;
        }
        //我的悦单
        case 2:{
            
            break;
        }
        default:
            break;
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == RECORD_TYPE) {
        return [redShowArr_ count];
    }
    if (tableView.tag == Fav_TYPE) {
        return [favShowArr_ count];
    }
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    RecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[RecordListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (tableView.tag == RECORD_TYPE) {
       
        
    }
    else if (tableView.tag == Fav_TYPE){
        NSDictionary *infoDic = [favShowArr_ objectAtIndex:indexPath.row];
        cell.titleLab.text = [infoDic objectForKey:@"content_name"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 60;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
