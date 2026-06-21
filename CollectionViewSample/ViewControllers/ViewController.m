//
//  ViewController.m
//  CollectionViewSample
//
//  Created by Prakash Maharjan on 2/22/17.
//  Copyright © 2017 Prakash Maharjan. All rights reserved.
//

#import "ViewController.h"
#import "ColCell.h"
#import <Photos/Photos.h>

@interface ViewController () <
UICollectionViewDelegate,
UICollectionViewDataSource,
PHPhotoLibraryChangeObserver>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionVC;

@property (nonatomic, strong) PHFetchResult<PHAsset *> *assetsFetchResults;
@property (nonatomic, strong) PHCachingImageManager *imageManager;

@end

@implementation ViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.imageManager = [[PHCachingImageManager alloc] init];

    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [self checkPhotoPermissionAndLoad];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - App State

- (void)appDidBecomeActive
{
    [self checkPhotoPermissionAndLoad];
}

#pragma mark - Permission Handling

- (void)checkPhotoPermissionAndLoad
{
    PHAuthorizationStatus status;

    if (@available(iOS 14, *))
    {
        status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
    }
    else
    {
        status = [PHPhotoLibrary authorizationStatus];
    }

    switch (status)
    {
        case PHAuthorizationStatusAuthorized:
        {
            [self loadPhotos];
            break;
        }

        case PHAuthorizationStatusLimited:
        {
            [self loadPhotos];
            break;
        }

        case PHAuthorizationStatusNotDetermined:
        {
            [self requestPhotoPermission];
            break;
        }

        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
        {
            [self showPhotoPermissionAlert];
            break;
        }
    }
}

- (void)requestPhotoPermission
{
    if (@available(iOS 14, *))
    {
        [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite
                                                   handler:^(PHAuthorizationStatus status)
         {
             dispatch_async(dispatch_get_main_queue(), ^{

                 if (status == PHAuthorizationStatusAuthorized ||
                     status == PHAuthorizationStatusLimited)
                 {
                     [self loadPhotos];
                 }
                 else
                 {
                     [self showPhotoPermissionAlert];
                 }
             });
         }];
    }
    else
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status)
         {
             dispatch_async(dispatch_get_main_queue(), ^{

                 if (status == PHAuthorizationStatusAuthorized)
                 {
                     [self loadPhotos];
                 }
                 else
                 {
                     [self showPhotoPermissionAlert];
                 }
             });
         }];
    }
}

- (void)showPhotoPermissionAlert
{
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"Photos Permission Required"
                                        message:@"Please enable Photo Library access in Settings to view your photos."
                                 preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                           handler:nil];

    UIAlertAction *settingsAction =
    [UIAlertAction actionWithTitle:@"Open Settings"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * _Nonnull action)
     {
         NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

         if ([[UIApplication sharedApplication] canOpenURL:url])
         {
             [[UIApplication sharedApplication] openURL:url
                                                options:@{}
                                      completionHandler:nil];
         }
     }];

    [alert addAction:cancelAction];
    [alert addAction:settingsAction];

    if (self.presentedViewController == nil)
    {
        [self presentViewController:alert
                           animated:YES
                         completion:nil];
    }
}

#pragma mark - Load Photos

- (void)loadPhotos
{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];

    options.sortDescriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:@"creationDate"
                                      ascending:NO]
    ];

    self.assetsFetchResults =
    [PHAsset fetchAssetsWithOptions:options];

    [self.collectionVC reloadData];
}

#pragma mark - Photo Library Changes

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadPhotos];
    });
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.assetsFetchResults.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ColCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"ColCell"
                                              forIndexPath:indexPath];

    PHAsset *asset = self.assetsFetchResults[indexPath.item];

    CGFloat scale = [UIScreen mainScreen].scale;

    CGSize targetSize =
    CGSizeMake(cell.colImgVC.bounds.size.width * scale,
               cell.colImgVC.bounds.size.height * scale);

    [self.imageManager requestImageForAsset:asset
                                 targetSize:targetSize
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result,
                                              NSDictionary *info)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             cell.colImgVC.image = result;
         });
     }];

    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.assetsFetchResults[indexPath.item];

    [self.imageManager requestImageForAsset:asset
                                 targetSize:PHImageManagerMaximumSize
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result,
                                              NSDictionary *info)
     {
         NSLog(@"Selected image: %@", result);
     }];
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
