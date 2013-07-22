//
//  ScanViewController.m
//  yueshipin
//
//  Created by lily on 13-7-10.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "ScanViewController.h"

#import "BundingViewController.h"

#define SCAN_TIMER_INTERVAL (4.0f)
@interface ScanViewController ()
@property (nonatomic,strong) NSTimer *scanTimer;
- (void)fireANewTimer;
@end

@implementation ScanViewController
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.readerDelegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    scanSymbolView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scaning.png"]];
    scanSymbolView.frame = CGRectMake(135, 80, 290, 35);
    [self.view addSubview:scanSymbolView];

    [self fireANewTimer];
    
    [self viewWillAppear:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //scanSymbolView.frame = CGRectMake(72, 391, 175, 20.5);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    scanSymbolView.frame = CGRectMake(135, 80, 290, 35);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:SCAN_TIMER_INTERVAL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationRepeatCount:MAXFLOAT];
    //[UIView setAnimationDidStopSelector:@selector(fireANewTimer)];
    scanSymbolView.frame = CGRectMake(135,250 + 148, 290, 35);
    [UIView commitAnimations];
}

- (void)appDidBecomeActive
{
    [self fireANewTimer];
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
    
    if (![symbol.data hasPrefix:@"joy"])
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                         message:@"请扫描悦视频TV版的\"我的悅视频\"中的二维码哦"
                                                        delegate:nil
                                               cancelButtonTitle:@"我知道了"
                                               otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
//    BundingViewController * bCtrl = [[BundingViewController  alloc] init];
//    bCtrl.strData = symbol.data;
//    bCtrl.hidesBottomBarWhenPushed = NO;
//    [self.navigationController pushViewController:bCtrl animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:ZBarReader object:symbol.data];
    
}


@end
