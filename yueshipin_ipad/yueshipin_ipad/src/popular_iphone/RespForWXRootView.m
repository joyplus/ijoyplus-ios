//
//  RespForWXRootView.m
//  yueshipin
//
//  Created by 08 on 13-4-2.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "RespForWXRootView.h"
#import "CommonHeader.h"
#import "RecordListCell.h"

#define SEGMENT_VIEW_FRAME      CGRectMake(12, 10, 297, 52)
#define HOT_BUTTON_FRAME        CGRectMake(0, 0, 99, 51)
#define FAV_BUTTON_FRAME        CGRectMake(99, 0, 99, 51)
#define REC_BUTTON_FRAME        CGRectMake(198, 0, 99, 51)

#define HOT_TABLEVIEW_FRAME(Y,Height)     CGRectMake(12, Y, 297, Height)
#define FAV_TABLEVIEW_FRAME(Y,Height)     CGRectMake(12, Y, 297, Height)

#define HOT_TABLEVIEWCELL_HEIGHT        (110.0f)
#define FAV_TABLEVIEWCELL_HEIGHT        (60.0f)

@interface RespForWXRootView ()

- (void)customView;
- (void)initTopSegmentView;
- (void)initTableView;
- (void)hiddenAllViews;
- (void)setDType:(NSInteger)type;

@end

@implementation RespForWXRootView
@synthesize delegate;
@synthesize dataType = _dataType;
@synthesize viewType = _viewType;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        _dataType = DATA_TYPE_HOT;
        _viewType = SEGMENT_VIEW_TYPE;
        [self customView];
    }
    return self;
}

- (void)dealloc
{
    _viewSegment = nil;
    _tableHot = nil;
    _tableFavAndRec = nil;
    _labNoData = nil;
    _arrSearch = nil;
    _arrHot = nil;
    _arrFav = nil;
    _arrRec = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark -
#pragma mark - private
- (void)customView
{
    _viewSegment = [[UIView alloc] initWithFrame:SEGMENT_VIEW_FRAME];
    _viewSegment.backgroundColor = [UIColor clearColor];
    [self addSubview:_viewSegment];
    
    _labNoData = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 170, 20)];
    _labNoData.center = self.center;
    _labNoData.font = [UIFont systemFontOfSize:14];
    _labNoData.textColor = [UIColor grayColor];
    _labNoData.backgroundColor = [UIColor clearColor];
    [self addSubview:_labNoData];
    _labNoData.hidden = YES;
    _labNoData.textAlignment = UITextAlignmentCenter;
    
    [self initTopSegmentView];
    [self initTableView];
    
}

- (void)initTopSegmentView
{
    UIButton * hotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    hotBtn.frame = HOT_BUTTON_FRAME;
    hotBtn.tag = HOT_BUTTON_TAG;
    [hotBtn addTarget:self
               action:@selector(buttonClicked:)
     forControlEvents:UIControlEventTouchUpInside];
    [hotBtn setBackgroundImage:[UIImage imageNamed:@"re_bo.png"]
                      forState:UIControlStateNormal];
    [hotBtn setBackgroundImage:[UIImage imageNamed:@"re_bo_s.png"]
                      forState:UIControlStateHighlighted];
    [hotBtn setBackgroundImage:[UIImage imageNamed:@"re_bo_s.png"]
                      forState:UIControlStateDisabled];
    hotBtn.enabled = NO;
    hotBtn.adjustsImageWhenDisabled = NO;
    
    UIButton * favBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [favBtn addTarget:self
               action:@selector(buttonClicked:)
     forControlEvents:UIControlEventTouchUpInside];
    [favBtn setBackgroundImage:[UIImage imageNamed:@"shou_cang.png"]
                      forState:UIControlStateNormal];
    [favBtn setBackgroundImage:[UIImage imageNamed:@"shou_cang_s.png"]
                      forState:UIControlStateHighlighted];
    [favBtn setBackgroundImage:[UIImage imageNamed:@"shou_cang_s.png"]
                      forState:UIControlStateDisabled];
    favBtn.frame = FAV_BUTTON_FRAME;
    favBtn.tag = FAV_BUTTON_TAG;
    favBtn.adjustsImageWhenDisabled = NO;
    
    UIButton * recBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [recBtn addTarget:self
               action:@selector(buttonClicked:)
     forControlEvents:UIControlEventTouchUpInside];
    [recBtn setBackgroundImage:[UIImage imageNamed:@"tab3_page1_icon.png"]
                      forState:UIControlStateNormal];
    [recBtn setBackgroundImage:[UIImage imageNamed:@"tab3_page1_icon_s.png"]
                      forState:UIControlStateHighlighted];
    [recBtn setBackgroundImage:[UIImage imageNamed:@"tab3_page1_icon_s.png"]
                      forState:UIControlStateDisabled];
    recBtn.frame = REC_BUTTON_FRAME;
    recBtn.tag = REC_BUTTON_TAG;
    recBtn.adjustsImageWhenDisabled = NO;
    
    [_viewSegment addSubview:hotBtn];
    [_viewSegment addSubview:favBtn];
    [_viewSegment addSubview:recBtn];
}

