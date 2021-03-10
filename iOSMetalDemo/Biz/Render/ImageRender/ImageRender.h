//
//  ImageRender.h
//  iOSMetalDemo
//
//  Created by 高明阳 on 2021/3/9.
//

#import <Foundation/Foundation.h>
@import MetalKit;

NS_ASSUME_NONNULL_BEGIN

@interface ImageRender : NSObject<MTKViewDelegate>
- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView;
@end

NS_ASSUME_NONNULL_END
