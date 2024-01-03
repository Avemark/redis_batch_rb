Gem::Specification.new do |s|
  s.name        = 'redis_batch'
  s.version     = '0.1.0'
  s.licenses    = ['MIT']
  s.summary     = "Redis based work queue."
  s.description = "Redis based work queue with reliable multi element dequeue."
  s.authors     = ["Christian Avemark"]
  s.files       = ["lib/redis_batch.rb", "lib/redis_batch/client.rb", "lib/redis_batch/queue.rb", "lib/redis_batch/configurable.rb"]
  s.homepage    = 'https://github.com/avemark/redis_batch_rb'
  s.metadata    = { "source_code_uri" => "https://github.com/avemark/redis_batch_rb" }

  s.add_runtime_dependency "redis", "~> 5.0.8"
  s.required_ruby_version = ">= 3.3.0"
end
