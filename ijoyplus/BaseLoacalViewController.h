//
//  BaseLoacalViewController.h
//  ijoyplus
//
//  Created by joyplus1 on 12-11-9.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MediaObject.h"
#import "GroupMediaObject.h"

@interface BaseLoacalViewController : UITableViewController{
    NSMutableArray *mediaArray;
    NSMutableArray *groupMediaArray;
}


-(void)loadLocalMediaFiles:(int)mediaType;

@end
