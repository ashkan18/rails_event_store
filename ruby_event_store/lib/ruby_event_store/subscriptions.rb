# frozen_string_literal: true

require 'concurrent'

module RubyEventStore
  class Subscriptions
    def initialize
      @subscriptions = Concurrent::ThreadLocalVar.new do
        Hash.new { |hsh, key| hsh[key] = [] }
      end
    end

    def add_subscription(subscriber, event_types)
      add(subscriber, event_types)
    end

    def add_global_subscription(subscriber)
      add(subscriber)
    end

    def add_thread_subscription(subscriber, event_types)
      add(subscriber, event_types)
    end

    def add_thread_global_subscription(subscriber)
      add(subscriber)
    end

    def all_for(event_type)
      [event_type, ANY_EVENT_TYPE]
        .map(&:to_s)
        .map{ |type| subscriptions.fetch(type, []) }
        .reduce(&:+)
    end

    private

    def subscriptions
      @subscriptions.value
    end

    def add(subscription, event_types = [ANY_EVENT_TYPE])
      event_types.each { |type| subscriptions[type.to_s] << subscription }
      -> { event_types.each { |type| subscriptions.fetch(type.to_s).delete(subscription) } }
    end
  end
end
