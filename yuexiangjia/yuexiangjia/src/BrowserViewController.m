//
//  GroupImageViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "BrowserViewController.h"
#import "CommonHeader.h"
#import "DDList.h"
#import "BookMarkViewController.h"

@interface BrowserViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong)UITextField *urlField;
@property (nonatomic, strong)NSString *searchStr;
@property (nonatomic, strong)DDList *ddList;

@end

@implementation BrowserViewController
@synthesize urlField;
@synthesize searchStr;
@synthesize ddList;

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
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

    [super showNavigationBar:@"浏览器"];
    
    [self addAddressView];
    [self addRemoteToolBar];
    [super showToolbar];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlFieldChanged) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)addAddressView
{
    UIView *container = [[UIView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+TOOLBAR_HEIGHT, self.bounds.size.width, 68)];
    [container setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:container];
    
    UIImageView *bg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, container.frame.size.width, container.frame.size.height - 1)];
    bg.image = [UIImage imageNamed:@"address_bg"];
    [container addSubview:bg];
    
    urlField = [[UITextField alloc]initWithFrame:CGRectMake(10, 15, container.frame.size.width - 85, 35)];
    urlField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    urlField.clearsOnBeginEditing = YES;
    urlField.borderStyle = UITextBorderStyleRoundedRect;
    urlField.placeholder = @"请输入网址";
    urlField.delegate = self;
    urlField.backgroundColor = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1];
    urlField.keyboardType = UIKeyboardTypeURL;
    urlField.returnKeyType = UIReturnKeyGo;
    [container addSubview:urlField];
    
    UIButton *goBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    goBtn.frame = CGRectMake(urlField.frame.origin.x + urlField.frame.size.width + 10, 15, 59, 35);
    [goBtn setBackgroundImage:[UIImage imageNamed:@"send_bt"] forState:UIControlStateNormal];
    [goBtn setBackgroundImage:[UIImage imageNamed:@"send_bt_pressed"] forState:UIControlStateHighlighted];
    [goBtn addTarget:self action:@selector(goBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:goBtn];
    
    ddList = [[DDList alloc] initWithStyle:UITableViewStylePlain];
    [ddList.view setFrame:CGRectMake(10, container.frame.origin.y + container.frame.size.height - 18, container.frame.size.width - 85, 0)];
    ddList._delegate = self;
    [self.view addSubview:ddList.view];
}

