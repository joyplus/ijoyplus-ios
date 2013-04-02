//
//  HomeViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ComicViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DDPageControl.h"
#import "MovieDetailViewController.h"
#import "DramaDetailViewController.h"
#import "ShowDetailViewController.h"
#import "ListViewController.h"
#import "SubsearchViewController.h"
#import "CommonHeader.h"

#define BOTTOM_IMAGE_HEIGHT 20
#define TOP_IMAGE_HEIGHT 167
#define LIST_LOGO_WIDTH 220
#define LIST_LOGO_HEIGHT 180
#define VIDEO_BUTTON_WIDTH 118
#define VIDEO_BUTTON_HEIGHT 29
#define TOP_SOLGAN_HEIGHT 93
#define SLIDER_VIEW_TAG 8924355

@interface ComicViewController (){
    UIView *backgroundView;
    UIImageView *sloganImageView;
    UIView *contentView;
    UITableView *table;
    UIImageView *bgImage;
    int videoType; // 0: 悦单 1: 电影 2: 电视剧 3: 综艺
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    NSUInteger reloads_;
    int pageSize;    
    NSString *umengPageName;
}
@property (nonatomic, strong) NSArray *btnLabelArray;
@property (nonatomic, strong) UIView *topCategoryView;
@property (nonatomic, strong) UIView *subcategoryView;

@end

