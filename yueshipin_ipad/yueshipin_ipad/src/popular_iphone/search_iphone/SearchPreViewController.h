//
//  SearchPreViewController.h
//  yueshipin
//
//  Created by 08 on 12-12-27.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchPreViewController : UIViewController<UISearchBarDelegate>{
    UISearchBar *searchBar_;

}
@property (nonatomic, strong)UISearchBar *searchBar;
@end
