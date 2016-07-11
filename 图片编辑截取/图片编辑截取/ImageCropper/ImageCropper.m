//
//  ImageCropper.m
//  图片编辑截取
//
//  Created by mac on 16/5/30.
//  Copyright © 2016年 ZnLG. All rights reserved.
//

#import "ImageCropper.h"

#define BOUNDCE_DURATION 0.3f

@interface ImageCropper ()
@property (nonatomic, retain) UIImage *originalImage;
@property (nonatomic, retain) UIImage *editedImage;
@property (nonatomic, retain) UIImageView *showImgView;
@property (nonatomic, assign) CGFloat limitRatio;
@property (nonatomic, assign) CGRect oldFrame;
@property (nonatomic, retain) UIView *ratioView;
@property (nonatomic, assign) CGRect largeFrame;
@property (nonatomic, assign) CGRect latestFrame;

@end

@implementation ImageCropper

- (instancetype)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio {
    self = [super init];
    if (self) {
        self.cropFrame = cropFrame;
        self.limitRatio = limitRatio;
        self.originalImage = originalImage;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"移动和缩放";
    
    UIBarButtonItem *confirm = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(finishAction:)];

    self.navigationItem.rightBarButtonItem = confirm;
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    self.navigationItem.leftBarButtonItem = cancel;

    
    [self initView];
    
    [self addGestureRecognizers];
    
    

}

- (void)cancelAction:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)finishAction:(id)sender {
    
    
    [self.navigationController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

- (void)dealloc {
    self.originalImage = nil;
    self.showImgView = nil;
    self.editedImage = nil;
    self.ratioView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (void) initView {

    self.view.backgroundColor = [UIColor blackColor];
    self.showImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.showImgView.image = self.originalImage;
    self.showImgView.multipleTouchEnabled = YES;
    self.showImgView.userInteractionEnabled = YES;
    
    CGFloat showImg_W = self.cropFrame.size.width;
    
    CGFloat showImg_X = self.cropFrame.origin.x + (self.cropFrame.size.width -showImg_W )/2;
    
//    CGFloat showImg_X = 0;

    CGFloat showImg_H = showImg_W * self.originalImage.size.height/self.originalImage.size.width;


    CGFloat showImg_Y = self.cropFrame.origin.y +(self.cropFrame.size.height - showImg_H)/2;

    self.oldFrame = CGRectMake(showImg_X, showImg_Y, showImg_W, showImg_H);
    self.latestFrame = self.oldFrame;
    self.showImgView.frame = self.oldFrame;

    self.largeFrame = CGRectMake(0, 0, self.limitRatio * self.oldFrame.size.width, self.limitRatio * self.oldFrame.size.height);
    [self.view addSubview:self.showImgView];

    CGFloat ratio_W ;//= self.showImgView.frame.size.width;
//    CGFloat ratio_H = ratio_W;
    if (self.showImgView.frame.size.width>self.showImgView.frame.size.height) {
        ratio_W = self.showImgView.frame.size.height ;
    }else {
        
        ratio_W = self.showImgView.frame.size.width ;

    }
    
    CGFloat ratio_H = ratio_W;
    CGFloat ratio_X = self.showImgView.frame.origin.x + (self.showImgView.frame.size.width - ratio_W)/2.0;
    CGFloat ratio_Y = self.showImgView.frame.origin.y + (self.showImgView.frame.size.height - ratio_H)/2.0;

    
    CGRect raTio = CGRectMake(ratio_X, ratio_Y, ratio_W, ratio_H);
    self.ratioView = [[UIView alloc] initWithFrame:raTio];
    self.ratioView.layer.cornerRadius = ratio_W/2;
    self.ratioView.layer.borderWidth = 1.0f;
    self.ratioView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.ratioView.autoresizingMask = UIViewAutoresizingNone;

    [self.view addSubview:self.ratioView];
    
    [self getView:self.view withRect:raTio];
}

/**
 *  添加了滤镜
 *
 *  @param backView 蒙版的VIEW
 *  @param rect     滤镜圆形宽
 */
- (void)getView:(UIView *)backView withRect:(CGRect) rect
{
    
    int radius = rect.size.width/2.0;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:backView.bounds cornerRadius:0];
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    
    [path appendPath:circlePath];
    
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer  layer];
    
    fillLayer.path = path.CGPath;
    
    fillLayer.fillRule =kCAFillRuleEvenOdd;
    
    fillLayer.fillColor = [UIColor  blackColor].CGColor;
    
    //透明度
    fillLayer.opacity =0.5;
    
    fillLayer.borderColor = [UIColor whiteColor].CGColor;
    
    [backView.layer  addSublayer:fillLayer];
    
}


// register all gestures
- (void) addGestureRecognizers
{
    //缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    //拖动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
}

// pinch gesture handler
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = self.showImgView;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

- (CGRect)handleScaleOverflow:(CGRect)newFrame {
    // bounce to original frame
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width/2, newFrame.origin.y + newFrame.size.height/2);
    if (newFrame.size.width < self.oldFrame.size.width) {
        newFrame = self.oldFrame;
    }
    if (newFrame.size.width > self.largeFrame.size.width) {
        newFrame = self.largeFrame;
    }
    newFrame.origin.x = oriCenter.x - newFrame.size.width/2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height/2;
    return newFrame;
}

