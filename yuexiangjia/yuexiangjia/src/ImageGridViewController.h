//
//  GroupImageViewController.h
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "BaseLocalViewController.h"
#import "GenericBaseViewController.h"

@interface ImageGridViewController : GenericBaseViewController

@property (nonatomic, strong)NSString *groupName;
@property (nonatomic, strong)NSArray *mediaObjectArray;

@end
