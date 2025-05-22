# in-memory-schema-style-cache

implement a mini in-memory schema-style cache in Ruby. This will give you hands-on understanding of:
	•	Memoization across method calls
	•	Caching values for multiple items (e.g., like Rails does for tables)
	•	Preloading and clearing the cache


## **🧠 What is “In-Memory Ruby Object Cache”?**

This refers to **plain old Ruby objects** stored in **instance variables or class variables** that live in memory **within the Ruby process** (e.g., a Puma worker or Sidekiq job).

It is:

- Fast (RAM access)
- Ephemeral (goes away when the process restarts)
- Local (not shared across threads or processes unless explicitly coded to do so)

## **🌀 Lifecycle of the Cache**

1. **App boots up**
2. First time a model/table is accessed → Rails queries DB
3. Result stored in memory under SchemaCache
4. Subsequent accesses use the cached result
5. Cache lives as long as the Rails process lives
6. When the process is restarted (e.g., code reload, deploy), the cache is empty again

## **🤝 Use with Multiple Processes**

***If you use multiple app servers, Rails preloads the schema cache during boot to reduce DB hits across processes.***
