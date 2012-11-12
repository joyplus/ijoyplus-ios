//
//  MediaGridViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-11-9.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaGridViewController : UITableViewController

@property (nonatomic, strong)NSArray *mediaArray;
@property (nonatomic, assign)int mediaType;

@end
