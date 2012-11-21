//
//  SettingsViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "PersonalViewController.h"
#import "CustomSearchBar.h"

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
    UITextField *nameTextField;
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
}

@end

@implementation PersonalViewController
@synthesize menuViewControllerDelegate;

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
        
        topImage = [[UIImageView alloc]initWithFrame:CGRectMake(80, 40, 140, 35)];
        topImage.image = [UIImage imageNamed:@"search_top_image"];
        [self.view addSubview:topImage];
        
        personalImage = [[UIImageView alloc]initWithFrame:CGRectMake(60, 115, 402, 150)];
        personalImage.image = [UIImage imageNamed:@"personal_image"];
        [self.view addSubview:personalImage];
        
        nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(165, 130, 260, 22)];
        nameLabel.backgroundColor = [UIColor yellowColor];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = [UIFont boldSystemFontOfSize:18];
        [self.view addSubview:nameLabel];
        
        nameTextField = [[UITextField alloc]initWithFrame:nameLabel.frame];
        nameTextField.textColor = [UIColor whiteColor];
        nameTextField.font = [UIFont boldSystemFontOfSize:17];
        nameTextField.hidden = YES;
        [self.view addSubview:nameTextField];
        
        editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        editBtn.frame = CGRectMake(430, 122, 25, 27);
        [editBtn setBackgroundImage:[UIImage imageNamed:@"edit_btn"] forState:UIControlStateNormal];
        [editBtn addTarget:self action:@selector(editNameBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:editBtn];
        
        supportLabel = [[UILabel alloc]initWithFrame:CGRectMake(70, 252, 80, 30)];
        supportLabel.textAlignment = NSTextAlignmentCenter;
        supportLabel.backgroundColor = [UIColor yellowColor];
        supportLabel.textColor = [UIColor whiteColor];
        supportLabel.font = [UIFont boldSystemFontOfSize:18];
        [self.view addSubview:supportLabel];        
        supportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        supportBtn.frame = supportLabel.frame;
        [supportBtn addTarget:self action:@selector(supportBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:supportBtn];
        
        collectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(70 + supportLabel.frame.size.width + 20, 252, 80, 30)];
        collectionLabel.textAlignment = NSTextAlignmentCenter;
        collectionLabel.backgroundColor = [UIColor yellowColor];
        collectionLabel.textColor = [UIColor whiteColor];
        collectionLabel.font = [UIFont boldSystemFontOfSize:18];
        [self.view addSubview:collectionLabel];
        collectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        collectionBtn.frame = collectionLabel.frame;
        [collectionBtn addTarget:self action:@selector(collectionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:collectionBtn];
        
        sharelabel = [[UILabel alloc]initWithFrame:CGRectMake(70 + supportLabel.frame.size.width*2 + 20, 252, 80, 30)];
        sharelabel.textAlignment = NSTextAlignmentCenter;
        sharelabel.backgroundColor = [UIColor yellowColor];
        sharelabel.textColor = [UIColor whiteColor];
        sharelabel.font = [UIFont boldSystemFontOfSize:18];
        [self.view addSubview:sharelabel];
        shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shareBtn.frame = sharelabel.frame;
        [shareBtn addTarget:self action:@selector(shareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:shareBtn];
        
        listLabel = [[UILabel alloc]initWithFrame:CGRectMake(70 + supportLabel.frame.size.width*3 + 20, 252, 80, 30)];
        listLabel.textAlignment = NSTextAlignmentCenter;
        listLabel.backgroundColor = [UIColor yellowColor];
        listLabel.textColor = [UIColor whiteColor];
        listLabel.font = [UIFont boldSystemFontOfSize:18];
        [self.view addSubview:listLabel];
        listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        listBtn.frame = listLabel.frame;
        [listBtn addTarget:self action:@selector(listBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:listBtn];
        
        myRecordImage = [[UIImageView alloc]initWithFrame:CGRectMake(60, 283, 95, 25)];
        myRecordImage.image = [UIImage imageNamed:@"my_record_image"];
        [self.view addSubview:myRecordImage];
        
        createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        createBtn.frame = CGRectMake(210, 282, 104, 31);
        [createBtn setBackgroundImage:[UIImage imageNamed:@"create_btn"] forState:UIControlStateNormal];
        [createBtn setBackgroundImage:[UIImage imageNamed:@"create_btn_pressed"] forState:UIControlStateHighlighted];
        [createBtn addTarget:self action:@selector(createBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:createBtn];
        
        importDoubanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        importDoubanBtn.frame = CGRectMake(430, 122, 25, 27);
        [importDoubanBtn setBackgroundImage:[UIImage imageNamed:@"import_douban_btn"] forState:UIControlStateNormal];
        [importDoubanBtn setBackgroundImage:[UIImage imageNamed:@"import_douban_btn_pressed"] forState:UIControlStateHighlighted];
        [importDoubanBtn addTarget:self action:@selector(importDoubanBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:editBtn];
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(60, 325, 400, 370) style:UITableViewStylePlain];
        [table setBackgroundColor:[UIColor yellowColor]];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


@end
