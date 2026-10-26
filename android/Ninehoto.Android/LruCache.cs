using System.Collections.Generic;

namespace Ninehoto
{
    internal sealed class LruCache<TKey, TValue> where TKey : notnull where TValue : class
    {
        private readonly int _capacity;
        private readonly Dictionary<TKey, LinkedListNode<KeyValuePair<TKey, TValue>>> _map = new();
        private readonly LinkedList<KeyValuePair<TKey, TValue>> _order = new();
        private readonly object _lock = new();

        public LruCache(int capacity) => _capacity = capacity < 1 ? 1 : capacity;

        public TValue? Get(TKey key)
        {
            lock (_lock)
            {
                if (!_map.TryGetValue(key, out var node)) return null;
                _order.Remove(node);
                _order.AddFirst(node);
                return node.Value.Value;
            }
        }

        public void Put(TKey key, TValue value)
        {
            lock (_lock)
            {
                if (_map.TryGetValue(key, out var existing))
                {
                    _order.Remove(existing);
                    _map.Remove(key);
                }
                _map[key] = _order.AddFirst(new KeyValuePair<TKey, TValue>(key, value));
                while (_map.Count > _capacity)
                {
                    var last = _order.Last!;
                    _order.RemoveLast();
                    _map.Remove(last.Value.Key);
                }
            }
        }

        public void EvictAll()
        {
            lock (_lock)
            {
                _map.Clear();
                _order.Clear();
            }
        }
    }
}
