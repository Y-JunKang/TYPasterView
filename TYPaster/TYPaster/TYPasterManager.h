//
//  TYPasterManager.h
//  TYPasterDemo
//
//  Created by 应俊康 on 2018/8/5.
//  Copyright © 2018年 应俊康. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYPasterView.h"


@interface TYPasterManager : NSObject

+ (instancetype)sharedInstance;

- (TYPasterView *)pasterWithImage:(UIImage *)image;

- (void)deletePasterWithId:(NSString *)pasterId;

@end
