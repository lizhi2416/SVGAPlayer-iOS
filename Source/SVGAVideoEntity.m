//
//  SVGAVideoEntity.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "SVGAVideoEntity.h"
#import "SVGABezierPath.h"
#import "SVGAVideoSpriteEntity.h"
#import "SVGAAudioEntity.h"
#import "Svga.pbobjc.h"

@interface SVGAVideoEntity ()

@property (nonatomic, assign) CGSize videoSize;
@property (nonatomic, assign) int FPS;
@property (nonatomic, assign) int frames;
@property (nonatomic, copy) NSDictionary<NSString *, UIImage *> *images;
@property (nonatomic, copy) NSDictionary<NSString *, NSData *> *audiosData;
@property (nonatomic, copy) NSArray<SVGAVideoSpriteEntity *> *sprites;
@property (nonatomic, copy) NSArray<SVGAAudioEntity *> *audios;
@property (nonatomic, copy) NSString *cacheDir;

@end

@implementation SVGAVideoEntity

static NSCache *videoCache;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        videoCache = [[NSCache alloc] init];
        videoCache.countLimit = 1;
    });
}

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject cacheDir:(NSString *)cacheDir {
    self = [super init];
    if (self) {
        _videoSize = CGSizeMake(100, 100);
        _FPS = 20;
        _images = @{};
        _cacheDir = cacheDir;
        [self resetMovieWithJSONObject:JSONObject];
    }
    return self;
}

- (void)resetMovieWithJSONObject:(NSDictionary *)JSONObject {
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *movieObject = JSONObject[@"movie"];
        if ([movieObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *viewBox = movieObject[@"viewBox"];
            if ([viewBox isKindOfClass:[NSDictionary class]]) {
                NSNumber *width = viewBox[@"width"];
                NSNumber *height = viewBox[@"height"];
                if ([width isKindOfClass:[NSNumber class]] && [height isKindOfClass:[NSNumber class]]) {
                    _videoSize = CGSizeMake(width.floatValue, height.floatValue);
                }
            }
            NSNumber *FPS = movieObject[@"fps"];
            if ([FPS isKindOfClass:[NSNumber class]]) {
                _FPS = [FPS intValue];
            }
            NSNumber *frames = movieObject[@"frames"];
            if ([frames isKindOfClass:[NSNumber class]]) {
                _frames = [frames intValue];
            }
        }
    }
}

- (void)resetImagesWithJSONObject:(NSDictionary *)JSONObject {
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary<NSString *, UIImage *> *images = [[NSMutableDictionary alloc] init];
        NSDictionary<NSString *, NSString *> *JSONImages = JSONObject[@"images"];
        if ([JSONImages isKindOfClass:[NSDictionary class]]) {
            [JSONImages enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSString class]]) {
                    NSString *filePath = [self.cacheDir stringByAppendingFormat:@"/%@.png", obj];
                    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
                    if (imageData != nil) {
                        UIImage *image = [[UIImage alloc] initWithData:imageData scale:2.0];
                        if (image != nil) {
                            [images setObject:image forKey:key];
                        }
                    }
                }
            }];
        }
        self.images = images;
    }
}

- (void)resetSpritesWithJSONObject:(NSDictionary *)JSONObject {
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSMutableArray<SVGAVideoSpriteEntity *> *sprites = [[NSMutableArray alloc] init];
        NSArray<NSDictionary *> *JSONSprites = JSONObject[@"sprites"];
        if ([JSONSprites isKindOfClass:[NSArray class]]) {
            [JSONSprites enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    SVGAVideoSpriteEntity *spriteItem = [[SVGAVideoSpriteEntity alloc] initWithJSONObject:obj];
                    [sprites addObject:spriteItem];
                }
            }];
        }
        self.sprites = sprites;
    }
}

