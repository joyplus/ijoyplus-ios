//
//  SegmentControlView.h
//  theatreiphone
//
//  Created by Rong on 13-5-13.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
enum{
    TYPE_MOVIE,
    TYPE_TV,
    TYPE_COMIC,
    TYPE_SHOW
};

@interface SegmentControlView : UIView

@property (nonatomic , assign) int type;
@property (nonatomic, strong) UISegmentedControl *seg;
@property (nonatomic, strong) NSArray *movieLabelArr;
@property (nonatomic, strong) NSArray *tvLabelArr;
@property (nonatomic, strong) NSArray *comicLabelArr;
@property (nonatomic, strong) NSArray *showLabelArr;

-(void)setSegmentControl:(int)type;
@end
