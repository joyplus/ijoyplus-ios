//
//  ListViewController.h
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CommonHeader.h"

@interface CommentDetailViewController : SlideBaseViewController

@property (nonatomic, strong)NSString *titleContent;
@property (nonatomic, strong)NSString *content;
@property (nonatomic, strong)id<DramaDetailViewControllerDelegate>parentDelegateController;
@end
