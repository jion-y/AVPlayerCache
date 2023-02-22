//
//  RCAsset.m
//  AVPlayerCacher
//
//  Created by yoyo on 2023/2/22.
//

#import "RCAsset.h"

@interface RCAsset()<AVAssetResourceLoaderDelegate>

@end
@implementation RCAsset
- (instancetype)initWithUrl:(NSString *)url
                   delegate:(id<RCAssetDelegate>)delegate{
    if (url.length <= 0) {
       return nil;
    }
    self = [super init];
    if(self) {
        _url = url;
        _delegate = delegate;
    }
    return self;
}
- (void)startPreLoad {
    BOOL canPreLoad = YES;
    if(self.delegate && [self.delegate respondsToSelector:@selector(assetCanPreLoading:)]) {
        canPreLoad = [self.delegate assetCanPreLoading:self];
    }
    if(canPreLoad) {
      //开始预加载
    }
}

- (void)cancelPreLoad {
    
}

- (AVPlayerItem *)startPlay {
//    BOOL can
    return nil;
}

- (void)cancelPlay {
    
}
- (void)cancelAll {
    
}



#pragma mark- AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest  {
    return YES;
}

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForRenewalOfRequestedResource:(AVAssetResourceRenewalRequest *)renewalRequest {
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    
}


- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForResponseToAuthenticationChallenge:(NSURLAuthenticationChallenge *)authenticationChallenge {
    
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)authenticationChallenge {
    
}
@end
