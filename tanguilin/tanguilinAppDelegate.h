//
//  tanguilinAppDelegate.h
//  tanguilin
//
//  Created by yangyuji on 14-2-17.
//  Copyright (c) 2014年 com.tanguilin. All rights reserved.
//  有问题需要解答的，让加q群 170627662 ,我会尽我全力来回答问题，谢谢支持
#import <UIKit/UIKit.h> 
#import "BMapKit.h" 

#import "DDMenuController.h"
@interface tanguilinAppDelegate : UIResponder <UIApplicationDelegate>{
    BMKMapManager* _mapManager; 
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain)DDMenuController *ddmenu;

@end