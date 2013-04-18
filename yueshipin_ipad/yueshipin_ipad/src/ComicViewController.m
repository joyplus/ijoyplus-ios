//
//  HomeViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ComicViewController.h"

@interface ComicViewController ()

@end

@implementation ComicViewController
- (void)viewDidUnload{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id)initWithFrame:(CGRect)frame {
    umengPageName = COMIC_CATEGORY;
    self.videoType = COMIC_TYPE;
    self = [super initWithFrame:frame];
	return self;
}

@end
