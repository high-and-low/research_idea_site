module Similarity
  # コサイン類似度の計算
  # v1, v2 は数値の配列 (embedding)
  def self.cosine_similarity(v1, v2)
    return 0.0 if v1.nil? || v2.nil? || v1.empty? || v2.empty?
    
    dot_product = v1.zip(v2).map { |a, b| a * b }.sum
    magnitude1 = Math.sqrt(v1.map { |x| x**2 }.sum)
    magnitude2 = Math.sqrt(v2.map { |x| x**2 }.sum)
    
    return 0.0 if magnitude1 == 0 || magnitude2 == 0
    
    dot_product / (magnitude1 * magnitude2)
  end
end
