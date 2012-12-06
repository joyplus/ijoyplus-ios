//
//  ProgramViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-10-8.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ProgramViewController.h"
#import "DateUtility.h"
#import "CMConstants.h"
#import "CacheUtility.h"


@interface ProgramViewController (){
}

@end

@implementation ProgramViewController
@synthesize programUrl;
@synthesize webView;
@synthesize subname;
@synthesize type;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"receive memory warning in %@", self.class);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self.webView loadRequest: nil];
    [self.webView removeFromSuperview];
    self.webView = nil;
    self.programUrl = nil;
    self.subname = nil;
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
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myButton.frame = CGRectMake(0, 0, 56, 29);
    [myButton setBackgroundImage:[UIImage imageNamed:@"left_btn"] forState:UIControlStateNormal];
    [myButton setBackgroundImage:[UIImage imageNamed:@"left_btn_pressed"] forState:UIControlStateHighlighted];
    [myButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside]; 
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:myButton];
    self.navigationItem.leftBarButtonItem = customItem;
    
    UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    t.font = [UIFont boldSystemFontOfSize:18];
    t.textColor = [UIColor whiteColor];
    t.backgroundColor = [UIColor clearColor];
    t.textAlignment = UITextAlignmentCenter;
    t.text = self.title;
    self.navigationItem.titleView = t;
    
    NSURL *url = [NSURL URLWithString:self.programUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
    [self updateWatchRecord];
}

- (void)closeSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)updateWatchRecord
{
    NSArray *watchRecordArray = (NSArray *)[[CacheUtility sharedCache]loadFromCache:@"watch_record"];
    int index = 0;
    BOOL exist = NO;
    NSMutableDictionary *watchingItem;
    for(int i = 0; i < watchRecordArray.count; i++){
        NSDictionary *item = (NSDictionary *)[watchRecordArray objectAtIndex:i];
        if ([[item objectForKey:@"name"] isEqualToString: self.title]) {
            watchingItem = [[NSMutableDictionary alloc]initWithDictionary:item];;
            index = i;
            exist = YES;
            break;
        }
    }
    if(watchingItem == nil){
        watchingItem = [[NSMutableDictionary alloc]initWithCapacity:7];
    }
    [watchingItem setValue:@"2" forKey:@"play_type"]; // 1:player 2 web-player
    [watchingItem setValue:(self.title == nil ? @"" : self.title) forKey:@"name"];
    [watchingItem setValue:(self.subname == nil ? @"" : self.subname) forKey:@"subname"];
    [watchingItem setValue:[NSString stringWithFormat:@"%i", self.type] forKey:@"type"];
    [watchingItem setValue:[DateUtility formatDateWithString:[NSDate date] formatString: @"yyyy-MM-dd HH:mm:ss"] forKey:@"createDateStr"];
    [watchingItem setValue:[NSNumber numberWithInt:0] forKey:@"playbackTime"];
    [watchingItem setValue:[NSNumber numberWithInt:0] forKey:@"duration"];
    [watchingItem setValue: self.programUrl forKey:@"videoUrl"];
    
    NSMutableArray *temp = [[NSMutableArray alloc]initWithCapacity:WATCH_RECORD_NUMBER];
    if(!exist){
        [temp addObject:watchingItem];
    }
    for(int i = 0; i < watchRecordArray.count; i++){
        if(exist && i == index){
            [temp addObject:watchingItem];
        } else {
            [temp addObject:[watchRecordArray objectAtIndex:i]];
        }
    }
    NSArray *sortedArray = [temp sortedArrayUsingComparator:^(NSDictionary *a, NSDictionary *b) {
        NSDate *first = [DateUtility dateFromFormatString:[a objectForKey:@"createDateStr"] formatString: @"yyyy-MM-dd HH:mm:ss"] ;
        NSDate *second = [DateUtility dateFromFormatString:[b objectForKey:@"createDateStr"] formatString: @"yyyy-MM-dd HH:mm:ss"];
        return [second compare:first];
    }];
    int num = sortedArray.count > WATCH_RECORD_NUMBER ? WATCH_RECORD_NUMBER : sortedArray.count;
    NSMutableArray *newWatchRecord = [[NSMutableArray alloc]initWithCapacity:num];
    for(int i = 0; i < num; i++){
        [newWatchRecord addObject:[temp objectAtIndex:i]];
    }
    [[CacheUtility sharedCache]putInCache:@"watch_record" result:newWatchRecord];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) hideGradientBackground:(UIView*)theView
{
    for (UIView * subview in theView.subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
        
        [self hideGradientBackground:subview];
    }
}

//- (UIButton *)findButtonInView:(UIView *)view {
//    UIButton *button = nil;
//
//    if ([view isMemberOfClass:[UIButton class]]) {
//        return (UIButton *)view;
//    }
//
//    if (view.subviews && [view.subviews count] > 0) {
//        for (UIView *subview in view.subviews) {
//            button = [self findButtonInView:subview];
//            if (button) return button;
//        }
//    }
//
//    return button;
//}

@end
