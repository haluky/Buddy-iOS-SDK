//
//  BPBaseIntegrationTests.m
//  BuddySDK
//
//  Created by Erik Kerber on 12/3/13.
//
//

#import "Buddy.h"
#import "BuddyIntegrationHelper.h"
#import <Kiwi/Kiwi.h>

#ifdef kKW_DEFAULT_PROBE_TIMEOUT
#undef kKW_DEFAULT_PROBE_TIMEOUT
#endif
#define kKW_DEFAULT_PROBE_TIMEOUT 10.0

SPEC_BEGIN(BuddyBlobSpec)

describe(@"BPBlobIntegrationSpec", ^{
    context(@"When a user is logged in", ^{
        __block BPBlob *newBlob;
        __block BPBlob *retrievedBlob;
        __block BOOL fin = NO;

        beforeAll(^{
            
            [BuddyIntegrationHelper bootstrapLogin:^{
                fin = YES;
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
        
        beforeEach(^{
            fin = NO;
        });
        
        it(@"Should allow users to upload blobs", ^{
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            NSString *blobPath = [bundle pathForResource:@"help" ofType:@"jpg"];
            NSData *blobData = [NSData dataWithContentsOfFile:blobPath];
            
            [[Buddy blobs] addBlob:blobData describe:^(id<BPBlobProperties> blobProperties) {
                blobProperties.friendlyName = @"So friendly";
            } callback:^(id newBuddyObject, NSError *error) {
                newBlob = newBuddyObject;
            }];
            
            [[expectFutureValue(newBlob) shouldEventually] beNonNil];
            [[expectFutureValue(theValue(newBlob.contentLength)) shouldEventually] equal:theValue(1)];
            [[expectFutureValue(newBlob.friendlyName) shouldEventually] equal:@"So friendly"];
            [[expectFutureValue(newBlob.signedUrl) shouldEventually] haveLengthOfAtLeast:1];
        });
        
        it(@"Should allow retrieving blobs", ^{
            [[Buddy blobs] getBlob:newBlob.id callback:^(BPBlob *blob, NSError *error) {
                retrievedBlob = blob;
                [[retrievedBlob.id should] equal:newBlob.id];
                [[error should] beNil];
                fin = YES;
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
        
        it(@"Should allow modifying blobs", ^{
            
            NSString *newFriendly = @"Not so friendly?";
            retrievedBlob.friendlyName = newFriendly;
            
            [retrievedBlob save:^(NSError *error) {
                [[error should] beNil];
                [[Buddy blobs] getBlob:newBlob.id callback:^(BPBlob *blob, NSError *error) {
                    retrievedBlob = blob;
                    [[retrievedBlob.id should] equal:newBlob.id];
                    [[retrievedBlob.friendlyName should] equal:newFriendly];
                    [[error should] beNil];
                    fin = YES;
                }];
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
        
        it(@"Should allow searching for blobs", ^{
            [[Buddy blobs] searchBlobs:^(id<BPBlobProperties> blobProperties) {
                blobProperties.friendlyName = @"So friendly";
            } callback:^(NSArray *buddyObjects, NSError *error) {
                [[theValue([buddyObjects count]) should] beGreaterThan:theValue(0)];
                fin = YES;
            }];

            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
        
        it (@"Should allow the user to delete blobs", ^{
            [newBlob destroy:^(NSError *error) {
                [[error should] beNil];
                fin = YES;
            }];
            
            [[expectFutureValue(theValue(fin)) shouldEventually] beTrue];
        });
        
        
    });
});

SPEC_END

