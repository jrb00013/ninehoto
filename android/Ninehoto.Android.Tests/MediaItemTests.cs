using System;
using System.Collections.Generic;
using System.Linq;
using Xunit;

namespace Ninehoto.Tests;

public class MediaItemTests
{
    [Fact]
    public void MediaItem_CanBeInstantiated()
    {
        var item = new MediaItem(1, Android.Net.Uri.Parse("content://test"), false, 1000L);
        Assert.Equal(1L, item.Id);
        Assert.False(item.IsVideo);
        Assert.Equal(1000L, item.DateAddedSec);
    }

    [Fact]
    public void MediaItem_VideoFlag()
    {
        var item = new MediaItem(42, Android.Net.Uri.Parse("content://test"), true, 2000L);
        Assert.True(item.IsVideo);
    }

    [Fact]
    public void MediaItem_DateAddedSec()
    {
        var item = new MediaItem(1, Android.Net.Uri.Parse("content://test"), false, 999999999L);
        Assert.Equal(999999999L, item.DateAddedSec);
    }

    [Theory]
    [InlineData(1)]
    [InlineData(999)]
    [InlineData(long.MaxValue)]
    public void MediaItem_IdValues(long id)
    {
        var item = new MediaItem(id, Android.Net.Uri.Parse("content://test"), false, 0);
        Assert.Equal(id, item.Id);
    }
}

public class MediaRepositoryTests
{
    [Fact]
    public void SessionLimit_IsReasonable()
    {
        Assert.Equal(200, MediaRepository.SessionLimit);
        Assert.True(MediaRepository.SessionLimit > 0);
        Assert.True(MediaRepository.SessionLimit < 10000);
    }
}

public class ThumbnailCacheTests
{
    [Fact]
    public void ThumbnailCache_CanBeInstantiatedWithContext()
    {
        var cache = new Ninehoto.ThumbnailCache(Android.App.Application.Context);
        Assert.NotNull(cache);
    }
}
