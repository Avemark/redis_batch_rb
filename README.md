## Redis Batch

A redis queue with reliable multi-element dequeue, intended for work aggregation. 

Common background work libraries like Resque, Sidekiq and GoodJob assume no coherence in 
the elements of their work queues, and will act on elements one by one.

Sometimes you want to asynchronously aggregate work units and later deal with them in batches, and this gem intends 
to facilitate that kind of pattern.

This gem does not try to deal with scheduling of dequeueing nor does it assist (much) with error handling.

If an error is raised within the `take` block, the taken values are returned to the queue.

If your process is killed for external reasons, the taken items might get stuck in the processing queue. `myqueue.abort_all` will clear all processing queues.  
If you take out elements concurrently, there is currently no way to distinguish such stuck processing queues from healthy queues. A timestamping feature to alleviate this might be added in the future.
### Usage
```Shell
gem install redis_batch
```
```Ruby
MessageQueue = Class.new(RedisBatch::Queue)
my_queue = MessageQueue.new

my_queue.add "Hello", "world"
my_queue.count => 2

the_same_queue = RedisBatch::Queue.new("MessageQueue")
the_same_queue.count => 2

my_queue.take(10) { |messages| messages.join(", ") } => "Hello, world"
my_queue.count => 0

my_queue.add "uh", "oh"
my_queue.take(10) { |messages| raise(messages.join("-")) } => StandardError: "uh-oh"
my_queue.count => 2
```
