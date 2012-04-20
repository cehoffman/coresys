class Array
  def sum
    inject(0) do |sum, el|
      sum + (block_given? && yield(el) || el).to_i
    end
  end
end