@implementation ComicViewController
@synthesize topCategoryView;
@synthesize btnLabelArray;
@synthesize subcategoryView;

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 24)];
        [backgroundView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:backgroundView];
        
        UITapGestureRecognizer *hideSubcategoryViewGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideSubcategoryView)];
        [hideSubcategoryViewGesture setNumberOfTapsRequired:1];
        [backgroundView addGestureRecognizer:hideSubcategoryViewGesture];

        sloganImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"slogan"]];
        sloganImageView.frame = CGRectMake(15, 36, 261, 42);
        [backgroundView addSubview:sloganImageView];
        
        topCategoryView = [[UIView alloc]initWithFrame:CGRectMake(5, 100, backgroundView.frame.size.width-15, 50)];
        [topCategoryView setBackgroundColor:[UIColor yellowColor]];
        UIImageView *topCatBgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, topCategoryView.frame.size.width, 45)];
        topCatBgImage.image = [UIImage imageNamed:@"top_category_bg"];
        [topCategoryView addSubview:topCatBgImage];
        
        UIView *sliderView = [[UIView alloc]initWithFrame:CGRectMake(5, 0, 50, 45)];
        sliderView.backgroundColor = CMConstants.yellowColor;
        sliderView.tag = SLIDER_VIEW_TAG;
        sliderView.layer.cornerRadius = 5;
        sliderView.layer.masksToBounds = YES;
        [topCategoryView addSubview:sliderView];
        btnLabelArray = [NSArray arrayWithObjects:@"全部", @"日本", @"欧美", @"国产", @"情感", @"科幻", @"热血", @"推理", @"搞笑", @"更多", nil];
        for (int i = 0; i < btnLabelArray.count; i++) {
            UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            tempBtn.frame = CGRectMake(5 + i * 50, 0, 50, 45);
            [tempBtn setBackgroundImage:nil forState:UIControlStateNormal];
            [tempBtn setBackgroundImage:nil forState:UIControlStateHighlighted];
            [tempBtn setBackgroundImage:nil forState:UIControlStateSelected];
            [tempBtn setTitle:[btnLabelArray objectAtIndex:i] forState:UIControlStateNormal];
            [tempBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
            [tempBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            tempBtn.tag = 1101 + i;
            [tempBtn addTarget:self action:@selector(categoryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [topCategoryView addSubview:tempBtn];
        }
        [backgroundView addSubview:topCategoryView];
               
        table = [[UITableView alloc] initWithFrame:CGRectMake(9, 150, backgroundView.frame.size.width - 18, backgroundView.frame.size.height - TOP_SOLGAN_HEIGHT - BOTTOM_IMAGE_HEIGHT) style:UITableViewStylePlain];
        [table setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [table setBackgroundColor:[UIColor yellowColor]];
		[table setDelegate:self];
		[table setDataSource:self];
        [table setBackgroundColor:[UIColor clearColor]];
        [table setShowsVerticalScrollIndicator:NO];
		[table setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
		[backgroundView addSubview:table];
        
        pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:table withClient:self];
        reloads_ = 2;
    }
    return self;
}

- (void)hideSubcategoryView
{
    subcategoryView.alpha = 0;
    for (UIView *subview in subcategoryView.subviews) {
        subview.alpha = 0;
    }
    [subcategoryView setHidden:YES];
    [subcategoryView removeFromSuperview];
}

- (void)loadTable {
    [table reloadData];
    [pullToRefreshManager_ tableViewReloadFinished];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (umengPageName) {
        [MobClick endLogPageView:umengPageName];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pageSize = 20;
    videoType = 0;
}

- (void)reloadTableViewDataSource{
    reloads_ = 2;
}

- (void)categoryBtnClicked:(UIButton *)btn
{
    int num = btn.tag - 1101;
    for (int i = 0; i < btnLabelArray.count; i++) {
        UIButton *tempBtn = (UIButton *)[topCategoryView viewWithTag:1101 + i];
        if (tempBtn.tag == btn.tag) {
            [tempBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            [tempBtn setTitleColor:[UIColor colorWithRed:132/255.0 green:132/255.0 blue:129/255.0 alpha:1] forState:UIControlStateNormal];
        }
    }
    UIView *sliderView = [topCategoryView viewWithTag:SLIDER_VIEW_TAG];
    if (sliderView) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
            sliderView.frame = CGRectMake(5 + num * 50, 0, sliderView.frame.size.width, sliderView.frame.size.height);
        } completion:^(BOOL finished) {
            if (num == btnLabelArray.count - 1) {
                [self showSubcategoryView];
            } else {
                [self hideSubcategoryView];
            }
        }];
    }
}

- (void)showSubcategoryView
{
    if (subcategoryView == nil) {
        subcategoryView = [[UIView alloc]initWithFrame:CGRectMake(10, 130, 500, 350)];
        subcategoryView.alpha = 0;
        [subcategoryView setBackgroundColor:[UIColor whiteColor]];
        NSArray *categoryLabelArray = [NSArray arrayWithObjects:@"全部", @"情感", @"科幻", @"热血", @"推理", @"搞笑", @"冒险", @"萝莉", @"校园", @"动作", @"机战", @"运动", @"耽美", @"战争", @"少年", @"少年", @"社会", @"原创", @"亲子", @"益智", @"励志", @"百合", @"其他", nil];
        NSArray *regionLabelArray = [NSArray arrayWithObjects:@"全部", @"日本", @"欧美", @"国产", @"其他", nil];
        NSDate * nowDate = [NSDate date];
        NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
        [dateformat setDateFormat:@"yyyy"];
        int year = [[dateformat stringFromDate:nowDate] integerValue];
        NSMutableArray *yearLabelArray = [[NSMutableArray alloc]initWithCapacity:12];
        [yearLabelArray addObject:@"全部"];
        for (int i = 1; i < 11; i++) {
            [yearLabelArray addObject:[NSString stringWithFormat:@"%i", year - i]];
        }
        [yearLabelArray addObject:@"其他"];
        UILabel *categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 50, 40, 45)];
        categoryLabel.textColor = CMConstants.grayColor;
        [categoryLabel setFont:[UIFont systemFontOfSize:15]];
        categoryLabel.text = @"类型";
        [subcategoryView addSubview:categoryLabel];
        
        for (int i = 0; i < categoryLabelArray.count; i++) {
            NSString *tempLabel = [categoryLabelArray objectAtIndex:i];
            UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            tempBtn.frame = CGRectMake(70 + (i%8) * 51, categoryLabel.frame.origin.y + (i/8) * 50, 50, 45);
            [tempBtn setBackgroundImage:nil forState:UIControlStateNormal];
            [tempBtn setBackgroundImage:nil forState:UIControlStateHighlighted];
            [tempBtn setBackgroundImage:nil forState:UIControlStateSelected];
            tempBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            [tempBtn setTitle:tempLabel forState:UIControlStateNormal];
            [tempBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
            [tempBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            tempBtn.tag = 1201 + i;
            [tempBtn addTarget:self action:@selector(subcategoryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [subcategoryView addSubview:tempBtn];
        }
        
        UILabel *regionLabel = [[UILabel alloc]initWithFrame:CGRectMake(categoryLabel.frame.origin.x, 200, categoryLabel.frame.size.width, categoryLabel.frame.size.height)];
        regionLabel.textColor = CMConstants.grayColor;
        [regionLabel setFont:[UIFont systemFontOfSize:15]];
        regionLabel.text = @"地区";
        [subcategoryView addSubview:regionLabel];
        for (int i = 0; i < regionLabelArray.count; i++) {
            NSString *tempLabel = [regionLabelArray objectAtIndex:i];
            UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            tempBtn.frame = CGRectMake(70 + (i%8) * 51, regionLabel.frame.origin.y, 50, 45);
            [tempBtn setBackgroundImage:nil forState:UIControlStateNormal];
            [tempBtn setBackgroundImage:nil forState:UIControlStateHighlighted];
            [tempBtn setBackgroundImage:nil forState:UIControlStateSelected];
            tempBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            [tempBtn setTitle:tempLabel forState:UIControlStateNormal];
            [tempBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
            [tempBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            tempBtn.tag = 1301 + i;
            [tempBtn addTarget:self action:@selector(subcategoryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [subcategoryView addSubview:tempBtn];
        }
        
        UILabel *yearLabel = [[UILabel alloc]initWithFrame:CGRectMake(categoryLabel.frame.origin.x, 250, categoryLabel.frame.size.width, categoryLabel.frame.size.height)];
        yearLabel.contentMode = UIControlContentVerticalAlignmentCenter;
        yearLabel.textColor = CMConstants.grayColor;
        [yearLabel setFont:[UIFont systemFontOfSize:15]];
        yearLabel.text = @"年份";
        [subcategoryView addSubview:yearLabel];
        for (int i = 0; i < yearLabelArray.count; i++) {
            NSString *tempLabel = [yearLabelArray objectAtIndex:i];
            UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            tempBtn.frame = CGRectMake(70 + (i%8) * 51, yearLabel.frame.origin.y + (i/8) * 50, 50, 45);
            [tempBtn setBackgroundImage:nil forState:UIControlStateNormal];
            [tempBtn setBackgroundImage:nil forState:UIControlStateHighlighted];
            [tempBtn setBackgroundImage:nil forState:UIControlStateSelected];
            tempBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            [tempBtn setTitle:tempLabel forState:UIControlStateNormal];
            [tempBtn setTitleColor:CMConstants.grayColor forState:UIControlStateNormal];
            [tempBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            tempBtn.tag = 1301 + i;
            [tempBtn addTarget:self action:@selector(subcategoryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [subcategoryView addSubview:tempBtn];
        }
        for (UIView *subview in subcategoryView.subviews) {
            subview.alpha = 0;
        }
    }
    [backgroundView addSubview:subcategoryView];
    [subcategoryView setHidden:NO];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        for (UIView *subview in subcategoryView.subviews) {
            subview.alpha = 1;
        }
        subcategoryView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)subcategoryBtnClicked:(UIButton *)btn
{

}

#pragma mark -
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    [pullToRefreshManager_ tableViewScrolled];
}

- (void)MNMBottomPullToRefreshManagerClientReloadTable {
    if (videoType == 0 || videoType == 3) {
        if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
            [UIUtility showNetWorkError:self.view];
            [self performSelector:@selector(loadTable) withObject:nil afterDelay:0.0f];
            return;
               
        
        }
    }
}
#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(indexPath.section == 0){
        static NSString *CellIdentifier = @"topImageCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
        }
    }
    return cell;
}

- (void)showDetailScreen:(NSDictionary *)item
{
    NSString *prodType = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]];
    if([prodType isEqualToString:@"1"]){
        MovieDetailViewController *viewController = [[MovieDetailViewController alloc] initWithNibName:@"MovieDetailViewController" bundle:nil];
        viewController.fromViewController = self;
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        viewController.prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE  removePreviousView:YES];
    } else if([prodType isEqualToString:@"2"] || [prodType isEqualToString:@"131"]){
        DramaDetailViewController *viewController = [[DramaDetailViewController alloc] initWithNibName:@"DramaDetailViewController" bundle:nil];
        viewController.fromViewController = self;
        viewController.prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
    } else if([prodType isEqualToString:@"3"]){
        ShowDetailViewController *viewController = [[ShowDetailViewController alloc] initWithNibName:@"ShowDetailViewController" bundle:nil];
        viewController.fromViewController = self;
        viewController.prodId = [NSString stringWithFormat:@"%@", [item objectForKey:@"prod_id"]];
        viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
    }
}

- (void)updatePressedBtn:(UIButton *)btn pressedLabel:(UILabel *)pressedLabel selectedRow:(NSInteger)selectedRow
{
//    if(lastPressedBtn != nil){
//        lastPressedLabel.textColor = [UIColor blackColor];
//        [lastPressedBtn setBackgroundImage:[UIImage imageNamed:@"moviecard"] forState:UIControlStateNormal];
//    }
//    pressedLabel.textColor = [UIColor whiteColor];
//    [btn setBackgroundImage:[UIImage imageNamed:@"moviecard_pressed"] forState:UIControlStateNormal];
//    lastPressedLabel = pressedLabel;
//    selectedRowNumber = selectedRow;
//    lastPressedBtn = btn;
//    lastSelectedListImage = nil;
//    lastSelectedOverlay = nil;
}

- (void)movieImageClicked:(UIButton *)btn
{
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    
    UILabel *titleLabel = (UILabel *)[[btn superview] viewWithTag:btn.tag + 1000];
    [self updatePressedBtn:btn pressedLabel:titleLabel selectedRow:indexPath.row];
//    if (indexPath.row >= 0 && indexPath.row < movieTopsArray.count) {
//        NSArray *items = [[movieTopsArray objectAtIndex:indexPath.row] objectForKey:@"items"];
//        if(btn.tag - 2011 < items.count){
//            NSDictionary *item = [items objectAtIndex:btn.tag - 2011];
//            [self showDetailScreen:item];
//        }
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 145;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


@end
