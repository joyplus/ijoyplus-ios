//
//  MovieDetailViewController.h
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "VideoDetailViewController.h"

@interface MovieDetailViewController : VideoDetailViewController <NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *bgScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *placeholderImage;
@property (weak, nonatomic) IBOutlet UIImageView *filmImage;
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIImageView *doulanLogo;
@property (weak, nonatomic) IBOutlet UILabel *directorLabel;
@property (weak, nonatomic) IBOutlet UILabel *directorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *actorLabel;
@property (weak, nonatomic) IBOutlet UILabel *actorName1Label;
@property (weak, nonatomic) IBOutlet UILabel *actorName2Label;
@property (weak, nonatomic) IBOutlet UILabel *actorName3Label;
@property (weak, nonatomic) IBOutlet UILabel *playLabel;
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *regionLabel;
@property (weak, nonatomic) IBOutlet UILabel *regionNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *dingBtn;
@property (weak, nonatomic) IBOutlet UIButton *collectionBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *addListBtn;
@property (weak, nonatomic) IBOutlet UIImageView *introImage;
@property (weak, nonatomic) IBOutlet UITextView *introContentTextView;
@property (weak, nonatomic) IBOutlet UIImageView *relatedImage;
@property (weak, nonatomic)UITableViewController *listViewController;
@property (weak, nonatomic)UITableViewController *commentViewController;
@property (weak, nonatomic) IBOutlet UIImageView *commentImage;
@property (weak, nonatomic) IBOutlet UILabel *dingNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *collectionNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UILabel *reportLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLable;

@property (weak, nonatomic) IBOutlet UIButton *playRoundBtn;

@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;


@end
