//
//  GroupImageViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "SettingsViewController.h"
#import "CommonHeader.h"
#import "ChangeScreenViewController.h"
#import "ChatViewController.h"
#import "TpSettingViewController.h"
#import "AboutViewController.h"

@interface SettingsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView *table;

@end

@implementation SettingsViewController
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


-(NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
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
    self.title = @"设置";
    [self showBackBtnForNavController];

    [self addContententView:0];
    table = [[UITableView alloc]initWithFrame:CGRectMake(10, 10, self.bounds.size.width - 20, 49 * 4) style:UITableViewStylePlain];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [table setScrollEnabled:NO];
    table.layer.cornerRadius = 5;
    table.layer.masksToBounds = YES;
    table.backgroundColor = [UIColor clearColor];
    table.delegate = self;
    table.dataSource = self;
    table.showsVerticalScrollIndicator = NO;
    [self addInContentView:table];
    
    UIImageView *bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 49 * 4)];
    bgImage.image = [[UIImage imageNamed:@"screen_table_bg"]resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [self addInContentView:bgImage];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    if (indexPath.row == 0) {        
        cell.textLabel.text = @"调整屏幕";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"遥控器设置";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"意见建议";
    } else if(indexPath.row == 3){
        cell.textLabel.text = @"关于我们";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
//        if(![self serverIsConnected]) return;
        ChangeScreenViewController *viewController = [[ChangeScreenViewController alloc]init];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (indexPath.row == 1) {
        UIViewController *viewController = [[TpSettingViewController alloc]init];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (indexPath.row == 2) {
        ChatViewController *viewController = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if(indexPath.row == 3){
        AboutViewController *viewController = [[AboutViewController alloc]init];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
