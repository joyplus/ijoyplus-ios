//
//  HomeViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "HomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "DDPageControl.h"
#import "MovieDetailViewController.h"

#define BOTTOM_IMAGE_HEIGHT 20
#define TOP_IMAGE_HEIGHT 167
#define LIST_LOGO_WIDTH 220
#define LIST_LOGO_HEIGHT 180
#define VIDEO_BUTTON_WIDTH 119
#define VIDEO_BUTTON_HEIGHT 29
#define TOP_SOLGAN_HEIGHT 93

@interface HomeViewController (){
    UIView *backgroundView;
    UIButton *menuBtn;
    UIImageView *sloganImageView;
    UIButton *searchBtn;
    UIView *contentView;
    UITableView *table;
    UIScrollView *scrollView;
    DDPageControl *pageControl;
    UIButton *listBtn;
    UIButton *movieBtn;
    UIButton *dramaBtn;
    UIButton *showBtn;
    UIImageView *bottomImageView;
}

@end

@implementation HomeViewController
@synthesize menuViewControllerDelegate;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 32)];
        [backgroundView setBackgroundColor:[UIColor yellowColor]];
        [self.view addSubview:backgroundView];
        
        UIImageView *bgImage = [[UIImageView alloc]initWithFrame:backgroundView.frame];
        bgImage.image = [UIImage imageNamed:@"left_background"];
        [backgroundView addSubview:bgImage];
        
		menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.frame = CGRectMake(17, 33, 29, 42);
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn"] forState:UIControlStateNormal];
        [menuBtn addTarget:self action:@selector(menuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:menuBtn];
        
        sloganImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"slogan"]];
        sloganImageView.frame = CGRectMake(80, 36, 265, 42);
        [backgroundView addSubview:sloganImageView];
        
        searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        searchBtn.frame = CGRectMake(440, 48, 42, 30);
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"search_btn"] forState:UIControlStateNormal];
        [searchBtn setBackgroundImage:[UIImage imageNamed:@"search_pressed_btn"] forState:UIControlStateHighlighted];

        [searchBtn addTarget:self action:@selector(searchBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:searchBtn];
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(8, 92, backgroundView.frame.size.width - 16, backgroundView.frame.size.height - TOP_SOLGAN_HEIGHT - BOTTOM_IMAGE_HEIGHT) style:UITableViewStylePlain];
        [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		[table setDelegate:self];
		[table setDataSource:self];
        [table setShowsVerticalScrollIndicator:NO];
		[table setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
		[backgroundView addSubview:table];
        
        bottomImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 8, self.view.frame.size.width, 20)];
        [backgroundView addSubview:bottomImageView];
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)pageControlClicked:(id)sender
{
	DDPageControl *thePageControl = (DDPageControl *)sender ;
	[scrollView setContentOffset: CGPointMake(scrollView.bounds.size.width * thePageControl.currentPage, scrollView.contentOffset.y) animated: YES] ;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
	CGFloat pageWidth = scrollView.bounds.size.width ;
    float fractionalPage = scrollView.contentOffset.x / pageWidth ;
	NSInteger nearestNumber = lround(fractionalPage) ;
	
	if (pageControl.currentPage != nearestNumber)
	{
		pageControl.currentPage = nearestNumber ;
		
		// if we are dragging, we want to update the page control directly during the drag
		if (scrollView.dragging)
			[pageControl updateCurrentPageDisplay] ;
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView
{
	// if we are animating (triggered by clicking on the page control), we update the page control
	[pageControl updateCurrentPageDisplay] ;
}

- (void)closeMenu
{
    [AppDelegate instance].closed = YES;
    [[AppDelegate instance].rootViewController.stackScrollViewController menuToggle:YES isStackStartView:YES];
}

- (void)videoBtnClicked:(UIButton *)sender
{
    [self closeMenu];
    if(sender.tag = 1001){
        MovieDetailViewController *viewController = [[MovieDetailViewController alloc] initWithNibName:@"MovieDetailViewController" bundle:nil];
        viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE];
        
    }
}

- (void)menuBtnClicked
{
    [self.menuViewControllerDelegate menuButtonClicked];
}

- (void)searchBtnClicked
{
    
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 1;
    } else {
        return 5;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if(indexPath.section == 0){
        NSString *CellIdentifier = @"topImageCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TOP_IMAGE_HEIGHT)];
            scrollView.delegate = self;
            NSMutableArray *imageArray = [[NSMutableArray alloc]initWithCapacity:10];
            for(int i = 0; i < 5; i++){
                [imageArray addObject:@"url"];
            }
            CGSize size = scrollView.frame.size;
            for (int i=0; i < imageArray.count; i++) {
                UIImageView *temp = [[UIImageView alloc]init];
                [temp setImageWithURL:[NSURL URLWithString:@""]
                     placeholderImage:[UIImage imageNamed:@"top_image_placeholder"]];
                temp.frame = CGRectMake(size.width * i, 0, size.width, size.height);
                [scrollView addSubview:temp];
            }
            scrollView.layer.zPosition = 1;
            [scrollView setContentSize:CGSizeMake(size.width * imageArray.count, size.height)];
            scrollView.pagingEnabled = YES;
            scrollView.showsHorizontalScrollIndicator = NO;
            [cell.contentView addSubview:scrollView];
            
            pageControl = [[DDPageControl alloc] init] ;
            [pageControl setCenter: CGPointMake(self.view.center.x, TOP_IMAGE_HEIGHT + 10)] ;
            [pageControl setNumberOfPages: 5] ;
            [pageControl setCurrentPage: 0] ;
            [pageControl addTarget: self action: @selector(pageControlClicked:) forControlEvents: UIControlEventValueChanged] ;
            [pageControl setDefersCurrentPageDisplay: YES] ;
            [pageControl setType: DDPageControlTypeOnFullOffEmpty] ;
            [pageControl setOnColor: [UIColor colorWithRed:160/255.0 green:180/255.0 blue:195/255.0 alpha: 1.0f]] ;
            [pageControl setOffColor: [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha: 1.0f]] ;

            [pageControl setIndicatorDiameter: 7.0f] ;
            [pageControl setIndicatorSpace: 8.0f] ;
            pageControl.layer.borderWidth = 3;
            pageControl.layer.borderColor = [UIColor whiteColor].CGColor;
            pageControl.layer.zPosition = 1;
            [cell.contentView addSubview:pageControl];
        }
    } else {
        NSString *CellIdentifier = @"contentCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
            UIImageView *imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(22, 0, LIST_LOGO_WIDTH, LIST_LOGO_HEIGHT)];
            imageView1.tag = 2001;
            [cell.contentView addSubview:imageView1];
            
            UIImageView *hotImage1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"hot"]];
            hotImage1.frame = CGRectMake(3, 3, 62, 62);
            [imageView1 addSubview:hotImage1];
            
            UIButton *imageBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
            imageBtn1.frame = imageView1.frame;
            [imageBtn1 addTarget:self action:@selector(imageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            imageBtn1.tag = 3001;
            [cell.contentView addSubview:imageBtn1];
            
            UILabel *nameLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(imageView1.frame.origin.x + 18, LIST_LOGO_HEIGHT - 35, 180, 20)];
            [nameLabel1 setBackgroundColor:[UIColor clearColor]];
            [nameLabel1 setTextColor:[UIColor whiteColor]];
            [nameLabel1 setFont:[UIFont boldSystemFontOfSize:15]];
            nameLabel1.tag = 6001;
            [cell.contentView addSubview:nameLabel1];
            
            UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(22 + LIST_LOGO_WIDTH + 18, 0, LIST_LOGO_WIDTH, LIST_LOGO_HEIGHT)];
            imageView2.tag = 2002;
            [cell.contentView addSubview:imageView2];
            
            UIImageView *hotImage2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"hot"]];
            hotImage2.frame = CGRectMake(3, 3, 62, 62);
            [imageView2 addSubview:hotImage2];
            
            UIButton *imageBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
            imageBtn2.frame = imageView2.frame;
            [imageBtn2 addTarget:self action:@selector(imageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            imageBtn2.tag = 3002;
            [cell.contentView addSubview:imageBtn2];
            
            UILabel *nameLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(imageView2.frame.origin.x + 18, LIST_LOGO_HEIGHT - 35, 180, 20)];
            [nameLabel2 setBackgroundColor:[UIColor clearColor]];
            [nameLabel2 setTextColor:[UIColor whiteColor]];
            [nameLabel2 setFont:[UIFont boldSystemFontOfSize:15]];
            nameLabel2.tag = 7001;
            [cell.contentView addSubview:nameLabel2];
            
            for(int i = 0; i < 3; i++){
                UIView *dotView1 = [self getDotView:6];
                dotView1.center = CGPointMake(120, 33 + 18 * i);
                [imageView1 addSubview:dotView1];
                
                UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(150, 23 + i * 19, 80, 20)];
                [label1 setBackgroundColor:[UIColor clearColor]];
                [label1 setTextColor:[UIColor lightGrayColor]];
                [label1 setFont:[UIFont systemFontOfSize:12]];
                label1.tag = 4001 + i;
                [cell.contentView addSubview:label1];
                
                UIView *dotView11 = [self getDotView:4];
                dotView11.center = CGPointMake(130 + 6 * i, 90);
                [imageView1 addSubview:dotView11];
                
                UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(388, 23 + i * 19, 80, 20)];
                [label2 setBackgroundColor:[UIColor clearColor]];
                [label2 setTextColor:[UIColor lightGrayColor]];
                [label2 setFont:[UIFont systemFontOfSize:12]];
                label2.tag = 5001 + i;
                [cell.contentView addSubview:label2];
                
                UIView *dotView2 = [self getDotView:6];
                dotView2.center = CGPointMake(120, 33 + 18 * i);
                [imageView2 addSubview:dotView2];
                
                UIView *dotView22 = [self getDotView:4];
                dotView22.center = CGPointMake(130 + 6 * i, 90);
                [imageView2 addSubview:dotView22];
            }
        }
        UIImageView *imageView1 = (UIImageView *)[cell viewWithTag:2001];
        [imageView1 setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"briefcard_orange"]];

        UIImageView *imageView2 = (UIImageView *)[cell viewWithTag:2002];
        [imageView2 setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"briefcard_blue"]];
        
        UILabel *nameLabel1 = (UILabel *)[cell viewWithTag:6001];
        nameLabel1.text = @"name1";
        [nameLabel1 sizeToFit];
        UILabel *nameLabel2 = (UILabel *)[cell viewWithTag:7001];
        nameLabel2.text = @"name2";
        [nameLabel2 sizeToFit];
        
        
        for(int i = 0; i < 3; i++){
            UILabel *label1 = (UILabel *)[cell viewWithTag:(4001 + i)];
            label1.text = [NSString stringWithFormat:@"name%i", i];
            [label1 sizeToFit];
            
            UILabel *label2 = (UILabel *)[cell viewWithTag:(5001 + i)];
            label2.text = [NSString stringWithFormat:@"name%i", i];
            [label2 sizeToFit];
        }

    }
    return cell;
}

