//
//  ChangeColorRender.h
//  iOSMetalDemo
//
//  Created by 高明阳 on 2021/3/8.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MTKView.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChangeColorRender : NSObject<MTKViewDelegate>
-(instancetype)initWithMetalKitView:(MTKView *)mtkView;
@end

NS_ASSUME_NONNULL_END
