//
//  CreateMyListOneViewController.m
//  yueshipin
//
//  Created by 08 on 13-1-5.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "CreateMyListOneViewController.h"
#import "SSCheckBoxView.h"
#import "RadioButton.h"
#import "CreateMyListTwoViewController.h"
#import "ServiceConstants.h"
#import "AFServiceAPIClient.h"
@interface CreateMyListOneViewController ()

@end

@implementation CreateMyListOneViewController
@synthesize titleTextField = titleTextField_;
@synthesize detailTextView = detailTextView_;
@synthesize infoDic = infoDic_;
@synthesize topicId = topicId_;
@synthesize nextBtn = nextBtn_;
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
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    bg.frame = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:bg];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 40, 30);
    [backButton setImage:[UIImage imageNamed:@"top_icon_common_writing_cancel.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"top_icon_common_writing_cancel_s.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    nextBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn_ addTarget:self action:@selector(nextButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn_.frame = CGRectMake(0, 0, 51, 31);
    nextBtn_.enabled = NO;
    [nextBtn_ setImage:[UIImage imageNamed:@"top_icon_writing_next.png"] forState:UIControlStateNormal];
    [nextBtn_ setImage:[UIImage imageNamed:@"top_icon_writing_next_s.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:nextBtn_];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    RadioButton *rb1 = [[RadioButton alloc] initWithGroupId:@"first group" index:0];
    RadioButton *rb2 = [[RadioButton alloc] initWithGroupId:@"first group" index:1];
    rb1.frame = CGRectMake(50,34,22,22);
    rb2.frame = CGRectMake(150,34,22,22);
    [rb1 setChecked:YES];
    [self.view addSubview:rb1];
    [self.view addSubview:rb2];
    [RadioButton addObserverForGroupId:@"first group" observer:self];
    
    UILabel *movie = [[UILabel alloc] initWithFrame:CGRectMake(90, 30, 70, 30)];
    movie.text = @"电影";
    movie.font = [UIFont systemFontOfSize:15];
    movie.backgroundColor = [UIColor clearColor];
    movie.textColor = [UIColor grayColor];
    UILabel *tv = [[UILabel alloc] initWithFrame:CGRectMake(190, 30, 80, 30)];
    tv.text = @"电视剧";
    tv.backgroundColor = [UIColor clearColor];
    tv.font = [UIFont systemFontOfSize:15];
    tv.textColor = [UIColor grayColor];
    titleTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(20, 70, 280, 25)];
    titleTextField_.placeholder = @" 标题";
    titleTextField_.backgroundColor = [UIColor whiteColor];
    titleTextField_.delegate = self;
    
    detailTextView_ = [[UITextView alloc] initWithFrame:CGRectMake(20, 105, 280, 90)];
    detailTextView_.delegate = self;
    detailTextView_.font = [UIFont systemFontOfSize:15];
    detailLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 100, 25)];
    detailLabel_.backgroundColor = [UIColor clearColor];
    detailLabel_.textColor = [UIColor grayColor];
    detailLabel_.font = [UIFont systemFontOfSize:15];
    detailLabel_.text = @"简介";
    [detailTextView_ addSubview:detailLabel_];
    [self.view addSubview:movie];
    [self.view addSubview:tv];
    [self.view addSubview:titleTextField_];
    [self.view addSubview:detailTextView_];
    
    
   
    
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *newString = nil;
	if (range.length == 0) {
		newString = [textField.text stringByAppendingString:string];
	} else {
		NSString *headPart = [textField.text substringToIndex:range.location];
		NSString *tailPart = [textField.text substringFromIndex:range.location+range.length];
		newString = [NSString stringWithFormat:@"%@%@",headPart,tailPart];
	}
    if ([newString isEqualToString:@""] && [string isEqualToString:@""]) {
        nextBtn_.enabled = NO;
    }
    else{
    
        nextBtn_.enabled = YES;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    NSString *str = textView.text;
    if (![str isEqualToString:@""]) {
        [detailLabel_ removeFromSuperview];
       
    }
    else{
       [detailTextView_ addSubview:detailLabel_];
         
    }
}
-(void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString *)groupId{

}
-(void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)nextButtonPressed:(id)sender{
     NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: titleTextField_.text, @"name", detailTextView_.text, @"content", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathNew parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        topicId_ = [result objectForKey:@"topic_id"];
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            [self next:result];
        }
        else {
            
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
       
    }];

}
-(void)next:(id)result{
    infoDic_ = [NSMutableDictionary dictionaryWithCapacity:10];
    [infoDic_ setObject:self.titleTextField.text forKey:@"name"];
    [infoDic_ setObject:self.detailTextView.text forKey:@"detail"];
    [infoDic_ setObject:topicId_ forKey:@"topic_id"];
    CreateMyListTwoViewController *createMyListTwoViewController = [[CreateMyListTwoViewController alloc] init];
    createMyListTwoViewController.infoDic = infoDic_;
    createMyListTwoViewController.topicId = [result objectForKey:@"topic_id"];
    
    [self.navigationController pushViewController:createMyListTwoViewController animated:YES];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
