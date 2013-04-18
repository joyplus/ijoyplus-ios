//
//  HomeViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "DramaViewController.h"

@interface DramaViewController ()

@end

@implementation DramaViewController
- (void)viewDidUnload{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id)initWithFrame:(CGRect)frame {
    umengPageName = DRAMA_CATEGORY;
    self.videoType = DRAMA_TYPE;
    self = [super initWithFrame:frame];
	return self;
}

@end