- (void)initTableView
{
    _tableHot = [[UITableView alloc] initWithFrame:HOT_TABLEVIEW_FRAME(72,(self.frame.size.height - _viewSegment.frame.size.height - _viewSegment.frame.origin.y - 5.0f))
                                             style:UITableViewStylePlain];
    _tableFavAndRec = [[UITableView alloc] initWithFrame:FAV_TABLEVIEW_FRAME(72,(self.frame.size.height - _viewSegment.frame.size.height - _viewSegment.frame.origin.y - 5.0f))
                                             style:UITableViewStylePlain];
    
    _tableHot.delegate   = self;
    _tableHot.dataSource = self;
    
    _tableFavAndRec.delegate   = self;
    _tableFavAndRec.dataSource = self;
    
    [self addSubview:_tableHot];
    [self addSubview:_tableFavAndRec];
    
    _tableFavAndRec.backgroundColor = [UIColor clearColor];
    _tableHot.backgroundColor = [UIColor clearColor];
    
    _tableHot.hidden = NO;
    _tableFavAndRec.hidden = YES;
    
    _tableFavAndRec.tableFooterView = [[UIView alloc] init];
    _tableHot.tableFooterView = [[UIView alloc] init];
}

- (void)buttonClicked:(id)sender
{
    UIButton * hotBtn = (UIButton *)[self viewWithTag:HOT_BUTTON_TAG];
    UIButton * favBtn = (UIButton *)[self viewWithTag:FAV_BUTTON_TAG];
    UIButton * recBtn = (UIButton *)[self viewWithTag:REC_BUTTON_TAG];
    
    hotBtn.enabled = YES;
    favBtn.enabled = YES;
    recBtn.enabled = YES;
    
    UIButton * btn = (UIButton *)sender;
    btn.enabled = NO;
    
    _dataType = (btn.tag - 101);
    
    [self hiddenAllViews];
    
    if (delegate && [delegate respondsToSelector:@selector(segmentBtnClicked:)])
    {
        [delegate segmentBtnClicked:(btn.tag - 101)];
    }
}

- (void)hiddenAllViews
{
    _labNoData.hidden = YES;
    _tableHot.hidden = YES;
    _tableFavAndRec.hidden = YES;
}

- (NSString *)composeContent:(NSDictionary *)item
{
    NSString *content;
    
    NSNumber *number = (NSNumber *)[item objectForKey:@"playback_time"];
    if ([[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]] isEqualToString:@"1"]) {
        content = [NSString stringWithFormat:@"已观看到 %@", [TimeUtility formatTimeInSecond:number.doubleValue]];
    } else if ([[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]] isEqualToString:@"2"]) {
        int subNum = [[item objectForKey:@"prod_subname"] intValue];
        content = [NSString stringWithFormat:@"已观看到第%d集 %@", subNum, [TimeUtility formatTimeInSecond:number.doubleValue]];
    } else if ([[NSString stringWithFormat:@"%@", [item objectForKey:@"prod_type"]] isEqualToString:@"3"]) {
        content = [NSString stringWithFormat:@"已观看 %@", [TimeUtility formatTimeInSecond:number.doubleValue]];
    }
    return content;
}

- (void)setDType:(NSInteger)type
{
    if (DATA_TYPE_HOT == _dataType)
    {
        _tableHot.hidden = NO;
        _tableFavAndRec.hidden = YES;
    }
    else
    {
        _tableHot.hidden = YES;
        _tableFavAndRec.hidden = NO;
    }
    _labNoData.hidden = YES;
}

#pragma mark -
#pragma mark - 对外接口