- (void)imageBtnClicked:(UIButton *)sender
{
    UIButton *btn = (UIButton *)sender;
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return TOP_IMAGE_HEIGHT + 16;
    } else {
        return LIST_LOGO_HEIGHT + 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return 0;
    } else {
        return 40;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 40)];
    customView.backgroundColor = [UIColor blackColor];
    if(listBtn == nil){
        listBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        listBtn.frame = CGRectMake(12, 0, VIDEO_BUTTON_WIDTH, VIDEO_BUTTON_HEIGHT);
        [listBtn setBackgroundImage:[UIImage imageNamed:@"list_btn_pressed"] forState:UIControlStateNormal];
        listBtn.tag = 1001;
        [listBtn addTarget:self action:@selector(videoBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [customView addSubview:listBtn];
        
        movieBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        movieBtn.frame = CGRectMake(12 + VIDEO_BUTTON_WIDTH + 6, 0, VIDEO_BUTTON_WIDTH, VIDEO_BUTTON_HEIGHT);
        [movieBtn setBackgroundImage:[UIImage imageNamed:@"movie_btn"] forState:UIControlStateNormal];
        movieBtn.tag = 1002;
        [movieBtn addTarget:self action:@selector(videoBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [customView addSubview:movieBtn];
        
        dramaBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        dramaBtn.frame = CGRectMake(12 + (VIDEO_BUTTON_WIDTH + 6)*2, 0, VIDEO_BUTTON_WIDTH, VIDEO_BUTTON_HEIGHT);
                [dramaBtn setBackgroundImage:[UIImage imageNamed:@"drama_btn"] forState:UIControlStateNormal];
        dramaBtn.tag = 1003;
        [dramaBtn addTarget:self action:@selector(videoBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [customView addSubview:dramaBtn];
        
        showBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        showBtn.frame = CGRectMake(12 + (VIDEO_BUTTON_WIDTH + 6)*3, 0, VIDEO_BUTTON_WIDTH, VIDEO_BUTTON_HEIGHT);
                [showBtn setBackgroundImage:[UIImage imageNamed:@"show_btn"] forState:UIControlStateNormal];
        showBtn.tag = 1004;
        [showBtn addTarget:self action:@selector(videoBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [customView addSubview:showBtn];
    }
    
    return customView;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)getDotView:(int)radius
{
    UIView *dotView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, radius, radius)];
    dotView.layer.cornerRadius = 5;
    dotView.layer.masksToBounds = YES;
    dotView.backgroundColor = [UIColor colorWithRed:129/255.0 green:129/255.0 blue:129/255.0 alpha:1.0];
    return dotView;
}

@end
