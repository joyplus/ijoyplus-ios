//
//  MovieDetailViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IphoneVideoViewController.h"
#import "FilmReviewViewCell.h"
#import "FeedBackView.h"

@interface IphoneMovieDetailViewController : IphoneVideoViewController< FilmReviewViewCellDelegate,FeedBackViewDelegate>{
    NSDictionary *videoInfo_;
    int videoType_;
    NSString *summary_;
    NSMutableArray *commentArray_;
    NSArray *relevantList_;
    int favCount_;
    int supportCount_;
    UIImageView *summaryBg_;
    UILabel *summaryLabel_;
    UIButton *moreBtn_;
    BOOL _reloading;
    NSUInteger reloads_;
    BOOL isLoaded_;
    BOOL isFavority_;
    NSArray *arrReviewData_;
    NSString *source_;
}
@property (nonatomic, strong) NSDictionary *videoInfo;
@property (nonatomic, assign) int videoType;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSMutableArray *commentArray;
@property (nonatomic, strong) NSArray *relevantList;
@property (nonatomic, strong) UIImageView *summaryBg;
@property (nonatomic, strong) UILabel *summaryLabel;
@property (nonatomic, strong) UIButton *moreBtn;
@end



