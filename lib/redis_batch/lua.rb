module RedisBatch
  class Lua
    def self.function_load(redis)
      redis.call("FUNCTION", "LOAD", "REPLACE", redis_batch_lua)
    end

    def self.redis_batch_lua
      <<~LUA
        #!lua name=redis_batch

        local function lmove(keys, args)
          local count = tonumber(args[1])
          local source = keys[1]
          local target = keys[2]
          local llen = redis.call("LLEN", source)
          if llen < count then
            count = llen
          end
          local values = {}
          for i=1,count do
            values[i] = redis.call("LMOVE", source, target, 'LEFT', 'RIGHT')
          end 
          return values
        end

        redis.register_function('rb_lmove', lmove)

        local function lrestore(keys, args)
          local source = keys[1]
          local target = keys[2]
          local llen = redis.call("LLEN", source)
          for i=1,llen do
            redis.call("LMOVE", source, target, 'RIGHT', 'LEFT')
          end
          return llen
        end

        redis.register_function('rb_lrestore', lrestore)
      LUA
    end
  end
end
