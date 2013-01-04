//
//  MovieDetailViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IphoneMovieDetailViewController : UITableViewController{
    NSDictionary *infoDic_;
    NSDictionary *videoInfo_;
    NSArray *episodesArr_;
    int videoType_;
    NSString *summary_;
    NSMutableArray *commentArray_;
}
@property (nonatomic, strong) NSDictionary *infoDic;
@property (nonatomic, strong) NSDictionary *videoInfo;
@property (nonatomic, strong) NSArray *episodesArr;
@property (nonatomic, assign) int videoType;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSMutableArray *commentArray;
@end



