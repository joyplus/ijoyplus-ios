//
//  IphoneShowViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IphoneShowDetailViewController : UITableViewController{
    NSDictionary *infoDic_;
    NSDictionary *videoInfo_;
    NSArray *episodesArr_;
    int videoType_;
    NSString *summary_;
    UIScrollView *scrollView_;
    int pageCount_;
    int currentPage_;
    UIButton *next_;
    UIButton *pre_;
    NSMutableArray *commentArray_;
    int favCount_;
    int supportCount_;
}
@property (nonatomic, strong) NSDictionary *infoDic;
@property (nonatomic, strong) NSDictionary *videoInfo;
@property (nonatomic, strong) NSArray *episodesArr;
@property (nonatomic, assign) int videoType;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *next;
@property (nonatomic, strong) UIButton *pre;
@property (nonatomic, strong) NSMutableArray *commentArray;
@end
