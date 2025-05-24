require_relative '../main'

RSpec.describe MiniSchemaCache do
  let(:fetcher) { DummyFetcher.new }
  let(:cache) { MiniSchemaCache.new(fetcher) }

  describe '#columns' do
    it 'fetches from DB on first call' do
      expect(fetcher).to receive(:fetch_column_names_for).with('users').once.and_return(%w[id name email])
      expect(cache.columns('users')).to eq(%w[id name email])
    end

    it 'uses cached value on subsequent calls' do
      expect(fetcher).to receive(:fetch_column_names_for).with('users').once.and_return(%w[id name email])
      cache.columns('users')
      expect(cache.columns('users')).to eq(%w[id name email])
    end
  end

  describe '#clear!' do
    it 'clears the entire cache' do
      expect(fetcher).to receive(:fetch_column_names_for).with('users').twice.and_return(%w[id name email])
      cache.columns('users')
      cache.clear!
      expect(cache.columns('users')).to eq(%w[id name email])
    end
  end

  describe '#clear_table!' do
    it 'clears only the specified table' do
      expect(fetcher).to receive(:fetch_column_names_for).with('users').twice.and_return(%w[id name email])
      expect(fetcher).to receive(:fetch_column_names_for).with('posts').once.and_return(%w[id title content])
      
      cache.columns('users')
      cache.columns('posts')
      cache.clear_table!('users')
      
      # posts should still be cached
      expect(cache.columns('posts')).to eq(%w[id title content])
      # users should be fetched again
      expect(cache.columns('users')).to eq(%w[id name email])
    end
  end
end
