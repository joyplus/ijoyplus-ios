//
//  SegmentControlView.h
//  theatreiphone
//
//  Created by Rong on 13-5-13.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
enum{
    TYPE_MOVIE = 1,
    TYPE_TV = 2,
    TYPE_COMIC = 131,
    TYPE_SHOW = 3
};

@interface SegmentControlView : UIView
@protocol SegmentDelegate <NSObject>
-(void)segmentDidSelectedLabelStr:(NSString *)str;
-(void)moreSelectWithType:(int)type;
@end


@interface SegmentControlView : UIView{
    int videoType_;

}
@property (nonatomic, weak) id <SegmentDelegate> delegate;
@property (nonatomic , assign) int type;
@property (nonatomic, strong) UISegmentedControl *seg;
@property (nonatomic, strong) NSArray *movieLabelArr;
@property (nonatomic, strong) NSArray *tvLabelArr;
@property (nonatomic, strong) NSArray *comicLabelArr;
@property (nonatomic, strong) NSArray *showLabelArr;

-(void)setSegmentControl:(int)type;
@end



@protocol FiltrateViewDelegate <NSObject>

-(void)filtrateWithVideoType:(int)type parameters:(NSMutableDictionary *)parameters;

@end

@interface FiltrateView : UIView{
    int _videoType;
}
@property (nonatomic, weak) id <FiltrateViewDelegate> delegate;
@property (nonatomic, strong)NSMutableDictionary *parametersDic;
-(void)setViewWithType:(int)type;
@end
