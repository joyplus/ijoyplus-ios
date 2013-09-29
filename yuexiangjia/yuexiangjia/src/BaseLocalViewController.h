//
//  BaseLocalViewController.h
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "GenericBaseViewController.h"

@interface BaseLocalViewController : GenericBaseViewController

@property (nonatomic, strong) NSMutableArray *groupMediaArray;
@property (nonatomic)int mediaType;

- (void)loadLocalMediaFiles;
@end