- (CGRect)handleBorderOverflow:(CGRect)newFrame {
    // horizontally
    if (newFrame.origin.x > self.cropFrame.origin.x) newFrame.origin.x = self.cropFrame.origin.x;
    if (CGRectGetMaxX(newFrame) < self.cropFrame.size.width) newFrame.origin.x = self.cropFrame.size.width - newFrame.size.width;
    // vertically
    if (newFrame.origin.y > self.cropFrame.origin.y) newFrame.origin.y = self.cropFrame.origin.y;
    if (CGRectGetMaxY(newFrame) < self.cropFrame.origin.y + self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + self.cropFrame.size.height - newFrame.size.height;
    }
    // adapt horizontally rectangle
    if (self.showImgView.frame.size.width > self.showImgView.frame.size.height && newFrame.size.height <= self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + (self.cropFrame.size.height - newFrame.size.height) / 2;
    }
    return newFrame;
}

// pan gesture handler
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = self.showImgView;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // calculate accelerator
        CGFloat absCenterX = self.cropFrame.origin.x + self.cropFrame.size.width / 2;
        CGFloat absCenterY = self.cropFrame.origin.y + self.cropFrame.size.height / 2;
        CGFloat scaleRatio = self.showImgView.frame.size.width / self.cropFrame.size.width;
        CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
        CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // bounce to original frame
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

-(UIImage *)getSubImage{
    CGRect squareFrame = self.cropFrame;
    CGFloat scaleRatio = self.latestFrame.size.width / self.originalImage.size.width;
    CGFloat x = (squareFrame.origin.x - self.latestFrame.origin.x) / scaleRatio;
    CGFloat y = (squareFrame.origin.y - self.latestFrame.origin.y) / scaleRatio;
    CGFloat w = squareFrame.size.width / scaleRatio;
    CGFloat h = squareFrame.size.width / scaleRatio;
    if (self.latestFrame.size.width < self.cropFrame.size.width) {
        CGFloat newW = self.originalImage.size.width;
        CGFloat newH = newW * (self.cropFrame.size.height / self.cropFrame.size.width);
        x = 0; y = y + (h - newH) / 2;
        w = newH; h = newH;
    }
    if (self.latestFrame.size.height < self.cropFrame.size.height) {
        CGFloat newH = self.originalImage.size.height;
        CGFloat newW = newH * (self.cropFrame.size.width / self.cropFrame.size.height);
        x = x + (w - newW) / 2; y = 0;
        w = newH; h = newH;
    }
    CGRect myImageRect = CGRectMake(x, y, w, h);
    CGImageRef imageRef = self.originalImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    CGSize size;
    size.width = myImageRect.size.width;
    size.height = myImageRect.size.height;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    return smallImage;
}


@end
