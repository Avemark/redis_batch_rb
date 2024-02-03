Gem::Specification.new do |s|
  s.name        = "redis_batch"
  s.version     = "0.0.1"
  s.summary     = "Redis based work queue."
  s.description = "A minimal gem for safely pushing data onto redis and taking it back out in batches of any size. Designed to work well in a multi host/thread environment."
  s.authors     = ["Christian Avemark"]
  s.files       = ["lib/redis_batch.rb", "lib/redis_batch/client.rb", "lib/redis_batch/queue.rb", "lib/redis_batch/configurable.rb"]
  s.homepage    = "https://github.com/avemark/redis_batch_rb"
  s.license     = "MIT"

  s.add_runtime_dependency "redis", "~> 5.0.8"
  s.required_ruby_version = ">= 3.3.0"
end
