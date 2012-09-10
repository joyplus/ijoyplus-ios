//
//  SearchFilmCell.h
//  ijoyplus
//
//  Created by joyplus1 on 12-9-10.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchFilmCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *filmImageView;
@property (weak, nonatomic) IBOutlet UILabel *filmTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *filmSubitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *filmThirdTitleLabel;

@end
