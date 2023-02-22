//
//  RCAsset.h
//  AVPlayerCacher
//
//  Created by yoyo on 2023/2/22.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@class RCAsset;

typedef NS_ENUM(NSInteger,RCAssetStatus) {
  None = 0, //空闲
  play,    //边下边播
  PreLoading, //预加载
  Finish,  //任务完成
  Error,   //任务出错
};

@protocol RCAssetDelegate <NSObject>

- (BOOL)assetCanPreLoading:(RCAsset *)asset;
- (BOOL)assetCanPlayerLoading:(RCAsset *)asset;

@end

@interface RCAsset : NSObject

/// 当前资源对应的 url
@property(nonatomic,strong,readonly)NSString * url;

@property(nonatomic,assign,readonly)RCAssetStatus status;

@property(nonatomic,weak,readonly)id<RCAssetDelegate> delegate;

/// 开始预加载
- (void)startPreLoad;

- (void)cancelPreLoad;

/// 开始边播边下载,如果之前正在执行预加载任务则会停止预加载，执行边播边下载，已将预加载完成的数据不会删掉
- (AVPlayerItem *)startPlay;

- (void)cancelPlay;

/// 取消当前所有任务(包括预加载和边播边下载)
- (void)cancelAll;
@end

NS_ASSUME_NONNULL_END
