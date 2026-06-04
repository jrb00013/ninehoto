using System.Collections.Generic;
using System.Linq;

namespace Ninehoto.Android.Models
{
    public enum GroupType
    {
        Burst,
        Duplicate,
        Single
    }

    public class AssetGroup
    {
        public string Id { get; }
        public List<MediaItem> Assets { get; }
        public GroupType Type { get; }
        public int Count => Assets.Count;
        public bool IsMultiple => Assets.Count > 1;
        public MediaItem BestAsset => Assets.First();
        public List<long> AssetIds => Assets.Select(a => a.Id).ToList();
        public string FormattedLabel => Type switch
        {
            GroupType.Burst => $"Burst · {Count}",
            GroupType.Duplicate => $"{Count} duplicates",
            _ => ""
        };

        public AssetGroup(List<MediaItem> assets, GroupType type)
        {
            var firstId = assets.FirstOrDefault()?.Id.ToString() ?? Guid.NewGuid().ToString();
            Id = $"{type}_{firstId}";
            Assets = assets;
            Type = type;
        }
    }
}
