//
//  TYPasterView+Private.h
//  TYPasterDemo
//
//  Created by 应俊康 on 2018/8/20.
//  Copyright © 2018年 应俊康. All rights reserved.
//


@protocol TYPasterViewDelegate <NSObject>

- (void)typasterViewDidTaped:(TYPasterView *)pasterView;

@end


@interface TYPasterView(Private)

- (void)setDelegate:(id<TYPasterViewDelegate>)delegate;

@end

