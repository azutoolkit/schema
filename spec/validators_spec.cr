require "./spec_helper"
include Schema::Predicates

describe Schema::Predicates do
  describe "#eq?" do
    it { eq?(1, 1).should be_true }
    it { eq?("one", "one").should be_true }
    it { eq?(1, 2).should be_false }
  end

  describe "#exclude?" do
    it { exclude?(1, [2, 3, 4]).should be_true }
    it { exclude?(1, (3..5)).should be_true }
    it { exclude?(1, [0, 1, 2, 3]).should be_false }
    it { exclude?(1, (0..3)).should be_false }
  end

  describe "#presense?" do
    it { presence?("", nil).should be_false }
    it { presence?(nil, nil).should be_false }
    it { presence?("hello", nil).should be_true }
  end

  describe "#gte?" do
    it { gte?(1, -1).should be_true }
    it { gte?(1, 0).should be_true }
    it { gte?(1, 1).should be_true }
    it { gte?(1, 2).should be_false }
    it { gte?(1.day.from_now, Time.utc).should be_true }
    it { gte?(1.day.ago, Time.utc).should be_false }
    time = Time.utc
    it { gte?(time, time).should be_true }
  end

  describe "#gt?" do
    it { gt?(1, -1).should be_true }
    it { gt?(1, 0).should be_true }
    it { gt?(1, 1).should be_false }
    it { gt?(1, 2).should be_false }
    it { gt?(1.day.from_now, Time.utc).should be_true }
    it { gt?(1.day.ago, Time.utc).should be_false }
  end

  describe "#lte?" do
    it { lte?(-1, 1).should be_true }
    it { lte?(0, 1).should be_true }
    it { lte?(1, 1).should be_true }
    it { lte?(2, 1).should be_false }
    it { lte?(1.day.from_now, Time.utc).should be_false }
    it { lte?(1.day.ago, Time.utc).should be_true }
    it { lte?(1.day.ago, 1.day.ago).should be_true }
  end

  describe "#lt?" do
    it { lt?(-1, 1).should be_true }
    it { lt?(0, 1).should be_true }
    it { lt?(1, 1).should be_false }
    it { lt?(1, 2).should be_true }
    it { lt?(1.day.from_now, Time.utc).should be_false }
    it { lt?(1.day.ago, Time.utc).should be_true }
  end

  describe "#in?" do
    it { in?(1, [1, 2, 3]).should be_true }
    it { in?(1, (-1..2)).should be_true }
    it { in?(1, (2..3)).should be_false }
    it { in?(1, [2, 3]).should be_false }
  end

  describe "#size?" do
    it { size?([1, 2, 3], 3).should be_true }
    it { size?((1..3), 3).should be_true }
    it { size?({1, 2, 3}, 3).should be_true }
    it { size?([1, 2, 3, 4], (1..6)).should be_true }
  end

  describe "#match?" do
    it { match?("test@example.com", /\w+@\w+\.\w{2,3}/).should be_true }
    it { match?("invalid", /\w+@\w+\.\w{2,3}/).should be_false }
  end
end
