//
//  SearchFilmResultViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-10.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSearchBar.h"


@interface ContactFriendListViewController : UITableViewController  <UISearchBarDelegate>


@property (strong, nonatomic) NSString *keyword;
@property (strong, nonatomic) IBOutlet CustomSearchBar *sBar;
@property (strong, nonatomic) NSString *sourceType;//1 sina 2 tecent

@end
