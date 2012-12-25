//
//  PageManageViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "PageManageViewController.h"
#import "sortedViewController.h"
#define PAGE_NUM 3

@interface PageManageViewController ()

@end

@implementation PageManageViewController
@synthesize scrollView = scrollView_;
@synthesize pageControl = pageControl_;

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
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 380)];
    self.scrollView.contentSize = CGSizeMake(320*PAGE_NUM, 380);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    
   
    
    for (int i = 0; i < PAGE_NUM; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(320*i, 0, 100, 100)];
        button.backgroundColor = [UIColor redColor];
        [button setTitle:[NSString stringWithFormat:@"%d",i] forState:UIControlStateNormal];
        //[button setFrame:CGRectMake(320*i, 0, 100, 100)];
        [self.scrollView addSubview:button];
        
    }
    [self.view addSubview:self.scrollView];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(125, 327, 70, 26)];
    self.pageControl.numberOfPages = PAGE_NUM;
    self.pageControl.currentPage = 0;
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.pageControl];
    
}

//- (void)scrollViewDidScroll:(UIScrollView *)sender {
//    
//    int page = sender.contentOffset.x / 320;
//    
//    self.pageControl.currentPage = page;
//    
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offsetofScrollView = scrollView.contentOffset;
    [self.pageControl setCurrentPage:offsetofScrollView.x / scrollView.frame.size.width];
}
-(void)changePage:(UIPageControl *)aPageControl {
    int whichPage = aPageControl.currentPage;
    
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:0.3f];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [self.scrollView setContentOffset:CGPointMake(320.0f * whichPage, 0.0f) animated:YES];
    
    [UIView commitAnimations];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