- (void)setViewType:(NSInteger)type
{
    _viewType = type;
    CGRect frame;
    if (SEARCH_VIEW_TYPE == type)
    {
        [self hiddenAllViews];
        _viewSegment.hidden = YES;
        frame = HOT_TABLEVIEW_FRAME(10,(self.frame.size.height - _viewSegment.frame.size.height - _viewSegment.frame.origin.y - 5.0f + 62.0f));
    }
    else
    {
        [self setDType:_dataType];
        _viewSegment.hidden = NO;
        frame = HOT_TABLEVIEW_FRAME(72,(self.frame.size.height - _viewSegment.frame.size.height - _viewSegment.frame.origin.y - 5.0f));
        [_tableHot reloadData];
        _arrSearch = nil;
    }
    _tableHot.frame = frame;
}

- (void)refreshTableView:(NSArray *)data
{
    if (SEGMENT_VIEW_TYPE == _viewType)
    {
        [self setDType:_dataType];
        
        switch (_dataType)
        {
            case DATA_TYPE_HOT:
            {
                _arrHot = data;
                if (_arrHot.count == 0)
                {
                    _labNoData.hidden = NO;
                    _labNoData.text = @"亲，暂时没有热播影片 : )";
                    _tableHot.hidden = YES;
                }
                else
                {
                    _labNoData.hidden = YES;
                    _tableHot.hidden = NO;
                }
                [_tableHot reloadData];
            }
                break;
            case DATA_TYPE_FAV:
            {
                _arrFav = data;
                if (_arrFav.count == 0)
                {
                    _labNoData.hidden = NO;
                    _labNoData.text = @"亲，您还没有收藏过任何影片 : )";
                    _tableFavAndRec.hidden = YES;
                }
                else
                {
                    _labNoData.hidden = YES;
                    _tableFavAndRec.hidden = NO;
                }
                [_tableFavAndRec reloadData];
            }
                break;
            case DATA_TYPE_REC:
            {
                _arrRec = data;
                if (_arrRec.count == 0)
                {
                    _labNoData.hidden = NO;
                    _labNoData.text = @"亲，您没有任何播放记录 : )";
                    _tableFavAndRec.hidden = YES;
                }
                else
                {
                    _labNoData.hidden = YES;
                    _tableFavAndRec.hidden = NO;
                }
                [_tableFavAndRec reloadData];
            }
                break;
            default:
                break;
        }
    }
    else if (SEARCH_VIEW_TYPE  == _viewType)
    {
        _arrSearch = data;
        _tableHot.hidden = NO;
        [_tableHot reloadData];
    }
    
}

