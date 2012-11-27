//
//  SettingsViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "PersonalViewController.h"
#import "CustomSearchBar.h"
#import "DingListViewController.h"
#import "CollectionListViewController.h"

#define TABLE_VIEW_WIDTH 370
#define MIN_BUTTON_WIDTH 45
#define MAX_BUTTON_WIDTH 355
#define BUTTON_HEIGHT 33
#define BUTTON_TITLE_GAP 13

@interface PersonalViewController (){
    UIView *backgroundView;
    UIButton *menuBtn;
    UIImageView *topImage;
    UIImageView *bgImage;
   
    UITableView *table;
    
    UIImageView *avatarImage;
    
    UILabel *nameLabel;
    UIButton *editBtn;
    
    UIImageView *personalImage;
    
    UILabel *supportLabel;
    UIButton *supportBtn;
    UILabel *collectionLabel;
    UIButton *collectionBtn;
    UILabel *sharelabel;
    UIButton *shareBtn;
    UILabel *listLabel;
    UIButton *listBtn;
    
    UIImageView *myRecordImage;
    UIButton *createBtn;
    UIButton *importDoubanBtn;
    
    UIImageView *tableBgImage;
}

@end

@implementation PersonalViewController
@synthesize menuViewControllerDelegate;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}
- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 24)];
        [backgroundView setBackgroundColor:[UIColor yellowColor]];
        [self.view addSubview:backgroundView];
        
        bgImage = [[UIImageView alloc]initWithFrame:backgroundView.frame];
        bgImage.image = [UIImage imageNamed:@"left_background"];
        [backgroundView addSubview:bgImage];
        
        menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.frame = CGRectMake(17, 33, 29, 42);
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn"] forState:UIControlStateNormal];
        [menuBtn addTarget:self action:@selector(menuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:menuBtn];
        
        topImage = [[UIImageView alloc]initWithFrame:CGRectMake(80, 40, 187, 36)];
        topImage.image = [UIImage imageNamed:@"my_title"];
        [self.view addSubview:topImage];
        
        personalImage = [[UIImageView alloc]initWithFrame:CGRectMake(60, 164, 404, 102)];
        personalImage.image = [UIImage imageNamed:@"my_summary_bg"];
        [self.view addSubview:personalImage];
        
        avatarImage = [[UIImageView alloc]initWithFrame:CGRectMake(80, 110, 70, 70)];
        NSString *avatarUrl = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserAvatarUrl];
        [avatarImage setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
        avatarImage.layer.borderWidth = 2;
        avatarImage.layer.borderColor = [UIColor whiteColor].CGColor;
        avatarImage.layer.cornerRadius = 5;
        avatarImage.layer.masksToBounds = YES;
        [self.view addSubview:avatarImage];
        
        nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(165, 130, 260, 22)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [UIFont systemFontOfSize:20];
        nameLabel.text = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserNickName];
        [self.view addSubview:nameLabel];
        
