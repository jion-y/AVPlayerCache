//
//  RCCacheManager.h
//  AVPlayerCacher
//
//  Created by yoyo on 2023/2/21.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "RCAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMediaManager : NSObject

/// 同时支持多少个边下编播任务，内部暂时支持先入先出策略。默认值为1
@property(nonatomic,assign)NSInteger maxPlayTaskNum ;

/// 同时支持多少个预加载任务,内部暂时支持先入先出策略。默认值为5
@property(nonatomic,assign)NSInteger maxPreLoadingTaskNum;


+ (instancetype) manager;

- (RCAsset *)createAsset:(NSString *)url;

- (void)cancelAsset:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
