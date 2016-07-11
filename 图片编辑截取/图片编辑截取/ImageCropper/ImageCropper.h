//
//  ImageCropper.h
//  图片编辑截取
//
//  Created by mac on 16/5/30.
//  Copyright © 2016年 ZnLG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCropper : UIViewController
@property (nonatomic, assign) CGRect cropFrame;
@property (nonatomic, copy) void (^dismissBlock)(void);


- (instancetype)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio;

-(UIImage *)getSubImage;


@end