- (void)addRemoteToolBar
{
    UIToolbar *remoteToolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT-1, self.bounds.size.width, TOOLBAR_HEIGHT)];
    [remoteToolBar setNeedsDisplay];
    [self.view addSubview:remoteToolBar];
    
    UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
    firstButton.frame = CGRectMake(10, 0, 40, 40);
    [firstButton setBackgroundImage:[UIImage imageNamed:@"menu_icon_blue"] forState:UIControlStateNormal];
    [firstButton setBackgroundImage:[UIImage imageNamed:@"menu_icon_blue_pressed"] forState:UIControlStateHighlighted];
    [firstButton addTarget:self action:@selector(firstButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:firstButton];
    
    UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
    secondButton.frame = CGRectMake(60, 0, 40, 40);
    [secondButton setBackgroundImage:[UIImage imageNamed:@"home_icon_blue"] forState:UIControlStateNormal];
    [secondButton setBackgroundImage:[UIImage imageNamed:@"home_icon_blue_pressed"] forState:UIControlStateHighlighted];
    [secondButton addTarget:self action:@selector(secondButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:secondButton];
    
    UIButton *thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    thirdButton.frame = CGRectMake(110, 0, 40, 40);
    [thirdButton setBackgroundImage:[UIImage imageNamed:@"back_icon_blue"] forState:UIControlStateNormal];
    [thirdButton setBackgroundImage:[UIImage imageNamed:@"back_icon_blue_pressed"] forState:UIControlStateHighlighted];
    [thirdButton addTarget:self action:@selector(thirdButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:thirdButton];
    
    UIButton *fourthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fourthButton.frame = CGRectMake(170, 0, 40, 40);
    [fourthButton setBackgroundImage:[UIImage imageNamed:@"keyboard_icon"] forState:UIControlStateNormal];
    [fourthButton setBackgroundImage:[UIImage imageNamed:@"keyboard_icon_pressed"] forState:UIControlStateHighlighted];
    [fourthButton addTarget:self action:@selector(fourthButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:fourthButton];
    
    UIButton *fifthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fifthButton.frame = CGRectMake(220, 0, 40, 40);
    [fifthButton setBackgroundImage:[UIImage imageNamed:@"setting_icon"] forState:UIControlStateNormal];
    [fifthButton setBackgroundImage:[UIImage imageNamed:@"setting_icon_pressed"] forState:UIControlStateHighlighted];
    [fifthButton addTarget:self action:@selector(fourthButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:fifthButton];
    
    UIButton *sixthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sixthButton.frame = CGRectMake(270, 0, 40, 40);
    [sixthButton setBackgroundImage:[UIImage imageNamed:@"mark_icon"] forState:UIControlStateNormal];
    [sixthButton setBackgroundImage:[UIImage imageNamed:@"mark_icon_pressed"] forState:UIControlStateHighlighted];
    [sixthButton addTarget:self action:@selector(showFavorite) forControlEvents:UIControlEventTouchUpInside];
    [remoteToolBar addSubview:sixthButton];
}

- (void)firstButtonClicked
{
    
}

- (void)secondButtonClicked
{
    
}

- (void)thirdButtonClicked
{
    
}

- (void)fourthButtonClicked
{
    
}

- (void)fifthButtonClicked
{
    
}


- (void)backButtonClicked
{
    [super homeButtonClicked];
}


- (void)passValue:(NSString *)value{
	if (value) {
		urlField.text = value;
		[self setDDListHidden:YES];
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]){
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0) {        
        [self setDDListHidden:YES];
        self.searchStr = [textField text];
        NSArray *historyArray = (NSArray *)[[ContainerUtility sharedInstance] attributeForKey:USER_INPUT_URL_HISTORY];
        NSMutableArray *newHistoryArray = [[NSMutableArray alloc]initWithCapacity:10];
        if (![historyArray containsObject:[textField text]]) {
            NSString *urlstr = [[textField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [newHistoryArray addObject:urlstr];
        }
        for (int i = 0; i < fmin(30-newHistoryArray.count, historyArray.count); i++) {
            [newHistoryArray addObject:[historyArray objectAtIndex:i]];
        }
        [[ContainerUtility sharedInstance] setAttribute:newHistoryArray forKey:USER_INPUT_URL_HISTORY];
        [textField resignFirstResponder];
        [self setDDListHidden:YES];
    }
    return YES;
}

- (void)goBtnClicked
{
    [self textFieldShouldReturn:urlField];
}

- (void)urlFieldChanged
{
    if ([urlField.text length] != 0) {
		ddList._searchText = urlField.text;
		[self setDDListHidden:NO];
		[ddList updateData];
	}
	else {
		[self setDDListHidden:YES];
	}
}

- (void)hideKeyBoard
{
    [urlField resignFirstResponder];
    [self setDDListHidden:YES];
}

- (void)setDDListHidden:(BOOL)hidden {
	NSInteger height = hidden ? 0 : ddList.view.frame.size.height;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:.2];
	[ddList.view setFrame:CGRectMake(10, ddList.view.frame.origin.y, ddList.view.frame.size.width, height)];
	[UIView commitAnimations];
}

- (void)showFavorite
{
    BookMarkViewController *viewController = [[BookMarkViewController alloc]init];
    viewController.httpUrl = urlField.text;
    [self presentViewController:viewController animated:YES completion:nil];
    [self hideKeyBoard];
}

@end
