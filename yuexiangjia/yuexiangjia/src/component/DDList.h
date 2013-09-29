//
//  DDList.h
//  DropDownList
//
//  Created by kingyee on 11-9-19.
//  Copyright 2011 Kingyee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowserViewController.h"

@interface DDList : UITableViewController

@property (nonatomic, strong)NSString		*_searchText;
@property (nonatomic, strong)NSString		*_selectedText;
@property (nonatomic, strong)NSMutableArray	*_resultList;
@property (nonatomic, weak) id <PassValueDelegate> _delegate;

- (void)updateData;

@end
