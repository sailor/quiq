class TestJob
  def perform(data, wait)
    puts "Receiving new data: #{data}"
    task.sleep wait
    puts "Time to wake up after #{wait} seconds"
  end
end