#pragma mark -
#pragma mark - TableViewDelegate & TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (SEARCH_VIEW_TYPE == _viewType)
    {
        return _arrSearch.count;
    }
    else
    {
        switch (_dataType)
        {
            case DATA_TYPE_HOT:
            {
                return _arrHot.count;
            }
                break;
            case DATA_TYPE_FAV:
            {
                return _arrFav.count;
            }
                break;
            case DATA_TYPE_REC:
            {
                return _arrRec.count;
            }
                break;
            default:
                break;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_tableHot == tableView)
    {
        static NSString *CellIdentifier = @"hotCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:CellIdentifier];
        }
        
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        NSDictionary *infoDic = nil;
        if (SEGMENT_VIEW_TYPE == _viewType)
        {
            infoDic = [_arrHot objectAtIndex:indexPath.row];
        }
        else
        {
            infoDic = [_arrSearch objectAtIndex:indexPath.row];
        }
        
        UIImageView *frame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"listFrame.png"]];
        frame.frame = CGRectMake(19, 11, 60, 90);
        [cell.contentView addSubview:frame];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(21, 13, 56, 84)];
        [imageView setImageWithURL:[NSURL URLWithString:[infoDic objectForKey:@"prod_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
        [cell.contentView addSubview:imageView];
        
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(88, 12, 170, 20)];
        titleLab.font = [UIFont systemFontOfSize:14];
        titleLab.text = [infoDic objectForKey:@"prod_name"];
        titleLab.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:titleLab];
        
        NSString * actorsStr = [infoDic objectForKey:@"stars"];
        if (nil == actorsStr)
        {
            actorsStr = [infoDic objectForKey:@"star"];
        }
        
        UILabel *actors = [[UILabel alloc] initWithFrame:CGRectMake(88, 32, 170, 15)];
        actors.text = [NSString stringWithFormat:@"主演：%@",actorsStr] ;
        actors.font = [UIFont systemFontOfSize:12];
        actors.textColor = [UIColor grayColor];
        actors.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:actors];
        
        UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(88, 46, 200, 15)];
        date.text = [NSString stringWithFormat:@"地区：%@",[infoDic objectForKey:@"area"]];
        date.font = [UIFont systemFontOfSize:11];
        date.textColor = [UIColor grayColor];
        date.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:date];
        
        
        NSString * directorStr = [infoDic objectForKey:@"directors"];
        if (nil == directorStr)
        {
            directorStr = [infoDic objectForKey:@"director"];
        }
        
        UILabel * director = [[UILabel alloc] initWithFrame:CGRectMake(88, 60, 200, 15)];
        director.text = [NSString stringWithFormat:@"导演：%@",directorStr];
        director.font = [UIFont systemFontOfSize:11];
        director.textColor = [UIColor grayColor];
        director.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:director];
        
        UILabel * releaseDate = [[UILabel alloc] initWithFrame:CGRectMake(88, 74, 200, 15)];
        releaseDate.text = [NSString stringWithFormat:@"年代：%@",[infoDic objectForKey:@"publish_date"]];
        releaseDate.font = [UIFont systemFontOfSize:11];
        releaseDate.textColor = [UIColor grayColor];
        releaseDate.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:releaseDate];
        
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_fen_ge_xian.png"]];
        line.frame = CGRectMake(0, 109, 297, 1);
        [cell.contentView addSubview:line];
        
        return cell;
    }
    else
    {
        if (DATA_TYPE_FAV == _dataType)
        {
            static NSString *CellIdentifier = @"favCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            NSDictionary *infoDic = [_arrFav objectAtIndex:indexPath.row];
            
            UIImageView *frame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"listFrame.png"]];
            frame.frame = CGRectMake(13, 5, 38, 53);
            [cell.contentView addSubview:frame];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7, 34, 48)];
            [imageView setImageWithURL:[NSURL URLWithString:[infoDic objectForKey:@"content_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
            [cell.contentView addSubview:imageView];
            
            UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(65, 8, 170, 15)];
            titleLab.font = [UIFont systemFontOfSize:14];
            titleLab.text = [infoDic objectForKey:@"content_name"];
            titleLab.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:titleLab];
            
            UILabel *actors = [[UILabel alloc] initWithFrame:CGRectMake(65, 30, 170, 15)];
            actors.text = [NSString stringWithFormat:@"主演：%@",[infoDic objectForKey:@"stars"]] ;
            actors.font = [UIFont systemFontOfSize:12];
            actors.textColor = [UIColor grayColor];
            actors.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:actors];
            
            UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(65, 42, 200, 15)];
            date.text = [NSString stringWithFormat:@"年代：%@",[infoDic objectForKey:@"publish_date"]];
            date.font = [UIFont systemFontOfSize:12];
            date.textColor = [UIColor grayColor];
            date.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:date];
            
            UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_fen_ge_xian.png"]];
            line.frame = CGRectMake(0, 59, 297, 1);
            [cell.contentView addSubview:line];
            
            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"recCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            NSDictionary *infoDic = [_arrRec objectAtIndex:indexPath.row];
            
            UIImageView *frame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"listFrame.png"]];
            frame.frame = CGRectMake(13, 5, 38, 52);
            [cell.contentView addSubview:frame];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7, 34, 48)];
            [imageView setImageWithURL:[NSURL URLWithString:[infoDic objectForKey:@"prod_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
            [cell.contentView addSubview:imageView];
            
            UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(65, 8, 170, 15)];
            titleLab.font = [UIFont systemFontOfSize:14];
            titleLab.text = [infoDic objectForKey:@"prod_name"];
            titleLab.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:titleLab];
            
            UILabel *actors = [[UILabel alloc] initWithFrame:CGRectMake(65, 30, 170, 15)];
            actors.text = [self composeContent:infoDic];
            actors.font = [UIFont systemFontOfSize:12];
            actors.textColor = [UIColor grayColor];
            actors.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:actors];
            
            return cell;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (DATA_TYPE_HOT == _dataType
        || SEARCH_VIEW_TYPE == _viewType)
    {
        return HOT_TABLEVIEWCELL_HEIGHT;
    }
    return FAV_TABLEVIEWCELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *infoDic = nil;
    if (_tableHot == tableView)
    {
        if (SEGMENT_VIEW_TYPE == _viewType)
        {
            infoDic = [_arrHot objectAtIndex:indexPath.row];
        }
        else
        {
            infoDic = [_arrSearch objectAtIndex:indexPath.row];
        }
    }
    else
    {
        if (DATA_TYPE_FAV == _dataType)
        {
            infoDic = [_arrFav objectAtIndex:indexPath.row];
        }
        else
        {
            infoDic = [_arrRec objectAtIndex:indexPath.row];
        }
    }
    if (delegate && [delegate respondsToSelector:@selector(gotoMoviewDetail:)])
    {
        [delegate gotoMoviewDetail:infoDic];
    }
}

@end
