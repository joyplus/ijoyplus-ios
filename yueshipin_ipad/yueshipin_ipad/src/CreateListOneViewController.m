//
//  CreateListOneViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CreateListOneViewController.h"
#import "CreateListTwoViewController.h"
#import "CommonHeader.h"
@interface CreateListOneViewController (){
    int type;
    
}

@end

@implementation CreateListOneViewController
@synthesize prodId;

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.titleField];
    [self setTitleImage:nil];
    [self setTitleField:nil];
    [self setContentBgImage:nil];
    [self setContentText:nil];
    [self setNextBtn:nil];
    [self setCloseBtn:nil];
    [self setTitleFieldBg:nil];
    self.prodId = nil;
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
    self.titleImage.frame = CGRectMake(LEFT_WIDTH, 35, 110, 27);
    self.titleImage.image = [UIImage imageNamed:@"create_list_title"];
    
    self.closeBtn.frame = CGRectMake(465, 20, 40, 42);
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    RadioButton *movieType = [[RadioButton alloc] initWithGroupId:@"list type" index:0];
    [movieType setChecked:YES];
    type = 1;
    movieType.frame = CGRectMake(LEFT_WIDTH,100,50,50);
    UILabel *movieTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(movieType.frame.origin.x+30, 100, 100, 20)];
    [movieTypeLabel setBackgroundColor:[UIColor clearColor]];
    movieTypeLabel.textColor = CMConstants.grayColor;
    movieTypeLabel.text = @"电影悦单";
    movieTypeLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:movieTypeLabel];
    
    
    RadioButton *dramaType = [[RadioButton alloc] initWithGroupId:@"list type" index:1];
    dramaType.frame = CGRectMake(LEFT_WIDTH + 150,100,50,50);
    UILabel *dramaTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(dramaType.frame.origin.x+30, 100, 100, 20)];
    [dramaTypeLabel setBackgroundColor:[UIColor clearColor]];
    dramaTypeLabel.textColor = CMConstants.grayColor;
    dramaTypeLabel.text = @"电视剧悦单";
    dramaTypeLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:dramaTypeLabel];
    
    [self.view addSubview:movieType];
    [self.view addSubview:dramaType];
    [RadioButton addObserverForGroupId:@"list type" observer:self];
    
    self.titleFieldBg.frame = CGRectMake(LEFT_WIDTH, 130, 400, 39);
    self.titleFieldBg.image = [UIImage imageNamed:@"box_title"];
    self.titleFieldBg.layer.borderColor = CMConstants.tableBorderColor.CGColor;
    self.titleFieldBg.layer.borderWidth = 1;
    
    self.titleField.frame = CGRectMake(LEFT_WIDTH+5, 133, 390, 33);
    self.titleField.placeholder = @"标题";
    self.titleField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNextBtnImage:) name:UITextFieldTextDidChangeNotification object:self.titleField];
    
    self.contentBgImage.frame = CGRectMake(LEFT_WIDTH, 175, 400, 102);
    self.contentBgImage.image = [UIImage imageNamed:@"box_content"];
    self.contentBgImage.layer.borderColor = CMConstants.tableBorderColor.CGColor;
    self.contentBgImage.layer.borderWidth = 1;
    
    self.contentText.frame = CGRectMake(LEFT_WIDTH+5, 180, 390, 92);
    self.contentText.placeholder = @"简介（可选）";
    
    self.nextBtn.frame = CGRectMake(380, 285, 62, 39);
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"next_disabled"] forState:UIControlStateDisabled];
    [self.nextBtn setBackgroundImage:[UIImage imageNamed:@"next_pressed"] forState:UIControlStateHighlighted];
    [self.nextBtn setEnabled:NO];
    [self.nextBtn addTarget:self action:@selector(nextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeNextBtnImage:(NSNotification *)notificaiton
{
    UITextField *textField = notificaiton.object;
    if(textField.text.length > 0){
        [self.nextBtn setEnabled:YES];
    } else {
        [self.nextBtn setEnabled:NO];
    }
}

- (void)nextBtnClicked:(id)sender
{
    [self.nextBtn setEnabled:NO];
    [self.titleField resignFirstResponder];
    [self.contentText resignFirstResponder];
    [myHUD showProgressBar:self.view];
    if(self.titleField.text.length > 0){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: self.titleField.text, @"name", self.contentText.text, @"content", [NSNumber numberWithInt:type], @"type", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathNew parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if(responseCode == nil){
                [[NSNotificationCenter defaultCenter] postNotificationName:PERSONAL_VIEW_REFRESH object:nil];
                if(![StringUtility stringIsEmpty:self.prodId]){
                    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [result objectForKey:@"topic_id"], @"topic_id", self.prodId, @"prod_id", nil];
                    [[AFServiceAPIClient sharedClient] postPath:kPathAddItem parameters:parameters success:^(AFHTTPRequestOperation *operation, id tempresult) {
                        [myHUD hide];
                        NSString *responseCode = [tempresult objectForKey:@"res_code"];
                        if([responseCode isEqualToString:kSuccessResCode]){
                            [self gotoNextScreen:result];
                        } else {
                            [[AppDelegate instance].rootViewController showFailureModalView:1.5];
                        }
                    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                        [myHUD hide];
                        [UIUtility showSystemError:self.view];
                    }];
                } else {
                    [myHUD hide];
                    [self gotoNextScreen:result];                    
                }
            } else {
                [myHUD hide];
                [[AppDelegate instance].rootViewController showListFailureModalView:1.5];
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            [myHUD hide];
            [UIUtility showSystemError:self.view];
        }];
    }
}

- (void)gotoNextScreen:(id)result
{
    CreateListTwoViewController *viewController = [[CreateListTwoViewController alloc]initWithNibName:@"CreateListTwoViewController" bundle:nil];
    viewController.view.frame = CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height);
    viewController.titleContent = self.titleField.text;
    viewController.topId = [NSString stringWithFormat:@"%@", [result objectForKey:@"topic_id"]];
    viewController.type = type;
    [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
}

-(void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString *)groupId{
    type = index + 1;
}
@end
