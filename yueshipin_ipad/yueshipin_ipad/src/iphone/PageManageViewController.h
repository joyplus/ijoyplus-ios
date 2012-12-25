//
//  PageManageViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageManageViewController : UIViewController<UIScrollViewDelegate>{

    UIScrollView *scrollView_;
    UIPageControl *pageControl_;
}
@property (strong, nonatomic)UIScrollView *scrollView;
@property (strong, nonatomic)UIPageControl *pageControl;
@end
