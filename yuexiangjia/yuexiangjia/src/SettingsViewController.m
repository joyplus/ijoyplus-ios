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
    self.title = @"浏览器";
       
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height-NAVIGATION_BAR_HEIGHT-TOOLBAR_HEIGHT) style:UITableViewStyleGrouped];
    table.backgroundView = nil;
    table.backgroundColor = [UIColor clearColor];
    table.delegate = self;
    table.dataSource = self;
    table.showsVerticalScrollIndicator = NO;
    [self.view addSubview:table];
    
    [super showToolbar:NAVIGATION_BAR_HEIGHT];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = CMConstants.textGreyColor;
    }
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"调整屏幕";
            break;
        case 1:
        {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"关于我们";
            } else if(indexPath.row == 1){
                cell.textLabel.text = @"意见建议";
            } else if(indexPath.row == 2){
                cell.textLabel.text = @"使用说明";
            }
            break;
        }
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0) {
                ChangeScreenViewController *viewController = [[ChangeScreenViewController alloc]init];
                [self.navigationController pushViewController:viewController animated:YES];
            } else if(indexPath.row == 1){
            } else if(indexPath.row == 2){
            }
        }
        default:
            break;
    }
}

- (void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
