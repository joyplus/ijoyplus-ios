//
//  MovieDetailViewController.h
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "VideoDetailViewController.h"

@protocol ShowDetailViewControllerDelegate <NSObject>

- (void)playVideoCallback:(NSInteger)num;

@end

@interface ShowDetailViewController : VideoDetailViewController <ShowDetailViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *previousShowBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextShowBtn;
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UIScrollView *bgScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *placeholderImage;
@property (weak, nonatomic) IBOutlet UIImageView *filmImage;
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIImageView *doulanLogo;
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
@property (weak, nonatomic) IBOutlet UIImageView *lineImage;
@property (weak, nonatomic) IBOutlet UIImageView *introImage;
@property (weak, nonatomic) IBOutlet UIImageView *introBgImage;
@property (weak, nonatomic) IBOutlet UITextView *introContentTextView;
@property (weak, nonatomic)UITableViewController *listViewController;
@property (weak, nonatomic)UITableViewController *commentViewController;
@property (weak, nonatomic) IBOutlet UIImageView *commentImage;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIImageView *dingNumberImage;
@property (weak, nonatomic) IBOutlet UIImageView *collectioNumber;
@property (weak, nonatomic) IBOutlet UILabel *dingNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *collectionNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@property (weak, nonatomic) IBOutlet UIButton *playRoundBtn;


@end
