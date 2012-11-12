//
//  BaseLoacalViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-11-9.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "BaseLoacalViewController.h"


@interface BaseLoacalViewController ()

@end

@implementation BaseLoacalViewController

- (void)viewDidUnload{
    [super viewDidUnload];
    [mediaArray removeAllObjects];
    mediaArray = nil;
    [groupMediaArray removeAllObjects];
    groupMediaArray = nil;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mediaArray = [[NSMutableArray alloc]initWithCapacity:10];
    groupMediaArray = [[NSMutableArray alloc]initWithCapacity:10];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadMediaObject:(ALAsset *)result
{
    MediaObject *mediaFile = [[MediaObject alloc]init];
    NSString *urlstr=[NSString stringWithFormat:@"%@",[result.defaultRepresentation url]];//图片的url
    /*result.defaultRepresentation.fullScreenImage//图片的大图
     result.thumbnail                             //图片的缩略图小图
     //                    NSRange range1=[urlstr rangeOfString:@"id="];
     //                    NSString *resultName=[urlstr substringFromIndex:range1.location+3];
     //                    resultName=[resultName stringByReplacingOccurrencesOfString:@"&ext=" withString:@"."];//格式demo:123456.png
     */
    
    mediaFile.mediaURL = urlstr;
    mediaFile.image = [UIImage imageWithCGImage:result.thumbnail];
    [mediaArray addObject:mediaFile];
}

-(void)loadLocalMediaFiles:(int)mediaType{
    
    ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
        NSLog(@"相册访问失败 =%@", [myerror localizedDescription]);
        if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound) {
            NSLog(@"无法访问相册.请在'设置->定位服务'设置为打开状态.");
        }else{
            NSLog(@"相册访问失败.");
        }
    };
    
    void (^groupEnumerAtion)
    (ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop){
        if (result!=NULL) {
            if(mediaType == 1){
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    [self loadMediaObject:result];
                }
            }else if(mediaType == 2) {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                    [self loadMediaObject:result];
                }
            }
        }
        
    };
    
    void (^libraryGroupsEnumeration)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup* group, BOOL* stop){
        if (group!=nil) {
            [group enumerateAssetsUsingBlock:groupEnumerAtion];
            
            NSString *g=[NSString stringWithFormat:@"%@",group];//获取相簿的组
            NSLog(@"gg:%@",g);//gg:ALAssetsGroup - Name:Camera Roll, Type:Saved Photos, Assets count:71
            NSString *g1=[g substringFromIndex:16 ] ;
            NSArray *arr=[[NSArray alloc] init];
            arr=[g1 componentsSeparatedByString:@","];
            NSString *groupName=[[arr objectAtIndex:0] substringFromIndex:5];
            GroupMediaObject *groupObject = [[GroupMediaObject alloc]init];
            groupObject.groupName = groupName;
            if(mediaArray.count > 0) {
                MediaObject *obj = [mediaArray objectAtIndex:0];
                groupObject.groupImage = obj.image;
                groupObject.itemNum = mediaArray.count;
                groupObject.mediaObjectArray = [[NSArray alloc]initWithArray:mediaArray];
                [mediaArray removeAllObjects];
            }
            [groupMediaArray addObject:groupObject];
            
        } else {
            [self.tableView reloadData];
        }
    };
    
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:libraryGroupsEnumeration
                         failureBlock:failureblock];
}

- (void)getImageFromUrl
{
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    NSURL *url=[NSURL URLWithString:@""];
    [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
        UIImage *image=[UIImage imageWithCGImage:asset.thumbnail];
        //    cellImageView.image=image;
        
    }failureBlock:^(NSError *error) {
        NSLog(@"error=%@",error);
    }
     ];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

@end
