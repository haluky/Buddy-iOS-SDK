//
//  BPAlbumItemCollection.m
//  BuddySDK
//
//  Created by Erik Kerber on 1/25/14.
//
//

#import "BPAlbumItemCollection.h"
#import "BuddyCollection+Private.h"
#import "BPAlbumItem.h"
#import "BPSisterObject.h"

@interface BPAlbumItemCollection()

@property (nonatomic, weak) BPAlbum *album;

@end

@implementation BPAlbumItemCollection

- (instancetype)initWithAlbum:(BPAlbum *)album andClient:(id<BPRestProvider>)client
{
    self = [super initWithClient:client];
    if (self) {
        self.type = [BPAlbumItem class];
        _album = album;
    }
    return self;
}

- (NSString *)requestPrefix
{
    return [NSString stringWithFormat:@"albums/%@/", self.album.id];
}

- (void)addAlbumItem:(NSString *)itemId
         withCaption:(NSString *)caption
            callback:(BuddyObjectCallback)callback
{
    NSDictionary *params = @{
                             @"ItemId": itemId,
                             @"caption": caption
                             };
    NSString *requestPath = [self.requestPrefix stringByAppendingString:[[self type] requestPath]];
    
    [self.client POST:requestPath parameters:params callback:^(id json, NSError *error) {
        callback(json, error);
    }];
}

- (void)searchAlbumItems:(BPSearchAlbumItems *)searchAlbumItems callback:(BuddyObjectCallback)callback
{
    id parameters = [searchAlbumItems parametersFromProperties:@protocol(BPAlbumItemProperties)];
    
    [self search:parameters callback:callback];
}


- (void)getAlbumItem:(NSString *)itemId
            callback:(BuddyObjectCallback)callback
{
    [self getItem:itemId callback:callback];
}
@end
