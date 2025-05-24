class MiniSchemaCache
  def initialize(fetcher)
    @fetcher = fetcher
    @cache = {}
    @mutex = Mutex.new
  end

  def columns(table_name)
    @mutex.synchronize do
      @cache[table_name] ||= @fetcher.fetch_column_names_for(table_name)
    end
  end

  def clear!
    @mutex.synchronize do
      @cache.clear
    end
  end

  def clear_table!(table_name)
    @mutex.synchronize do
      @cache.delete(table_name)
    end
  end
end

class DummyFetcher
  def fetch_column_names_for(table_name)
    puts "Fetching columns for #{table_name} from DB..."
    sleep(1) # simulate DB latency
    %w[id name email] # pretend this is fetched from DB
  end
end

# Usage example:
if __FILE__ == $PROGRAM_NAME
  fetcher = DummyFetcher.new
  cache = MiniSchemaCache.new(fetcher)

  puts cache.columns('users') # Fetches from DB and caches it
  puts cache.columns('users') # Uses cached value

  puts 'clearing cache...'
  cache.clear! # Clear the cache
  puts cache.columns('users') # Fetches from DB again after clearing the cache
  puts 'clearing users table...'
  cache.clear_table!('users')
  puts cache.columns('users') # Fetches from DB again after clearing the table
end
