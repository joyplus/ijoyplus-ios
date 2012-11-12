//
//  HomeViewController
//  ijoyplus
//
//  Created by joyplus1 on 12-9-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaterflowView.h"
#import "UIGenericViewController.h"

@protocol HomeViewControllerDelegate <NSObject>

- (void)refreshContent;

@end

@interface HomeViewController : UIGenericViewController< WaterflowViewDelegate,WaterflowViewDatasource,UIScrollViewDelegate, UIPickerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, HomeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UISegmentedControl *segment;
@property (strong, nonatomic) IBOutlet UIImageView *topImageView;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UIImageView *roundImageView;
@property (strong, nonatomic) IBOutlet UILabel *watchedNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *fansNumberLabel;
@property (strong, nonatomic) IBOutlet UIButton *watchBtn;
@property (strong, nonatomic) IBOutlet UIButton *collectionBtn;
@property (strong, nonatomic) IBOutlet UILabel *username;
- (IBAction)followUser:(id)sender;
- (IBAction)fansUser:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *watchedLabel;
@property (strong, nonatomic) IBOutlet UIButton *avatarImageViewBtn;
@property (strong, nonatomic) IBOutlet UILabel *fansLabel;
@property (strong, nonatomic) IBOutlet UIView *bgView;
- (void)bgImageClicked:(id)sender;
- (IBAction)avatarImageClicked:(id)sender;
@property (strong, nonatomic)NSString *userid;
@property (assign, nonatomic)int offsety;
@end
