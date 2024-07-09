# frozen_string_literal: true

module Puma
  class FIFOPriorityQueue
    def initialize
      @queues = []
      @front = []
    end

    # @param [Object] element
    # @param [Integer] priority
    def queue(element, priority)
      get_queue(priority) << element
    end

    alias_method :push, :queue

    def unqueue
      until @queues.empty? && @front.empty?
        if !@front.empty?
          return @front.shift
        else
          first_queue = @queues[0]

          if first_queue.empty?
            @queues.shift
          else
            return first_queue.shift
          end
        end
      end

      nil
    end

    alias_method :shift, :unqueue

    def size
      @queues.sum(&:size) + @front.size
    end

    def empty?
      size == 0
    end

    private

    PrioritisedQueue = Struct.new(:prio, :queue)

    # Gets or creates a queue array
    # @param [Integer|Symbol] priority
    # @return [Array]
    def get_queue(priority)
      if priority == :front
        return @front
      end

      found = @queues.bsearch do |pq|
        pq.prio >= priority
      end

      if found.nil? || found.prio != priority
        found = PrioritisedQueue.new(prio: priority, queue: [])
        @queues << found
        sort_queues
      end

      found.queue
    end

    def sort_queues
      @queues.sort_by!(&:prio)
    end
  end
end