//        editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        editBtn.frame = CGRectMake(430, 122, 25, 27);
//        [editBtn setBackgroundImage:[UIImage imageNamed:@"edit_btn"] forState:UIControlStateNormal];
//        [editBtn addTarget:self action:@selector(editNameBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:editBtn];
        
        supportLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 228, 60, 30)];
        supportLabel.backgroundColor = [UIColor clearColor];
        supportLabel.textColor = [UIColor colorWithRed:51/255.0 green:109/255.0 blue:190/255.0 alpha:1];
        supportLabel.text = @"18";
        supportLabel.textAlignment = NSTextAlignmentCenter;
        supportLabel.font = [UIFont boldSystemFontOfSize:22];
        [self.view addSubview:supportLabel];        
        supportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        supportBtn.frame = CGRectMake(70, 180, 88, 87);
        supportBtn.tag = 1001;
        [supportBtn addTarget:self action:@selector(summaryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:supportBtn];
        
        collectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(80 + supportLabel.frame.size.width + 40, 228, 60, 30)];
        collectionLabel.textColor = [UIColor colorWithRed:51/255.0 green:109/255.0 blue:190/255.0 alpha:1];
        collectionLabel.textAlignment = NSTextAlignmentCenter;
        collectionLabel.backgroundColor = [UIColor clearColor];
        collectionLabel.font = [UIFont boldSystemFontOfSize:22];
        collectionLabel.text = @"18";
        [self.view addSubview:collectionLabel];
        collectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        collectionBtn.frame = CGRectMake(70 + supportLabel.frame.size.width + 40, 180, 88, 87);
        collectionBtn.tag = 1002;
        [collectionBtn addTarget:self action:@selector(summaryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:collectionBtn];
        
        sharelabel = [[UILabel alloc]initWithFrame:CGRectMake(80 + (supportLabel.frame.size.width + 40)*2, 228, 60, 30)];
        sharelabel.textAlignment = NSTextAlignmentCenter;
        sharelabel.textColor = [UIColor colorWithRed:51/255.0 green:109/255.0 blue:190/255.0 alpha:1];
        sharelabel.backgroundColor = [UIColor clearColor];
        sharelabel.font = [UIFont boldSystemFontOfSize:22];
        sharelabel.text = @"18";
        [self.view addSubview:sharelabel];
        shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shareBtn.frame = sharelabel.frame;
        shareBtn.frame = CGRectMake(70 + (supportLabel.frame.size.width + 40)*2, 180, 88, 87);
        shareBtn.tag = 1003;
        [shareBtn addTarget:self action:@selector(summaryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:shareBtn];
        
        listLabel = [[UILabel alloc]initWithFrame:CGRectMake(80 + (supportLabel.frame.size.width + 40)*3, 228, 60, 30)];
        listLabel.textAlignment = NSTextAlignmentCenter;
        listLabel.textColor = [UIColor colorWithRed:51/255.0 green:109/255.0 blue:190/255.0 alpha:1];
        listLabel.backgroundColor = [UIColor clearColor];
        listLabel.font = [UIFont boldSystemFontOfSize:22];
        listLabel.text = @"18";
        [self.view addSubview:listLabel];
        listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        listBtn.frame = CGRectMake(70 + (supportLabel.frame.size.width + 40)*3, 180, 88, 87);
        listBtn.tag = 1004;
        [listBtn addTarget:self action:@selector(summaryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:listBtn];
        
        myRecordImage = [[UIImageView alloc]initWithFrame:CGRectMake(60, 283, 95, 25)];
        myRecordImage.image = [UIImage imageNamed:@"my_record"];
        [self.view addSubview:myRecordImage];
        
        createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        createBtn.frame = CGRectMake(210, 282, 104, 31);
        [createBtn setBackgroundImage:[UIImage imageNamed:@"create_list"] forState:UIControlStateNormal];
        [createBtn setBackgroundImage:[UIImage imageNamed:@"create_list_pressed"] forState:UIControlStateHighlighted];
        [createBtn addTarget:self action:@selector(createBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:createBtn];
        
        importDoubanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        importDoubanBtn.frame = CGRectMake(320, 282, 142, 31);
        [importDoubanBtn setBackgroundImage:[UIImage imageNamed:@"import_douban"] forState:UIControlStateNormal];
        [importDoubanBtn setBackgroundImage:[UIImage imageNamed:@"import_douban_pressed"] forState:UIControlStateHighlighted];
        [importDoubanBtn addTarget:self action:@selector(importDoubanBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:importDoubanBtn];
        
        tableBgImage = [[UIImageView alloc]initWithFrame:CGRectMake(60, 325, 402, 370)];
        tableBgImage.image = [[UIImage imageNamed:@"setting_cell_bg"] resizableImageWithCapInsets: UIEdgeInsetsMake(10, 10, 10, 10)];
        [self.view addSubview:tableBgImage];

        table = [[UITableView alloc] initWithFrame:CGRectMake(60, 325, 400, 370) style:UITableViewStylePlain];
        [table setBackgroundColor:[UIColor clearColor]];
        [table setSeparatorStyle:UITableViewCellSelectionStyleNone];
		[table setDelegate:self];
		[table setDataSource:self];
        [table setScrollEnabled:NO];
        [self.view addSubview:table];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)closeMenu
{
    [AppDelegate instance].closed = YES;
    [[AppDelegate instance].rootViewController.stackScrollViewController menuToggle:YES isStackStartView:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return 40;
}

- (void)menuBtnClicked
{
    [self.menuViewControllerDelegate menuButtonClicked];
}

- (void)summaryBtnClicked:(UIButton *)sender
{
    [self closeMenu];
    for(int i = 0; i < 4; i++){
        UIButton *btn = (UIButton *)[self.view viewWithTag:1001 + i];
        [btn setBackgroundImage:nil forState:UIControlStateNormal];
        [btn setBackgroundImage:nil forState:UIControlStateHighlighted];
    }
    [sender setBackgroundImage:[UIImage imageNamed:@"selected_bg"] forState:UIControlStateNormal];
    [sender setBackgroundImage:[UIImage imageNamed:@"selected_bg"] forState:UIControlStateHighlighted];
    if(sender.tag == 1001){
        DingListViewController *viewController = [[DingListViewController alloc] init];
        viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE];
    } else if(sender.tag == 1002){
        CollectionListViewController *viewController = [[CollectionListViewController alloc] init];
        viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE];
    } else if(sender.tag == 1003){
        
    } else if(sender.tag = 1004){
        
    }
}

@end
