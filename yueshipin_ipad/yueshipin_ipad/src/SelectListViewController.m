//
//  ShowListViewController.m
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SelectListViewController.h"
#import "CommonHeader.h"
#import "SSCheckBoxView.h"
#import "CreateListOneViewController.h"

#define LEFT_GAP 50
@interface SelectListViewController (){
    NSMutableArray *listData;
    UIImageView *titleImage;
    UIButton *closeBtn;
    UIButton *doneBtn;
    UITableView *table;
    UIImageView *bgImage;
    NSMutableSet *checkboxes;
    UIButton *createBtn;
}

@end

@implementation SelectListViewController
@synthesize prodId;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    bgImage = [[UIImageView alloc]initWithFrame:self.view.frame];
    bgImage.image = [UIImage imageNamed:@"detail_bg"];
    [self.view addSubview:bgImage];
    
    titleImage = [[UIImageView alloc]initWithFrame: CGRectMake(LEFT_GAP, 35, 183, 27)];
    titleImage.image = [UIImage imageNamed:@"add_title"];
    [self.view addSubview:titleImage];
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(470, 20, 40, 42);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(25, 120, 460, self.view.frame.size.height - 350)];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.showsVerticalScrollIndicator = NO;
    [self.view addSubview:table];
    
    createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    createBtn.frame = CGRectMake(LEFT_GAP, 80, 105, 31);
    [createBtn setBackgroundImage:[UIImage imageNamed:@"create_list"] forState:UIControlStateNormal];
    [createBtn setBackgroundImage:[UIImage imageNamed:@"create_list_pressed"] forState:UIControlStateHighlighted];
    [createBtn addTarget:self action:@selector(createBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];
    
    doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(createBtn.frame.origin.x + 115, 80, 62, 31);
    [doneBtn setBackgroundImage:[UIImage imageNamed:@"finish"] forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:[UIImage imageNamed:@"finish_pressed"] forState:UIControlStateHighlighted];
    [doneBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneBtn];
    
    checkboxes = [[NSMutableSet alloc]initWithCapacity:10];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    
    
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"my_topic_list"];
    if(cacheResult != nil){
        [self parseVideoData:cacheResult];
    }
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%i", 1], @"page_num", @"30", @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathUserTopics parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseVideoData:result];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            [listData removeAllObjects];
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
        }];
    }
}

- (void)parseVideoData:(id)result
{
    listData = [[NSMutableArray alloc]initWithCapacity:10];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *videos = [result objectForKey:@"tops"];
        if(videos != nil && videos.count > 0){
            [[CacheUtility sharedCache] putInCache:@"my_topic_list" result:result];
            [listData addObjectsFromArray:videos];
        }
    }
    [table reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_MB_PROGRESS_BAR object:self userInfo:nil];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 10, cell.bounds.size.width, 20)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor lightGrayColor];
        nameLabel.tag = 1001;
        nameLabel.font = [UIFont systemFontOfSize:16];
        [cell.contentView addSubview:nameLabel];
        
        SSCheckBoxView *checkbox = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(10, 3, 20, 20) style:kSSCheckBoxViewStyleBox checked:NO];
        checkbox.tag = 2001;
        [checkbox setStateChangedTarget:self selector:@selector(checkBoxViewChangedState:)];
        [cell.contentView addSubview:checkbox];
        
        UIImageView *devidingLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 38, table.frame.size.width, 2)];
        devidingLine.image = [UIImage imageNamed:@"dividing"];
        [cell.contentView addSubview:devidingLine];
    }
    NSDictionary *item =  [listData objectAtIndex:indexPath.row];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1001];
    nameLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"name"]];
    
    SSCheckBoxView *checkbox = (SSCheckBoxView *)[cell viewWithTag:2001];
    checkbox.value = [NSString stringWithFormat:@"%@", [item objectForKey:@"id"]];
    
    return cell;
}

- (void) checkBoxViewChangedState:(SSCheckBoxView *)cbv
{
    if(cbv.checked){
        if(![checkboxes containsObject:[cbv value]]){
            [checkboxes addObject:[cbv value]];
        }
    } else {
        if([checkboxes containsObject:[cbv value]]){
            [checkboxes removeObject:[cbv value]];
        }
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
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

}

- (void)addBtnClicked
{
    for(NSString *topicId in checkboxes){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: topicId, @"topic_id", self.prodId, @"prod_id", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathAddItem parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if([responseCode isEqualToString:kSuccessResCode]){
                [[AppDelegate instance].rootViewController showSuccessModalView:1.5];
            } else {
                [[AppDelegate instance].rootViewController showFailureModalView:1.5];
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            [UIUtility showSystemError:self.view];
        }];
    }
}

- (void)createBtnClicked
{
    CreateListOneViewController *viewController = [[CreateListOneViewController alloc]initWithNibName:@"CreateListOneViewController" bundle:nil];
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE  removePreviousView:YES];
}

@end
