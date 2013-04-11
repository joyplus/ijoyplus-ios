//
//  DimensionalCodeScanViewController.m
//  yueshipin
//
//  Created by 08 on 13-4-9.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "DimensionalCodeScanViewController.h"
#import "BundingViewController.h"

#define SCAN_TIMER_INTERVAL (4.0f)

@interface DimensionalCodeScanViewController ()
@property (nonatomic,strong) NSTimer    *scanTimer;
- (void)fireANewTimer;
@end

@implementation DimensionalCodeScanViewController
@synthesize scanSymbolView,scanTimer;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    if (scanTimer)
    {
        [scanTimer invalidate];
        scanTimer = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.readerDelegate = self;
    
    UILabel *titleText = [[UILabel alloc] initWithFrame: CGRectMake(90, 0, 40, 40)];
    titleText.backgroundColor = [UIColor clearColor];
    titleText.textColor=[UIColor whiteColor];
    [titleText setFont:[UIFont boldSystemFontOfSize:18.0]];
    [titleText setText:@"扫一扫"];
    self.navigationItem.titleView=titleText;
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, 49, 30);
    leftButton.backgroundColor = [UIColor clearColor];
    [leftButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    scanSymbolView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan_symbol.png"]];
    scanSymbolView.frame = CGRectMake(72, kCurrentWindowHeight - 391, 175, 20.5);
    [self.view addSubview:scanSymbolView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self fireANewTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)fireANewTimer
{
    [scanTimer invalidate];
    scanTimer = nil;
    
    scanTimer = [NSTimer timerWithTimeInterval:SCAN_TIMER_INTERVAL
                                        target:self
                                      selector:@selector(scanAnimation)
                                      userInfo:nil
                                       repeats:NO];
    [scanTimer fire];
}

- (void)scanAnimation
{
    //kCurrentWindowHeight - 44 - 342.5
    scanSymbolView.frame = CGRectMake(72, kCurrentWindowHeight - 391, 175, 20.5);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:SCAN_TIMER_INTERVAL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(fireANewTimer)];
    scanSymbolView.frame = CGRectMake(72, kCurrentWindowHeight - 391 + 168.5, 175, 20.5);
    [UIView commitAnimations];
}

#pragma mark - 
#pragma mark - ZBarReaderDelegate
- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    
    BundingViewController * bCtrl = [[BundingViewController  alloc] init];
    bCtrl.strData = symbol.data;
    bCtrl.hidesBottomBarWhenPushed = NO;
    [self.navigationController pushViewController:bCtrl animated:YES];
    
}

@end
