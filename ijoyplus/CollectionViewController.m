//
//  CollectionViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-13.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CollectionViewController.h"
#import "TestView.h"

@interface CollectionViewController ()

@end

@implementation CollectionViewController

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
    TestView *view = [[TestView alloc]initWithFrame:CGRectMake(0, 100, 320, 300)];
    self.view = view;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
