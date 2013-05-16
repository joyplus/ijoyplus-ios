//
//  GroupImageViewController.h
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "GenericBaseViewController.h"
#import "AVPlayerViewController.h"

#define EPISODE_TABLE_WIDTH  175
#define EPISODE_TABLE_CELL_HEIGHT 50

@interface EpisodeListViewController : GenericBaseViewController
@property (nonatomic) int currentNum;
@property (nonatomic) int type;
@property (nonatomic, strong) NSArray *episodeArray;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, weak) id <AVPlayerViewControllerDelegate> delegate;
@end
