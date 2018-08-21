//
//  TYPasterView.h
//  TYPasterDemo
//
//  Created by 应俊康 on 2018/8/5.
//  Copyright © 2018年 应俊康. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYPasterView : UIView

@property (nonatomic, strong) NSString *pasterId;

@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) CGFloat controlWidth;

@property (nonatomic, strong) UIImage *deleteControlIcon;
@property (nonatomic, strong) UIImage *scaleControlIcon;
@property (nonatomic, strong) UIImage *rotateControlIcon;



/**
 创建贴纸实例
 
 @param image 贴纸展示的图片
 @param pasterId 贴纸Id，具有唯一性
 @return 贴纸实例
 */
- (instancetype)initWithImage:(UIImage *)image
                     pasterId:(NSString *)pasterId;

- (void)showControls;

- (void)hideControls;

@end
