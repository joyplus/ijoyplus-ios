//
//  SearchPreViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-27.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SearchPreViewController.h"
#import "IphoneSearchViewController.h"

@interface SearchPreViewController ()

@end

@implementation SearchPreViewController
@synthesize searchBar = searchBar_;
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
    self.title = @"搜索";
	// Do any additional setup after loading the view.
    searchBar_ = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchBar_.delegate = self;
    [self.view addSubview:searchBar_];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    IphoneSearchViewController *searchViewController = [[IphoneSearchViewController alloc] init];
    searchViewController.keyWords = searchBar_.text;
    [self.navigationController pushViewController:searchViewController animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
