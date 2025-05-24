require_relative '../main'

RSpec.describe MiniSchemaCache do
  let(:fetcher) { DummyFetcher.new }
  let(:cache) { MiniSchemaCache.new(fetcher) }

  describe 'thread safety' do
    it 'ensures only one thread fetches from DB' do
      expect(fetcher).to receive(:fetch_column_names_for).with('users').once.and_return(%w[id name email])
      
      threads = []
      5.times do
        threads << Thread.new do
          cache.columns('users')
        end
      end
      
      threads.each(&:join)
    end

    it 'handles concurrent cache clearing' do
      # Use a barrier to ensure all threads start at the same time
      barrier = Queue.new
      
      # First populate the cache
      expect(fetcher).to receive(:fetch_column_names_for).with('users').once.and_return(%w[id name email])
      cache.columns('users')
      
      # Now expect exactly 4 more fetches from the concurrent operations
      expect(fetcher).to receive(:fetch_column_names_for).with('users').exactly(4).times.and_return(%w[id name email])
      
      # Multiple threads try to clear and fetch simultaneously
      threads = []
      4.times do
        threads << Thread.new do
          barrier.pop # Wait for all threads to be ready
          cache.clear!
          cache.columns('users')
        end
      end

      # Release all threads at once
      4.times { barrier.push(true) }
      threads.each(&:join)
    end

    it 'handles concurrent table-specific clearing' do
      # Use a barrier to ensure all threads start at the same time
      barrier = Queue.new
      
      # First populate both caches
      expect(fetcher).to receive(:fetch_column_names_for).with('users').once.and_return(%w[id name email])
      expect(fetcher).to receive(:fetch_column_names_for).with('posts').once.and_return(%w[id title content])
      cache.columns('users')
      cache.columns('posts')

      # Now expect exactly 4 more fetches for users from the concurrent operations
      expect(fetcher).to receive(:fetch_column_names_for).with('users').exactly(4).times.and_return(%w[id name email])
      
      # Multiple threads try to clear users table and fetch simultaneously
      threads = []
      4.times do
        threads << Thread.new do
          barrier.pop # Wait for all threads to be ready
          cache.clear_table!('users')
          cache.columns('users')
        end
      end

      # Release all threads at once
      4.times { barrier.push(true) }
      threads.each(&:join)
      
      # Verify posts table is still cached
      expect(cache.columns('posts')).to eq(%w[id title content])
    end
  end
end 