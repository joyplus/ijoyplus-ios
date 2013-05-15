//
//  FeedbackViewController.m
//  UMeng Analysis
//
//  Created by liu yu on 7/12/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "FeedbackViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "L_FeedbackTableViewCell.h"
#import "R_FeedbackTableViewCell.h"
#import "CMConstants.h"

@implementation FeedbackViewController

@synthesize mTextField = _mTextField, mTableView = _mTableView, mToolBar = _mToolBar, mFeedbackDatas = _mFeedbackDatas;


- (void)customizeNavigationBar:(UINavigationBar *)bar
{
    UINavigationBar *navBar = bar;
    navBar.barStyle = UIBarStyleBlackTranslucent;
    navBar.backgroundColor = [UIColor blackColor];

    if ([navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        [navBar setBackgroundImage:[UIImage imageNamed:@"nav_bar_bg"] forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:
                                  [UIImage imageNamed:@"nav_bar_bg"]];
        imageView.frame = navBar.bounds;
        imageView.backgroundColor = [UIColor whiteColor];
        [navBar insertSubview:imageView atIndex:0];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [feedbackClient get];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"用户反馈";
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(backToPrevious) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 55, 44);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;

    self.mTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"messages_tableview_background"]];
    self.mToolBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"messages_toolbar_background"]];

    feedbackClient = [UMFeedback sharedInstance];
    [feedbackClient setAppkey:umengAppKey delegate:(id<UMFeedbackDataDelegate>)self];

//    从缓存取topicAndReplies
    [self initDataArr];
    
    [self updateTableView:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}

-(void)initDataArr{
    if (_mFeedbackDatas == nil) {
        _mFeedbackDatas = [NSMutableArray arrayWithCapacity:5];
    }
    [_mFeedbackDatas removeAllObjects];
    
    NSString *content = @"亲，说说你的使用感受吧，有任何问题我们一定会在第一时间解决哦，你的陪伴会让我们做的更好，谢谢你的支持：)";
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:content,@"content",@"dev_reply",@"type", nil];
    [_mFeedbackDatas addObject:dic];
    [self.mFeedbackDatas addObjectsFromArray: feedbackClient.topicAndReplies] ;

}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark keyboard notification

- (void)keyboardWillShow:(NSNotification *) notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat height = [[[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size.height;
    
    CGRect bottomBarFrame = self.mToolBar.frame;
    {
        [UIView beginAnimations:@"bottomBarUp" context:nil];
        [UIView setAnimationDuration: animationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        bottomBarFrame.origin.y = self.view.bounds.size.height - 44 - height;
        self.mToolBar.frame = bottomBarFrame;
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *) notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat height = [[[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size.height;
    
    CGRect bottomBarFrame = self.mToolBar.frame;
    if (bottomBarFrame.origin.y < 300)
    {
        [UIView beginAnimations:@"bottomBarDown" context:nil];
        [UIView setAnimationDuration: animationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        bottomBarFrame.origin.y += height;
        self.mToolBar.frame = bottomBarFrame;
        [UIView commitAnimations];
    }
}

- (void)backToPrevious {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendFeedback:(id)sender
{
    if ([self.mTextField.text length])
    {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:self.mTextField.text forKey:@"content"];
//        [dictionary setObject:@"2" forKey:@"age_group"];
//        [dictionary setObject:@"female" forKey:@"gender"];
        
        [feedbackClient post:dictionary];
        [self.mTextField resignFirstResponder];

    }
}

#pragma mark tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_mFeedbackDatas count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *content = [[self.mFeedbackDatas objectAtIndex:indexPath.row] objectForKey:@"content"];
    CGSize labelSize = [content sizeWithFont:[UIFont systemFontOfSize:14.0f]
                               constrainedToSize:CGSizeMake(250.0f, MAXFLOAT)
                                   lineBreakMode:NSLineBreakByWordWrapping];


    return labelSize.height + 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *L_CellIdentifier = @"L_UMFBTableViewCell";
    static NSString *R_CellIdentifier = @"R_UMFBTableViewCell";
    
    NSDictionary *data = [self.mFeedbackDatas objectAtIndex:indexPath.row];
    
    if ([[data valueForKey:@"type"] isEqualToString:@"dev_reply"]) {
        L_FeedbackTableViewCell *cell = (L_FeedbackTableViewCell *) [tableView dequeueReusableCellWithIdentifier:L_CellIdentifier];
        if (cell == nil) {
            cell = [[L_FeedbackTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:L_CellIdentifier];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@",@"Angelin：",[data valueForKey:@"content"]];
        cell.dateLabel.text = [data valueForKey:@"datetime"];
        return cell;
    }
    else {
        
        R_FeedbackTableViewCell *cell = (R_FeedbackTableViewCell *) [tableView dequeueReusableCellWithIdentifier:R_CellIdentifier];
        if (cell == nil) {
            cell = [[R_FeedbackTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:R_CellIdentifier];
        }
        
         cell.textLabel.text = [NSString stringWithFormat:@"%@%@",@"我：",[data valueForKey:@"content"]];
        cell.dateLabel.text = [data valueForKey:@"datetime"];
        return cell;
        
    }
}

#pragma mark Umeng Feedback delegate

- (void)updateTableView:(NSError *)error
{
    if ([self.mFeedbackDatas count])
    {
        [self.mTableView reloadData];
        
        int lastRowNumber = [self.mTableView numberOfRowsInSection:0] - 1;
        NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [self.mTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
        

    }
    else
    {

    }
}

- (void)updateTextField:(NSError *)error
{
    self.mTextField.text = @"";
    [feedbackClient get];
}

- (void)getFinishedWithError:(NSError *)error
{
    if (!error)
    {
        [self initDataArr];
        [self updateTableView:error];
    }
}

- (void)postFinishedWithError:(NSError *)error
{
    [self updateTextField:error];
}

#pragma mark scrollow delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [self.mTextField resignFirstResponder];
}

- (void)dealloc {
    feedbackClient.delegate = nil;
}

@end
