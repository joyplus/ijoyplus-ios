//
//  AppRecommendViewController.h
//  yueshipin
//
//  Created by 08 on 13-2-5.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMUFPGridView.h"
@interface AppRecommendViewController : UIViewController<GridViewDelegate,GridViewDataSource, UMUFPTableViewDataLoadDelegate>{
  UMUFPGridView *_mGridView;
}
@property (nonatomic, strong)UMUFPGridView *mGridView;
@end
