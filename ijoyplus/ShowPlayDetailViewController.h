//
//  PlayDetailViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-10-17.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayDetailViewController.h"
#import "DramaCell.h"

@interface ShowPlayDetailViewController : PlayDetailViewController{
    NSDictionary *show;
    NSInteger totalDramaCount;
    NSArray *episodeArray;
}
- (UITableViewCell *)displayEpisodeCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath cellIdentifier:(NSString *)cellIdentifie;
- (void)gotoWebsite:(NSInteger)num;
@end;