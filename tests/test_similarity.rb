require 'minitest/autorun'
require_relative '../lib/similarity'

class TestSimilarity < Minitest::Test
  def test_cosine_similarity_perfect_match
    v1 = [1, 0, 1]
    v2 = [1, 0, 1]
    assert_in_delta 1.0, Similarity.cosine_similarity(v1, v2)
  end

  def test_cosine_similarity_orthogonal
    v1 = [1, 0]
    v2 = [0, 1]
    assert_in_delta 0.0, Similarity.cosine_similarity(v1, v2)
  end

  def test_cosine_similarity_opposite
    v1 = [1, 1]
    v2 = [-1, -1]
    assert_in_delta -1.0, Similarity.cosine_similarity(v1, v2)
  end

  def test_cosine_similarity_nil_input
    assert_equal 0.0, Similarity.cosine_similarity(nil, [1, 2])
    assert_equal 0.0, Similarity.cosine_similarity([1, 2], nil)
  end

  def test_cosine_similarity_empty_input
    assert_equal 0.0, Similarity.cosine_similarity([], [1, 2])
  end

  def test_cosine_similarity_zero_vector
    v1 = [0, 0]
    v2 = [1, 1]
    assert_equal 0.0, Similarity.cosine_similarity(v1, v2)
  end
end
