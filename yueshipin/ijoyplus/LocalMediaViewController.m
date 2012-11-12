//
//  LocalMediaViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-11-8.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "LocalMediaViewController.h"
#import "MediaObject.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AssetsLibrary/ALAsset.h>
#import "MediaPlayerViewController.h"

@interface LocalMediaViewController (){
    NSMutableArray *imageArray;
    NSMutableArray *videoArray;
    NSMutableArray *groupArray;
    NSMutableArray *thumbnailImageArray;
    NSMutableArray *mediaObjectArray;
}
@end

@implementation LocalMediaViewController

- (void)viewDidUnload
{
    [super viewDidUnload];
    [imageArray removeAllObjects];
    imageArray = nil;
    [videoArray removeAllObjects];
    videoArray = nil;
    [groupArray removeAllObjects];
    groupArray = nil;
    [thumbnailImageArray removeAllObjects];
    thumbnailImageArray = nil;
    [mediaObjectArray removeAllObjects];
    mediaObjectArray = nil;
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
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"close", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(closeSelf)];
    self.navigationItem.leftBarButtonItem = leftButton;
    [self loadLocalMediaFiles];
    
    imageArray = [[NSMutableArray alloc]initWithCapacity:10];
    videoArray = [[NSMutableArray alloc]initWithCapacity:10];
    groupArray = [[NSMutableArray alloc]initWithCapacity:10];
    thumbnailImageArray = [[NSMutableArray alloc]initWithCapacity:10];
    mediaObjectArray = [[NSMutableArray alloc]initWithCapacity:10];
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return thumbnailImageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.imageView.image = [thumbnailImageArray objectAtIndex:indexPath.row];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MediaObject *mediaFile = (MediaObject *)[mediaObjectArray objectAtIndex:indexPath.row];
//    if(mediaFile.mediaType == 2){
//        MediaPlayerViewController *viewController = [[MediaPlayerViewController alloc]initWithNibName:@"MediaPlayerViewController" bundle:nil];
//        viewController.videoUrl = mediaFile.mediaURL;
//        [self presentModalViewController:viewController animated:YES];
//    }
    
}


-(void)loadLocalMediaFiles{
    
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
            MediaObject *mediaFile = [[MediaObject alloc]init];
            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                NSString *urlstr=[NSString stringWithFormat:@"%@",result.defaultRepresentation.url];//图片的url
                /*result.defaultRepresentation.fullScreenImage//图片的大图
                 result.thumbnail                             //图片的缩略图小图
                 //                    NSRange range1=[urlstr rangeOfString:@"id="];
                 //                    NSString *resultName=[urlstr substringFromIndex:range1.location+3];
                 //                    resultName=[resultName stringByReplacingOccurrencesOfString:@"&ext=" withString:@"."];//格式demo:123456.png
                 */
                
//                mediaFile.mediaType = 1;
                mediaFile.mediaURL = urlstr;
                [imageArray addObject:urlstr];
                
                [thumbnailImageArray addObject:[UIImage imageWithCGImage:result.thumbnail]];
                [mediaObjectArray addObject:mediaFile];
            } else if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                NSString *urlstr=[NSString stringWithFormat:@"%@",result.defaultRepresentation.url];
//                mediaFile.mediaType = 2;
                mediaFile.mediaURL = urlstr;
                [videoArray addObject:urlstr];
                [thumbnailImageArray addObject:[UIImage imageWithCGImage:result.thumbnail]];
                [mediaObjectArray addObject:mediaFile];
                
            }
        }
        
    };
    
    void (^libraryGroupsEnumeration)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup* group, BOOL* stop){
        if (group!=nil) {
            NSString *g=[NSString stringWithFormat:@"%@",group];//获取相簿的组
            NSLog(@"gg:%@",g);//gg:ALAssetsGroup - Name:Camera Roll, Type:Saved Photos, Assets count:71
            
            NSString *g1=[g substringFromIndex:16 ] ;
            NSArray *arr=[[NSArray alloc] init];
            arr=[g1 componentsSeparatedByString:@","];
            NSString *g2=[[arr objectAtIndex:0] substringFromIndex:5];
            [groupArray addObject:g2];
            
            [group enumerateAssetsUsingBlock:groupEnumerAtion];
        } else {
            [self.tableView reloadData];
        }
    };
    
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:libraryGroupsEnumeration
                         failureBlock:failureblock];
    
    
    
    
}


- (void)getImage
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
- (void)closeSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
