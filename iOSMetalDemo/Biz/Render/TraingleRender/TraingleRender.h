//
//  TraingleRender.h
//  iOSMetalDemo
//
//  Created by 高明阳 on 2021/3/8.
//

#import <Foundation/Foundation.h>
// 导入MetalKit工具包
@import MetalKit;

NS_ASSUME_NONNULL_BEGIN

@interface TraingleRender : NSObject <MTKViewDelegate>

-(instancetype)initWithMTKView:(MTKView *)mtkView;

@end

NS_ASSUME_NONNULL_END
