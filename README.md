# horizontalCollectionView


# iOS Photo Gallery (Objective-C + Photos Framework)

A simple and efficient iOS photo gallery app built using **Objective-C**, **Photos framework**, and **UICollectionView (Horizontal Layout)**.  
It loads images from the user’s photo library with proper permission handling, supports iOS 14+ limited access, and updates automatically when the photo library changes.

---

## Features

- Load photos from device photo library
- Proper Photos permission handling (iOS 11+ / iOS 14+)
- Immediate UI update after permission is granted
- Supports **Limited Photos Access (iOS 14+)**
- Auto refresh when photo library changes
- Smooth image loading using `PHCachingImageManager`
- Optimized thumbnail rendering
- Handles denied / restricted permissions with settings redirect

---

## Tech Stack

- Objective-C
- Uses UIKit `UICollectionView` with **horizontal scrolling direction**
- Photos Framework (`PHAsset`, `PHFetchResult`, `PHCachingImageManager`)

---

## How It Works

### 1. Permission Handling
The app checks photo library permission on launch:

- First launch → Requests permission
- Granted → Loads images immediately
- Denied → Shows alert with **Open Settings** option
- Limited Access → Loads selected photos + supports updates


---

### 2. Fetching Photos

Photos are fetched using:

- `PHFetchResult` for asset retrieval
- Sorted by creation date (newest first)

Only image assets are loaded:

```objective-c
[PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];


Requirements
iOS 11+
Xcode 12+
Objective-C support enabled project
