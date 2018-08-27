//
//  TYPasterView.h
//  TYPasterDemo
//
//  Created by 应俊康 on 2018/8/5.
//  Copyright © 2018年 应俊康. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TYPasterView;
@class TYPasterControl;
@class TYScaleControl;
@class TYRotateControl;
@class TYDeleteControl;

@protocol TYPasterViewDelegate <NSObject>

- (void)typasterViewDidTaped:(TYPasterView *)pasterView;

@end

@interface TYPasterView : UIView

@property (nonatomic, strong, readonly) NSString *pasterId;

// 贴纸上controls的相关设置
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) CGFloat controlWidth;

@property (nonatomic, strong) TYScaleControl *scaleControl;
@property (nonatomic, strong) TYRotateControl *rotateControl;
@property (nonatomic, strong) TYDeleteControl *deleteControl;

@property (nonatomic) BOOL enableGesture;
@property (nonatomic) BOOL enableDrag;
@property (nonatomic) BOOL enableScale;
@property (nonatomic) BOOL enableRotate;

// paster content
@property (nonatomic, strong, readonly) UIImageView *contentImageView;
@property (nonatomic, strong, readonly) UILabel *contentLabelView;
@property (nonatomic, strong, readonly) UIView *customeView;

/**
 创建贴纸实例
 
 @param image 贴纸展示的图片
 @param pasterId 贴纸Id，具有唯一性
 @return 贴纸实例
 */
- (instancetype)initWithImage:(UIImage *)image
                     pasterId:(NSString *)pasterId;


/**
 创建贴纸实例

 @param text 贴纸展示的文本
 @param pasterId 贴纸Id， 具有唯一性
 @return 贴纸实例
 */
- (instancetype)initWithText:(NSString *)text
                    pasterId:(NSString *)pasterId;

/**
 创建贴纸实例

 @param customeView 自定义贴纸显示的内容的view
 @param pasterId 贴纸Id， 具有唯一性
 @return 贴纸实例
 */
- (instancetype)initWithCustomeView:(UIView *)customeView
                           pasterId:(NSString *)pasterId;

/**
 显示贴纸的控制按钮
 */
- (void)showControls;

/**
 隐藏贴纸的控制按钮
 */
- (void)hideControls;

/**
 在paster上增加一个control

 @param control 自定义control
 */
- (void)addControl:(TYPasterControl *)control;

/**
 在paster上移除一个control

 @param control control
 */
- (void)removeControl:(TYPasterControl *)control;

/**
 清空所有control
 */
- (void)clearAllControl;

/**
 显示border
 */
- (void)showBorders;

/**
 隐藏border
 */
- (void)hideBorders;

@end


@interface TYPasterManager : NSObject

+ (instancetype)sharedInstance;

/**
 创建paster

 @param image paster显示的image
 @return pasterView
 */
- (TYPasterView *)pasterWithImage:(UIImage *)image;

/**
 创建paster

 @param text pster显示的text
 @return pasterView
 */
- (TYPasterView *)pasterWithText:(NSString *)text;

/**
 创建paster

 @param customeView 自定义view
 @return pasterView;
 */
- (TYPasterView *)pasterWithCustomeView:(UIView *)customeView;

/**
 通过pasterId删除paster

 @param pasterId for pasterView
 */
- (void)deletePasterWithId:(NSString *)pasterId;

/**
 清空所有paster
 */
- (void)clearAll;
@end

@interface TYPasterControl : UIImageView

- (instancetype)initWithPasterView:(TYPasterView *)pasterView;

@end

/**
 缩放控制按钮
 */
@interface TYScaleControl : TYPasterControl

@end

/**
 旋转控制钮
 */
@interface TYRotateControl : TYPasterControl

@end

/**
 删除控制钮
 */
@interface TYDeleteControl : TYPasterControl

@end