- (instancetype)initWithProtoObject:(SVGAProtoMovieEntity *)protoObject cacheDir:(NSString *)cacheDir {
    self = [super init];
    if (self) {
        _videoSize = CGSizeMake(100, 100);
        _FPS = 20;
        _images = @{};
        _cacheDir = cacheDir;
        [self resetMovieWithProtoObject:protoObject];
    }
    return self;
}

- (void)resetMovieWithProtoObject:(SVGAProtoMovieEntity *)protoObject {
    if (protoObject.hasParams) {
        self.videoSize = CGSizeMake((CGFloat)protoObject.params.viewBoxWidth, (CGFloat)protoObject.params.viewBoxHeight);
        self.FPS = (int)protoObject.params.fps;
        self.frames = (int)protoObject.params.frames;
    }
}

- (void)resetImagesWithProtoObject:(SVGAProtoMovieEntity *)protoObject {
    NSMutableDictionary<NSString *, UIImage *> *images = [[NSMutableDictionary alloc] init];
    NSMutableDictionary<NSString *, NSData *> *audiosData = [[NSMutableDictionary alloc] init];
    NSDictionary *protoImages = [protoObject.images copy];
    for (NSString *key in protoImages) {
        NSString *fileName = [[NSString alloc] initWithData:protoImages[key] encoding:NSUTF8StringEncoding];
        if (fileName != nil) {
            NSString *filePath = [self.cacheDir stringByAppendingFormat:@"/%@.png", fileName];
            if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
               filePath = [self.cacheDir stringByAppendingFormat:@"/%@", fileName];
            }
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                NSData *imageData = [NSData dataWithContentsOfFile:filePath];
                if (imageData != nil) {
                    UIImage *image = [[UIImage alloc] initWithData:imageData scale:2.0];
                    if (image != nil) {
                        [images setObject:image forKey:key];
                    }
                }
            }
        }
        else if ([protoImages[key] isKindOfClass:[NSData class]]) {
            NSData *fileTag = [protoImages[key] subdataWithRange:NSMakeRange(0, 4)];
            if (![[fileTag description] isEqualToString:@"<89504e47>"]) {
                // mp3
                [audiosData setObject:protoImages[key] forKey:key];
            }
            else {
                UIImage *image = [[UIImage alloc] initWithData:protoImages[key] scale:2.0];
                if (image != nil) {
                    [images setObject:image forKey:key];
                }
            }
        }
    }
    self.images = images;
    self.audiosData = audiosData;
}

- (void)resetSpritesWithProtoObject:(SVGAProtoMovieEntity *)protoObject {
    NSMutableArray<SVGAVideoSpriteEntity *> *sprites = [[NSMutableArray alloc] init];
    NSArray *protoSprites = [protoObject.spritesArray copy];
    [protoSprites enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[SVGAProtoSpriteEntity class]]) {
            SVGAVideoSpriteEntity *spriteItem = [[SVGAVideoSpriteEntity alloc] initWithProtoObject:obj];
            [sprites addObject:spriteItem];
        }
    }];
    self.sprites = sprites;
}
    
- (void)resetAudiosWithProtoObject:(SVGAProtoMovieEntity *)protoObject {
    NSMutableArray<SVGAAudioEntity *> *audios = [[NSMutableArray alloc] init];
    NSArray *protoAudios = [protoObject.audiosArray copy];
    [protoAudios enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[SVGAProtoAudioEntity class]]) {
            SVGAAudioEntity *audioItem = [[SVGAAudioEntity alloc] initWithProtoObject:obj];
            [audios addObject:audioItem];
        }
    }];
    self.audios = audios;
}

+ (SVGAVideoEntity *)readCache:(NSString *)cacheKey {
    return [videoCache objectForKey:cacheKey];
}

- (void)saveCache:(NSString *)cacheKey {
    [videoCache setObject:self forKey:cacheKey];
}

@end

@interface SVGAVideoSpriteEntity()

@property (nonatomic, copy) NSString *imageKey;
@property (nonatomic, copy) NSArray<SVGAVideoSpriteFrameEntity *> *frames;

@end

