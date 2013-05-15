//
//  FiltrateCell.h
//  theatreiphone
//
//  Created by Rong on 13-5-14.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FiltrateCell;
@protocol FiltrateCellDelegate <NSObject>
-(void)didSelectAtCell:(FiltrateCell *)cell inPosition:(int)position;
@end


@interface FiltrateCell : UITableViewCell
@property (nonatomic, strong)UIImageView *firstImageView;
@property (nonatomic, strong)UIImageView *secondImageView;
@property (nonatomic, strong)UIImageView *thirdImageView;
@property (nonatomic, strong)UILabel *firstLabel;
@property (nonatomic, strong)UILabel *secondLabel;
@property (nonatomic, strong)UILabel *thirdLabel;
@property (nonatomic, assign)int selectIndex;
@property (nonatomic, weak) id <FiltrateCellDelegate> delagate;
@end
